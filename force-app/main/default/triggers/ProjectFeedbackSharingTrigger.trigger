trigger ProjectFeedbackSharingTrigger on Project_Feedback__c (after insert, after update) {
    Id userId = UserInfo.getUserId();
    
    For (Project_Feedback__c p:Trigger.New){
        if(p.Resource_Name__c != userId){
            ProjectFeedbackSharing.manualShareAll(p.Id, userId);
        }
        
        ProjectFeedbackSharing.manualShareAll(p.Id, p.Project_Manager__c);
    }
}