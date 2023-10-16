trigger MainFeedWiki on WikiPage__c (after insert, after update) {
    /**
    * This happens after insert
    */
    
    if(trigger.isInsert){
    
      	List<String> teams = new List<String>();
	    for(WikiPage__c newWiki : trigger.new) {
	    		teams.add(newWiki.Team__c);	
	    }
	    
	    Map<Id, Team__c> teamMap = new Map<Id, Team__c>([Select Name from Team__c where Id in: teams]);      	
      
		WikiPage__c[] n = Trigger.new;
		
    	List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
        for(Integer i = 0; i < Trigger.new.size(); i++) {
        
            minifeed.add( new MiniFeed__c( Type__c='WikiNewPage',
                                            FeedDate__c=System.now(),
                                            Team__c=n[i].Team__c,
                                            User__c=n[i].CreatedById,
                                            Message__c='created a new wiki page <a href="/apex/WikiPage?idWP=' + n[i].Id + '">' + n[i].Name + '</a> in <a href="/apex/TeamsRedirect?id=' + n[i].Team__c + '">' + teamMap.get(n[i].Team__c).Name + '</a>'));
         }        
        
        insert minifeed;
    }   
    
    /**
    * 
    */
    
    if(trigger.isUpdate){
    
        List<String> teams = new List<String>();
	    for(WikiPage__c newWiki : trigger.new) {
	    		teams.add(newWiki.Team__c);	
	    }
	    
	    Map<Id, Team__c> teamMap = new Map<Id, Team__c>([Select Name from Team__c where Id in: teams]);      	
      
    	List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
    	    	
		WikiPage__c[] n = Trigger.new;
		WikiPage__c[] o = Trigger.old;
    
        for(Integer i = 0; i < Trigger.new.size(); i++) {
    
          
        	// Blurb:
        	minifeed.add( new MiniFeed__c( 	Type__c = 'WikiEditPage',
                                            FeedDate__c = System.now(),
                                            Team__c = n[i].Team__c,
                                            User__c = n[i].CreatedById,
                                            Message__c = 'updated wiki page <a href="/apex/WikiPage?idWP=' + n[i].Id + '">' + n[i].Name + '</a> in <a href="/apex/TeamsRedirect?id=' + n[i].Team__c + '">' + teamMap.get(n[i].Team__c).Name + '</a>'));
        }        
        
        insert minifeed;
    }   
}