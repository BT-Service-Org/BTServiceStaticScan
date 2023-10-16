/**
* @author: Rohan Saxena
* @description: This is a handler class for QuestionTrigger
*/
public with sharing class QuestionTriggerHandler {
   public static void shareQuestionwithLeaders(List<Question__c> newlist){
    try{
    set<Id> communityId = new set<Id> ();
    for(Question__c question: newlist){
        communityId.add(question.Community__c);
    }
    List<Contribution_Team__c> lstCT= [SELECT Id,Community__c,psc_Team_Member__c,RecordTypeId,psc_Role__c,Community_Owner__c from Contribution_Team__c WHERE 
                                        RecordTypeId =:ContributionTeamTriggerHandler.COMMUNITY_RECORD_TYPE AND 
                                        psc_Role__c=: ContributionTeamTriggerHandler.LEADER AND 
                                        psc_Team_Member__c != null AND
                                        Community__c =: communityId];
        if(!lstCT.isEmpty()){
            ContributionTeamTriggerHandler.shareQuestionwithLeaders(lstCT);
        }

   }
catch(Exception ex){
    throw new PSCException(ex.getMessage());
}
   }
}