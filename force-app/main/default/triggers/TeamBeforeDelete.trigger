trigger TeamBeforeDelete on Team__c bulk (before delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
			
		    Integer mySoql = 0;
		    Integer mySoqlLimit = Limits.getLimitQueries();    
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES LIMIT:\n' + mySoqlLimit + '\n ///////////////////////////// \n \n');
		    
		    mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT:\n' + mySoql + '\n ///////////////////////////// \n \n');
		    
		    Team__c[] t = Trigger.old;      
		        
		    //Remove Members from the Team 
		    List<TeamMember__c> members = [SELECT Id FROM TeamMember__c WHERE Team__c in :Trigger.old];
		    delete members;     
			
			mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT members:\n' + mySoql + '\n ///////////////////////////// \n \n');
			
		    //Remove Wiki Pages from the Team 
		    // commenting for now untill we're ready for deleting wiki pages.
		    List<Wikipage__c> pages = [SELECT Id FROM WikiPage__c WHERE Team__c in :Trigger.old];
		    delete pages; 
		    
		    mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT pages:\n' + mySoql + '\n ///////////////////////////// \n \n');
		    
		    //Remove Project2__c
		     List<Project2__c> project2 = [SELECT Id FROM Project2__c WHERE Team__c in :Trigger.old];
		     delete project2;  
		    
		   	mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT project2:\n' + mySoql + '\n ///////////////////////////// \n \n');
		    
		    //Remove BlogEntry__c
		    List<BlogEntry__c> blogs = [SELECT Id FROM BlogEntry__c WHERE Team__c in :Trigger.old];                
		    delete blogs;   
		    
		    mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT blogs:\n' + mySoql + '\n ///////////////////////////// \n \n');  
		   
		    //Remove Bookmark__c
		    List<Bookmark__c> bookmarks = [SELECT Id FROM Bookmark__c WHERE Team__c in :Trigger.old];               
		    delete bookmarks;                  
		    
		    mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT bookmarks:\n' + mySoql + '\n ///////////////////////////// \n \n');
		    
		    //Remove Discussion Forum from the Team 
		    List<DiscussionForum__c> forum = [Select d.Id From DiscussionForum__c d where d.Team__c in :Trigger.old];
		    delete forum;
		    
		    mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT forum:\n' + mySoql + '\n ///////////////////////////// \n \n');
		     
		    //Remove Minifeeds
		    List<MiniFeed__c> minifeeds = [SELECT Id FROM MiniFeed__c WHERE Team__c in :Trigger.old];                     
		    delete minifeeds;   
		    
		    mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT minifeeds:\n' + mySoql + '\n ///////////////////////////// \n \n');
		      
		    //Remove SubTeams
		    List<Team__c> subteams = [SELECT Id FROM Team__c WHERE ParentTeam__c in :Trigger.old];                     
		    delete subteams;
		    
		    mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT subteams:\n' + mySoql + '\n ///////////////////////////// \n \n');
		    
		    
		    List<String> groupsNames = new List<String>();
		    for (Team__c iterTeam : Trigger.old) {
		    	groupsNames.add('Blog' + iterTeam.Id);	
				groupsNames.add('Wiki' + iterTeam.Id);
				groupsNames.add('Discussion' + iterTeam.Id);
				groupsNames.add('Bookmark' + iterTeam.Id);
				groupsNames.add('Project' + iterTeam.Id);
		    }
		    
		    List<Group> groups = [select g.Id, g.Name from Group g where g.Name in:groupsNames]; 
		    delete groups; 	
			
			mySoql = Limits.getQueries();
		    System.debug('\n \n ///////////////////////////////// \n SAVE THIS SOQL QUERIES COUNT groups:\n' + mySoql + '\n ///////////////////////////// \n \n');
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 		    
}