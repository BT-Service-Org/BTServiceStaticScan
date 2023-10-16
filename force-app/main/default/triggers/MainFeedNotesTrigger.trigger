trigger MainFeedNotesTrigger on Note bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
		  	
		  	List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
			for(Integer i = 0; i < Trigger.new.size(); i++) {
		        Note n = Trigger.new[i];
		    	// We need to:
		        minifeed.add( new MiniFeed__c( Type__c='Note',
		                                       User__c=n.CreatedById,
		                                       Message__c='has made a Note: <a href="' + n.Id + '">' + n.Title + '</a>' ));
		    }
		    insert minifeed;
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}    
}