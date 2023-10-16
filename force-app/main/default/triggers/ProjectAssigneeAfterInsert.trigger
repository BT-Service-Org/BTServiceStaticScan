trigger ProjectAssigneeAfterInsert on ProjectAssignee__c (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
            
            List<String> teamSharingGroupNames = new List<String>();		
			for(ProjectAssignee__c p : Trigger.new) {
				teamSharingGroupNames.add('teamSharing' + p.Team__c);
			}
			
			Map<String, Id> teamMap = new Map<String, Id>();					
			for(Group g: [select id, name from Group where Name in: teamSharingGroupNames]) {
				teamMap.put(g.Name, g.Id);
			}
			
			
			List<ProjectAssignee__Share> assignee = new List<ProjectAssignee__Share>();
			for(ProjectAssignee__c m : Trigger.new) {
				
				ProjectAssignee__Share p = new ProjectAssignee__Share();
				p.ParentId = m.Id;							
				p.UserOrGroupId = teamMap.get('teamSharing' + m.Team__c);
			    p.AccessLevel = 'Read';
			    p.RowCause = 'Manual';
			    assignee.add(p);
			}
			
			insert assignee;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}    
}