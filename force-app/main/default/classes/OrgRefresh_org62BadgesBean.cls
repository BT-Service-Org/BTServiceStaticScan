public virtual with sharing class OrgRefresh_org62BadgesBean {
     public String Quiz_Result {get;set;}
     public String State {get;set;}
     public Datetime Date_Badge_Acquired {get;set;}
     public Boolean Required_Training {get;set;}
     public String Certification_Status {get;set;}
     public Id Id {get; set;}
     public Datetime CreatedDate {get;set;}
     
     
     //set of string attributes in the flat structure not set by JSON parser directly.
     //The bean setter methods when invoked is expected to set these values
     public BadgeInfo Badge {get;set;}
     public UserInfo User {get;set;}
    
     public Class BadgeInfo{
        public String Name {get;set;}
        public Boolean Hide_On_Profile {get;set;} //to check for retired badges
        public String Type {get;set;} // GR 9/21/18 to check for retired badges
        public String Learning_Goals {get;set;}
        public Id Id {get;set;}
     }

     public Class UserInfo{
       public String Email {get;set;}   
     }
}