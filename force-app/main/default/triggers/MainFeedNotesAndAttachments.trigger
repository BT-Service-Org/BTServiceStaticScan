trigger MainFeedNotesAndAttachments on Attachment bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        Attachment n = Trigger.new[i];
		        minifeed.add( new MiniFeed__c( Type__c='Attachment',
		                                           User__c=n.CreatedById,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has uploaded an attachment: <a href="' + n.Id + '">' + n.Name + '</a>' ));
		    }
		    insert minifeed;
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}