trigger ProjectTaskAfterInsert on ProjectTask__c (after insert) {
	
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
			
			List<String> teamSharingGroupNames = new List<String>();		
			for(ProjectTask__c p : Trigger.new) {
				teamSharingGroupNames.add('teamSharing' + p.Team__c);
			}
			
			Map<String, Id> teamMap = new Map<String, Id>();					
			for(Group g: [select id, name from Group where Name in: teamSharingGroupNames]) {
				teamMap.put(g.Name, g.Id);
			}
			
			
			List<ProjectTask__Share> tasks = new List<ProjectTask__Share>();
			for(ProjectTask__c m : Trigger.new) {
				
				ProjectTask__Share p = new ProjectTask__Share();
				p.ParentId = m.Id;
				p.UserOrGroupId = teamMap.get('teamSharing' + m.Team__c);
			    p.AccessLevel = 'Read';
			    p.RowCause = 'Manual';
			    tasks.add(p);
			}
			
			insert tasks;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}  
}