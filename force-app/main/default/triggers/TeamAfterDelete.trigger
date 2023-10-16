trigger TeamAfterDelete on Team__c bulk (after delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
			
			List<Group> teamq = [select g.Id, g.Name from Group g where g.Name like 'Team%' or g.Name like 'teamSharing%'];
				
			for(Team__c delTeam : trigger.old){
				
				String teamQueue = 'Team' + delTeam.Id;
				String teamSharing = 'teamSharing' + delTeam.Id;
				
				List<Group> groupDel = new List<Group>();
				for (Group iterGroup: teamq) {
					if (iterGroup.Name == teamQueue || iterGroup.Name == teamSharing) {
						groupDel.add(iterGroup);	
					}	
				}
				delete groupDel;
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}			
}