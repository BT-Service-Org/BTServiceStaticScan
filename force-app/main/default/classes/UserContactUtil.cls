public class UserContactUtil {

    public static boolean doNotExecuteTrigger = false;
    
    @future
    public static void createContactAsync(Set<Id> userId, Id acctId){
        
        createContact(userId, acctId);
        Util.inFutureContext = true;
    }
    
    @future
    public static void updateContactAsync(Set<Id> uIds){
        
        updateContact(uIds);
        Util.inFutureContext = true;
    }
    
    //insert contact
    public static Set<Id> createContact(Set<Id> userId, Id acctId) {
      List<Contact> lContact = new List<Contact>();
      for (User u: [select Id, firstName, lastName, Email, Title, Role__c, jobgrade__c,location__c, 
          hire_date__c, business_unit__c, organization__c,companyName, EmployeeNumber, department from User where Id in: userId ]) {
        
            Contact c = new Contact();
            c.FirstName = u.firstName;
            c.LastName = u.LastName;
            c.Email = u.Email;
            c.Title__c = u.title;
            c.Role__c = u.role__c;
            c.Organization__c = u.organization__c;
            c.AccountId = acctId;
            c.OwnerId = UserInfo.getUserId();
            c.UserId__c = u.Id; 
            c.User_Record__c = u.Id;
            
            c.Location__c = u.location__c;
            c.Job_Grade__c = u.jobgrade__c;
            
            c.Hire_Date__c = u.hire_date__c;
            
            c.Business_Unit__c = u.Business_Unit__c;
            c.Department = u.Department;
            c.Employee_ID__c = u.EmployeeNumber;
            
            lcontact.add(c);
        }
        
        //insert lcontact;
        // Iterate through each returned result
        Database.SaveResult[] srList = Database.insert(lcontact, false);
        Set<Id> idSet = new Set<Id>();
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted contact: ID: ' + sr.getId());
                idSet.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Contact fields that affected this error: ' + err.getFields());
                }
            }
        }
        return idSet;
      
    }
    
    //update contact
    public static void updateContact(Set<Id> uIds){
      
        Map<Id, User> users = new Map<Id, User>([select Id, firstName, lastName, Email, Title, Role__c, jobgrade__c,location__c, 
          hire_date__c, business_unit__c, organization__c,companyName, EmployeeNumber, department from User where Id in: uIds]);
        
        List<Contact> lContact = new List<Contact>();
        for (Contact c : [select id,firstname,lastname,email,title__c,role__c,organization__c,location__c,Job_Grade__c,
          Hire_date__c,Business_Unit__c,userid__c,User_Record__c,Department,Employee_ID__c from Contact where User_Record__c in :uIds]) {
           
            User u = users.get(c.User_Record__c);
            c.FirstName = u.FirstName;
            c.LastName = u.LastName;
            c.Email = u.Email;
            c.Title__c = u.Title;
            c.Role__c = u.Role__c;
            c.Organization__c = u.Organization__c;
            c.Location__c = u.Location__c;
            c.Job_Grade__c = u.JobGrade__c;
            c.Hire_Date__c = u.Hire_Date__c;
            c.Business_Unit__c = u.Business_Unit__c;  
            c.Department = u.Department;
            c.Employee_ID__c = u.EmployeeNumber;
            c.UserId__c = u.Id; 
            c.User_Record__c = u.Id;
            
            lContact.add(c);          
        }
        
        update lContact;
        
    }
    
}