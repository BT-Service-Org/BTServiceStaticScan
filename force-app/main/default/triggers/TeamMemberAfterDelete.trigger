trigger TeamMemberAfterDelete on TeamMember__c bulk (before delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;	
	
			List<Group> groupTeamSharing = [select g.Id, g.Name from Group g where g.Name like 'teamSharing%'];
			
			List<String> idsTeam = new List<String>();
			for (TeamMember__c tm : Trigger.old) {
				idsTeam.add(tm.team__c);
			}
			
			List<Team__c> teamList = [select t.PublicProfile__c ,t.NewMemberProfile__c, t.Id, t.Name from Team__c t where t.Id in: idsTeam];
			
			List<TeamProfile__c> lstTp = [Select
											t.Id, 
											t.Name,
											t.PostWikiComments__c, 
											t.PostDiscussionTopicReplies__c, 
											t.PostBookmarkComments__c, 
											t.PostBlogComments__c,					
											t.ManageWikis__c, 
											t.ManageTeams__c, 
											t.ManageProjectTasks__c, 
											t.ManageDiscussionForums__c, 
											t.ManageBookmarks__c, 
											t.ManageBlogs__c, 
											t.CreateWikiPages__c, 
											t.CreateProjectTasks__c, 
											t.CreateDiscussionTopics__c, 
											t.CreateBookmarks__c, 
											t.CreateBlogs__c from TeamProfile__c t];
			
			//List<Group> allQueue = [ select Id, Name From Group where Type = 'Queue'];
			List<String> groupsNames = new List<String>();
			List<String> userIds = new List<String>();
			for (TeamMember__c tm : Trigger.old) {
				groupsNames.add('Blog' + tm.Team__c);	
				groupsNames.add('Wiki' + tm.Team__c);
				groupsNames.add('Discussion' + tm.Team__c);
				groupsNames.add('Bookmark' + tm.Team__c);
				groupsNames.add('Team' + tm.Team__c);
				groupsNames.add('Project' + tm.Team__c);
				
				userIds.add(tm.User__c);
			}
			
			
			List<Group> ManageQueueList = [ select Id, Name From Group where Name in: groupsNames and Type = 'Queue' order by Name];
			List<GroupMember> gmList = [select Id, UserOrGroupId, GroupId from GroupMember where UserOrGroupId in:userIds and GroupId in: ManageQueueList];
			List<GroupMember> gmAllList = [select gm.Id, UserOrGroupId, GroupId from GroupMember gm where gm.UserOrGroupId in: userIds];
			
			List<GroupMember> gm = new List<GroupMember>();
			
			for (TeamMember__c tm : Trigger.old) {
		
				//Get Group
				Group g = new Group();
				
				String groupName = 'teamSharing' + tm.Team__c;
				Boolean findGroup = false;
				Integer countGroup = 0;
				while (!findGroup && countGroup < groupTeamSharing.size()) {
					if (groupTeamSharing[countGroup].Name == groupName) {
						findGroup = true;
						g = groupTeamSharing[countGroup];	
					}
					countGroup++;
				}
				 
				if (g != null) {
					//Get Team
					Team__c t = new Team__c();			
					Boolean findTeam = false;
					Integer countTeam = 0;
					while (!findTeam && countTeam < teamList.size()) {
						if (teamList[countTeam].Id == tm.team__c) {
							findTeam = true;
							t = teamList[countTeam];
						}
						countTeam++;	
					}	
					
					//If team access is private, delete group member.
					TeamProfile__c tp = new TeamProfile__c();				
					Boolean findProfile = false;
					Integer countProfile = 0;
					while (!findProfile && countProfile < lstTp.size()) {
						if (lstTp[countProfile].Id == tm.TeamProfile__c) {
							findProfile = true;	
							tp = lstTp[countProfile];
						}
						countProfile++;
					}
					
					List<Group> ManageQueue = new List<Group>(); 
					Map<String,Group> groupIdsMap = new Map<String,Group>();
					for (Group iterQueue : ManageQueueList) {
						if (iterQueue.Name.indexOf(tm.Team__c) != -1) {
							ManageQueue.add(iterQueue);
							groupIdsMap.put(iterQueue.Id, iterQueue);
						}
					}
					
					for (GroupMember iterGroupMember : gmList) {
						if (iterGroupMember.UserOrGroupId == tm.User__c && groupIdsMap.containsKey(iterGroupMember.GroupId)) {
							gm.add(iterGroupMember);	
						}	
					}
					
					if(t.PublicProfile__c == null && t.NewMemberProfile__c == null){			
						Boolean findGM = false;
						Integer countGM = 0;
						while (!findGM && countGM < gmAllList.size()) {
							if (gmAllList[countGM].GroupId == g.Id && gmAllList[countGM].UserOrGroupId == tm.User__c) {
								findGM = true;	
								gm.add(gmAllList[countGM]);
							}
							countGM++;
						}
					}
				}
			}
			delete gm;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}