trigger TeamProfileAfterUpdate on TeamProfile__c bulk (after update) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			List<TeamMember__c> membersProfileList = [select id, team__c, user__c, teamProfile__c from TeamMember__c where teamProfile__c in: Trigger.new];
			System.debug(membersProfileList);
			List<String> idsTeam = new List<String>();
			List<String> groupsNames = new List<String>();
			List<String> userIds = new List<String>();
			for (TeamMember__c tm : membersProfileList) {
				groupsNames.add('Blog' + tm.Team__c);	
				groupsNames.add('Wiki' + tm.Team__c);
				groupsNames.add('Discussion' + tm.Team__c);
				groupsNames.add('Bookmark' + tm.Team__c);
				groupsNames.add('Team' + tm.Team__c);
				groupsNames.add('Project' + tm.Team__c);
				groupsNames.add('teamSharing' + tm.Team__c);
				idsTeam.add(tm.team__c);
				userIds.add(tm.User__c);
			}
			
			List<Team__c> teamList = [select id, name, PublicProfile__c, NewMemberProfile__c from Team__c where id in: idsTeam];
			List<Group> ManageQueueList = [ select Id, Name From Group where Name in: groupsNames];
			List<GroupMember> gmList = [select Id, UserOrGroupId, GroupId from GroupMember where UserOrGroupId in:userIds and GroupId in:ManageQueueList];
			
			for (TeamProfile__c teamProfile : Trigger.new) {
				List<TeamMember__c> membersProfile = new List<TeamMember__c>(); 
				for (TeamMember__c iter : membersProfileList) {
					if (iter.teamProfile__c == teamProfile.Id) {
						membersProfile.add(iter);
					}	
				}
				
				for (TeamMember__c tm : membersProfile) {
					// Delete all Queue entries of the user
						List<GroupMember> toRemoveMembers = new List<GroupMember>();
						String queueNameDel;
						Group ManageQueueDel;
						List<GroupMember> toRemoveMember;
						
						//Search the Queue Group
						queueNameDel = 'Blog' + tm.Team__c;
						Boolean findQueue = false;
						Integer countQueue = 0;
						while (!findQueue && countQueue < ManageQueueList.size()) {
							if (ManageQueueList[countQueue].Name == queueNameDel) {
								findQueue = true;
								//Search the Queue Group Member
								for (GroupMember iterMember : gmList) {
									if (iterMember.UserOrGroupId == tm.User__c && iterMember.GroupId == ManageQueueList[countQueue].Id)	{
										toRemoveMembers.add(iterMember);	
									}
								}	
							}
							countQueue++;	
						}
						
						//Search the Queue Group
						queueNameDel = 'Wiki' + tm.Team__c;
						findQueue = false;
						countQueue = 0;
						while (!findQueue && countQueue < ManageQueueList.size()) {
							if (ManageQueueList[countQueue].Name == queueNameDel) {
								findQueue = true;
								//Search the Queue Group Member
								for (GroupMember iterMember : gmList) {
									if (iterMember.UserOrGroupId == tm.User__c && iterMember.GroupId == ManageQueueList[countQueue].Id)	{
										toRemoveMembers.add(iterMember);	
									}
								}	
							}
							countQueue++;	
						}
						
						//Search the Queue Group
						queueNameDel = 'Discussion' + tm.Team__c;
						findQueue = false;
						countQueue = 0;
						while (!findQueue && countQueue < ManageQueueList.size()) {
							if (ManageQueueList[countQueue].Name == queueNameDel) {
								findQueue = true;
								//Search the Queue Group Member
								for (GroupMember iterMember : gmList) {
									if (iterMember.UserOrGroupId == tm.User__c && iterMember.GroupId == ManageQueueList[countQueue].Id)	{
										toRemoveMembers.add(iterMember);	
									}
								}	
							}
							countQueue++;	
						}
						
						//Search the Queue Group
						queueNameDel = 'Bookmark' + tm.Team__c;
						findQueue = false;
						countQueue = 0;
						while (!findQueue && countQueue < ManageQueueList.size()) {
							if (ManageQueueList[countQueue].Name == queueNameDel) {
								findQueue = true;
								//Search the Queue Group Member
								for (GroupMember iterMember : gmList) {
									if (iterMember.UserOrGroupId == tm.User__c && iterMember.GroupId == ManageQueueList[countQueue].Id)	{
										toRemoveMembers.add(iterMember);	
									}
								}	
							}
							countQueue++;	
						}
						
						//Search the Queue Group
						queueNameDel = 'Team' + tm.Team__c;
						findQueue = false;
						countQueue = 0;
						while (!findQueue && countQueue < ManageQueueList.size()) {
							if (ManageQueueList[countQueue].Name == queueNameDel) {
								findQueue = true;
								//Search the Queue Group Member
								for (GroupMember iterMember : gmList) {
									if (iterMember.UserOrGroupId == tm.User__c && iterMember.GroupId == ManageQueueList[countQueue].Id)	{
										toRemoveMembers.add(iterMember);	
									}
								}	
							}
							countQueue++;	
						}
						
						//Search the Queue Group
						queueNameDel = 'Project' + tm.Team__c;
						findQueue = false;
						countQueue = 0;
						while (!findQueue && countQueue < ManageQueueList.size()) {
							if (ManageQueueList[countQueue].Name == queueNameDel) {
								findQueue = true;
								//Search the Queue Group Member
								for (GroupMember iterMember : gmList) {
									if (iterMember.UserOrGroupId == tm.User__c && iterMember.GroupId == ManageQueueList[countQueue].Id)	{
										toRemoveMembers.add(iterMember);	
									}
								}	
							}
							countQueue++;	
						}
				
						//Delete the queue entries
						delete toRemoveMembers;
						
					// Determine Different Queue Additions
					///////////////////////////////////////
						List<GroupMember> groupMembers = new List<GroupMember>();
						TeamProfile__c tp = teamProfile;
						if(tp.ManageBlogs__c){
							String queueName = 'Blog' + tm.Team__c;
							Boolean findGroup = false;
							Integer countGroup = 0;
							while (!findGroup && countGroup < ManageQueueList.size()) {
								if (ManageQueueList[countGroup].Name == queueName) {
									findGroup = true;
									GroupMember gm = new GroupMember();
									gm.UserOrGroupId = tm.User__c;
									gm.GroupId = ManageQueueList[countGroup].Id;
									groupMembers.add(gm);	
								}
								countGroup++;	
							}
						}	
						
						if(tp.ManageWikis__c){
							String queueName = 'Wiki' + tm.Team__c;
							Boolean findGroup = false;
							Integer countGroup = 0;
							while (!findGroup && countGroup < ManageQueueList.size()) {
								if (ManageQueueList[countGroup].Name == queueName) {
									findGroup = true;
									GroupMember gm = new GroupMember();
									gm.UserOrGroupId = tm.User__c;
									gm.GroupId = ManageQueueList[countGroup].Id;
									groupMembers.add(gm);	
								}
								countGroup++;	
							}
						}
						
						if(tp.ManageDiscussionForums__c){
							String queueName = 'Discussion' + tm.Team__c;
							Boolean findGroup = false;
							Integer countGroup = 0;
							while (!findGroup && countGroup < ManageQueueList.size()) {
								if (ManageQueueList[countGroup].Name == queueName) {
									findGroup = true;
									GroupMember gm = new GroupMember();
									gm.UserOrGroupId = tm.User__c;
									gm.GroupId = ManageQueueList[countGroup].Id;
									groupMembers.add(gm);	
								}
								countGroup++;	
							}
						}
						
						if(tp.ManageBookmarks__c){
							String queueName = 'Bookmark' + tm.Team__c;
							Boolean findGroup = false;
							Integer countGroup = 0;
							while (!findGroup && countGroup < ManageQueueList.size()) {
								if (ManageQueueList[countGroup].Name == queueName) {
									findGroup = true;
									GroupMember gm = new GroupMember();
									gm.UserOrGroupId = tm.User__c;
									gm.GroupId = ManageQueueList[countGroup].Id;
									groupMembers.add(gm);	
								}
								countGroup++;	
							}
						}
						
						if(tp.ManageTeams__c){
							String queueName = 'Team' + tm.Team__c;
							Boolean findGroup = false;
							Integer countGroup = 0;
							while (!findGroup && countGroup < ManageQueueList.size()) {
								if (ManageQueueList[countGroup].Name == queueName) {
									findGroup = true;
									GroupMember gm = new GroupMember();
									gm.UserOrGroupId = tm.User__c;
									gm.GroupId = ManageQueueList[countGroup].Id;
									groupMembers.add(gm);	
								}
								countGroup++;	
							}
						}
						
						if(tp.ManageProjectTasks__c){
							String queueName = 'Project' + tm.Team__c;
							Boolean findGroup = false;
							Integer countGroup = 0;
							while (!findGroup && countGroup < ManageQueueList.size()) {
								if (ManageQueueList[countGroup].Name == queueName) {
									findGroup = true;
									GroupMember gm = new GroupMember();
									gm.UserOrGroupId = tm.User__c;
									gm.GroupId = ManageQueueList[countGroup].Id;
									groupMembers.add(gm);	
								}
								countGroup++;	
							}
						}
						
						insert groupMembers;					
				}	
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}