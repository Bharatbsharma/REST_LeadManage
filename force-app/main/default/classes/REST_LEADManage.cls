@RestResource(urlMapping ='/myLeadResource/LEADManage/*')


/**
 * Rest_LeadManage Class
 * Post Method Url ='/services/apexrest/myLeadResource/LEADManage'
 */
global with sharing class REST_LEADManage {
    /*
     * Post Methdod 
     */
    @HttpPost
    global static void doPost(){
        Map<String,Lead> leadMap = new Map<String,Lead>();
        Map<String,Map<String,Product_Interest__c>> leadProductToInsertMap = new Map<String,Map<String,Product_Interest__c>>();
        Map<String,Map<String,List<Source_Tracker__c>>> sourceToInsertMap = new Map<String,Map<String,List<Source_Tracker__c>>>();
        List<Source_Tracker__c> sourceTrackertoInsert = new List<Source_Tracker__c>();
        List<String> productNameList=new List<String>();
        RestResponse res = RestContext.response;

        String requestBody = RestContext.request.requestBody.toString();    
        LeadWrapper leadwrapperResponse = new LeadWrapper();
        leadwrapperResponse = (LeadWrapper)JSON.deserialize(requestBody, LeadWrapper.class);
          
        for(LeadWrapper.Lead l : leadwrapperResponse.Lead) {
    
            Lead leadObj = new Lead();
            leadObj.LastName = l.name;
            leadObj.phone = l.phone;
            leadObj.email = l.email;
            leadObj.Company = l.company;                       //required field
            leadObj.Status = l.status;                         //required field   
        
            leadMap.put(leadObj.phone, leadObj);
            
            for(LeadWrapper.Product_Intrest p : l.Product_Intrest) {
				
				Map<String,Product_Interest__c> productChildMap = new Map<String,Product_Interest__c>();
                Product_Interest__c	productObj = new Product_Interest__c();
                productObj.name = p.productName;
                productObj.Counter__c = p.counter;
                productChildMap.put(p.productName,productObj);
                leadProductToInsertMap.put(l.phone,productChildMap);
                productNameList.add(l.name);
                
                for(leadwrapper.Source_tracker s : p.Source_tracker) {
					Map<String,List<Source_Tracker__c>> SourceChildMap = new Map<String,List<Source_Tracker__c>>();
                    Source_Tracker__c trackerObj = new Source_Tracker__c();
                    trackerObj.Source_tracker__c = s.source;
                    trackerObj.Sub_Source__c = s.sub_source;
                    sourceTrackertoInsert.add(trackerObj);
                    SourceChildMap.put( leadObj.phone, sourceTrackertoInsert );
					sourceToInsertMap.put( l.phone, SourceChildMap );
                }
            }                
        }  
        
        System.debug(leadMap.keySet());
        List<Lead> LeadToUpsertOldList = [SELECT Id, Name, Phone,Email, (SELECT Id,Name FROM Product_Interests__r) FROM Lead WHERE phone IN: leadMap.keySet()];
        List<Lead> upsertLeadList = new List<Lead>();
        if(LeadToUpsertOldList.size() > 0){
            for(Integer i = 0; i < LeadToUpsertOldList.size(); i++) {
                Lead leadObj = leadMap.get(LeadToUpsertOldList[i].phone);
                LeadToUpsertOldList[i].LastName = leadObj.LastName;
                LeadToUpsertOldList[i].email = leadObj.email;
                upsertLeadList.add(LeadToUpsertOldList[i]);
            }
            upsert LeadToUpsertOldList;
        } else {
            upsert leadMap.values();
        }

       List<Product_Interest__c> productToInsertList = new List<Product_Interest__c>();
       List<Product_Interest__c> productToUpdateList = new List<Product_Interest__c>();
       Map<String,Product_Interest__c> productToUpdateMap=new Map<String,Product_Interest__c>();
       Map<String,Product_Interest__c> productToInsertMap = new Map<String,Product_Interest__c>();
       Map<String,Product_Interest__c> productMap = new Map<String,Product_Interest__c>();
      
       List<Lead> LeadToUpsertList = [SELECT Id, Name, Phone,Email, (SELECT Id,Name,Counter__c FROM Product_Interests__r) FROM Lead WHERE phone IN: leadMap.keySet()]; 
      System.debug('LeadToUpsertList'+LeadToUpsertList);
       if(LeadToUpsertList.size() > 0 || upsertLeadList.size()==0){
            for(Integer i = 0; i < LeadToUpsertList.size(); i++) {
                Lead leadObj = leadMap.get(LeadToUpsertList[i].phone);
                LeadToUpsertList[i].LastName = leadObj.LastName;
                LeadToUpsertList[i].email = leadObj.email;
                upsertLeadList.add(LeadToUpsertList[i]);
            }
       }    
       
       
       for(Integer j = 0 ; j < LeadToUpsertList.size() ; j++) {
           System.debug('**LeadToUpsertList[j].Product_Interests__r'+LeadToUpsertList[j].Product_Interests__r);
            for(Product_Interest__c product:LeadToUpsertList[j].Product_Interests__r){
                System.debug('product '+product);
                productMap.put(product.Name, product);
            }
            System.debug('**productMap**'+productMap);
            for(String productName : leadProductToInsertMap.get(LeadToUpsertList[j].phone).keySet()){
                System.debug('productName'+productName);
                if(!productMap.containsKey(productName) && !productToInsertMap.containsKey(LeadToUpsertList[j].phone + productName)){
                    Product_Interest__c proObject = leadProductToInsertMap.get(LeadToUpsertList[j].phone).get(productName);
                    proObject.LeadToProduct__c = LeadToUpsertList[j].id;
                    productToInsertMap.put(LeadToUpsertList[j].phone + proObject.Name,proObject);
                    productToInsertList.add(proObject);
                } else {
                    Product_Interest__c pdtObject = LeadToUpsertList[j].Product_Interests__r;
                    System.debug('***pdtObject'+pdtObject.Name);
                    pdtObject.Counter__c= pdtObject.Counter__c + 1;
                    productToUpdateMap.put(pdtObject.Id,pdtObject);
                    //productToUpdateList.add(pdtObject);
                }
            }
        }       
        
        insert productToInsertMap.values();
       
        if(!productToUpdateMap.isEmpty()) {
            System.debug('### productToUpdateMap'+productToUpdateMap);
            update productToUpdateMap.values();
        }
        
        List<Source_Tracker__c> sourceToInsertList = new List<Source_Tracker__c>();
        
        Map<String,Source_Tracker__c> sourceInsertMap=new Map<String,Source_Tracker__c>();
        for(lead leadObjct : upsertLeadList){
            for(Product_Interest__c product : productToInsertList ) {
                 if(product.LeadToProduct__c == leadObjct.id) {
                    for(Source_Tracker__c source : sourceToInsertMap.get(leadObjct.phone).get(leadObjct.phone)) {
                        Source_Tracker__c sourceObj = new Source_Tracker__c();          
                        if(!sourceInsertMap.containsKey(source.Sub_Source__c + leadObjct.phone)){
                            sourceObj.Source_tracker__c = source.Source_tracker__c;
                            sourceObj.Sub_Source__c=source.Sub_Source__c;
                            sourceObj.SourcesOfProduct__c = product.id;
                            sourceInsertMap.put(source.Sub_Source__c + leadObjct.phone,sourceObj);
                        }
                    }
                }
            }
        }
        try{
            upsert sourceInsertMap.values();
        }catch(Exception e){
            System.debug(e.getMessage());
        }    
    }             
}