trigger WikiRecentlyViewedAfterInsert on WikiRecentlyViewed__c (after insert) {
	
	if (!TeamUtil.currentlyExeTrigger) {
		try {
            
            List<String> teamSharingGroupNames = new List<String>();		
			for(WikiRecentlyViewed__c p : Trigger.new) {
				teamSharingGroupNames.add('teamSharing' + p.Team__c);
			}
			
			Map<String, Id> teamMap = new Map<String, Id>();					
			for(Group g: [select id, name from Group where Name in: teamSharingGroupNames]) {
				teamMap.put(g.Name, g.Id);
			}
			
			
			List<WikiRecentlyViewed__Share> view = new List<WikiRecentlyViewed__Share>();
			for(WikiRecentlyViewed__c m : Trigger.new) {
				
				WikiRecentlyViewed__Share p = new WikiRecentlyViewed__Share();
				p.ParentId = m.Id;							
				p.UserOrGroupId = teamMap.get('teamSharing' + m.Team__c);
			    p.AccessLevel = 'Read';
			    p.RowCause = 'Manual';
			    view.add(p);
			}
			
			insert view;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}  
}