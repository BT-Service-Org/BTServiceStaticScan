public class DiscussionWidgetMostReadController {
	
	public List<DiscussionTopic__c> getMostRead () {

		List<DiscussionTopic__c> mostRead = new List<DiscussionTopic__c>();
		mostRead = [select Id, Subject__c, ViewCount__c, LastViewedDate__c from DiscussionTopic__c order by LastViewedDate__c desc limit 5];
		
		return mostRead;
	}
	
}