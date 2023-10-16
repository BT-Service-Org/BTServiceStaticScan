public class MethodRelatedListsTriggerHandler {
    public static void isDeletableRecord(List<sObject> records, String methodLookUpName) {
        Set<Id> parentMethodIds = new Set<Id>();
        for (sObject mop : records) {
            String methodId = (String) mop.get(methodLookUpName);
            if (methodId != null) {
                parentMethodIds.add(methodId);
            }
    	}
        if(parentMethodIds.size() > 0) {
        	List<Method__c> methods = [Select Id, Status__c from Method__c where ID IN:parentMethodIds];
        	for (sObject mop : records) {
            	String methodId = (String) mop.get(methodLookUpName);
            	if (methodId != null) {
                	for ( Method__c mtd: methods ) {
                		if(methodId == mtd.Id && mtd.Status__c == 'Published')
                    	mop.adderror('Sorry, you cannot edit or delete this record as it\'s parent method is already published.');
            		}
            	}  
        	}
        }
    }
}