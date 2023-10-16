trigger TeamMemberAfterInsert on TeamMember__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
			
			List<String> idsTeam = new List<String>();
			List<String> idsProfile = new List<String>();
			List<String> groupsNames = new List<String>();
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
			}
			
			List<Team__c> teamList = [select id, name, PublicProfile__c, NewMemberProfile__c from Team__c where id in: idsTeam];
			List<Group> ManageQueueList = [ select Id, Name From Group where Name in: groupsNames];
			
			List<TeamProfile__c> tpList = [Select
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
											t.CreateBlogs__c from TeamProfile__c t where t.Id in:idsProfile];
			
			for(TeamMember__c tm : Trigger.new) {
				//Get Team Sharing Group
				String groupName = 'teamSharing' + tm.Team__c;
				Group g;
				Boolean findTSG = false;
				Integer countTSG = 0;
				while (!findTSG && countTSG < ManageQueueList.size()) {
					if (ManageQueueList[countTSG].Name == groupName) {
						findTSG = true;
						g = ManageQueueList[countTSG];
					}
					countTSG++;	
				}
				
				//Get Team
				Team__c t;
				Boolean findTeam = false;
				Integer countTeam = 0;
				while (!findTeam && countTeam < teamList.size()) {
					if (teamList[countTeam].Id == tm.team__c) {
						findTeam = true;
						t = teamList[countTeam];	
					}
					countTeam++;	
				}
				
				// ### Determine Team access level ###
				if(t.PublicProfile__c == null){
					//If team is private
					GroupMember gm = new GroupMember();
					gm.GroupId = g.Id;
					gm.UserOrGroupId = tm.User__c;
					insert gm;			
				}
				
				// Determine Different Queue Additions
				///////////////////////////////////////
				List<GroupMember> groupMembers = new List<GroupMember>();
				TeamProfile__c tp = new TeamProfile__c();
				Boolean findProfile = false;
				Integer countProfile = 0;
				while (!findProfile && countProfile < tpList.size()) {
					if (tpList[countProfile].id == tm.TeamProfile__c) {
						findProfile = true;	
						tp = tpList[countProfile];
					}
					countProfile++;	
				}
				
				if (findProfile) {
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
					
					/**
					* Insert intro the Sharing Table 
					*/
					TeamMember__Share tms = new TeamMember__Share();
					tms.ParentId = tm.Id;
					tms.UserOrGroupId = g.Id;
					tms.AccessLevel = 'Read';
					tms.RowCause = 'Manual';
					insert tms; 
				
					/*
					TeamMember__Share tms2 = new TeamMember__Share();
					tms2.ParentId = tm.Id;
					tms2.UserOrGroupId = tm.User__c;
					tms2.AccessLevel = 'All';
					tms2.RowCause = Schema.TeamMember__Share.RowCause.Manual;
					insert tms2; 
					*/
				
				}
			}	
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 								
}