trigger MainFeedBlogs on BlogEntry__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			/**
			* This happens after insert
			*/	
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
			
			List<String> idsTeam = new List<String>();
			for (BlogEntry__c iterBlog : Trigger.new) {
				idsTeam.add(iterBlog.team__c);	
			}
			
			List<Team__c> teamList = [select Name, Id from Team__c where Id in: idsTeam];
			
			for(Integer i = 0; i < Trigger.new.size(); i++) {
		
		        BlogEntry__c n = Trigger.new[i];
		        
		        if(n.PublishedDate__c != null){ 
					Team__c Team;
					Boolean findTeam = false;
					Integer countTeam = 0;
					while (!findTeam && countTeam < teamList.size()) {
						if (teamList[countTeam].Id == n.Team__c) {
							findTeam = true;
							Team = teamList[countTeam];	
						}
						countTeam++;
					}
			        // Blurb:
			        minifeed.add( new MiniFeed__c( Type__c='BlogPublished',
			                                           User__c=n.PostedBy__c,
			                                           FeedDate__c=n.PublishedDate__c,
			                                           Team__c=n.Team__c,
			                                           Message__c='created new blog <a href="/apex/BlogDetails?id=' + n.Id +'"/>' + n.Name + '</a> in <a href="/apex/TeamsRedirect?id=' + n.Team__c + '">' + Team.Name + '</a>'));
		    
		        }
		    }
		    if(minifeed.size() > 0) { 
		    	insert minifeed; 
		    }
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}