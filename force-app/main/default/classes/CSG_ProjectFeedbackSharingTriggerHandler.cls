/**
* @description       : 
* @author            : Shiva Pasumarty
* @group             : 
* @last modified on  : 08-12-2023
* @last modified by  : Shiva Pasumarty
**/

public without sharing class CSG_ProjectFeedbackSharingTriggerHandler {
    
    public static List<CSG_Project_Feedback__Share> createFeedbackSharingRecords(List<CSG_Project_Feedback__c> lstPF, Boolean triggerContextVar) {
        // Collect all the Feedback Ids that were inserted
        Set<Id> FeedbackIds = new Set<Id>();
        for (CSG_Project_Feedback__c objPF : lstPF) {
            FeedbackIds.add(objPF.Id);
        }
        
        // Query the related Feedback records and their Candidate Ids
        Map<Id, CSG_Project_Feedback__c> FeedbackMap = new Map<Id, CSG_Project_Feedback__c>(
            [SELECT Id, Onboarding__r.Candidate__r.IsActive FROM CSG_Project_Feedback__c WHERE Id IN :FeedbackIds AND Onboarding__r.Candidate__r.IsActive=TRUE]
        );
        
        // Collect the list of Candidate users
        Set<Id> candidateIds = new Set<Id>();
        for (CSG_Project_Feedback__c objFP : FeedbackMap.values()) {
            candidateIds.add(objFP.Onboarding__r.Candidate__c);
        }
        
        // Query the list of Candidate users's management hierarchy
        Map<Id,set<id>> UserMgmtmap = new Map<Id,set<id>>();
        for(user u: [SELECT Id, Mgmt_Chain_Hierarchy_Level_02__c,
                     Mgmt_Chain_Hierarchy_Level_03__c,
                     Mgmt_Chain_Hierarchy_Level_04__c,
                     Mgmt_Chain_Hierarchy_Level_05__c,
                     Mgmt_Chain_Hierarchy_Level_06__c,
                     Mgmt_Chain_Hierarchy_Level_07__c,
                     Mgmt_Chain_Hierarchy_Level_08__c,
                     Mgmt_Chain_Hierarchy_Level_09__c,
                     Mgmt_Chain_Hierarchy_Level_10__c,
                     Mgmt_Chain_Hierarchy_Level_11__c,
                     Mgmt_Chain_Hierarchy_Level_12__c FROM User WHERE Id IN :candidateIds]){
                         Set<Id> mgrIds = new Set<Id>();
                         if (u.Mgmt_Chain_Hierarchy_Level_12__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_12__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_11__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_11__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_10__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_10__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_09__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_09__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_08__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_08__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_07__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_07__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_06__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_06__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_05__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_05__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_04__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_04__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_03__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_03__c);
                         }
                         if (u.Mgmt_Chain_Hierarchy_Level_02__c != null) {
                             mgrIds.add(u.Mgmt_Chain_Hierarchy_Level_02__c);
                         }
                         if(mgrIds.size()>0){
                             UserMgmtmap.put(u.id,mgrIds);
                         }
                         
                     }
        
        // Create Share records for hierarchy Users
        List<CSG_Project_Feedback__Share> prjFeedbackShares = new List<CSG_Project_Feedback__Share>();
        for (CSG_Project_Feedback__c objPF : FeedbackMap.values()) {
            if(UserMgmtmap!=null && UserMgmtmap.get(objPF.Onboarding__r.candidate__c)!=null){
                for(id mgIds: UserMgmtmap.get(objPF.Onboarding__r.candidate__c)){
                    prjFeedbackShares.add(new CSG_Project_Feedback__Share(
                        ParentId = objPF.Id, //prjFd ID                  
                        UserOrGroupId = mgIds,//manger ID
                        AccessLevel = 'read',
                        RowCause = Schema.CSG_Project_Feedback__Share.RowCause.Management_Hierarchy__c //Management_Hierarchy  
                    ));
                } 
            }
        }
        
        if(triggerContextVar){
            insertFeedbackShareRecords(prjFeedbackShares);
        }else{
            return prjFeedbackShares;
        }
        return null;
    }
    
    public static void insertFeedbackShareRecords (List<CSG_Project_Feedback__Share> prjFeedbackShares){
        // Insert FeedbackShare records
        if (!prjFeedbackShares.isEmpty()) {
            insert prjFeedbackShares;
        }
    }
}