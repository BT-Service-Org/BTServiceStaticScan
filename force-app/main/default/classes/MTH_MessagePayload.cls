public with sharing class MTH_MessagePayload{
    public String notify{get;set;}
    public String type{get;set;}
    public String notificationMessage{get;set;}
    public String header{get;set;}
    public String messageBody{get;set;}
    public String footer{get;set;}
    public PayloadDetails[] details{get;set;}

    public with sharing class PayloadDetails{
        public String id{get;set;}
        public String column{get;set;}
        public String message{get;set;}
        public String code{get;set;}
    }
}