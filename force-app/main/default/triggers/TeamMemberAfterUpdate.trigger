trigger TeamMemberAfterUpdate on TeamMember__c bulk (after update) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
			
			List<String> idsTeam = new List<String>();
			List<String> idsProfile = new List<String>();
			List<String> groupsNames = new List<String>();
			List<String> userIds = new List<String>();
			for (TeamMember__c tm : Trigger.new) {
				groupsNames.add('Blog' + tm.Team__c);	
				groupsNames.add('Wiki' + tm.Team__c);
				groupsNames.add('Discussion' + tm.Team__c);
				groupsNames.add('Bookmark' + tm.Team__c);
				groupsNames.add('Team' + tm.Team__c);
				groupsNames.add('Project' + tm.Team__c);
				groupsNames.add('teamSharing' + tm.Team__c);
				idsTeam.add(tm.team__c);
				idsProfile.add(tm.TeamProfile__c);	
				userIds.add(tm.User__c);
			}
			Map<Id, Team__c> teamMap = new Map<Id, Team__c>();
			for (Team__c iterTeam :  [select id, name, PublicProfile__c, NewMemberProfile__c from Team__c where id in: idsTeam]) {
				teamMap.put(iterTeam.Id, iterTeam);	
			}
			
			Map<String, Group> ManageQueueMap = new Map<String, Group>();
			List<Group> ManageQueueList = [ select Id, Name From Group where Name in: groupsNames]; 
			for (Group iterGroup : ManageQueueList) {
				ManageQueueMap.put(iterGroup.Name, iterGroup);	
			}
			
			// Delete all Queue entries of the users
			List<GroupMember> gmList = [select Id, UserOrGroupId, GroupId from GroupMember where UserOrGroupId in:userIds and GroupId in:ManageQueueList];
			delete gmList;
			
			Map<Id, TeamProfile__c> tpMap = new Map<Id, TeamProfile__c>();
			for (TeamProfile__c iterProfile : [Select
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
											t.CreateBlogs__c from TeamProfile__c t where t.Id in:idsProfile]) {
				tpMap.put(iterProfile.Id, iterProfile);
			}
			List<GroupMember> groupMembers = new List<GroupMember>();
			for (TeamMember__c tm : Trigger.new) {
				// Determine Different Queue Additions
				///////////////////////////////////////
					TeamProfile__c tp = new TeamProfile__c();
					Boolean findProfile = false;
					if (tpMap.get(tm.TeamProfile__c) != null) {
						findProfile = true;
						tp = tpMap.get(tm.TeamProfile__c);
					}
					
					if (findProfile) {
						if(tp.ManageBlogs__c){
							String queueName = 'Blog' + tm.Team__c;
							if (ManageQueueMap.get(queueName) != null) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = tm.User__c;
								gm.GroupId = ManageQueueMap.get(queueName).Id;
								groupMembers.add(gm);	
							}
						}	
						
						if(tp.ManageWikis__c){
							String queueName = 'Wiki' + tm.Team__c;
							if (ManageQueueMap.get(queueName) != null) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = tm.User__c;
								gm.GroupId = ManageQueueMap.get(queueName).Id;
								groupMembers.add(gm);	
							}
						}
						
						if(tp.ManageDiscussionForums__c){
							String queueName = 'Discussion' + tm.Team__c;
							if (ManageQueueMap.get(queueName) != null) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = tm.User__c;
								gm.GroupId = ManageQueueMap.get(queueName).Id;
								groupMembers.add(gm);	
							}
						}
						
						if(tp.ManageBookmarks__c){
							String queueName = 'Bookmark' + tm.Team__c;
							if (ManageQueueMap.get(queueName) != null) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = tm.User__c;
								gm.GroupId = ManageQueueMap.get(queueName).Id;
								groupMembers.add(gm);	
							}
						}
						
						if(tp.ManageTeams__c){
							String queueName = 'Team' + tm.Team__c;
							if (ManageQueueMap.get(queueName) != null) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = tm.User__c;
								gm.GroupId = ManageQueueMap.get(queueName).Id;
								groupMembers.add(gm);	
							}
						}
						
						if(tp.ManageProjectTasks__c){
							String queueName = 'Project' + tm.Team__c;
							if (ManageQueueMap.get(queueName) != null) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = tm.User__c;
								gm.GroupId = ManageQueueMap.get(queueName).Id;
								groupMembers.add(gm);	
							}
						}
					}					
			}
			insert groupMembers;
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}