trigger TeamAfterInsert on Team__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			TeamProfile__c defaultProfile = [select Id from TeamProfile__c where Name = 'Team Administrator' limit 1];
			List<Group> go = [Select g.Type, g.Name from Group g where Type = 'Organization'];
			// build for bulk
			Team__c[] t = Trigger.new;
			
			for (Team__c team : Trigger.new) {
				/**
				* Group List To Insert.
				*/
				List<Group> newGroups = new List<Group>();
				
				/**
				* Create Sharing Group for current Team.
				*/		
				Group g = new Group();
				g.Name = 'teamSharing' + team.Id;
				insert g;
				
				if(team.PublicProfile__c != null){
					GroupMember gm = new GroupMember();
					gm.GroupId = g.Id;
					gm.UserOrGroupId = go[0].Id;
					insert gm;
				}	
						
				/* ### Create Queues ###*/
				// Create Team Queue
				Group gdqteam = new Group();
				gdqteam.Type = 'Queue';
				gdqteam.Name = 'Team' + team.Id;
				newGroups.add(gdqteam);
					
				// Create Discussion Queues
				Group discussionQueue = new Group();
				discussionQueue.Type = 'Queue';
				discussionQueue.Name = 'Discussion' + team.Id;
				newGroups.add(discussionQueue);
				
				// Create Wiki Queue
				Group gdqw = new Group();
				gdqw.Type = 'Queue';
				gdqw.Name = 'Wiki' + team.Id;
				newGroups.add(gdqw);
					
				// Create Blog Queue
				Group gdqb = new Group();
				gdqb.Type = 'Queue';
				gdqb.Name = 'Blog' + team.Id;
				newGroups.add(gdqb);
						
				// Create Bookmark Queue
				Group gdqbb = new Group();
				gdqbb.Type = 'Queue';
				gdqbb.Name = 'Bookmark' + team.Id;
				newGroups.add(gdqbb);
							
				// Rename this to project 		
				// Create Task Queue
				Group gdqt = new Group();
				gdqt.Type = 'Queue';		
				gdqt.Name = 'Project' + team.Id;
				newGroups.add(gdqt);
					
				Database.SaveResult[] lsr = Database.insert(newGroups,false);
				
				String teamQueueId = lsr[0].getId();
				String discussionQueueId = lsr[1].getId();
				String wikiQueueId = lsr[2].getId();
				String blogQueueId = lsr[3].getId();
				String bookmarkQueueId = lsr[4].getId();
				String taskQueueId = lsr[5].getId();
				
				// ### Allow SObjects to be managed by recently created queues ###
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>();
				
				// Discussion allows
				
				QueueSobject allowForum = new QueueSobject(SobjectType = 'DiscussionForum__c',QueueId = discussionQueueId);
			   	sobjectsQueueAllowed.add(allowForum);
				
				QueueSobject allowTopics = new QueueSobject(SobjectType = 'DiscussionTopic__c',QueueId = discussionQueueId);
			   	sobjectsQueueAllowed.add(allowTopics);
			   	
			   	QueueSobject allowMessages = new QueueSobject(SobjectType = 'DiscussionMessage__c',QueueId = discussionQueueId);
			   	sobjectsQueueAllowed.add(allowMessages);
						
			   	// Wiki allows
				
				QueueSobject allowWikiPages = new QueueSobject(SobjectType = 'WikiPage__c',QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowWikiPages);
			   	
			   	QueueSobject allowComments = new QueueSobject(SobjectType = 'Comment__c',QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowComments);
			   	
			   	QueueSobject allowRecentlyViewed = new QueueSobject(SobjectType = 'WikiRecentlyViewed__c',QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowRecentlyViewed);
			   	
			   	QueueSobject allowWikiLink = new QueueSobject(SobjectType = 'WikiLink__c',QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowWikiLink);
			   	
			   	QueueSobject allowFavWiki = new QueueSobject(SobjectType = 'FavoriteWikis__c',QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowFavWiki);
			   	
			   	// Blog
			   	
				QueueSobject allowBlogs = new QueueSobject(SobjectType = 'BlogEntry__c',QueueId = blogQueueId);
			   	sobjectsQueueAllowed.add(allowBlogs);
			   	
			   	// Bookmark
			   	
				QueueSobject allowBookmarks = new QueueSobject(SobjectType = 'Bookmark__c',QueueId = bookmarkQueueId);
			   	sobjectsQueueAllowed.add(allowBookmarks);
			   	
			   	// Project Tasks - assignees
			   	
				QueueSobject allowAsignee = new QueueSobject(SobjectType = 'ProjectAssignee__c',QueueId = taskQueueId);
			   	sobjectsQueueAllowed.add(allowAsignee);
				
				QueueSobject allowTasks = new QueueSobject(SobjectType = 'ProjectTask__c',QueueId = taskQueueId);
			   	sobjectsQueueAllowed.add(allowTasks);
			   	
			   	QueueSobject allowProject = new QueueSobject(SobjectType = 'Project2__c',QueueId = taskQueueId);
			   	sobjectsQueueAllowed.add(allowProject);
			   	
			    QueueSobject allowProjectTaskPred = new QueueSobject(SobjectType = 'ProjectTaskPred__c',QueueId = taskQueueId);
			   	sobjectsQueueAllowed.add(allowProjectTaskPred);
			   	
			   	// Team
			   	
				QueueSobject allowTeams = new QueueSobject(SobjectType = 'Team__c', QueueId = teamQueueId);
			   	sobjectsQueueAllowed.add(allowTeams);
			   	
			   	QueueSobject allowTeamMembers = new QueueSobject(SobjectType = 'TeamMember__c', QueueId = teamQueueId);
			   	sobjectsQueueAllowed.add(allowTeamMembers);	
			   	
			   	QueueSobject allowMiniFeed = new QueueSobject(SobjectType = 'MiniFeed__c', QueueId = teamQueueId);
			   	sobjectsQueueAllowed.add(allowMiniFeed);	
			      	
				// Insert all the allowed sobjects       	
			   	insert sobjectsQueueAllowed;
			   	
			    // This has to be here and not in MainFeedTeam b/c that trigger will 
				// get called before the sharing group is created.
				MiniFeed__c minifeed = null;
	        	
	            // Blurb:
	            minifeed = new MiniFeed__c( Type__c='TeamNew',
	                                        FeedDate__c=System.now(),
	                                        Team__c=team.Id,
	                                        User__c=team.CreatedById,
	                                        Message__c='created new team <a href="/apex/TeamsRedirect?id=' + team.Id + '">' + team.Name + '</a>');
	       		
	        	insert minifeed;
			   	
			   	//Upsert Team owner
			   	Team__c tempTeam = [select ownerId, Id, Name from Team__c where Id =: team.Id limit 1];
			   	tempTeam.ownerId = teamQueueId;
			   	// We set this to true becuase we dont want all the minifeed triggers and update 
			   	// triggers firing off when all we want to do is update the owner id.
			   	TeamUtil.currentlyExeTrigger = true;
			   	upsert tempTeam;
			   	TeamUtil.currentlyExeTrigger = false;
						
				/**
				* Create __Shared object for team
				*/
				Team__Share teamS = new Team__Share();
				teamS.ParentId = team.Id;
				teamS.UserOrGroupId = g.Id;
			    teamS.AccessLevel = 'Read';
			    teamS.RowCause = 'Manual';
			    insert teamS;  
			
				/**
				* Create the first team member (the founder)
				*/
				
				TeamMember__c firstTeamMember = new TeamMember__c();
				firstTeamMember.User__c = Userinfo.getUserId();
				firstTeamMember.Name = UserInfo.getName();
				firstTeamMember.Team__c = team.Id;
				firstTeamMember.TeamProfile__c = defaultProfile.Id;
				insert firstTeamMember;
				
			  	/**
				* Add Discussion Forum to the Team 
				*/
				DiscussionForum__c newForum = new DiscussionForum__c();
				newForum.Team__c = team.Id;
				insert newForum;
				
								/**
				* Add a Project for this Team 
				*/		
				Project2__c p = new Project2__c();
				p.Team__c = team.Id;
				p.synchClndr__c = false;
				p.Priority__c = 'Medium';
				p.Name = team.Name + ' Project';
				insert p;
				
				/**
				* Create __Shared object for Project2__c
				*/
				Project2__Share projectS = new Project2__Share();
				projectS.ParentId = p.Id;
				projectS.UserOrGroupId = g.Id;
			    projectS.AccessLevel = 'Read';
			    projectS.RowCause = 'Manual';
			    insert projectS;  	
				
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}
}