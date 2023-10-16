/**
* @description       : 
* @author            : Shiva Pasumarty
* @group             : 
* @last modified on  : 09-04-2023
* @last modified by  : Shiva Pasumarty
**/

global class CSG_BatchtoCreateFeedbackShareRecords implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<CSG_Project_Feedback__c> ListFeedbackRecordswithNoShareRecords = new List<CSG_Project_Feedback__c>();
        Set<Id> FeedbackIdswithnoShareRecords = new Set<Id>();
        List<CSG_Project_Feedback__c> listCSGPF = new List<CSG_Project_Feedback__c>();
        for(CSG_Project_Feedback__c objCSGPF : [SELECT Id, Onboarding__r.Candidate__r.IsActive, (Select Id from Shares where rowcause='Management_Hierarchy__c') FROM CSG_Project_Feedback__c WHERE Onboarding__r.Candidate__r.IsActive=TRUE]){   
            if(objCSGPF.shares.size()<1) {
                ListFeedbackRecordswithNoShareRecords.add(objCSGPF);
            }   
        }
        String query = 'SELECT Id, Onboarding__r.Candidate__r.IsActive, Name FROM CSG_Project_Feedback__c where Id IN:ListFeedbackRecordswithNoShareRecords';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,  List<CSG_Project_Feedback__c> scope) {     
        
        List<CSG_Project_Feedback__Share> ListprjFeedbackShares = CSG_ProjectFeedbackSharingTriggerHandler.createFeedbackSharingRecords(scope, false);
        
        Database.SaveResult [] insertResult = Database.insert(ListprjFeedbackShares, false);
        
    }
    global void finish(Database.BatchableContext BC) {
        
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors,
                          a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
                          a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        
    }   
}