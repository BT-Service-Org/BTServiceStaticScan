trigger DiscussionForumAfterInsert on DiscussionForum__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			if(trigger.isInsert){
				
		       	List<Group> groupTeam = [select id, Name from Group where Name like 'teamSharing%'];
		       	List<DiscussionForum__Share> newDiscussionForumShare = new List<DiscussionForum__Share>();	
		       		
		        for(DiscussionForum__c newForum : trigger.new){
		            DiscussionForum__Share fShare = new DiscussionForum__Share();
		            fShare.ParentId = newForum.Id;
		            String groupName = 'teamSharing' + newForum.team__c;
		            Boolean findGroup = false;
			        Integer countGroup = 0;
			        while (!findGroup && countGroup < groupTeam.size()) {
			        	if (groupTeam[countGroup].Name == groupName) {
			        		findGroup = true;
			        		fShare.UserOrGroupId = groupTeam[countGroup].Id;
			        	}
			        	countGroup++;
			        }
			        
		            fShare.AccessLevel = 'Read';
		            fShare.RowCause = 'Manual';
		            newDiscussionForumShare.add(fShare);
		        }
		        insert newDiscussionForumShare;
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}