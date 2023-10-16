public class TeamsWidgetRecentDiscussionController {
/*
	Id teamspaceId;
	DiscussionForum__c forum;
	
	public TeamsWidgetRecentDiscussionController() {
		
		teamspaceId = System.currentPageReference().getParameters().get('id');
		
		List<DiscussionForum__c> temp = [SELECT Id
				 				  		 FROM DiscussionForum__c
				 				  		 WHERE Team__c =: teamspaceId];
				   
				   
	    if(temp.size() > 0) {
	    	forum = temp[0];
	    }
	}
	
	public Id getTeamspaceId() {
		return teamspaceId;
	}
	
	public List<DiscussionTopic__c> getRecentDiscussions() {
		
		if(forum == null) return new List<DiscussionTopic__c>();
		
		List<DiscussionTopic__c> threads = [SELECT Subject__c
											 FROM DiscussionTopic__c
											 WHERE DiscussionForum__c =: forum.Id
											 ORDER BY LastPostDate__c DESC
											 LIMIT 5];
		
		return threads;
	}
*/
}