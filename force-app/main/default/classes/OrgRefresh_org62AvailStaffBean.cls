public class OrgRefresh_org62AvailStaffBean {
    
    public String id {get; set;} // need this for updating org62 record
    public String email {get; set; } 
    
    public boolean pseIs_Resource {get;set;}
    public boolean pseIs_Resource_Active {get;set;}

    public String Employee_Number {get;set;}
    public Date Next_Available_Date {get;set;} // need this for updating org62 & aligns with the Custom Setting

    public BeanAcct account{get;set;}

    public Class BeanAcct {
        public String Name {get;set;}
    }
    
    public OrgRefresh_org62AvailStaffBean() {
        this.account = new BeanAcct();
    }
    
    public String getField(String fieldName){ // this is so I can have dynamic field names
        Map<String, String> fieldMap = new Map<String, String>();
        
        // list all the fields here
        // must turn everything into a string for this to work
        fieldMap.put('Id' , this.id);
        fieldMap.put('Next_Available_Date__c', string.valueof(this.Next_Available_Date));
        fieldMap.put('Next_Available_Date', string.valueof(this.Next_Available_Date));
        fieldMap.put('Account.Name', this.account.name);
        fieldMap.put('Employee_Number', this.employee_number);
        fieldMap.put('pseIs_Resource', string.valueof(this.pseIs_Resource));
        fieldMap.put('pseIs_Resource_Active', string.valueof(this.pseIs_Resource_Active));
        fieldMap.put('Email', this.email);
        
        return (fieldMap.get(fieldName) == null)?'':fieldMap.get(fieldName);
    }
}