trigger FavoriteWikiAfterInsert on FavoriteWikis__c (after insert) {

	if (!TeamUtil.currentlyExeTrigger) {
		try {
            
            List<String> teamSharingGroupNames = new List<String>();		
			for(FavoriteWikis__c p : Trigger.new) {
				teamSharingGroupNames.add('teamSharing' + p.Team__c);
			}
			
			Map<String, Id> teamMap = new Map<String, Id>();					
			for(Group g: [select id, name from Group where Name in: teamSharingGroupNames]) {
				teamMap.put(g.Name, g.Id);
			}
			
			
			List<FavoriteWikis__Share> fav = new List<FavoriteWikis__Share>();
			for(FavoriteWikis__c m : Trigger.new) {
				
				FavoriteWikis__Share p = new FavoriteWikis__Share();
				p.ParentId = m.Id;							
				p.UserOrGroupId = teamMap.get('teamSharing' + m.Team__c);
			    p.AccessLevel = 'Read';
			    p.RowCause = 'Manual';
			    fav.add(p);
			}
			
			insert fav;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}  
}