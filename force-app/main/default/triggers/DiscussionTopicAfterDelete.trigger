trigger DiscussionTopicAfterDelete on DiscussionTopic__c bulk (after delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
		 	
		 	List<String> idsTeam = new List<String>();
			for (DiscussionTopic__c iterTopic : Trigger.old) {
				idsTeam.add(iterTopic.team__c); 
			}
			
			List<DiscussionForum__c> forumList = [select id, TopicCount__c, team__c from DiscussionForum__c where team__c in: idsTeam];
		 	
		 	for (DiscussionTopic__c t : Trigger.old) {
		        DiscussionForum__c forum;
		        Id forumId = t.DiscussionForum__c;
		        
		        Boolean findForum = false;
		        Integer countForum = 0;
		        while (!findForum && countForum < forumList.size()) {
		        	if (forumList[countForum].Id == forumId) {
		        		findForum = true;	
		        		// Decrease Topic Count
						forumList[countForum].TopicCount__c -= 1;
				      	update forumList[countForum];
		        	}
		        	countForum++;
		        }   
		    }
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 		    
}