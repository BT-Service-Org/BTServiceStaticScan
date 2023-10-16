trigger MiniFeedBeforeInsert on MiniFeed__c bulk (before insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
			
			List<String> queueNames = new List<String>();
			for (MiniFeed__c t : Trigger.new) { 
		     	if(t.Team__c != null) queueNames.add('Team' + t.Team__c);
			}
			
			Map<String, Id> queueMap = new Map<String, Id>();
			for(Group g: [select id, Name from Group where name in: queueNames and type = 'Queue']) {
				
				queueMap.put(g.Name, g.Id);
			}
				
			for (MiniFeed__c t : Trigger.new) {
		     	t.FeedDate__c = System.now();
		     	if(t.Team__c != null) t.OwnerId = queueMap.get('Team'+ t.Team__c);
			}
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 		
}