public virtual with sharing class OrgRefresh_org62ContactsBean {
    public String Id {get;set;}
    //contact name
    public String Name {get;set;}
    //is the contact still marked active in org62
    public Boolean pse_Is_Resource_Active {get;set;}
    public Datetime pse_Start_Date {get;set;}
    public String department {get;set;}
    public String Employee_Number {get;set;}
     
    public Double pse_Default_Cost_Rate {get;set;}
     //set of string attributes in the flat structure not set by JSON parser directly.
     //The bean setter methods when invoked is expected to set these values
    public PSERegionInfo pse_Region{get;set;}
    
    public PSEUtilizationDetails pse_Utilization_Details{get;set;}

    public EmployeeUserDetails Employee_User{get;set;}

    //region lookup ie AS - AMER
    public Class PSERegionInfo{
        public String Name {get;set;}
     }

     public Class EmployeeUserDetails{
        public ManagerInfo sf62user_manager {get;set;}
     }

     //utilization detail lookup.  we will take the most recent FY value
    public Class PSEUtilizationDetailInfo{
        public Decimal Billable_Utilization_Total {get;set;}    
     }

     //the utilization details come back as a JSON array
     public Class PSEUtilizationDetails{
        public list<PSEUtilizationDetailInfo> records{get;set;}
     }

     public Class ManagerInfo{
        public String Email{get;set;}
     }

}