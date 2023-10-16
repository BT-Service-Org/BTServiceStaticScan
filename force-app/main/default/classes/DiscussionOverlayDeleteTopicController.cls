public without sharing class  DiscussionOverlayDeleteTopicController {
	
	public DiscussionOverlayDeleteTopicController (){
	
	}
	String topicId = '';
	
	public String getTopicId() {	
		return topicId;
	}
	
	public void setTopicId(String tID) {	
		topicId = tID;
	}
	
	
	public void deleteTopic(){
		
		DiscussionTopic__c topicToDelete = [Select Id FROM DiscussionTopic__c where Id =: topicId];		
		delete topicToDelete;
		
	}
}