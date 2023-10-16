trigger MainFeedProjectAsignee on ProjectAssignee__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    List<String> idsTask = new List<String>();
		    List<String> idsUser = new List<String>();
		    for (ProjectAssignee__c newAssignee : Trigger.new) {
		    	idsTask.add(newAssignee.ProjectTask__c);
		    	idsUser.add(newAssignee.User__c);
		    }
		    List<ProjectTask__c> ProjectTaskList =[ SELECT Id, Team__c, Team__r.Id, Team__r.Name , Name FROM  ProjectTask__c WHERE Id in: idsTask];
		    List<User> userList =[ SELECT Id, Name FROM  User WHERE Id in: idsUser];
		    
		    System.debug('\n\n ////////////////////////////// \n Trigger.new : ' + Trigger.new + '\n //////////////////////////////////// \n\n');
		    System.debug('\n\n ////////////////////////////// \n ProjectTaskList : ' + ProjectTaskList + '\n //////////////////////////////////// \n\n');
		    
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
				// Must do some auxiliar querys
		        ProjectAssignee__c n = Trigger.new[i];
				
				ProjectTask__c ProjectTask = new ProjectTask__c();
				Boolean findTask = false;
				Integer countTask = 0;
				while (!findTask && countTask < ProjectTaskList.size()) {
					if (ProjectTaskList[countTask].Id == n.ProjectTask__c) {
						findTask = true;
						ProjectTask = ProjectTaskList[countTask];
					}
					else {
						countTask++;
					}	
				}
				System.debug('\n\n ////////////////////////////// \n ProjectTask : ' + ProjectTask + '\n //////////////////////////////////// \n\n');
				
				User currentUser;
				Boolean findUser = false;
				Integer countUser = 0;
				while (!findUser && countUser < userList.size()) {
					if (userList[countUser].Id == n.User__c) {
						findUser = true;
						currentUser	= userList[countUser];
					}
					else {
						countUser++;
					}	
				}
				
				System.debug('\n\n ////////////////////////////// \n userList : ' + userList + '\n //////////////////////////////////// \n\n');
				System.debug('\n\n ////////////////////////////// \n currentUser : ' + currentUser + '\n //////////////////////////////////// \n\n');
		        // Blurb:	    
		        minifeed.add( new MiniFeed__c( Type__c='TaskAssigned',
		        									FeedDate__c=System.now(),
		                                           	Team__c=ProjectTask.Team__c,
		                                           	User__c=n.CreatedById,
		                                           	Message__c='assigned new task ' + ProjectTask.Name + 'to <a href="/apex/PeopleProfileDisplay?id=' + n.User__c + '">' + currentUser.Name +  '</a> in <a href="/apex/TeamsRedirect?id=' + ProjectTask.Team__c + '">' + ProjectTask.Team__r.Name + '</a>'));
			}   
			insert minifeed;
			    
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 				    
}