trigger MainFeedProfile on PeopleProfile__c bulk (after update) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
			
		    List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    for(Integer i = 0; i < Trigger.old.size(); i++) {
		        PeopleProfile__c o = Trigger.old[i];
		        PeopleProfile__c n = Trigger.new[i];
		        // We need to:
		        if(n.AboutMe__c != o.AboutMe__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their About me' ));
		        }
		        
		        if(n.HomePageUrl__c != o.HomePageUrl__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their HomePage Url' ));
		        }
		
		        if(n.Linkedin__c != o.Linkedin__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their Linkedin' ));
		        }
		
		        if(n.Facebook__c != o.Facebook__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their Facebook' ));
		        }
		
		        if(n.Delicious__c != o.Delicious__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their Delicious' ));
		        }
		
		        if(n.YahooIM__c != o.YahooIM__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their YahooIM' ));
		        }
		
		        if(n.Aol__c != o.Aol__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their Aol' ));
		        }
		
		        if(n.Gtalk__c != o.Gtalk__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their Gtalk' ));
		        }
		
		        if(n.Skype__c != o.Skype__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeopleEditProfile',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their Skype' ));
		        }
		        
		        if(n.Picture__c != o.Picture__c) {
		            minifeed.add( new MiniFeed__c( Type__c='PeoplePhoto',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their Photo' ));
		        }
		    }
		    insert minifeed;
		    
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 		    
}