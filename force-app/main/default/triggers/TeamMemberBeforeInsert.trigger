trigger TeamMemberBeforeInsert on TeamMember__c bulk (before insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
			
			List<String> queueNames = new List<String>();
			for(TeamMember__c newMember : trigger.new) {
				queueNames.add('Team' + newMember.team__c);
			}
			
			Map<String, Id> queueMap = new Map<String, Id>();
			for(Group g: [select id, Name from Group where name in: queueNames and type = 'Queue' limit 1]) {
				queueMap.put(g.Name, g.Id);
			}
			
			for(TeamMember__c newMember : trigger.new) {
				Id queueId = queueMap.get('Team' + newMember.team__c);
				if(queueId != null)
					newMember.OwnerId = queueId;
			}	
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}