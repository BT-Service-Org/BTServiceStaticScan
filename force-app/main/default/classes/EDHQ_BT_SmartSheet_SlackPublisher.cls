public with sharing class EDHQ_BT_SmartSheet_SlackPublisher {
    
    @InvocableMethod(label='Post Message to Slack')
    public static void SlackMsgHttpPostCallout(List<PSA_Project__c> psaProjectList) {
        EDHQ_BT_SmartSheet_SlackPublisher.sendSuccessMessage(psaProjectList);
    }

    public static void sendSuccessMessage(List<PSA_Project__c> psaProjectListId){
        List<Project_Assignment__c> assignments = [SELECT Id,Resource__c,Project_Role__c, Project_Name__c, PSA_Project__c, PSA_Project__r.Name, PSA_Project__r.SmartSheet_Link__c, PSA_Project__r.Org62_Id__c  
                                                   FROM Project_Assignment__c 
                                                   WHERE PSA_Project__c = :psaProjectListId[0].Id];

        MTH_SlackAppMessenger messenger = new MTH_SlackAppMessenger();
        messenger.sendSmartsheetMessages(assignments);
        
    
    }
    
}