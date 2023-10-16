// DISABLED THIS TRIGGER B/C OF BEHAVIRO CHANGE IN 154.  
// GETTING INFO FROM HQ
trigger MainFeedUserUpdate on User (before update) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
    
		    List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        User o = Trigger.old[i];
		        User n = Trigger.new[i];
		        // We need to:
		        if(n.Title != o.Title) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their title' ));
		        }
		
		        if(n.Street != o.Street) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their street' ));
		        }
		
		        if(n.State != o.State) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their state' ));
		        }
		
		        if(n.Phone != o.Phone) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their phone' ));
		        }
		
		        if(n.MobilePhone != o.MobilePhone) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their mobile phone' ));
		        }
		
		        if(n.ManagerId != o.ManagerId) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their manager' ));
		        }
		
		        if(n.Email != o.Email) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their email' ));
		        }
		
		        if(n.Division != o.Division) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their division' ));
		        }
		
		        if(n.Department != o.Department) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their department' ));
		        }
		
		        if(n.City != o.City) {
		            minifeed.add( new MiniFeed__c( Type__c='profile',
		                                           User__c=n.Id,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their city' ));
		        }
		
		    }
		    insert minifeed;
		    
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 		    
}