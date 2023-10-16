public class LPDeactivateUser {
	
	//static List<Id> users = new List<Id>();
	
	List<Id> judges = new List<Id>();

    public void attrit(List<PA_Onboarding__c> scope) {
    	List<Id> users = new List<Id>();
      	List<Id> onbIds = new List<Id>();

   		for (PA_Onboarding__c onb : scope) {
   			onbIds.add(onb.Id);
   		}
   		
   		for (PA_Onboarding__c onb : [select Id, Candidate__c, Status__c from PA_Onboarding__c where Id in: onbIds]) {
   			
        	if (onb.status__c == 'External Attrition') {
    			//add to list of users to deactivate
    			users.add(onb.Candidate__c);
    			judges.add(onb.Candidate__c);
    		}
    		
    		if (onb.status__c == 'Internal Attrition') {
    			
    			judges.add(onb.Candidate__c);
    		}
   		}
   		if (judges.size() > 0) {
   			removeJudge();
   			//removePermSet(users);
   		}
   		if (users.size() > 0) {
   			deactivate(users);
   		}	
    }

   
	//freeze the user
	@future
	private static void deactivate(List<Id> users) {
		List<User> ul = new List<User>(); 
		for (User u : [SELECT Id, IsActive FROM User WHERE Id in: users]) {
			if (u.isActive == false) {
            	u.isActive = true;
            	ul.add(u);
			}
        }
        update ul;
	}
	
	@future
	private static void removePermSet(List<Id> users) {
		
		for (PermissionSet permSet : [SELECT Id,Name FROM PermissionSet WHERE Name like 'PA Onboarding%' ]) {
			system.debug('permset ' + permset.Name);
			delete [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN : users AND PermissionSetId = : permSet.Id];
		}
	}
	
	//remove the user from judging pool
	private void removeJudge() {
		List<Judge__c> jrecs = new List<Judge__c>();
		for (Judge__c j : [select Id, name,Is_Active__c from Judge__c where User__c in: judges]) {
			if (j.Is_Active__c) {
				j.Is_Active__c = false;
			}
			jrecs.add(j);
		}
		update jrecs;
	}
}