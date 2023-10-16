public class ValidateTeamSharingController {
	private static final Integer maxTeamsToProcess = 1;
	private static final Integer maxLinesInLog = 1000;
	private Integer totalRemainingTeams = 0;
	private Integer totalTeams = 0;
	private Id lastTeamId = null;
	private List<String> results = new List<String>();
	private Boolean resultsTruncated = false;
	private Long startTime;
	private Long endTime;
	private Integer countOk = 0;
	private Integer countFaild = 0;
	private Integer countFixed = 0;
	
	/* HACK FOR THE TEST CLASS */
	public void setLastTeamId () {
		this.lastTeamId = null; 
	}
	public void setTotalRemainingTeams () {
		this.totalRemainingTeams = 0;
	}
	
	
	
	
    public ValidateTeamSharingController() {
		System.debug('ValidateTeamSharingController called.');
    }

    public Integer getTotalTeams() {
		System.debug('getTotalTeams called: ' + this.totalTeams);
		return this.totalTeams;
    }

    public Integer getRemainingTeams() {
		System.debug('getRemainingTeams called: ' + this.totalRemainingTeams);
		return this.totalRemainingTeams;
    }

    public Boolean getDebugging() {
		return false;
    }

    public Double getProgressPercent() {
        Double result = 0;

        Double totalTeams = this.getTotalTeams();
        if (totalTeams > 0) {
                result = ((totalTeams - this.getRemainingTeams()) / totalTeams);
        }
        return result;
    }

    public Boolean getProcessing() {
        System.debug('getProcessing called: ' + (this.totalRemainingTeams > 0));
        return this.totalRemainingTeams > 0;
    }

    public String[] getResults() {
        System.debug('getResults called: ' + this.results);
        return this.results;
    }

    public PageReference startValidation() {
        System.debug('startValidation called.');
        System.debug('\n\n////////////////\n SAVE THIS TEAMPARAM : ' + teamParam + '\n ////////////////// \n');
        if (this.totalRemainingTeams == 0) {
			/* ****
			This is for internal development use only , so that we can process one team at a time in a faster fashion. 
			the standard flow will process all teams, but if only one team is needed for processing, then passing the id param on the url will do the trick.
			**** */
			if (teamParam == null) {
				this.totalTeams = [select count() from Team__c];
			}
			else {
				this.totalTeams = 1;
			}
			
			this.totalRemainingTeams = this.totalTeams;
			this.lastTeamId = null;
			this.results.add('Validation started: ' + System.Now() + '<br>');
			this.startTime = System.Now().getTime();
			this.resultsTruncated = false;
		}

		return null;
	}
	
	public List<String> validateTeams (List<Team__c> teams) {
		List<String> actionsTaken = new List<String>();
		
		for (Team__c currentTeam : teams) {
			// Validate the current team
			String idTeam = currentTeam.Id;
			String nameTeam = currentTeam.Name;
			String ownerTeam = currentTeam.OwnerId;
			
			System.debug('\n \n ////////////////////////// \n Proccessing Team: ' + currentTeam + '\n /////////////////////// \n \n');
			actionsTaken.add('<div class="teamName">Processing Team: ' + nameTeam + '</div>' + System.now() + '<br>');
			
			List<Group> teamGroups = [select id, Name from Group where name like :('%' + idTeam + '%')];
			
			/* Find Queues Booleans*/
			Boolean findWikiQueue = false;
			Boolean findProjectQueue = false;
			Boolean findBlogQueue = false;
			Boolean findBookmarkQueue = false;
			Boolean findTeamQueue = false;
			Boolean findDiscussionQueue = false;
			Boolean findTeamSharing = false;
			
			/* Team Groups Ids*/
			String wikiQueueId;
			String projectQueueId;
			String blogQueueId;
			String bookmarkQueueId;
			String teamQueueId;
			String discussionQueueId;
			String teamSharingId;
			
			/* /////////////////////////// */
			/* Set Queue Booleans and Ids  */
			/* plus set the QueueSObjects  */
			/* /////////////////////////// */
			for (Group teamGroup : teamGroups) {
				if (teamGroup.Name == 'Wiki' + idTeam) {
					findWikiQueue = true;
					wikiQueueId = teamGroup.Id;
					System.debug('\n \n ////////////////////////// \n findWikiQueue: ' + findWikiQueue + '\n /////////////////////// \n \n');
					actionsTaken.add('<span class="goodResult">Wiki Queue Found</span>'); 
					this.countOk++;	
				}
				if (teamGroup.Name == 'Project' + idTeam) {
					findProjectQueue = true;
					projectQueueId = teamGroup.Id;
					System.debug('\n \n ////////////////////////// \n findProjectQueue: ' + findProjectQueue + '\n /////////////////////// \n \n');
					actionsTaken.add('<span class="goodResult">Project Queue Found</span>'); 
					this.countOk++;	
				}
				if (teamGroup.Name == 'Blog' + idTeam) {
					findBlogQueue = true;	
					blogQueueId = teamGroup.Id;
					System.debug('\n \n ////////////////////////// \n findBlogQueue: ' + findBlogQueue + '\n /////////////////////// \n \n');
					actionsTaken.add('<span class="goodResult">Blog Queue Found</span>');
					this.countOk++; 
				}
				if (teamGroup.Name == 'Bookmark' + idTeam) {
					findBookmarkQueue = true;
					bookmarkQueueId = teamGroup.Id;	
					System.debug('\n \n ////////////////////////// \n findBookmarkQueue: ' + findBookmarkQueue + '\n /////////////////////// \n \n');
					actionsTaken.add('<span class="goodResult">Bookmark Queue Found</span>'); 
					this.countOk++;
				}
				if (teamGroup.Name == 'Team' + idTeam) {
					findTeamQueue = true;
					teamQueueId = teamGroup.Id;
					System.debug('\n \n ////////////////////////// \n findTeamQueue: ' + findTeamQueue + '\n /////////////////////// \n \n');
					actionsTaken.add('<span class="goodResult">Team Queue Found</span>'); 
					this.countOk++;	
				}
				if (teamGroup.Name == 'Discussion' + idTeam) {
					findDiscussionQueue = true;	
					discussionQueueId = teamGroup.Id;
					System.debug('\n \n ////////////////////////// \n findDiscussionQueue: ' + findDiscussionQueue + '\n /////////////////////// \n \n');
					actionsTaken.add('<span class="goodResult">Discussion Queue Found</span>'); 
					this.countOk++;
				}
				if (teamGroup.Name == 'teamSharing' + idTeam) {
					findTeamSharing = true;	
					teamSharingId = teamGroup.Id;
					System.debug('\n \n ////////////////////////// \n findTeamSharing: ' + findTeamSharing + '\n teamSharingId: ' + teamSharingId + '\n /////////////////////// \n \n');
					actionsTaken.add('<span class="goodResult">Team Sharing Group Found</span>');
					this.countOk++;
				}
			}
			
			/* /////////////////////////// */
			/* Validate Team Sharing Group */
			/* /////////////////////////// */
			if (!findTeamSharing) {
				actionsTaken.add('<span class="badResult">Team Sharing Group NOT Found</span>'); 
				this.countFaild++;
				Group teamSharingGroup = new Group();
				teamSharingGroup.Name = 'teamSharing' + idTeam;
				insert teamSharingGroup;
				actionsTaken.add('<div class="identAction"><b>Inserting teamSharing:</b> ' + teamSharingGroup + '</div>'); 
				this.countFixed++;
				teamSharingId = teamSharingGroup.Id;
				
				if(currentTeam.PublicProfile__c != null){
					List<Group> go = [Select g.Type, g.Name from Group g where Type = 'Organization'];
					GroupMember gm = new GroupMember();
					gm.GroupId = teamSharingGroup.Id;
					gm.UserOrGroupId = go[0].Id;
					insert gm;
					actionsTaken.add('<div class="identAction"><b>Inserting GroupMember Open/Close:</b> ' + gm + '</div>');
					this.countFixed++; 
				}
				
				actionsTaken.add('<span class="badResult">Team Share NOT Found</span>');
				this.countFaild++;
				Team__Share teamShare = new Team__Share();
				teamShare.ParentId = idTeam;
				teamShare.UserOrGroupId = teamSharingId;
			    teamShare.AccessLevel = 'Read';
			    teamShare.RowCause = 'Manual';
			    insert teamShare;
			    actionsTaken.add('<div class="identAction"><b>Inserting Team__Share:</b> ' + teamShare + '</div>');
			    this.countFixed++;
			}
			else {
				if (currentTeam.PublicProfile__c != null) {
					List<GroupMember> teamSharingGroupMembers = [select id from GroupMember where GroupId =:teamSharingId];
					if (teamSharingGroupMembers.size() == 0) {
						actionsTaken.add('<span class="badResult">Team Sharing Group Member NOT Found</span>');
						this.countFaild++; 
						List<Group> go = [Select g.Type, g.Name from Group g where Type = 'Organization'];
						GroupMember gm = new GroupMember();
						gm.GroupId = teamSharingId;
						gm.UserOrGroupId = go[0].Id;
						insert gm;
						actionsTaken.add('<div class="identAction"><b>Inserting GroupMember Open/Close:</b> ' + gm + '</div>');
						this.countFixed++; 
					}
				}
				else {
					actionsTaken.add('<span class="goodResult">Team Sharing Group Member Found</span>'); 
					this.countOk++;
				}
			}
			
			/* /////////////////////////// */
			/* 	Validate First Team Member */
			/* /////////////////////////// */
			TeamProfile__c defaultProfile = [select Id from TeamProfile__c where Name = 'Team Administrator'];
			List<TeamMember__c> teamTeamMembers = [select id from TeamMember__c where Team__c =:idTeam and TeamProfile__r.ManageTeams__c =true];
			if (teamTeamMembers.size() == 0) {	
				actionsTaken.add('<span class="badResult">Team Administrator Member NOT Found</span>');
				this.countFaild++;
				TeamMember__c firstTeamMember = new TeamMember__c();
				firstTeamMember.User__c = currentTeam.TeamCreatedBy__c;
				firstTeamMember.Team__c = idTeam;
				firstTeamMember.TeamProfile__c = defaultProfile.Id;
				insert firstTeamMember;
				actionsTaken.add('<div class="identAction"><b>Inserting First TeamMember__c:</b> ' + firstTeamMember + '</div>');
				this.countFixed++;
			}
			else {
				actionsTaken.add('<span class="goodResult">Team Administrator Member Found</span>');
				this.countOk++;
			}
			
			/* SELECT ALL TEAM MEMBERS */
			List<TeamMember__c> currentTeamMembers = [select OwnerId, TeamProfile__c, TeamProfile__r.ManageWikis__c, TeamProfile__r.ManageTeams__c, TeamProfile__r.ManageProjectTasks__c, TeamProfile__r.ManageDiscussionForums__c, TeamProfile__r.ManageBookmarks__c, TeamProfile__r.ManageBlogs__c, id, User__c from TeamMember__c where Team__c =:idTeam];
			
			/* /////////////////////////// */
			/*   Validate Members Sharing  */
			/* /////////////////////////// */
			List<TeamMember__share> teamMembersShare = new List<TeamMember__share>();
			List<TeamMember__share> teamInShare = [select ParentId, id, UserOrGroupId, AccessLevel, RowCause from TeamMember__share where UserOrGroupId =: teamSharingId and  RowCause = 'Manual' and AccessLevel = 'Read'];
			List<TeamMember__c> ownerChangeTM = new List<TeamMember__c>();
			
			Boolean problemShare = false;
			for (TeamMember__c iterTeamMember : currentTeamMembers) {
				Boolean findShare = false;
				Integer countShare = 0;
				while (!findShare && countShare < teamInShare.size()) {
					if (teamInShare[countShare].ParentId == iterTeamMember.Id) {
						findShare = true;
						problemShare = true;
					}
					else {
						countShare++;
					}	
				}
				
				if (!findShare) {	
					TeamMember__Share tms = new TeamMember__Share();
					tms.ParentId = iterTeamMember.Id;
					tms.UserOrGroupId = teamSharingId;
					tms.AccessLevel = 'Read';
					tms.RowCause = 'Manual';
					teamMembersShare.add(tms);
				}
			}
			
			if (!problemShare) {
				actionsTaken.add('<span class="badResult">Team Member Share Links NOT Found</span>');	
				this.countFaild++;
				insert teamMembersShare;
				actionsTaken.add('<div class="identAction"><b>Inserting Team Member Share:</b> ' + teamMembersShare + '</div>');
				this.countFixed++;
			}
			else {
				actionsTaken.add('<span class="goodResult">NO Missings Team Member Share</span>'); 
				this.countOk++;
			}
			
			
			/* /////////////////////////// */
			/*  	Validate Wiki Queue    */
			/* /////////////////////////// */
			if (!findWikiQueue) {
				actionsTaken.add('<span class="badResult">Wiki Queue NOT Found</span>'); 
				this.countFaild++;
				Group wikiQueue = new Group();
				wikiQueue.Type = 'Queue';		
				wikiQueue.Name = 'Wiki' + idTeam;
				insert wikiQueue;	
				wikiQueueId = wikiQueue.Id;
				actionsTaken.add('<div class="identAction"><b>Inserting Wiki Queue:</b> ' + wikiQueue + '</div>');
				this.countFixed++;
				
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>();
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
			   	
			   	insert sobjectsQueueAllowed;
   				actionsTaken.add('<div class="identAction"><b>Inserting Wiki QueueSobject:</b> ' + allowWikiPages + '</div>');
   				this.countFixed++;
   				
   				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
   				
   				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageWikis__c == true) {
						GroupMember gm = new GroupMember();
						gm.UserOrGroupId = iterTeamMember.User__c;
						gm.GroupId = wikiQueueId;
						newQueueGroupMembers.add(gm);
					}
				}
				
				actionsTaken.add('<span class="badResult">Missings Group Members in Wiki Queue</span>'); 
				this.countFaild++;
				insert newQueueGroupMembers;
				actionsTaken.add('<div class="identAction"><b>Inserting Wiki Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
				this.countFixed++;	
   				
			}
			else {
				
				// Once we have confirmed the queue exists make sure the QueueSObjects are correct
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				Map<String, QueueSobject> queueMap = new Map<String, QueueSobject>();
				for(QueueSobject queue: [Select SobjectType From QueueSobject where QueueId =: wikiQueueId]) 
					{queueMap.put(queue.SObjectType, queue);}
				
				if( queueMap.get('WikiPage__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'WikiPage__c',QueueId = wikiQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
				
				if( queueMap.get('Comment__c') == null) {
					QueueSobject allowTasks = new QueueSobject(SobjectType = 'Comment__c',QueueId = wikiQueueId);
			   		sobjectsQueueAllowed.add(allowTasks);
				}
			   	
			   	if( queueMap.get('WikiRecentlyViewed__c') == null) {
			   		QueueSobject allowProject = new QueueSobject(SobjectType = 'WikiRecentlyViewed__c',QueueId = wikiQueueId);
			   		sobjectsQueueAllowed.add(allowProject);
			   	}
			   	
			   	if( queueMap.get('WikiLink__c') == null) {
			    	QueueSobject allowWikiLink = new QueueSobject(SobjectType = 'WikiLink__c',QueueId = wikiQueueId);
			   		sobjectsQueueAllowed.add(allowWikiLink);
			   	}
			
			   	if( queueMap.get('FavoriteWikis__c') == null) {
			    	QueueSobject allowFavoriteWiki = new QueueSobject(SobjectType = 'FavoriteWikis__c',QueueId = wikiQueueId);
			   		sobjectsQueueAllowed.add(allowFavoriteWiki);
			   	}
			   	
			   	if(sobjectsQueueAllowed.size() > 0) {
					insert sobjectsQueueAllowed;
					actionsTaken.add('<div class="identAction"><b>Inserting QueueSobject for Wiki Queue</b></div>');
			   	}
				
				List<GroupMember> wikiQueueGM = [select id, UserOrGroupId , GroupId from GroupMember where GroupId =:wikiQueueId];
				
				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
				List<GroupMember> deleteQueueGroupMembers = new List<GroupMember>();
				
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM MEMBERS: ' + currentTeamMembers + '\n /////////////////////// \n \n');
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM WIKI QUEUE: ' + wikiQueueGM + '\n /////////////////////// \n \n');
				
				/* Validate and Insert the missing group Members */
				System.debug('\n\n //////////////////////////// \n SAVE THIS MANAGE WIKIS TEAM MEMBERS SIZE: ' + currentTeamMembers.size() + '\n //////////////////////// \n\n');
				System.debug('\n\n //////////////////////////// \n SAVE THIS MANAGE WIKIS QUEUE SIZE: ' + wikiQueueGM.size() + '\n //////////////////////// \n\n');
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageWikis__c == true) {
							Boolean findInQueue = false;
							System.debug('\n\n //////////////////////////// \n SAVE THIS MANAGE WIKIS TEAM MEMBER: ' + iterTeamMember + '\n //////////////////////// \n\n');
							/* Search the Team Member in the Queue Group Members */
							Integer countQueuePos = 0;
							while (countQueuePos < wikiQueueGM.size() && !findInQueue) {
								if (wikiQueueGm[countQueuePos].UserOrGroupId == iterTeamMember.User__c) {
									findInQueue = true;	
								}
								countQueuePos++;
							}
							System.debug('\n\n //////////////////////////// \n SAVE THIS MANAGE WIKIS TEAM MEMBER FIND IN QUEUE : ' + findInQueue + '\n //////////////////////// \n\n');
							
							if (!findInQueue) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = iterTeamMember.User__c;
								gm.GroupId = wikiQueueId;
								newQueueGroupMembers.add(gm);
							}
					}
				}
				
				if (newQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Missings Group Members in Wiki Queue</span>'); 
					this.countFaild++;
					insert newQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Inserting Wiki Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Missings Group Members in Wiki Queue</span>'); 
					this.countOk++;
				}
				
				/* Validate and Delete the extra group Members */
				for (GroupMember iterGroupMember : wikiQueueGM) {
					if (iterGroupMember.UserOrGroupId != null && iterGroupMember.GroupId != null) {
							Boolean findInTeamMember = false;
							
							/* Search the Group Member in Team Members */
							Integer countMembersPos = 0;
							while (countMembersPos < currentTeamMembers.size() && !findInTeamMember) {
								if ((currentTeamMembers[countMembersPos].User__c == iterGroupMember.UserOrGroupId) && (currentTeamMembers[countMembersPos].TeamProfile__c != null) && (currentTeamMembers[countMembersPos].TeamProfile__r.ManageWikis__c)) {
									findInTeamMember = true;	
								}
								countMembersPos++;
							}
							
							if (!findInTeamMember) {
								deleteQueueGroupMembers.add(iterGroupMember);
							}
					}
					else {
						deleteQueueGroupMembers.add(iterGroupMember);
					}
				}
				
				if (deleteQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Extra Group Members in Wiki Queue</span>'); 
					this.countFaild++;
					delete deleteQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Deleting Wiki Queue Group Members:</b> ' + deleteQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Extra Group Members in Wiki Queue</span>'); 
					this.countOk++;
				}
				
			}
			
			/* /////////////////////////// */
			/*   Validate Project Queue    */
			/* /////////////////////////// */
			if (!findProjectQueue) {
				actionsTaken.add('<span class="badResult">Project Queue NOT Found</span>'); 
				this.countFaild++;
				Group projectQueue = new Group();
				projectQueue.Type = 'Queue';		
				projectQueue.Name = 'Project' + idTeam;
				insert projectQueue;	
				projectQueueId = projectQueue.Id;
				actionsTaken.add('<div class="identAction"><b>Inserting Project Queue:</b> ' + projectQueue + '</div>');
				this.countFixed++;
				
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				QueueSobject allowAsignee = new QueueSobject(SobjectType = 'ProjectAssignee__c',QueueId = projectQueueId);
			   	sobjectsQueueAllowed.add(allowAsignee);
				
				QueueSobject allowTasks = new QueueSobject(SobjectType = 'ProjectTask__c',QueueId = projectQueueId);
			   	sobjectsQueueAllowed.add(allowTasks);
			   	
			   	QueueSobject allowProject = new QueueSobject(SobjectType = 'Project2__c',QueueId = projectQueueId);
			   	sobjectsQueueAllowed.add(allowProject);
			   	
			   	QueueSobject allowProjectTaskPred = new QueueSobject(SobjectType = 'ProjectTaskPred__c',QueueId = projectQueueId);
			   	sobjectsQueueAllowed.add(allowProjectTaskPred);
				
				insert sobjectsQueueAllowed;
   				actionsTaken.add('<div class="identAction"><b>Inserting Projects QueueSobject:</b> ' + sobjectsQueueAllowed + '</div>');
   				this.countFixed++;
   				
   				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
   				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageProjectTasks__c == true) {
						GroupMember gm = new GroupMember();
						gm.UserOrGroupId = iterTeamMember.User__c;
						gm.GroupId = projectQueueId;
						newQueueGroupMembers.add(gm);
					}
				}
				
				actionsTaken.add('<span class="badResult">Missings Group Members in Project Queue</span>'); 
				this.countFaild++;
				insert newQueueGroupMembers;
				actionsTaken.add('<div class="identAction"><b>Inserting Project Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
				this.countFixed++;	
   				
			}
			else {
				
				// Once we have confirmed the queue exists make sure the QueueSObjects are correct
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				Map<String, QueueSobject> queueMap = new Map<String, QueueSobject>();
				for(QueueSobject queue: [Select SobjectType From QueueSobject where QueueId =: projectQueueId]) 
					{queueMap.put(queue.SObjectType, queue);}
				
				if( queueMap.get('ProjectAssignee__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'ProjectAssignee__c',QueueId = projectQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
				
				if( queueMap.get('ProjectTask__c') == null) {
					QueueSobject allowTasks = new QueueSobject(SobjectType = 'ProjectTask__c',QueueId = projectQueueId);
			   		sobjectsQueueAllowed.add(allowTasks);
				}
			   	
			   	if( queueMap.get('Project2__c') == null) {
			   		QueueSobject allowProject = new QueueSobject(SobjectType = 'Project2__c',QueueId = projectQueueId);
			   		sobjectsQueueAllowed.add(allowProject);
			   	}
			   	
			   	if( queueMap.get('ProjectTaskPred__c') == null) {
			    	QueueSobject allowProjectTaskPred = new QueueSobject(SobjectType = 'ProjectTaskPred__c',QueueId = projectQueueId);
			   		sobjectsQueueAllowed.add(allowProjectTaskPred);
			   	}
			   	
				if(sobjectsQueueAllowed.size() > 0) {
					insert sobjectsQueueAllowed;
					actionsTaken.add('<div class="identAction"><b>Inserting QueueSobject for Project Queue</b></div>');
			   	}
			   	
				
				//Validate Group Members
				   	
				List<GroupMember> projectQueueGM = [select id, UserOrGroupId , GroupId from GroupMember where GroupId =:projectQueueId];
				
				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
				List<GroupMember> deleteQueueGroupMembers = new List<GroupMember>();
				
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM MEMBERS: ' + currentTeamMembers + '\n /////////////////////// \n \n');
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM PROJECT QUEUE: ' + projectQueueGM + '\n /////////////////////// \n \n');
				
				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageProjectTasks__c == true) {
							Boolean findInQueue = false;
							
							/* Search the Team Member in the Queue Group Members */
							Integer countQueuePos = 0;
							while (countQueuePos < projectQueueGM.size() && !findInQueue) {
								if (projectQueueGM[countQueuePos].UserOrGroupId == iterTeamMember.User__c) {
									findInQueue = true;	
								}
								countQueuePos++;
							}
							
							if (!findInQueue) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = iterTeamMember.User__c;
								gm.GroupId = projectQueueId;
								newQueueGroupMembers.add(gm);
							}
					}
				}
				
				if (newQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Missings Group Members in Project Queue</span>'); 
					this.countFaild++;
					insert newQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Inserting Project Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Missings Group Members in Project Queue</span>'); 
					this.countOk++;
				}
				
				/* Validate and Delete the extra group Members */
				for (GroupMember iterGroupMember : projectQueueGM) {
					if (iterGroupMember.UserOrGroupId != null && iterGroupMember.GroupId != null) {
							Boolean findInTeamMember = false;
							
							/* Search the Group Member in Team Members */
							Integer countMembersPos = 0;
							while (countMembersPos < currentTeamMembers.size() && !findInTeamMember) {
								if ((currentTeamMembers[countMembersPos].User__c == iterGroupMember.UserOrGroupId) && (currentTeamMembers[countMembersPos].TeamProfile__c != null) && (currentTeamMembers[countMembersPos].TeamProfile__r.ManageProjectTasks__c)) {
									findInTeamMember = true;	
								}
								countMembersPos++;
							}
							
							if (!findInTeamMember) {
								deleteQueueGroupMembers.add(iterGroupMember);
							}
					}
					else {
						deleteQueueGroupMembers.add(iterGroupMember);
					}
				}
				
				if (deleteQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Extra Group Members in Project Queue</span>'); 
					this.countFaild++;
					delete deleteQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Deleting Project Queue Group Members:</b> ' + deleteQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Extra Group Members in Project Queue</span>'); 
					this.countOk++;
				}
			}
			
			/* /////////////////////////// */
			/*  	Validate Blog Queue    */
			/* /////////////////////////// */
			if (!findBlogQueue) {
				actionsTaken.add('<span class="badResult">Blog Queue NOT Found</span>'); 
				this.countFaild++;
				Group blogQueue = new Group();
				blogQueue.Type = 'Queue';		
				blogQueue.Name = 'Blog' + idTeam;
				insert blogQueue;	
				blogQueueId = blogQueue.Id;
				actionsTaken.add('<div class="identAction"><b>Inserting Blog Queue:</b> ' + blogQueue + '</div>');
				this.countFixed++;
				
				QueueSobject allowBlogs = new QueueSobject(SobjectType = 'BlogEntry__c',QueueId = blogQueueId);
   				insert allowBlogs;
   				actionsTaken.add('<div class="identAction"><b>Inserting Blog QueueSobject:</b> ' + allowBlogs + '</div>');
   				this.countFixed++;
   				
   				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
   				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageBlogs__c == true) {
						GroupMember gm = new GroupMember();
						gm.UserOrGroupId = iterTeamMember.User__c;
						gm.GroupId = blogQueueId;
						newQueueGroupMembers.add(gm);
					}
				}
				
				actionsTaken.add('<span class="badResult">Missings Group Members in Blog Queue</span>'); 
				this.countFaild++;
				insert newQueueGroupMembers;
				actionsTaken.add('<div class="identAction"><b>Inserting Blog Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
				this.countFixed++;	
			}
			else {
				
				// Once we have confirmed the queue exists make sure the QueueSObjects are correct
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				Map<String, QueueSobject> queueMap = new Map<String, QueueSobject>();
				for(QueueSobject queue: [Select SobjectType From QueueSobject where QueueId =: blogQueueId]) 
					{queueMap.put(queue.SObjectType, queue);}
				
				if( queueMap.get('BlogEntry__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'BlogEntry__c',QueueId = blogQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
			   	
			   	if(sobjectsQueueAllowed.size() > 0) {
					insert sobjectsQueueAllowed;
					actionsTaken.add('<div class="identAction"><b>Inserting QueueSobject for Blog Queue</b></div>');
			   	}
				
				//Validate Group Members
				
				List<GroupMember> blogQueueGM = [select id, UserOrGroupId , GroupId from GroupMember where GroupId =:blogQueueId];
				
				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
				List<GroupMember> deleteQueueGroupMembers = new List<GroupMember>();
				
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM MEMBERS: ' + currentTeamMembers + '\n /////////////////////// \n \n');
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM PROJECT QUEUE: ' + blogQueueGM + '\n /////////////////////// \n \n');
				
				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageBlogs__c == true) {
							Boolean findInQueue = false;
							
							/* Search the Team Member in the Queue Group Members */
							Integer countQueuePos = 0;
							while (countQueuePos < blogQueueGM.size() && !findInQueue) {
								if (blogQueueGM[countQueuePos].UserOrGroupId == iterTeamMember.User__c) {
									findInQueue = true;	
								}
								countQueuePos++;
							}
							
							if (!findInQueue) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = iterTeamMember.User__c;
								gm.GroupId = blogQueueId;
								newQueueGroupMembers.add(gm);
							}
					}
				}
				
				if (newQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Missings Group Members in Blog Queue</span>'); 
					this.countFaild++;
					insert newQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Inserting Blog Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Missings Group Members in Blog Queue</span>'); 
					this.countOk++;
				}
				
				/* Validate and Delete the extra group Members */
				for (GroupMember iterGroupMember : blogQueueGM) {
					if (iterGroupMember.UserOrGroupId != null && iterGroupMember.GroupId != null) {
							Boolean findInTeamMember = false;
							
							/* Search the Group Member in Team Members */
							Integer countMembersPos = 0;
							while (countMembersPos < currentTeamMembers.size() && !findInTeamMember) {
								if ((currentTeamMembers[countMembersPos].User__c == iterGroupMember.UserOrGroupId) && (currentTeamMembers[countMembersPos].TeamProfile__c != null) && (currentTeamMembers[countMembersPos].TeamProfile__r.ManageBlogs__c)) {
									findInTeamMember = true;	
								}
								countMembersPos++;
							}
							
							if (!findInTeamMember) {
								deleteQueueGroupMembers.add(iterGroupMember);
							}
					}
					else {
						deleteQueueGroupMembers.add(iterGroupMember);
					}
				}
				
				if (deleteQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Extra Group Members in Blog Queue</span>'); 
					this.countFaild++;
					delete deleteQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Deleting Blog Queue Group Members:</b> ' + deleteQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Extra Group Members in Blog Queue</span>'); 
					this.countOk++;
				}
			}
			
			/* /////////////////////////// */
			/*  Validate Bookmark Queue    */
			/* /////////////////////////// */
			if (!findBookmarkQueue) {
				actionsTaken.add('<span class="badResult">Bookmark Queue NOT Found</span>');
				this.countFaild++;
				Group bookmarkQueue = new Group();
				bookmarkQueue.Type = 'Queue';		
				bookmarkQueue.Name = 'Bookmark' + idTeam;
				insert bookmarkQueue;	
				bookmarkQueueId = bookmarkQueue.Id;
				actionsTaken.add('<div class="identAction"><b>Inserting Bookmark Queue:</b> ' + bookmarkQueue + '</div>');
				this.countFixed++;
				
				QueueSobject allowBookmarks = new QueueSobject(SobjectType = 'Bookmark__c',QueueId = bookmarkQueueId);
   				insert allowBookmarks;
   				actionsTaken.add('<div class="identAction"><b>Inserting Bookmark QueueSobject:</b> ' + allowBookmarks + '</div>');
   				this.countFixed++; 
   				
   				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
   				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageBookmarks__c == true) {
						GroupMember gm = new GroupMember();
						gm.UserOrGroupId = iterTeamMember.User__c;
						gm.GroupId = bookmarkQueueId;
						newQueueGroupMembers.add(gm);
					}
				}
				
				actionsTaken.add('<span class="badResult">Missings Group Members in Bookmark Queue</span>'); 
				this.countFaild++;
				insert newQueueGroupMembers;
				actionsTaken.add('<div class="identAction"><b>Inserting Bookmark Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
				this.countFixed++;	
			}
			else {
				
				// Once we have confirmed the queue exists make sure the QueueSObjects are correct
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				Map<String, QueueSobject> queueMap = new Map<String, QueueSobject>();
				for(QueueSobject queue: [Select SobjectType From QueueSobject where QueueId =: bookmarkQueueId]) 
					{queueMap.put(queue.SObjectType, queue);}
				
				if( queueMap.get('Bookmark__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'Bookmark__c',QueueId = bookmarkQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
			   	
				if(sobjectsQueueAllowed.size() > 0) {
					insert sobjectsQueueAllowed;
					actionsTaken.add('<div class="identAction"><b>Inserting QueueSobject for Bookmark Queue</b></div>');
			   	}
				
				//Validate Group Members
				
				List<GroupMember> bookmarkQueueGM = [select id, UserOrGroupId , GroupId from GroupMember where GroupId =:bookmarkQueueId];
				
				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
				List<GroupMember> deleteQueueGroupMembers = new List<GroupMember>();
				
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM MEMBERS: ' + currentTeamMembers + '\n /////////////////////// \n \n');
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM PROJECT QUEUE: ' + bookmarkQueueGM + '\n /////////////////////// \n \n');
				
				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageBookmarks__c == true) {
							Boolean findInQueue = false;
							
							/* Search the Team Member in the Queue Group Members */
							Integer countQueuePos = 0;
							while (countQueuePos < bookmarkQueueGM.size() && !findInQueue) {
								if (bookmarkQueueGM[countQueuePos].UserOrGroupId == iterTeamMember.User__c) {
									findInQueue = true;	
								}
								countQueuePos++;
							}
							
							if (!findInQueue) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = iterTeamMember.User__c;
								gm.GroupId = bookmarkQueueId;
								newQueueGroupMembers.add(gm);
							}
					}
				}
				
				if (newQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Missings Group Members in Bookmark Queue</span>'); 
					this.countFaild++;
					insert newQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Inserting Bookmark Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Missings Group Members in Bookmark Queue</span>'); 
					this.countOk++;
				}
				
				/* Validate and Delete the extra group Members */
				for (GroupMember iterGroupMember : bookmarkQueueGM) {
					if (iterGroupMember.UserOrGroupId != null && iterGroupMember.GroupId != null) {
							Boolean findInTeamMember = false;
							
							/* Search the Group Member in Team Members */
							Integer countMembersPos = 0;
							while (countMembersPos < currentTeamMembers.size() && !findInTeamMember) {
								if ((currentTeamMembers[countMembersPos].User__c == iterGroupMember.UserOrGroupId) && (currentTeamMembers[countMembersPos].TeamProfile__c != null) && (currentTeamMembers[countMembersPos].TeamProfile__r.ManageBookmarks__c)) {
									findInTeamMember = true;	
								}
								countMembersPos++;
							}
							
							if (!findInTeamMember) {
								deleteQueueGroupMembers.add(iterGroupMember);
							}
					}
					else {
						deleteQueueGroupMembers.add(iterGroupMember);
					}
				}
				
				if (deleteQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Extra Group Members in Bookmark Queue</span>'); 
					this.countFaild++;
					delete deleteQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Deleting Bookmark Queue Group Members:</b> ' + deleteQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Extra Group Members in Bookmark Queue</span>'); 
					this.countOk++;
				}
			}
			
			/* /////////////////////////// */
			/*  	Validate Team Queue    */
			/* /////////////////////////// */
			if (!findTeamQueue) {
				actionsTaken.add('<span class="badResult">Team Queue NOT Found</span>'); 
				this.countFaild++;
				Group teamQueue = new Group();
				teamQueue.Type = 'Queue';		
				teamQueue.Name = 'Team' + idTeam;
				insert teamQueue;	
				teamQueueId = teamQueue.Id;
				actionsTaken.add('<div class="identAction"><b>Inserting Team Queue:</b> ' + teamQueue + '</div>');
				this.countFixed++;
				
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				QueueSobject allowTeams = new QueueSobject(SobjectType = 'Team__c', QueueId = teamQueueId);
   				sobjectsQueueAllowed.add(allowTeams);	
   				
   				QueueSobject allowTeamMembers = new QueueSobject(SobjectType = 'TeamMember__c', QueueId = teamQueueId);
			   	sobjectsQueueAllowed.add(allowTeamMembers);	
			   	
   				QueueSobject allowMiniFeed = new QueueSobject(SobjectType = 'MiniFeed__c', QueueId = teamQueueId);
			   	sobjectsQueueAllowed.add(allowMiniFeed);	
			   	
			   	insert sobjectsQueueAllowed;
			      				      	
   				actionsTaken.add('<div class="identAction"><b>Inserting Team QueueSobject:</b> ' + allowTeams + '</div>');
   				this.countFixed++;
   				
   				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
   				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageTeams__c == true) {
						GroupMember gm = new GroupMember();
						gm.UserOrGroupId = iterTeamMember.User__c;
						gm.GroupId = teamQueueId;
						newQueueGroupMembers.add(gm);
					}
					if (iterTeamMember.OwnerId != teamQueueId) {
						iterTeamMember.OwnerId = teamQueueId;
						ownerChangeTM.add(iterTeamMember);
					}
				}
				
				if (ownerChangeTM.size() > 0) {
					update ownerChangeTM;
					actionsTaken.add('<div class="identAction"><b>Updating Team Members Owner:</b> ' + ownerChangeTM + '</div>');
					this.countFixed++;	
				}
				
				actionsTaken.add('<span class="badResult">Missings Group Members in Team Queue</span>'); 
				this.countFaild++;
				insert newQueueGroupMembers;
				actionsTaken.add('<div class="identAction"><b>Inserting Team Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
				this.countFixed++;	
			}
			else {
				
				// Once we have confirmed the queue exists make sure the QueueSObjects are correct
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				Map<String, QueueSobject> queueMap = new Map<String, QueueSobject>();
				for(QueueSobject queue: [Select SobjectType From QueueSobject where QueueId =: teamQueueId]) 
					{queueMap.put(queue.SObjectType, queue);}
				
				if( queueMap.get('Team__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'Team__c',QueueId = teamQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
				
				if( queueMap.get('TeamMember__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'TeamMember__c',QueueId = teamQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
								
				if( queueMap.get('MiniFeed__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'MiniFeed__c',QueueId = teamQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
							   								   	
				if(sobjectsQueueAllowed.size() > 0) {
					insert sobjectsQueueAllowed;
					actionsTaken.add('<div class="identAction"><b>Inserting QueueSobject for Project Queue</b></div>');
			   	}
				
				//Validate Group Members
				
				List<GroupMember> teamQueueGM = [select id, UserOrGroupId , GroupId from GroupMember where GroupId =:teamQueueId];
				
				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
				List<GroupMember> deleteQueueGroupMembers = new List<GroupMember>();
				
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM MEMBERS: ' + currentTeamMembers + '\n /////////////////////// \n \n');
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM PROJECT QUEUE: ' + teamQueueGM + '\n /////////////////////// \n \n');
				
				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageTeams__c == true) {
							Boolean findInQueue = false;
							
							/* Search the Team Member in the Queue Group Members */
							Integer countQueuePos = 0;
							while (countQueuePos < teamQueueGM.size() && !findInQueue) {
								if (teamQueueGM[countQueuePos].UserOrGroupId == iterTeamMember.User__c) {
									findInQueue = true;	
								}
								countQueuePos++;
							}
							
							if (!findInQueue) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = iterTeamMember.User__c;
								gm.GroupId = teamQueueId;
								newQueueGroupMembers.add(gm);
							}
					}
					if (iterTeamMember.OwnerId != teamQueueId) {
						iterTeamMember.OwnerId = teamQueueId;
						ownerChangeTM.add(iterTeamMember);
					}
				}
				
				if (ownerChangeTM.size() > 0) {
					update ownerChangeTM;
					actionsTaken.add('<div class="identAction"><b>Updating Team Members Owner:</b> ' + ownerChangeTM + '</div>');
					this.countFixed++;	
				}
				
				if (newQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Missings Group Members in Team Queue</span>'); 
					this.countFaild++;
					insert newQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Inserting Team Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Missings Group Members in Team Queue</span>'); 
					this.countOk++;
				}
				
				/* Validate and Delete the extra group Members */
				for (GroupMember iterGroupMember : teamQueueGM) {
					if (iterGroupMember.UserOrGroupId != null && iterGroupMember.GroupId != null) {
							Boolean findInTeamMember = false;
							
							/* Search the Group Member in Team Members */
							Integer countMembersPos = 0;
							while (countMembersPos < currentTeamMembers.size() && !findInTeamMember) {
								if ((currentTeamMembers[countMembersPos].User__c == iterGroupMember.UserOrGroupId) && (currentTeamMembers[countMembersPos].TeamProfile__c != null) && (currentTeamMembers[countMembersPos].TeamProfile__r.ManageTeams__c)) {
									findInTeamMember = true;	
								}
								countMembersPos++;
							}
							
							if (!findInTeamMember) {
								deleteQueueGroupMembers.add(iterGroupMember);
							}
					}
					else {
						deleteQueueGroupMembers.add(iterGroupMember);
					}
				}
				
				if (deleteQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Extra Group Members in Team Queue</span>'); 
					this.countFaild++;
					delete deleteQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Deleting Team Queue Group Members:</b> ' + deleteQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Extra Group Members in Team Queue</span>'); 
					this.countOk++;
				}
			}
			
			/* /////////////////////////// */
			/*  Validate Discussion Queue  */
			/* /////////////////////////// */
			if (!findDiscussionQueue) {
				actionsTaken.add('<span class="badResult">Discussion Queue NOT Found</span>'); 
				this.countFaild++;
				Group discussionQueue = new Group();
				discussionQueue.Type = 'Queue';		
				discussionQueue.Name = 'Discussion' + idTeam;
				insert discussionQueue;	
				discussionQueueId = discussionQueue.Id;
				actionsTaken.add('<div class="identAction"><b>Inserting Discussion Queue:</b> ' + discussionQueue + '</div>');
				this.countFixed++;
				
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				QueueSobject allowForum = new QueueSobject(SobjectType = 'DiscussionForum__c',QueueId = discussionQueueId);
			   	sobjectsQueueAllowed.add(allowForum);
				
				QueueSobject allowTopics = new QueueSobject(SobjectType = 'DiscussionTopic__c',QueueId = discussionQueueId);
			   	sobjectsQueueAllowed.add(allowTopics);
			   	
			   	QueueSobject allowMessages = new QueueSobject(SobjectType = 'DiscussionMessage__c',QueueId = discussionQueueId);
			   	sobjectsQueueAllowed.add(allowMessages);
				
				insert sobjectsQueueAllowed;
   				actionsTaken.add('<div class="identAction"><b>Inserting Discussion QueueSobject:</b> ' + sobjectsQueueAllowed + '</div>');
   				this.countFixed++;
   				
   				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
   				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageDiscussionForums__c == true) {
						GroupMember gm = new GroupMember();
						gm.UserOrGroupId = iterTeamMember.User__c;
						gm.GroupId = discussionQueueId;
						newQueueGroupMembers.add(gm);
					}
				}
				
				actionsTaken.add('<span class="badResult">Missings Group Members in Discussion Queue</span>'); 
				this.countFaild++;
				insert newQueueGroupMembers;
				actionsTaken.add('<div class="identAction"><b>Inserting Discussion Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
				this.countFixed++;
			}
			else {
				
				// Once we have confirmed the queue exists make sure the QueueSObjects are correct
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>(); 
				Map<String, QueueSobject> queueMap = new Map<String, QueueSobject>();
				for(QueueSobject queue: [Select SobjectType From QueueSobject where QueueId =: discussionQueueId]) 
					{queueMap.put(queue.SObjectType, queue);}
				
				if( queueMap.get('DiscussionForum__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'DiscussionForum__c',QueueId = discussionQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
				
				if( queueMap.get('DiscussionTopic__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'DiscussionTopic__c',QueueId = discussionQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
								
				if( queueMap.get('DiscussionMessage__c') == null) {
					QueueSobject allowAsignee = new QueueSobject(SobjectType = 'DiscussionMessage__c',QueueId = discussionQueueId);
			   		sobjectsQueueAllowed.add(allowAsignee);
				}
							   	
				if(sobjectsQueueAllowed.size() > 0) {
					insert sobjectsQueueAllowed;
					actionsTaken.add('<div class="identAction"><b>Inserting QueueSobject for Discussion Queue</b></div>');
			   	}
				
				//Validate Group Members
				
				List<GroupMember> discussionQueueGM = [select id, UserOrGroupId , GroupId from GroupMember where GroupId =:discussionQueueId];
				
				List<GroupMember> newQueueGroupMembers = new List<GroupMember>();
				List<GroupMember> deleteQueueGroupMembers = new List<GroupMember>();
				
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM MEMBERS: ' + currentTeamMembers + '\n /////////////////////// \n \n');
				System.debug('\n \n //////////////////////////////////// \n CURRENT TEAM PROJECT QUEUE: ' + discussionQueueGM + '\n /////////////////////// \n \n');
				
				/* Validate and Insert the missing group Members */
				for (TeamMember__c iterTeamMember : currentTeamMembers) {
					if (iterTeamMember.TeamProfile__c != null && iterTeamMember.TeamProfile__r.ManageDiscussionForums__c == true) {
							Boolean findInQueue = false;
							
							/* Search the Team Member in the Queue Group Members */
							Integer countQueuePos = 0;
							while (countQueuePos < discussionQueueGM.size() && !findInQueue) {
								if (discussionQueueGM[countQueuePos].UserOrGroupId == iterTeamMember.User__c) {
									findInQueue = true;	
								}
								countQueuePos++;
							}
							
							if (!findInQueue) {
								GroupMember gm = new GroupMember();
								gm.UserOrGroupId = iterTeamMember.User__c;
								gm.GroupId = discussionQueueId;
								newQueueGroupMembers.add(gm);
							}
					}
				}
				
				if (newQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Missings Group Members in Discussion Queue</span>'); 
					this.countFaild++;
					insert newQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Inserting Discussion Queue Group Members:</b> ' + newQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Missings Group Members in Discussion Queue</span>'); 
					this.countOk++;
				}
				
				/* Validate and Delete the extra group Members */
				for (GroupMember iterGroupMember : discussionQueueGM) {
					if (iterGroupMember.UserOrGroupId != null && iterGroupMember.GroupId != null) {
							Boolean findInTeamMember = false;
							
							/* Search the Group Member in Team Members */
							Integer countMembersPos = 0;
							while (countMembersPos < currentTeamMembers.size() && !findInTeamMember) {
								if ((currentTeamMembers[countMembersPos].User__c == iterGroupMember.UserOrGroupId) && (currentTeamMembers[countMembersPos].TeamProfile__c != null) && (currentTeamMembers[countMembersPos].TeamProfile__r.ManageDiscussionForums__c)) {
									findInTeamMember = true;	
								}
								countMembersPos++;
							}
							
							if (!findInTeamMember) {
								deleteQueueGroupMembers.add(iterGroupMember);
							}
					}
					else {
						deleteQueueGroupMembers.add(iterGroupMember);
					}
				}
				
				if (deleteQueueGroupMembers.size() > 0) {
					actionsTaken.add('<span class="badResult">Extra Group Members in Discussion Queue</span>'); 
					this.countFaild++;
					delete deleteQueueGroupMembers;
					actionsTaken.add('<div class="identAction"><b>Deleting Discussion Queue Group Members:</b> ' + deleteQueueGroupMembers + '</div>');
					this.countFixed++;	
				}
				else {
					actionsTaken.add('<span class="goodResult">NO Extra Group Members in Discussion Queue</span>'); 
					this.countOk++;
				}
			}
			
			
			/* /////////////////////////// */
			/* 		Validate Team Share    */
			/* /////////////////////////// */
			List<Team__Share> teamShares = [select id from Team__Share where ParentId =:idTeam and UserOrGroupId =:teamSharingId and AccessLevel = 'Read' and RowCause = 'Manual'];
			if (teamShares.size() == 0) {	
				actionsTaken.add('<span class="badResult">Team Share NOT Found</span>');
				this.countFaild++;
				Team__Share teamShare = new Team__Share();
				teamShare.ParentId = idTeam;
				teamShare.UserOrGroupId = teamSharingId;
			    teamShare.AccessLevel = 'Read';
			    teamShare.RowCause = 'Manual';
			    insert teamShare;
			    actionsTaken.add('<div class="identAction"><b>Inserting Team__Share:</b> ' + teamShare + '</div>');
			    this.countFixed++;
			}
			else {
				actionsTaken.add('<span class="goodResult">Team Share Found</span>');
				this.countOk++;
			}
			
			/* /////////////////////////// */
			/* 		Validate Team Owner    */
			/* /////////////////////////// */
			if (ownerTeam != teamQueueId) {	
				actionsTaken.add('<span class="badResult">Team Owner incorrect</span>');
				this.countFaild++;
				currentTeam.OwnerId = teamQueueId;
				update currentTeam;
			    actionsTaken.add('<div class="identAction"><b>Updating Team Owner:</b> ' + currentTeam + '</div>');
			    this.countFixed++;
			}
			else {
				actionsTaken.add('<span class="goodResult">Team Owner OK</span>');
				this.countOk++;
			}
			
			/* /////////////////////////// */
			/* 		Validate Project2 	   */
			/* /////////////////////////// */
			List<Project2__c> teamProjects = [select team__c, id, Name from Project2__c where team__c =: idTeam and name =: (nameTeam + ' Project')];
			System.debug('\n\n////////////////////////////// \n SAVE THIS TEAMPROJECTS: ' + teamProjects + '\n //////////////////////////// \n\n');
			if (teamProjects.size() == 0) {
				actionsTaken.add('<span class="badResult">Team Project NOT Found</span>'); 
				this.countFaild++;
				System.debug('\n\n////////////////////////////// \n SAVE THIS projectQueueId: ' + projectQueueId + '\n //////////////////////////// \n\n');
				Project2__c p = new Project2__c();
				p.Team__c = idTeam;
				p.synchClndr__c = false;
				p.Priority__c = 'Medium';
				p.Name = nameTeam + ' Project';
				//p.OwnerId = projectQueueId;
				System.debug('\n\n////////////////////////////// \n SAVE THIS Project to insert: ' + p + '\n //////////////////////////// \n\n');
				insert p;
				actionsTaken.add('<div class="identAction"><b>Inserting Project2__c:</b> ' + p + '</div>'); 
				this.countFixed++;
				
				List<Project2__Share> teamProjectsShare = [select id from Project2__Share where ParentId =: p.Id and UserOrGroupId =:teamSharingId and AccessLevel = 'Read' and RowCause = 'Manual'];
				if (teamProjectsShare.size() == 0) {
					actionsTaken.add('<span class="badResult">Team Project Share NOT Found</span>'); 
					this.countFaild++;
					Project2__Share projectS = new Project2__Share();
					projectS.ParentId = p.Id;
					projectS.UserOrGroupId = teamSharingId;
				    projectS.AccessLevel = 'Read';
				    projectS.RowCause = 'Manual';
				    insert projectS; 
				    actionsTaken.add('<div class="identAction"><b>Inserting Project2__Share:</b> ' + projectS + '</div>');
				    this.countFixed++;
				} 		
			}
			else {
				List<Project2__Share> teamProjectsShare = [select id from Project2__Share where ParentId =: teamProjects[0].Id and UserOrGroupId =:teamSharingId and AccessLevel = 'Read' and RowCause = 'Manual'];
				if (teamProjectsShare.size() == 0) {
					actionsTaken.add('<span class="badResult">Team Project Share NOT Found</span>'); 
					this.countFaild++;
					Project2__Share projectS = new Project2__Share();
					projectS.ParentId = teamProjects[0].Id;
					projectS.UserOrGroupId = teamSharingId;
				    projectS.AccessLevel = 'Read';
				    projectS.RowCause = 'Manual';
				    insert projectS; 
				    actionsTaken.add('<div class="identAction"><b>Inserting Project2__Share:</b> ' + projectS + '</div>');
				    this.countFixed++;
				}	
				else {
					actionsTaken.add('<span class="goodResult">Team Project Found</span>'); 	
					this.countOk++;
				}
			}
			
			/* Delete Extra Team Project */
			List<Project2__c> extraTeamProjects = [select team__c, id, Name from Project2__c where team__c =: idTeam and name !=: (nameTeam + ' Project')];
			if (extraTeamProjects.size() > 0) {
				actionsTaken.add('<span class="badResult">Extra Team Project Found</span>'); 
				this.countFaild++;
				delete extraTeamProjects;
				actionsTaken.add('<div class="identAction"><b>Deleting Extra Team Project:</b> ' + extraTeamProjects + '</div>');
				this.countFixed++;
			}
			
			/* /////////////////////////// */
			/* 	Validate Discussion Forum  */
			/* /////////////////////////// */
			List<DiscussionForum__c> teamDiscussionForums = [select team__c, id, Name from DiscussionForum__c where team__c =: idTeam];
			if (teamDiscussionForums.size() == 0) {
				actionsTaken.add('<span class="badResult">Team Discussion Forum NOT Found</span>'); 
				this.countFaild++;
				DiscussionForum__c teamDiscussionForum = new DiscussionForum__c();
				teamDiscussionForum.Team__c = idTeam;
				//teamDiscussionForum.OwnerId = discussionQueueId;
				insert teamDiscussionForum;
				actionsTaken.add('<div class="identAction"><b>Inserting DiscussionForum__c:</b> ' + teamDiscussionForum + '</div>'); 
				this.countFixed++;
				
				List<DiscussionForum__Share> teamDiscussionForumShares = [select id from DiscussionForum__Share where ParentId =: teamDiscussionForum.Id and UserOrGroupId =:teamSharingId and AccessLevel = 'Read' and RowCause = 'Manual'];
				if (teamDiscussionForumShares.size() == 0) {
					actionsTaken.add('<span class="badResult">Team Discussion Forum Share NOT Found</span>'); 
					this.countFaild++;
					DiscussionForum__Share teamDiscussionForumShare = new DiscussionForum__Share();
					teamDiscussionForumShare.ParentId = teamDiscussionForum.Id;
					teamDiscussionForumShare.UserOrGroupId = teamSharingId;
				    teamDiscussionForumShare.AccessLevel = 'Read';
				    teamDiscussionForumShare.RowCause = 'Manual';
				    insert teamDiscussionForumShare; 
				    actionsTaken.add('<div class="identAction"><b>Inserting DiscussionForum__Share:</b> ' + teamDiscussionForumShare + '</div>');
				    this.countFixed++;
				}		
			}
			else {
				if (teamDiscussionForums.size() > 1) {
					actionsTaken.add('<span class="badResult">Extra Team Discussion Forum Found</span>');
					this.countFaild++; 
					List<DiscussionForum__c> extraTeamDiscussionForums = [select team__c, id, Name from DiscussionForum__c where team__c =: idTeam order by CreatedDate desc limit :(teamDiscussionForums.size() - 1)];
					delete extraTeamDiscussionForums;
					actionsTaken.add('<div class="identAction"><b>Deleting Extra Discussion Forums:</b> ' + extraTeamDiscussionForums + '</div>');
				    this.countFixed++;
				}
				
				List<DiscussionForum__Share> teamDiscussionForumShares = [select id from DiscussionForum__Share where ParentId =: teamDiscussionForums[0].Id and UserOrGroupId =:teamSharingId and AccessLevel = 'Read' and RowCause = 'Manual'];
				if (teamDiscussionForumShares.size() == 0) {
					actionsTaken.add('<span class="badResult">Team Discussion Forum Share NOT Found</span>');
					this.countFaild++; 
					DiscussionForum__Share teamDiscussionForumShare = new DiscussionForum__Share();
					teamDiscussionForumShare.ParentId = teamDiscussionForums[0].Id;
					teamDiscussionForumShare.UserOrGroupId = teamSharingId;
				    teamDiscussionForumShare.AccessLevel = 'Read';
				    teamDiscussionForumShare.RowCause = 'Manual';
				    insert teamDiscussionForumShare; 
				    actionsTaken.add('<div class="identAction"><b>Inserting DiscussionForum__Share:</b> ' + teamDiscussionForumShare + '</div>');
				    this.countFixed++;
				}
				else {
					actionsTaken.add('<span class="goodResult">Team Discussion Forum Found</span>'); 
					this.countOk++;
				}	
				
				/*
				// Check Sharing and owners on all the Topic/Message objects
				// Select all topics and message under this
				List<DiscussionTopic__c> topics = [select Id, OwnerId from DiscussionTopic__c where Team__c =: idTeam];
				List<DiscussionMessage__c> messages = [select Id, OwnerId from DiscussionMessage__c where Team__c =: idTeam];
				
				// Select all sharing from topic table and put into a map where 
				Map<Id, DiscussionTopic__Share> topicShareMap = new Map<Id, DiscussionTopic__Share>();
				for(DiscussionTopic__Share t: [select parentId from DiscussionTopic__Share where parentId in: topics and UserOrGroupId =: teamSharingId]) {
					topicShareMap.put(t.parentId, t);
				}
				
				// Select all sharing records for the message table and put into a map
				Map<Id, DiscussionMessage__Share> messageShareMap = new Map<Id, DiscussionMessage__Share>();
				for(DiscussionMessage__Share m: [select parentId from DiscussionMessage__Share where parentId in: messages and UserOrGroupId =: teamSharingId]) {
					messageShareMap.put(m.parentId, m);
				}
				
				List<DiscussionTopic__Share> topicShares = new List<DiscussionTopic__Share>();
				List<DiscussionMessage__Share> messageShares = new List<DiscussionMessage__Share>();
				
				// Iterate over evey topic and check to see if ti has a sharing row.  if not create
				for(DiscussionTopic__c topic : topics) {
				
				    if(topicShareMap.get(topic.Id) == null) {
					  	DiscussionTopic__Share topicShare = new DiscussionTopic__Share();
						topicShare.ParentId = topic.Id;
						topicShare.UserOrGroupId = teamSharingId;
					   	topicShare.AccessLevel = 'Read';
				    	topicShare.RowCause = 'Manual';
						topicShares.add(topicShare);
				     }
				     
				     // need to check owner too.
				     if(topic.OwnerId != DiscussionQueueId)
					      topic.OwnerId = DiscussionQueueId;
				}
				 
				update topics;
				insert topicShares;
				
				// Iternate over every message and check to see if it has a sharing row if not create
				 for(DiscussionMessage__c message : messages) {
				
				    if(messageShareMap.get(message.Id) == null) {
					  	DiscussionMessage__Share messageShare = new DiscussionMessage__Share();
						messageShare.ParentId = message.Id;
						messageShare.UserOrGroupId = teamSharingId;
				   		messageShare.AccessLevel = 'Read';
				    	messageShare.RowCause = 'Manual';
						messageShares.add(messageShare);
				     }
				
				     // need to check owner too.
				     if(message.OwnerId != DiscussionQueueId)
					      message.OwnerId = DiscussionQueueId;
				}
				 
				update messages;
				insert messageShares;
				*/
			}
			
			/* /////////////////////////// */
			/* 	Validate Team Mini Feeds   */
			/* /////////////////////////// */
			List<MiniFeed__c> teamMiniFeeds = [select id from MiniFeed__c where Type__c='TeamNew' and Team__c =:idTeam and Message__c like '%created new team%'];
			if (teamMiniFeeds.size() == 0) {
				actionsTaken.add('<span class="badResult">Team Mini Feed NOT Found</span>');
				this.countFaild++;
				MiniFeed__c teamMiniFeed = new MiniFeed__c();
				teamMiniFeed.Type__c='TeamNew';
				teamMiniFeed.FeedDate__c=System.now();
                teamMiniFeed.Team__c= idTeam;
                teamMiniFeed.User__c= currentTeam.TeamCreatedBy__c;
                teamMiniFeed.Message__c= 'created new team <a href="/apex/TeamsRedirect?id=' + idTeam + '">' + nameTeam + '</a>';
       			insert teamMiniFeed;
       			actionsTaken.add('<div class="identAction"><b>Inserting Team MiniFeed__c:</b> ' + teamMiniFeed + '</div>');
       			this.countFixed++;
			}
			else {
				actionsTaken.add('<span class="goodResult">Team Mini Feed Found</span>');
				this.countOk++;
			}
			/* Validate Owner Id*/
			List<MiniFeed__c> ownerChangeMF = new List<MiniFeed__c>();
			
			List<MiniFeed__Share> newMiniFeedSharing = new List<MiniFeed__Share>();
			Map<Id, MiniFeed__Share> mapMiniFeedSharing = new Map<Id, MiniFeed__Share>();
			for (MiniFeed__Share iterMiniFeed : [select id, ParentId from MiniFeed__Share where UserOrGroupId =: teamSharingId]) {
				mapMiniFeedSharing.put(iterMiniFeed.ParentId, iterMiniFeed);
			}
			
			for (MiniFeed__c iterMiniFeed : [select id, OwnerId from MiniFeed__c where Team__c =:idTeam]) {
				if (iterMiniFeed.ownerId != teamQueueId) {
					iterMiniFeed.ownerId = teamQueueId;
					ownerChangeMF.add(iterMiniFeed);
				}
				if (mapMiniFeedSharing.get(iterMiniFeed.Id) == null) {
					MiniFeed__Share newMiniFeedShare = new MiniFeed__Share();
					newMiniFeedShare.ParentId = iterMiniFeed.Id;
					newMiniFeedShare.UserOrGroupId = teamSharingId;
				    newMiniFeedShare.AccessLevel = 'Read';
				    newMiniFeedShare.RowCause = Schema.MiniFeed__Share.RowCause.Manual;
				    newMiniFeedSharing.add(newMiniFeedShare);	
				}	
			}
			if (newMiniFeedSharing.size() > 0) {
				insert newMiniFeedSharing;
				actionsTaken.add('<span class="badResult">Mini Feed Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing MiniFeed__Share entries:</b> ' + newMiniFeedSharing + '</div>');
       			this.countFixed++;
			}
			if (ownerChangeMF.size() > 0) {
				update ownerChangeMF;
				actionsTaken.add('<span class="badResult">Wrong Mini Feed Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Mini Feed Owner:</b> ' + ownerChangeMF + '</div>');
       			this.countFixed++;
			}
			
			Integer queriesCount = Limits.getQueries();
			if (queriesCount > 85) {
				actionsTaken.add('<span class="badResult">Queries Count CLOSE TO LIMIT : ' + queriesCount + '</span>');
			}
			else {
				actionsTaken.add('<span class="goodResult">Queries Count : ' + queriesCount + '</span>');
			}
			
			/* //////////////////////////////////// */
			/* 	Validate WIKI PAGES OWNER and SHARE */
			/* //////////////////////////////////// */
			List<WikiPage__c> changeOwnerWP = new List<WikiPage__c>();
			
			List<WikiPage__Share> newWikisSharing = new List<WikiPage__Share>();
			Map<Id, WikiPage__Share> mapWikiSharing = new Map<Id, WikiPage__Share>();
			for (WikiPage__Share iterWikiShare : [select id, ParentId from WikiPage__Share where UserOrGroupId =: teamSharingId]) {
				mapWikiSharing.put(iterWikiShare.ParentId, iterWikiShare);
			}
			
			for (WikiPage__c iterWikiPage : [select id, OwnerId from WikiPage__c where team__c =:idTeam]) {
				if (mapWikiSharing.get(iterWikiPage.Id) == null) {
					WikiPage__Share newWikiShare = new WikiPage__Share();
					newWikiShare.ParentId = iterWikiPage.Id;
					newWikiShare.UserOrGroupId = teamSharingId;
				    newWikiShare.AccessLevel = 'Read';
				    newWikiShare.RowCause = Schema.WikiPage__Share.RowCause.Manual;
				    newWikisSharing.add(newWikiShare);
				}
				if(iterWikiPage.OwnerId != WikiQueueId) {
					iterWikiPage.OwnerId = wikiQueueId;	
					changeOwnerWP.add(iterWikiPage);
				}
			}
			if (newWikisSharing.size() > 0) {
				insert newWikisSharing;
				actionsTaken.add('<span class="badResult">Wiki Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing WikiPage__Share entries:</b> ' + newWikisSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerWP.size() > 0) {
				update changeOwnerWP;
				actionsTaken.add('<span class="badResult">Wrong Wiki Page Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Wiki Page Owner:</b> ' + changeOwnerWP + '</div>');
       			this.countFixed++;
			}
			
			/* //////////////////////////////////////////////////// */
			/* 	Validate WIKI PAGES RECENTLY VIEWED OWNER and SHARE */
			/* //////////////////////////////////////////////////// */
			List<WikiRecentlyViewed__c> changeOwnerWRV = new List<WikiRecentlyViewed__c>();
			
			List<WikiRecentlyViewed__Share> newRecentWikiSharing = new List<WikiRecentlyViewed__Share>();
			Map<Id, WikiRecentlyViewed__Share> mapRecentWikiSharing = new Map<Id, WikiRecentlyViewed__Share>();
			for (WikiRecentlyViewed__Share iterRecentWikiShare : [select id, ParentId from WikiRecentlyViewed__Share where UserOrGroupId =: teamSharingId]) {
				mapRecentWikiSharing.put(iterRecentWikiShare.ParentId, iterRecentWikiShare);
			}
			
			for (WikiRecentlyViewed__c iterRecentWikiPage : [select id, OwnerId from WikiRecentlyViewed__c where team__c =:idTeam]) {
				if (mapWikiSharing.get(iterRecentWikiPage.Id) == null) {
					WikiRecentlyViewed__Share newRecentWikiShare = new WikiRecentlyViewed__Share();
					newRecentWikiShare.ParentId = iterRecentWikiPage.Id;
					newRecentWikiShare.UserOrGroupId = teamSharingId;
				    newRecentWikiShare.AccessLevel = 'Read';
				    newRecentWikiShare.RowCause = Schema.WikiRecentlyViewed__Share.RowCause.Manual;
				    newRecentWikiSharing.add(newRecentWikiShare);
				}
				if(iterRecentWikiPage.OwnerId != WikiQueueId) {
					iterRecentWikiPage.OwnerId = wikiQueueId;	
					changeOwnerWRV.add(iterRecentWikiPage);
				}
			}
			if (newRecentWikiSharing.size() > 0) {
				insert newRecentWikiSharing;
				actionsTaken.add('<span class="badResult">Wiki Recently Viewed Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing WikiRecentlyViewed__Share entries:</b> ' + newRecentWikiSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerWRV.size() > 0) {
				update changeOwnerWRV;
				actionsTaken.add('<span class="badResult">Wrong Wiki Recently Viewed Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Wiki Recently Viewed Owner:</b> ' + changeOwnerWRV + '</div>');
       			this.countFixed++;
			}			
			
			/* /////////////////////////////////// */
			/* 	Validate WIKI LINK OWNER and SHARE */
			/* /////////////////////////////////// */
			List<WikiLink__c> changeOwnerWL = new List<WikiLink__c>();
			
			List<WikiLink__Share> newWikiLinkSharing = new List<WikiLink__Share>();
			Map<Id, WikiLink__Share> mapWikiLinkSharing = new Map<Id, WikiLink__Share>();
			for (WikiLink__Share iterWikiLinkShare : [select id, ParentId from WikiLink__Share where UserOrGroupId =: teamSharingId]) {
				mapWikiLinkSharing.put(iterWikiLinkShare.ParentId, iterWikiLinkShare);
			}
			
			for (WikiLink__c iterWikiLink : [select id, OwnerId from WikiLink__c where team__c =:idTeam]) {
				if (mapWikiLinkSharing.get(iterWikiLink.Id) == null) {
					WikiLink__Share newWikiLinkShare = new WikiLink__Share();
					newWikiLinkShare.ParentId = iterWikiLink.Id;
					newWikiLinkShare.UserOrGroupId = teamSharingId;
				    newWikiLinkShare.AccessLevel = 'Read';
				    newWikiLinkShare.RowCause = Schema.WikiLink__Share.RowCause.Manual;
				    newWikiLinkSharing.add(newWikiLinkShare);
				}
				if(iterWikiLink.OwnerId != WikiQueueId) {
					iterWikiLink.OwnerId = wikiQueueId;	
					changeOwnerWL.add(iterWikiLink);
				}
			}
			if (newWikiLinkSharing.size() > 0) {
				insert newWikiLinkSharing;
				actionsTaken.add('<span class="badResult">Wiki Link Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing WikiLink__Share entries:</b> ' + newWikiLinkSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerWL.size() > 0) {
				update changeOwnerWL;
				actionsTaken.add('<span class="badResult">Wrong Wiki Link Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Wiki Link Owner:</b> ' + changeOwnerWL + '</div>');
       			this.countFixed++;
			}
			
			/* //////////////////////////////////////// */
			/* 	Validate FAVORITE WIKIS OWNER and SHARE */
			/* //////////////////////////////////////// */
			List<FavoriteWikis__c> changeOwnerWF = new List<FavoriteWikis__c>();
			
			List<FavoriteWikis__Share> newWikiFavSharing = new List<FavoriteWikis__Share>();
			Map<Id, FavoriteWikis__Share> mapWikiFavSharing = new Map<Id, FavoriteWikis__Share>();
			for (FavoriteWikis__Share iterWikiFavShare : [select id, ParentId from FavoriteWikis__Share where UserOrGroupId =: teamSharingId]) {
				mapWikiFavSharing.put(iterWikiFavShare.ParentId, iterWikiFavShare);
			}
			
			for (FavoriteWikis__c iterWikiFav : [select id, OwnerId from FavoriteWikis__c where team__c =:idTeam]) {
				if (mapWikiFavSharing.get(iterWikiFav.Id) == null) {
					FavoriteWikis__Share newWikiFavShare = new FavoriteWikis__Share();
					newWikiFavShare.ParentId = iterWikiFav.Id;
					newWikiFavShare.UserOrGroupId = teamSharingId;
				    newWikiFavShare.AccessLevel = 'Read';
				    newWikiFavShare.RowCause = Schema.FavoriteWikis__Share.RowCause.Manual;
				    newWikiFavSharing.add(newWikiFavShare);
				}
				if(iterWikiFav.OwnerId != WikiQueueId) {
					iterWikiFav.OwnerId = wikiQueueId;	
					changeOwnerWF.add(iterWikiFav);
				}
			}
			if (newWikiFavSharing.size() > 0) {
				insert newWikiFavSharing;
				actionsTaken.add('<span class="badResult">Favorite Wikis Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing FavoriteWikis__Share entries:</b> ' + newWikiFavSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerWF.size() > 0) {
				update changeOwnerWF;
				actionsTaken.add('<span class="badResult">Wrong Favorite Wikis Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Favorite Wikis Owner:</b> ' + changeOwnerWF + '</div>');
       			this.countFixed++;
			}
			
			
			/* ///////////////////////////// */
			/* Validate WIKI COMMENTS OWNER  */
			/* ///////////////////////////// */
			List<Comment__c> changeOwnerWPC = new List<Comment__c>();
			
			List<Comment__Share> newWikiCommentSharing = new List<Comment__Share>();
			Map<Id, Comment__Share> mapWikiCommentSharing = new Map<Id, Comment__Share>();
			for (Comment__Share iterWikiCommentShare : [select id, ParentId from Comment__Share where UserOrGroupId =: teamSharingId]) {
				mapWikiCommentSharing.put(iterWikiCommentShare.ParentId, iterWikiCommentShare);
			}
			
			for (Comment__c iterWikiPageComment : [select id, OwnerId from Comment__c where ParentWikiPage__c != null and ParentWikiPage__r.team__c =:idTeam]) {
				if (mapWikiCommentSharing.get(iterWikiPageComment.Id) == null) {
					Comment__Share newWikiCommentShare = new Comment__Share();
					newWikiCommentShare.ParentId = iterWikiPageComment.Id;
					newWikiCommentShare.UserOrGroupId = teamSharingId;
				    newWikiCommentShare.AccessLevel = 'Read';
				    newWikiCommentShare.RowCause = Schema.Comment__Share.RowCause.Manual;
				    newWikiCommentSharing.add(newWikiCommentShare);
				}
				if (iterWikiPageComment.OwnerId != wikiQueueId) {
					iterWikiPageComment.OwnerId = wikiQueueId;	
					changeOwnerWPC.add(iterWikiPageComment);
				}
			}
			if (newWikiCommentSharing.size() > 0) {
				insert newWikiCommentSharing;
				actionsTaken.add('<span class="badResult">Wiki Comments Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing Comment__Share entries:</b> ' + newWikiCommentSharing + '</div>');
       			this.countFixed++;
			}
			
			if (changeOwnerWPC.size() > 0) {
				update changeOwnerWPC;
				actionsTaken.add('<span class="badResult">Wrong Wiki Comments Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Wiki Comments Owner:</b> ' + changeOwnerWPC + '</div>');
       			this.countFixed++;
			}
			
			/* ////////////////////////////////////////// */
			/* 	Validate DISCUSSION FORUM OWNER and SHARE */
			/* ////////////////////////////////////////// */
			List<DiscussionForum__c> changeOwnerDF = new List<DiscussionForum__c>();
			
			List<DiscussionForum__Share> newDiscSharing = new List<DiscussionForum__Share>();
			Map<Id, DiscussionForum__Share> mapDiscSharing = new Map<Id, DiscussionForum__Share>();
			for (DiscussionForum__Share iterDiscShare : [select id, ParentId from DiscussionForum__Share where UserOrGroupId =: teamSharingId]) {
				mapDiscSharing.put(iterDiscShare.ParentId, iterDiscShare);
			}
			
			for (DiscussionForum__c iterDiscussionForum : [select id, OwnerId from DiscussionForum__c where team__c =:idTeam]) {
				if (mapDiscSharing.get(iterDiscussionForum.Id) == null) {
					DiscussionForum__Share newDiscShare = new DiscussionForum__Share();
					newDiscShare.ParentId = iterDiscussionForum.Id;
					newDiscShare.UserOrGroupId = teamSharingId;
				    newDiscShare.AccessLevel = 'Read';
				    newDiscShare.RowCause = Schema.DiscussionForum__Share.RowCause.Manual;
				    newDiscSharing.add(newDiscShare);
				}
				if (iterDiscussionForum.OwnerId != discussionQueueId) {
					iterDiscussionForum.OwnerId = discussionQueueId;
					changeOwnerDF.add(iterDiscussionForum);
				}
			}
			if (newDiscSharing.size() > 0) {
				insert newDiscSharing;
				actionsTaken.add('<span class="badResult">Discussion Forum Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing DiscussionForum__Share entries:</b> ' + newDiscSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerDF.size() > 0) {
				update changeOwnerDF;
				actionsTaken.add('<span class="badResult">Wrong Discussion Forum Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Discussion Forum Owner:</b> ' + changeOwnerDF + '</div>');
       			this.countFixed++;
			}
			
			/* ///////////////////////////////////////////// */
			/* 	Validate DISCUSSION MESSAGE OWNER and SHARE  */
			/* ///////////////////////////////////////////// */
			List<DiscussionMessage__c> changeOwnerDM = new List<DiscussionMessage__c>();
			
			List<DiscussionMessage__Share> newDiscMSharing = new List<DiscussionMessage__Share>();
			Map<Id, DiscussionMessage__Share> mapDiscMSharing = new Map<Id, DiscussionMessage__Share>();
			for (DiscussionMessage__Share iterDiscMShare : [select id, ParentId from DiscussionMessage__Share where UserOrGroupId =: teamSharingId]) {
				mapDiscMSharing.put(iterDiscMShare.ParentId, iterDiscMShare);
			}
			
			for (DiscussionMessage__c iterDiscussionMessage : [select id, OwnerId from DiscussionMessage__c where team__c =:idTeam]) {
				if (mapDiscMSharing.get(iterDiscussionMessage.Id) == null) {
					DiscussionMessage__Share newDiscMShare = new DiscussionMessage__Share();
					newDiscMShare.ParentId = iterDiscussionMessage.Id;
					newDiscMShare.UserOrGroupId = teamSharingId;
				    newDiscMShare.AccessLevel = 'Read';
				    newDiscMShare.RowCause = Schema.DiscussionMessage__Share.RowCause.Manual;
				    newDiscMSharing.add(newDiscMShare);
				}
				if (iterDiscussionMessage.OwnerId != discussionQueueId) {
					iterDiscussionMessage.OwnerId = discussionQueueId;	
					changeOwnerDM.add(iterDiscussionMessage);	
				}
			}
			if (newDiscMSharing.size() > 0) {
				insert newDiscMSharing;
				actionsTaken.add('<span class="badResult">Discussion Message Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing DiscussionMessage__Share entries:</b> ' + newDiscMSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerDM.size() > 0) {
				update changeOwnerDM;
				actionsTaken.add('<span class="badResult">Wrong Discussion Message Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Discussion Message Owner:</b> ' + changeOwnerDM + '</div>');
       			this.countFixed++;
			}
			
			/* ////////////////////////////////////////// */
			/* 	Validate DISCUSSION TOPIC OWNER and SHARE */
			/* ////////////////////////////////////////// */
			List<DiscussionTopic__c> changeOwnerDT = new List<DiscussionTopic__c>();
			
			List<DiscussionTopic__Share> newDiscTSharing = new List<DiscussionTopic__Share>();
			Map<Id, DiscussionTopic__Share> mapDiscTSharing = new Map<Id, DiscussionTopic__Share>();
			for (DiscussionTopic__Share iterDiscTShare : [select id, ParentId from DiscussionTopic__Share where UserOrGroupId =: teamSharingId]) {
				mapDiscTSharing.put(iterDiscTShare.ParentId, iterDiscTShare);
			}
			
			for (DiscussionTopic__c iterDiscussionTopic : [select id, OwnerId from DiscussionTopic__c where team__c =:idTeam]) {
				if (mapDiscTSharing.get(iterDiscussionTopic.Id) == null) {
					DiscussionTopic__Share newDiscTShare = new DiscussionTopic__Share();
					newDiscTShare.ParentId = iterDiscussionTopic.Id;
					newDiscTShare.UserOrGroupId = teamSharingId;
				    newDiscTShare.AccessLevel = 'Read';
				    newDiscTShare.RowCause = Schema.DiscussionTopic__Share.RowCause.Manual;
				    newDiscTSharing.add(newDiscTShare);
				}
				if (iterDiscussionTopic.OwnerId != discussionQueueId) {
					iterDiscussionTopic.OwnerId = discussionQueueId;	
					changeOwnerDT.add(iterDiscussionTopic);
				}
			}
			if (newDiscTSharing.size() > 0) {
				insert newDiscTSharing;	
				actionsTaken.add('<span class="badResult">Discussion Topic Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing DiscussionTopic__Share entries:</b> ' + newDiscTSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerDT.size() > 0) {
				update changeOwnerDT;
				actionsTaken.add('<span class="badResult">Wrong Discussion Topic Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Discussion Topic Owner:</b> ' + changeOwnerDT + '</div>');
       			this.countFixed++;
			}
			
			TeamUtil.currentlyExeTrigger = true;
			/* ////////////////////////////////////// */
			/* 	Validate PROJECT TASK OWNER and SHARE */
			/* ////////////////////////////////////// */
			List<ProjectTask__c> changeOwnerPT = new List<ProjectTask__c>();
			
			List<ProjectTask__Share> newTaskSharing = new List<ProjectTask__Share>();
			Map<Id, ProjectTask__Share> mapTaskSharing = new Map<Id, ProjectTask__Share>();
			for (ProjectTask__Share iterTaskShare : [select id, ParentId from ProjectTask__Share where UserOrGroupId =: teamSharingId]) {
				mapTaskSharing.put(iterTaskShare.ParentId, iterTaskShare);
			}
			
			for (ProjectTask__c iterProjectTask : [select id, OwnerId from ProjectTask__c where team__c =:idTeam]) {
				if (mapTaskSharing.get(iterProjectTask.Id) == null) {
					ProjectTask__Share newTaskShare = new ProjectTask__Share();
					newTaskShare.ParentId = iterProjectTask.Id;
					newTaskShare.UserOrGroupId = teamSharingId;
				    newTaskShare.AccessLevel = 'Read';
				    newTaskShare.RowCause = Schema.ProjectTask__Share.RowCause.Manual;
				    newTaskSharing.add(newTaskShare);
				}
				if (iterProjectTask.OwnerId != projectQueueId) {
					iterProjectTask.OwnerId = projectQueueId;	
					changeOwnerPT.add(iterProjectTask);
				}
			}
			if (newTaskSharing.size() > 0) {
				insert newTasksharing;
				actionsTaken.add('<span class="badResult">Project Task Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing ProjectTask__Share entries:</b> ' + newTaskSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerPT.size() > 0) {
				update changeOwnerPT; 
				actionsTaken.add('<span class="badResult">Wrong Project Task Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Project Task Owner:</b> ' + changeOwnerPT + '</div>');
       			this.countFixed++;
			}
			TeamUtil.currentlyExeTrigger = false;
			
			/* ////////////////////////////////////////// */
			/* 	Validate Project Assignee OWNER and Share */
			/* ////////////////////////////////////////// */
			List<ProjectAssignee__c> changeOwnerPA = new List<ProjectAssignee__c>();
			
			List<ProjectAssignee__Share> newAssignSharing = new List<ProjectAssignee__Share>();
			Map<Id, ProjectAssignee__Share> mapAssignSharing = new Map<Id, ProjectAssignee__Share>();
			for (ProjectAssignee__Share iterAssignShare : [select id, ParentId from ProjectAssignee__Share where UserOrGroupId =: teamSharingId]) {
				mapAssignSharing.put(iterAssignShare.ParentId, iterAssignShare);
			}
			
			for (ProjectAssignee__c iterProjectAssignee : [select id, OwnerId from ProjectAssignee__c where team__c =:idTeam]) {
				if (mapAssignSharing.get(iterProjectAssignee.Id) == null) {
					ProjectAssignee__Share newAssignShare = new ProjectAssignee__Share();
					newAssignShare.ParentId = iterProjectAssignee.Id;
					newAssignShare.UserOrGroupId = teamSharingId;
				    newAssignShare.AccessLevel = 'Read';
				    newAssignShare.RowCause = Schema.ProjectAssignee__Share.RowCause.Manual;
				    newAssignSharing.add(newAssignShare);
				}
				if (iterProjectAssignee.OwnerId != projectQueueId) {
					iterProjectAssignee.OwnerId = projectQueueId;	
					changeOwnerPA.add(iterProjectAssignee);
				}
			}
			if (newAssignSharing.size() > 0) {
				insert newAssignSharing;
				actionsTaken.add('<span class="badResult">Project Assignee Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing ProjectAssignee__Share entries:</b> ' + newAssignSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerPA.size() > 0) {
				update changeOwnerPA; 
				actionsTaken.add('<span class="badResult">Wrong Project Assignee Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Project Assignee Owner:</b> ' + changeOwnerPA + '</div>');
       			this.countFixed++;
			}
			
			/* ////////////////////////////////////////// */
			/* 	Validate Project Task Pred OWNER and Share */
			/* ////////////////////////////////////////// */
			List<ProjectTaskPred__c> changeOwnerPTP = new List<ProjectTaskPred__c>();
			
			List<ProjectTaskPred__Share> newTaskPredSharing = new List<ProjectTaskPred__Share>();
			Map<Id, ProjectTaskPred__Share> mapTaskPredSharing = new Map<Id, ProjectTaskPred__Share>();
			for (ProjectTaskPred__Share iterTaskPredShare : [select id, ParentId from ProjectTaskPred__Share where UserOrGroupId =: teamSharingId]) {
				mapTaskPredSharing.put(iterTaskPredShare.ParentId, iterTaskPredShare);
			}
			
			for (ProjectTaskPred__c iterTaskPred : [select id, OwnerId from ProjectTaskPred__c where team__c =:idTeam]) {
				if (mapTaskPredSharing.get(iterTaskPred.Id) == null) {
					ProjectTaskPred__Share newTaskPredShare = new ProjectTaskPred__Share();
					newTaskPredShare.ParentId = iterTaskPred.Id;
					newTaskPredShare.UserOrGroupId = teamSharingId;
				    newTaskPredShare.AccessLevel = 'Read';
				    newTaskPredShare.RowCause = Schema.ProjectTaskPred__Share.RowCause.Manual;
				    newTaskPredSharing.add(newTaskPredShare);
				}
				if (iterTaskPred.OwnerId != projectQueueId) {
					iterTaskPred.OwnerId = projectQueueId;	
					changeOwnerPTP.add(iterTaskPred);
				}
			}
			if (newTaskPredSharing.size() > 0) {
				insert newTaskPredSharing;
				actionsTaken.add('<span class="badResult">Project Task Pred Share Objects Missing</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Inserting Missing ProjectTaskPred__Share entries:</b> ' + newTaskPredSharing + '</div>');
       			this.countFixed++;
			}
			if (changeOwnerPTP.size() > 0) {
				update changeOwnerPTP; 
				actionsTaken.add('<span class="badResult">Wrong Project Task Pred Owner</span>');
				this.countFaild++;
				actionsTaken.add('<div class="identAction"><b>Updating Project Task Pred Owner:</b> ' + changeOwnerPTP + '</div>');
       			this.countFixed++;
			}
			
			actionsTaken.add('<br>');
		}
		return actionsTaken;
	}
	
	/* ****
	This is for internal development use only , so that we can process one team at a time in a faster fashion. 
	the standard flow will process all teams, but if only one team is needed for processing, then passing the id param on the url will do the trick.
	**** */
	public String teamParam = System.currentPageReference().getParameters().get('id');
	
	public void setTeamParam (String teamParam) {
		this.teamParam = teamParam;
	}
	
	public String getTeamParam () {
		return teamParam;
	}
	
	public PageReference processValidation() {
		System.debug('processValidation called.');
		List<Team__c> teamsBeingProcessed;


		/* ****
		This is for internal development use only , so that we can process one team at a time in a faster fashion. 
		the standard flow will process all teams, but if only one team is needed for processing, then passing the id param on the url will do the trick.
		**** */		
		if (teamParam == null) {
			if (this.lastTeamId == null) {
				teamsBeingProcessed = [select id, PublicProfile__c, Name, OwnerId, TeamCreatedBy__c from Team__c order by id2__c asc limit :maxTeamsToProcess];
			} else {
				teamsBeingProcessed = [select id, PublicProfile__c, Name, OwnerId, TeamCreatedBy__c from Team__c where id2__c >: this.lastTeamId order by id2__c asc limit :maxTeamsToProcess];
			}
		}
		else {
			if (this.lastTeamId == null) {
				teamsBeingProcessed = [select id, PublicProfile__c, Name, OwnerId, TeamCreatedBy__c from Team__c where id=: teamParam];	
			}
			else {
				teamsBeingProcessed = null;
			}
		}
		
		if ((teamsBeingProcessed != null) && (teamsBeingProcessed.size() > 0)) {
			String[] r = validateTeams(teamsBeingProcessed);
			
			if (!this.resultsTruncated && (this.results.size() + r.size() < maxLinesInLog - 2)) {
				this.results.addAll(r);
			} else {
				this.resultsTruncated = true;
			}
			
			this.totalRemainingTeams -= teamsBeingProcessed.size();
			this.lastTeamId = teamsBeingProcessed[teamsBeingProcessed.size() - 1].Id;
			
		} else {
			this.totalRemainingTeams = 0;
		}

		if (this.totalRemainingTeams == 0) {
			if (this.resultsTruncated) {
				this.results.add('LOG TRUNCATED...');
			}
			this.results.add('Validation completed: ' + System.Now());
			
			/* Stadistic */
			
			Integer queriesCount = Limits.getQueries();
			String queriesCountRow;
			if (queriesCount > 85) {
				queriesCountRow = '<td>Queries Count :</td><td class="badResult">' + queriesCount + '</td>';
			}
			else {
				queriesCountRow = '<td>Queries Count :</td><td class="goodResult">' + queriesCount + '</td>';
			}
			
			/* Validate Owner Id*/
			List<MiniFeed__c> ownerChangeMF = new List<MiniFeed__c>();
			String organizationGroupId = TeamUtil.getOrganizationGroup().Id;
			List<MiniFeed__Share> newMiniFeedSharing = new List<MiniFeed__Share>();
			Map<Id, MiniFeed__Share> mapMiniFeedSharing = new Map<Id, MiniFeed__Share>();
			for (MiniFeed__Share iterMiniFeed : [select id, ParentId from MiniFeed__Share where UserOrGroupId =:organizationGroupId]) {
				mapMiniFeedSharing.put(iterMiniFeed.ParentId, iterMiniFeed);
			}
			
			for (MiniFeed__c iterMiniFeed : [select id, OwnerId from MiniFeed__c where Team__c = null]) {
				if (mapMiniFeedSharing.get(iterMiniFeed.Id) == null) {
					MiniFeed__Share newMiniFeedShare = new MiniFeed__Share();
					newMiniFeedShare.ParentId = iterMiniFeed.Id;
					newMiniFeedShare.UserOrGroupId = organizationGroupId;
				    newMiniFeedShare.AccessLevel = 'Read';
				    newMiniFeedShare.RowCause = Schema.MiniFeed__Share.RowCause.Manual;
				    newMiniFeedSharing.add(newMiniFeedShare);	
				}	
			}
			if (newMiniFeedSharing.size() > 0) {
				insert newMiniFeedSharing;
				this.results.add('<span class="badResult">Mini Feed Objects Missing</span>');
				this.countFaild++;
				this.results.add('<div class="identAction"><b>Inserting Missing MiniFeed__Share entries:</b> ' + newMiniFeedSharing + '</div>');
       			this.countFixed++;
			}
			
			
			this.results.add('<table class="stadistics"><tr><td class="label">Teams Processed:</td><td><span class="goodResult">' + this.totalTeams + '</span></td></tr><tr><td class="label">Ok Validations:</td><td><span class="goodResult">' + this.countOk + '</span></td></tr><tr><td class="label">Faild Validations:</td><td><span class="badResult">' + this.countFaild + '</span></td></tr><tr><td class="label">Fix Actions:</td><td><span class="badResult">' + this.countFixed + '</span></td></tr></table>');
			
			this.endTime = System.Now().getTime();
			
			/* CALCULATE THE TIME ELAPSED */
			Long elapsedMS = this.endTime - this.startTime;
			Integer countDays = 0;
			Integer countHours = 0;
			Integer countMinutes = 0;
			Integer countSeconds = 0;
			String timeElapsed = '';
			countDays = (Math.floor(elapsedMS / (1000 * 60 * 60 * 24))).intValue();
			if (countDays > 0) {
				timeElapsed += String.valueOf(countDays) + ' days ';
			}
			Long tempDiff = 0;
			tempDiff = elapsedMS - countDays * 1000 * 60 * 60 * 24;
			if (tempDiff > 0) {
				countHours = (Math.floor(tempDiff / (1000 * 60 * 60))).intValue();
				if (countHours > 0) {
					timeElapsed += String.valueOf(countHours) + ' hours ';
				}
				tempDiff = tempDiff - countHours * 1000 * 60 * 60;
				if (tempDiff > 0) {
					countMinutes = (Math.floor(tempDiff / (1000 * 60))).intValue();
					if (countMinutes > 0) {
						timeElapsed += String.valueOf(countMinutes) + ' minutes ';
					}
					tempDiff = tempDiff - countMinutes * 1000 * 60;
					if (tempDiff > 0) {
						countSeconds = (Math.floor(tempDiff / (1000))).intValue();
						if (countSeconds > 0) {
							timeElapsed += String.valueOf(countSeconds) + ' seconds ';
						}
					}
				}
			}
			
			this.results.add('<div class="teamName">Time Elapsed ' + timeElapsed + '</div>');
		}

		return null;
	}
}