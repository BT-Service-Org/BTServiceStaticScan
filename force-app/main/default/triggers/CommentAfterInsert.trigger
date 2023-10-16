trigger CommentAfterInsert on Comment__c (after insert) {
 	if (!TeamUtil.currentlyExeTrigger) {
 		try {

            List<String> teamSharingGroupNames = new List<String>();		
			for(Comment__c p : Trigger.new) {
				teamSharingGroupNames.add('teamSharing' + p.Team__c);
			}
			
			Map<String, Id> teamMap = new Map<String, Id>();					
			for(Group g: [select id, name from Group where Name in: teamSharingGroupNames]) {
				teamMap.put(g.Name, g.Id);
			}
			
			
			List<Comment__Share> comments = new List<Comment__Share>();
			for(Comment__c m : Trigger.new) {
				
				Comment__Share p = new Comment__Share();
				p.ParentId = m.Id;							
				p.UserOrGroupId = teamMap.get('teamSharing' + m.Team__c);
			    p.AccessLevel = 'Read';
			    p.RowCause = Schema.Comment__Share.RowCause.Manual;
			    comments.add(p);
			}
			
			insert comments;
		 	
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}  
}