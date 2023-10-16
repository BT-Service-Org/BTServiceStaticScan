trigger DiscussionTopicAfterInsert on DiscussionTopic__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
		    
		    // Collect the Id and group names for processing
		    List<String> idsTeam = new List<String>();
			List<String> teamSharingGroupNames = new List<String>();		
			for(DiscussionTopic__c t : Trigger.new) {
				idsTeam.add(t.team__c);
				teamSharingGroupNames.add('teamSharing' + t.Team__c);
			}
			
			// Get the parent forums for hte topic so we can update teh counts			
			Map<Id, DiscussionForum__c> forumList = new Map<Id, DiscussionForum__c>([select id, TopicCount__c, team__c from DiscussionForum__c where team__c in: idsTeam]);
		    			
			Map<String, Id> teamMap = new Map<String, Id>();					
			for(Group g: [select id, name from Group where Name in: teamSharingGroupNames]) {
				teamMap.put(g.Name, g.Id);
			}
			
			List<DiscussionTopic__Share> topics = new List<DiscussionTopic__Share>();
			for(DiscussionTopic__c t : Trigger.new) {
				
				// Up the counter
				DiscussionForum__c forum = forumList.get(t.DiscussionForum__c);
				if(forum != null) forum.TopicCount__c += 1;
				
				// Create teh Sharing rule
				DiscussionTopic__Share s = new DiscussionTopic__Share();
				s.ParentId = t.Id;
				s.UserOrGroupId = teamMap.get('teamSharing' + t.Team__c);
			    s.AccessLevel = 'Read';
			    s.RowCause = Schema.DiscussionTopic__Share.RowCause.Manual;
			    topics.add(s);
			}
			
			update forumList.values();
			insert topics;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 
}