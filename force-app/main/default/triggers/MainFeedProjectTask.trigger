trigger MainFeedProjectTask on ProjectTask__c (after insert, after update, after delete) {
	
	/**
	* This happens after insert
	*/	
	if(trigger.isInsert){
		
		
	    List<String> teams = new List<String>();
	    for(ProjectTask__c newProject : trigger.new) {
	    		teams.add(newProject.Team__c);	
	    }
	    
	    Map<Id, Team__c> teamMap = new Map<Id, Team__c>([Select Name from Team__c where Id in: teams]);
		
		List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		for(Integer i = 0; i < Trigger.new.size(); i++) {
		
			ProjectTask__c n = Trigger.new[i];

			if(n.Milestone__c){	
			   	minifeed.add( new MiniFeed__c( Type__c='MilestoneNew',
			   											FeedDate__c=System.now(),
	                                           			Team__c=n.Team__c,	 
			                                           	User__c=n.CreatedById,
				                                       	Message__c='created new milestone ' + n.Name + ' in <a href="/apex/TeamsRedirect?id=' + n.Team__c + '">' + teamMap.get(n.Team__c).Name + '</a>' ));
               	               
			} else {
				minifeed.add( new MiniFeed__c( Type__c='TaskNew',
														FeedDate__c=System.now(),
	                                           			Team__c=n.Team__c,
			                                           	User__c=n.CreatedById,
				                                       	Message__c='created new task ' + n.Name + ' in <a href="/apex/TeamsRedirect?id=' + n.Team__c + '">' + teamMap.get(n.Team__c).Name + '</a>' ));            
			}
		}
		
		insert minifeed;
	}	
	
	/**
	* This happens after insert
	*/	
	if(trigger.isUpdate){
	
			List<String> teams = new List<String>();
	    	for(ProjectTask__c newProject : trigger.new) {
	    		teams.add(newProject.Team__c);	
	    	}
	    
	    	Map<Id, Team__c> teamMap = new Map<Id, Team__c>([Select Name from Team__c where Id in: teams]);			
			
			ProjectTask__c[] n = Trigger.new;
			ProjectTask__c[] o = Trigger.old; 
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();    
			for(Integer i = 0; i < Trigger.new.size(); i++){
				
				if(n[i].Milestone__c){
				if(n[i].Percent_Completed__c == 100){	
				    minifeed.add( new MiniFeed__c( Type__c='MilestoneCompleted',
				    										FeedDate__c=System.now(),
	                                           				Team__c=n[i].Team__c,
				                                           	User__c=n[i].LastModifiedById,
				                                           	Message__c='updated milestone ' + n[i].Name + ' to 100% complete in <a href="/apex/TeamsRedirect?id=' + n[i].Team__c + '">' + teamMap.get(n[i].Team__c).Name + '</a>' ));
						
					
				} else {
					minifeed.add( new MiniFeed__c( Type__c='MilestoneEdited',
															FeedDate__c=System.now(),
	                                           				Team__c=n[i].Team__c,
				                                           	User__c=n[i].LastModifiedById,
				                                           	Message__c='updated milestone information ' + n[i].Name + ' in <a href="/apex/TeamsRedirect?id=' + n[i].Team__c + '">' + teamMap.get(n[i].Team__c).Name + '</a>' ));
						
				}			
			}else{	
				if(n[i].Percent_Completed__c == 100){	
					
					
					
					
				    minifeed.add( new MiniFeed__c( Type__c='TaskCompleted',
				    										FeedDate__c=System.now(),
	                                           				Team__c=n[i].Team__c,
				                                           	User__c=n[i].LastModifiedById,
				                                           	Message__c='updated task ' + n[i].Name + ' to 100% complete in <a href="/apex/TeamsRedirect?id=' + n[i].Team__c + '">' + teamMap.get(n[i].Team__c).Name + '</a>' ));
						
					
				} else {
					minifeed.add( new MiniFeed__c( Type__c='TaskEdited',
															FeedDate__c=System.now(),
	                                           				Team__c=n[i].Team__c,
				                                           	User__c=n[i].LastModifiedById,
				                                           	Message__c='updated task information ' + n[i].Name + ' in <a href="/apex/TeamsRedirect?id=' + n[i].Team__c + '">' + teamMap.get(n[i].Team__c).Name + '</a>' ));
						
				}
			}
			
		}

		insert minifeed;	
			
	
	}		
}