public with sharing class OrgRefresh_org62ProjectsBean {
     public ID id {get;set;}
     public String Name {get;set;}
     public Decimal pseBillable_Hours_Submitted {get;set;}
     public Decimal pseNon_Billable_Hours_Submitted {get;set;}
     public String pseStatus {get;set;}
     public Date pseStart_Date {get;set;}
     public Date pseEnd_Date {get;set;}
     public String pseRole {get;set;}
     public String proType {get; set;}
     public String pseDescription{get;set;}
     public String Reason_for_Swap {get;set;}

     
    
     //set of string attributes in the flat structure not set by JSON parser directly.
     //The bean setter methods when invoked is expected to set these values
     public PSEProjectInfo pseProject {get;set;}
     public PSEResourceInfo pseResource {get;set;}
        
     public Class PSEResourceInfo{
        public String Email {get;set;}
     }
    
     public Class PSERegionInfo{
        public String Name {get;set;}
     }
    
     public Class PSEProjectInfo{
        public PSEAccountInfo pseAccount {get;set;}
        public PSERecordType RecordType {get; set;}
        public PSERegionInfo pseRegion {get;set;}
        public String Franchise {get;set;}
        public String pseOpportunity {get;set;}
        public PSEManagerInfo pseProject_Manager {get;set;}
         public Id id {get;set;}
        
     }

     public Class PSEAccountInfo{
        public String Name {get;set;}
        public String Id {get;set;}
        
     }

     public Class PSERecordType{
        public String Name {get; set;}
        
     }
     
     public Class PSEManagerInfo{
        public String Name {get;set;}    
     }
 
}
/*public with sharing class OrgRefresh_org62ProjectsBean {
     public String Name {get;set;}
     //public String pseResource {get;set;}
     public Decimal pseBillable_Hours_Submitted {get;set;}
     public Decimal pseNon_Billable_Hours_Submitted {get;set;}
     public String pseStatus {get;set;}
     public Date pseStart_Date {get;set;}
     public Date pseEnd_Date {get;set;}
     
     //set of string attributes in the flat structure not set by JSON parser directly.
     //The bean setter methods when invoked is expected to set these values
     public PSEProjectInfo pseProject {get;set;}
     public PSEResourceInfo pseResource {get;set;}

     public Class PSEResourceInfo{
        public ID id {get;set;}
        public String Email {get;set;}
     }
    
     public Class PSEProjectInfo{
        public PSEAccountInfo pseAccount {get;set;}
     }

     public Class PSEAccountInfo{
        public String Name {get;set;}
     }

     public Class UserInfo{
       public String Email {get;set;}   
     }
}*/