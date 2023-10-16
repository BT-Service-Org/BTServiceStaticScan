public class CSG_PrjFdbkSharingTrigger_Handler {
	
    //Method to recalculate the sharing for Feedback Records
    public static void insertSharingRecord (List<CSG_Project_Feedback__c> triggerNew){
        // Create a new list of sharing objects for CSG Project Feedback
            List<CSG_Project_Feedback__Share> feedbackShrs = new List<CSG_Project_Feedback__Share>();
            
            List<CSG_Project_Feedback__c> fdbackList = [SELECT Id, Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_12__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_11__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_10__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_09__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_08__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_07__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_06__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_05__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_04__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_03__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_02__c,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_12__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_11__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_10__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_09__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_08__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_07__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_06__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_05__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_04__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_03__r.isActive,
                                                        Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_02__r.isActive
                                                        from CSG_Project_Feedback__c where Id IN :triggernew AND Onboarding__r.Candidate__r.IsActive=TRUE];
         
            //Map<ID,User> mgmtHierarchy(List<User> userList, Map<Id,User>mgmtMap){
            //Set<Id> mgrs = new Set<Id>();
            
            for (CSG_Project_Feedback__c x : fdbackList){
                Set<Id> mgrs = new Set<Id>();
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_12__c != null && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_12__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_12__c);
                }
                
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_11__c != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_11__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_11__c);
                }

                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_10__c != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_10__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_10__c);
                }

                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_09__c != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_09__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_09__c);
                }
                
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_08__c  != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_08__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_08__c );
                }
                
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_07__c  != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_07__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_07__c );
                }
                
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_06__c  != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_06__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_06__c );
                }
                
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_05__c  != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_05__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_05__c );
                }
                
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_04__c  != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_04__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_04__c );
                }
                
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_03__c  != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_03__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_03__c );
                }
                
                if (x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_02__c  != null  && x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_02__r.isActive) {
                    mgrs.add(x.Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_02__c );
                }
                
                
                //mgrMap.put(x.Id, x)
                
                
                for(Id manager : mgrs){
                    CSG_Project_Feedback__Share mgmt02Shr= new CSG_Project_Feedback__Share();
                    mgmt02Shr.ParentId = x.Id; //prjFd ID                  
                    mgmt02Shr.UserOrGroupId = manager;//manger ID
                    mgmt02Shr.AccessLevel = 'read';
                    mgmt02Shr.RowCause = Schema.CSG_Project_Feedback__Share.RowCause.Management_Hierarchy__c; //Management_Hierarchy
                    feedbackShrs.add(mgmt02Shr);
                    
                }
            }
        insert feedbackShrs;
    }
}