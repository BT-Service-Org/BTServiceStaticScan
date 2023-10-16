trigger WikiLinkAfterInsert on WikiLink__c (after insert) {
	
	if (!TeamUtil.currentlyExeTrigger) {
		try {
            
            List<String> teamSharingGroupNames = new List<String>();		
			for(WikiLink__c p : Trigger.new) {
				teamSharingGroupNames.add('teamSharing' + p.Team__c);
			}
			
			Map<String, Id> teamMap = new Map<String, Id>();					
			for(Group g: [select id, name from Group where Name in: teamSharingGroupNames]) {
				teamMap.put(g.Name, g.Id);
			}
			
			
			List<WikiLink__Share> wikilink = new List<WikiLink__Share>();
			for(WikiLink__c m : Trigger.new) {
				
				WikiLink__Share p = new WikiLink__Share();
				p.ParentId = m.Id;							
				p.UserOrGroupId = teamMap.get('teamSharing' + m.Team__c);
			    p.AccessLevel = 'Read';
			    p.RowCause = 'Manual';
			    wikilink.add(p);
			}
			
			insert wikilink;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}  
}