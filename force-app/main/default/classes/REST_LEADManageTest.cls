@isTest
public with sharing class REST_LEADManageTest {
  
    @TestSetup
    public static void dataSetup(){
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'Test';
        leadObj.phone = '98290000';
        leadObj.email = 'test@test.com';
        leadObj.Company = 'abc';                       
        leadObj.Status = 'Open';      

        insert leadObj;

    }

    @isTest()
    public static void testPost(){
        String JSONdata='{"lead": [{"name": "A","phone": "9829","email": "test@test.com", "company": "Aethna Home Products","status": "Working - Contacted","Product_Intrest": [{ "counter": 1, "productName": "xuv 500", "source_tracker": [{ "source": "social media","sub_source": "facebook"}]}]},	{ "name": "B","phone":"9829213","email": "test@test.com",  "company": "Aethna Home Products", "status": "Working - Contacted","Product_Intrest": [{"counter": 1,"productName": "xuv 500","source_tracker": [{"source": "social media","sub_source": "facebook"}]}]}]}';      
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/myLeadResource/LEADManage/';
        req.httpMethod = 'POST';
        req.requestBody=Blob.valueOf(JSONdata);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            REST_LEADManage.doPost();
        Test.stopTest();    
    }
}