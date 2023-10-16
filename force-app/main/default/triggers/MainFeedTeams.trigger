trigger MainFeedTeams on Team__c (after update, after delete) {
    
    /**
    * This happens after Update
    */  
    if(trigger.isUpdate){

    List<MiniFeed__c> minifeed = new List<MiniFeed__c>();

        for(Integer i = 0; i < Trigger.old.size(); i++) {
    
            Team__c o = Trigger.old[i];
            Team__c n = Trigger.new[i];
    
            // Blurb:
            String updatedData = '';
            
            if(o.Name != n.Name){ updatedData += ' Team name';  }
            if(o.Description__c != n.Description__c){ updatedData += ' Team Description';  }
            
            if((o.Name != n.Name) || (o.Description__c != n.Description__c)){
                updatedData = ' in ';
            }
            
            if(updatedData != '')
            	minifeed.add( new MiniFeed__c( Type__c='TeamEdit',
                                            FeedDate__c=System.now(),
                                            Team__c=n.Id,
                                           	User__c=UserInfo.getUserId(),
                                           	Message__c=' updated ' + updatedData + '<a href="/apex/TeamsRedirect?id=' + n.Id + '">' + n.Name + '</a>'));

        }
    
        insert minifeed;

    }
    
    /**
    * This happens after Delete
    */      
    if(trigger.isDelete){
        if (!TeamUtil.currentlyExeTrigger) {
			try {	
				
		        List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    
		        for(Integer i = 0; i < Trigger.old.size(); i++) {
		    
		            Team__c o = Trigger.old[i];
		    
		            // Blurb:
		            minifeed.add( new MiniFeed__c( Type__c='TeamDelete',
		                                            FeedDate__c=System.now(),
		                                               User__c=UserInfo.getUserId(),
		                                               Message__c=' deleted team ' + o.Name));
		        }
		  		insert minifeed;
		  	} finally {
            	TeamUtil.currentlyExeTrigger = false;
			}
		}		
    }   
}