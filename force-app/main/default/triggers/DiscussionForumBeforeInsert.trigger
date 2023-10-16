trigger DiscussionForumBeforeInsert on DiscussionForum__c bulk (before insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
			
		    List<Group> groupTeam = [select id, Name from Group where Name like 'Discussion%' and type = 'Queue'];
			
			List<String> idsTeam = new List<String>();
			for (DiscussionForum__c iterForum : Trigger.new) {
				idsTeam.add(iterForum.team__c);	
			}	
			
			List<TeamMember__c> membersLst = [select id, TeamProfile__c, Team__c,
												TeamProfile__r.ManageDiscussionForums__c 
												from TeamMember__c where 
												User__c =:UserInfo.getUserId() and 
												Team__c in: idsTeam];
	
			for(DiscussionForum__c newForum : trigger.new){
				String idTeam = newForum.Team__c;
				String groupName = 'Discussion' + idTeam;
				Boolean findGroup = false;
			    Integer countGroup = 0;
			    while (!findGroup && countGroup < groupTeam.size()) {
			    	if (groupTeam[countGroup].Name == groupName) {
            			findGroup = true;
            			newForum.OwnerId = groupTeam[countGroup].Id;
            		}
            		countGroup++;	
            	}
				
				List<TeamMember__c> members = new List<TeamMember__c>();
				Boolean findMember = false;
				Boolean canCreate = false;
				Integer countMember = 0;
				while (!findMember && countMember < membersLst.size()) {
					if (membersLst[countMember].team__c == idTeam) {
						findMember = true;
						if ((membersLst[countMember].TeamProfile__c != null) && (membersLst[countMember].TeamProfile__r.ManageDiscussionForums__c)) {
							canCreate = true;
						}
					}
					countMember++;	
				}
				
				if (!canCreate) {
					newForum.addError('Cannot Insert a new forum.');	
				}
			}
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}