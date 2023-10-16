trigger MiniFeedStatusChange on PeopleProfile__c bulk (after update) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
		 	
		 	List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        PeopleProfile__c n = Trigger.new[i];
		        PeopleProfile__c o = Trigger.old[i];
				// status change?
				if(n.Status__c != o.Status__c){
			        minifeed.add( new MiniFeed__c( Type__c='PeopleChangeStatus',
			                                           User__c=n.User__c,
			                                           Message__c=' ' + n.Status__c ));
				}
		    }
		    insert minifeed;
		    
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}