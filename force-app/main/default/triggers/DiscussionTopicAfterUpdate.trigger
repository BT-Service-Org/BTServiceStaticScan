trigger DiscussionTopicAfterUpdate on DiscussionTopic__c (after update) {
/*
	for (DiscussionTopic__c thread : Trigger.new) {
		
		   
         List<DiscussionMessage__c> messages = [Select Header__c, Message__c from DiscussionMessage__c
                                        where DiscussionTopic__c =:thread.Id and ParentMessage__c = null
                                        Order By Name];
        
        if (messages.size() > 0)
        {
	        DiscussionMessage__c msg = messages[0];
	        
	        msg.Message__c = thread.FirstMessageText__c;
	        
	        update msg;
        }
                                        
	}
	*/
}