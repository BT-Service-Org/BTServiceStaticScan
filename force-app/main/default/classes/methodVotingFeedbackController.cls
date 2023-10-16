public with sharing class methodVotingFeedbackController{
    
    @AuraEnabled
    public static void createFeedbackRecord(String methodRecordId,String feedbackMessage){
        Feedback_for_Method__c feedbackRecord;    
        try{
            feedbackRecord = [select id,Feedback__c,Method__c,Feedback_By__c from Feedback_for_Method__c where Method__c=:methodRecordId and Feedback_By__c=:UserInfo.getUserId() LIMIT 1];
        }
        catch(QueryException e){
            System.debug('Error is ' + e);
        }
        if(feedbackRecord!=Null){
            String s = feedbackRecord.Feedback__c;
            System.debug(s+'     '+feedbackMessage);
            feedbackRecord.Feedback__c = s+ '<br/>' + feedbackMessage;
            update feedbackRecord;
        }
        else{
            Feedback_for_Method__c feedbackInstance = new Feedback_for_Method__c();
            feedbackInstance.Method__c = methodRecordId;
            feedbackInstance.Feedback__c = feedbackMessage;
            feedbackInstance.Feedback_By__c =  UserInfo.getUserId();
            insert feedbackInstance;
        }
    }
    
    
    @AuraEnabled
    public static void createVoteRecord(String methodRecordId,String voteType){
        list<Vote_for_Method__c> voteRecords = [select id,Vote_Type__c,Method__c,Voted_by__c from Vote_for_Method__c where Method__c=:methodRecordId and Voted_by__c=:UserInfo.getUserId()
                                                LIMIT 1];
        if (!voteRecords.isEmpty()) {
            Vote_for_Method__c voteInstance = new Vote_for_Method__c(id=voteRecords[0].id);
            voteInstance.Vote_Type__c = voteType;
            update voteInstance;         
        }
        else{
            Vote_for_Method__c voteInstance = new Vote_for_Method__c();
            voteInstance.Method__c = methodRecordId;
            voteInstance.Vote_Type__c = voteType;
            voteInstance.Voted_by__c = UserInfo.getUserId();
            insert voteInstance;
        }
    }
    
    @AuraEnabled
    public static list<Vote_for_Method__c> existingVoteRecord(String methodRecordId){
        string userId = UserInfo.getUserId();
        list<Vote_for_Method__c> voteRecords = [select id,Vote_Type__c,Method__c,Voted_by__c from Vote_for_Method__c where Method__c=:methodRecordId and Voted_by__c=:userId
                                                LIMIT 1];
        return voteRecords;
    }
}