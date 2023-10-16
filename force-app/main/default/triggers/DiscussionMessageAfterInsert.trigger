trigger DiscussionMessageAfterInsert on DiscussionMessage__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
		    
		    List<String> idsTeam = new List<String>();
			for (DiscussionMessage__c iterMsg : Trigger.new) {
				idsTeam.add(iterMsg.team__c); 
			}
		    
		    List<Group> groupTeam = [select id, Name from Group where Name like 'teamSharing%'];
		    List<DiscussionTopic__c> topicList = [select id, MessageCount__c, DiscussionForum__c, team__c from DiscussionTopic__c where team__c in: idsTeam];
		    List<DiscussionForum__c> forumList = [select Id, MessageCount__c, team__c from DiscussionForum__c where team__c in: idsTeam];
		    
		    for (DiscussionMessage__c m : Trigger.new) {
		       // Update Message count at topic
		       DiscussionTopic__c topic; 
		       Id topicId = m.DiscussionTopic__c;       
		       
		       	Boolean findTopic = false;
		       	Integer countTopic = 0;
		       	while (!findTopic && countTopic < topicList.size()) {
		       		if (topicList[countTopic].Id == topicId) {
		       			topicList[countTopic].MessageCount__c += 1;
		       			topicList[countTopic].LastPostedMessage__c = m.Id;
		       			update topicList[countTopic];
		       			findTopic = true;
		       		}
		       		else {
		    			countTopic++;
		       		}
		    	}
		       
		       // Update Message count at forum  
		       	String dfId = topicList[countTopic].DiscussionForum__c;
		       
		  		Boolean findForum = false;
		  		Integer countForum = 0;
		  		while (!findForum && countForum < forumList.size()) {
		  			if (forumList[countForum].Id == dfId) {
		  				findForum = true;
		  				forumList[countForum].MessageCount__c += 1;
		  				// Update LastPostedMessage Forum
		     			forumList[countForum].LastPostedMessage__c = m.Id; 
		     			update forumList[countForum];
		  			}
		  			countForum++;
		  		}     
		       
		       // Instantiate the sharing objects
			   DiscussionMessage__Share fShare = new DiscussionMessage__Share();
			   fShare.ParentId = m.Id;    
			   // Set the ID of user or group being granted access
			   	String groupName = 'teamSharing' + m.team__c;
			   	Boolean findGroup = false;
			   	Integer countGroup = 0;
			   	while (!findGroup && countGroup < groupTeam.size()) {
					if (groupTeam[countGroup].Name == groupName) {
						findGroup = true;	
						fShare.UserOrGroupId = groupTeam[countGroup].Id;
					}
					countGroup++;
			   	}
			   // Set the access level
			   fShare.AccessLevel = 'read';
			   fShare.RowCause = 'Manual';          
			   // Add objects to list for insert
			   insert fShare;    	   
		        
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}