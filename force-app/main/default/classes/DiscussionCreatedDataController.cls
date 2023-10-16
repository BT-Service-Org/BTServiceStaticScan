public class DiscussionCreatedDataController {
	
	public void updateData () {
		
		/*List<DiscussionMessage__c> messageList = [select Id, CreatedById, CreatedDate, PostedBy__c, PostedDate__c from DiscussionMessage__c];
		for (DiscussionMessage__c item: messageList) {
				item.PostedBy__c = item.CreatedById;
				item.PostedDate__c = item.CreatedDate; 
		}
		update messageList;
		
		List<DiscussionTopic__c> topicList = [select Id, CreatedById, CreatedDate, PostedBy__c, PostedDate__c from DiscussionTopic__c];
		for (DiscussionTopic__c item: topicList) {
				item.PostedBy__c = item.CreatedById;
				item.PostedDate__c = item.CreatedDate; 
		}
		update topicList;
		*/
	}
}