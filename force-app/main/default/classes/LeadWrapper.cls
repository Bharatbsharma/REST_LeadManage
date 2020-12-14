public class LeadWrapper {
    
    public List<Lead> lead;
    
    public class Lead {
        public String name;
        public String phone;
        public String email;
        public String company;
        public String status;
        public List<Product_Intrest> Product_Intrest;
    }
    
    public class Product_Intrest {
        public Integer counter;
        public String productName;
        public List<Source_tracker> source_tracker;
    }
    
    public class Source_tracker {
        public String source;
        public String sub_source;
    }
}