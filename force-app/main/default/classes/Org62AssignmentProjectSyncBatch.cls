/*
* Description: This Class is used to run sync of Assignment's Project
* Date: 01-03-2023
* */
global class Org62AssignmentProjectSyncBatch implements Database.Batchable<sObject> {


global Database.QueryLocator start(Database.BatchableContext BC) {
// collect the batches of records or objects to be passed to execute

String query = 'select Id, Org62_Project_Id__c '+
'from Project_Assignment__c where PSA_Project__c = \'\'';

return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<Project_Assignment__c> assignmentList) {

// process each batch of project records 
try {
    Map<Id,Id> assignmentWithoutProject = new Map <Id,Id>();
    Set<Id> opportunityIds = New Set<Id>();
    Set<Id> accountIds = New Set<Id>();
    Set<Id> contactsIds = New Set<Id>();
    Set<Id> userIds = New Set<Id>();
    Map<Id,Id> AcctMap =  new Map <Id, Id>();
    Map<Id,Id> OpportunityMap = new Map<Id,Id>();
    Map<Id,Id> org62ContactMap = new Map<Id,Id>();
    Map<Id,Id> org62UserMap = new Map<Id,Id>();
    for (Project_Assignment__c asgmnt :assignmentList)
{
    if (!(assignmentWithoutProject.containsKey(asgmnt.Org62_Project_Id__c)))
        assignmentWithoutProject.put(asgmnt.Org62_Project_Id__c,asgmnt.Id);
        
}
List<pse_Proj_c__x> org62ProjectList = [Select id,pse_Account_c__c,pse_Is_Active_c__c,pse_Billing_Type_c__c, pse_Bookings_c__c,pse_Start_Date_c__c, OwnerId__c,ExternalId, 
                                        pse_End_Date_c__c,pse_Opportunity_c__c, pse_Project_Manager_c__c,pse_Project_Manager_c__r.Name__c, ProjectManagerUser_c__c,ProjectManagerUser_c__r.Name__c,LastModifiedDate__c 
                                        from pse_Proj_c__x 
                                        where
                                        ExternalId in :assignmentWithoutProject.keySet() 
                                        ];

                                        for (pse_Proj_c__x projExternal :org62ProjectList){
                                        opportunityIds.add(projExternal.pse_Opportunity_c__c);
                                        accountIds.add(projExternal.pse_Account_c__c);
                                        contactsIds.add(projExternal.pse_Project_Manager_c__c);
                                        userIds.add(projExternal.ProjectManagerUser_c__c);
                                    }
    for (Account b: [select Id,Org62_Id__c from Account WHERE Org62_Id__c IN :accountIds])
                                    {
                                        AcctMap.put(b.Org62_Id__c,b.Id);
                                    }
                                    
                                    for (Opportunity opty :[SELECT Id,Org62_Id__c FROM Opportunity WHERE Org62_Id__c IN :opportunityIds]){
                                        
                                        OpportunityMap.put(opty.Org62_Id__c, opty.Id);
                                    }
                                    
                                    for(Contact con :[SELECT Id,Org62_Contact_ID__c from Contact WHERE Org62_Contact_ID__c IN :contactsIds ]){
                                            org62ContactMap.put(con.Org62_Contact_ID__c,con.Id);
                                    }
                                    
                                    for(User usr :[SELECT Id,Org62Id__c from User WHERE Org62Id__c IN :userIds]){
                                            org62UserMap.put(usr.Org62Id__c,usr.Id);
                                    }
                                    
                                    List<PSA_Project__c> PSAProjectUpsert = new List<PSA_Project__c>();
                                    
                                    
                                    for (pse_Proj_c__x projExternal :org62ProjectList)
                                    {
                                        System.debug('In the loop');
                                        
                                        PSA_Project__c PsaProj = new PSA_Project__c();
                                        
                                        PsaProj.Name = projExternal.Name__c;
                                        PsaProj.Account__c = AcctMap.get(projExternal.pse_Account_c__c);
                                        PsaProj.Active__c = projExternal.pse_Is_Active_c__c;
                                        PsaProj.Billing_Type__c =projExternal.pse_Billing_Type_c__c;
                                        PsaProj.Bookings__c = projExternal.pse_Bookings_c__c;
                                        PsaProj.End_Date__c = projExternal.pse_End_Date_c__c;
                                        PsaProj.Org62_Id__c = projExternal.ExternalId;
                                        PsaProj.Org62_Project_ID__c = projExternal.Project_ID__c;
                                        PSaProj.Project_Manager__c = org62ContactMap.get(projExternal.pse_Project_Manager_c__r.ExternalId);
                                        // PSaProj.Project_Setup_Status__c = projExternal.
                                        PSaProj.ProjectManagerUser__c = org62UserMap.get(projExternal.ProjectManagerUser_c__r.ExternalId);
                                        //  PSaProj.Regional_Services_Manager__c = projExternal.
                                        PsaProj.Start_Date__c = projExternal.pse_Start_Date_c__c;
                                        PsaProj.Project_Manager_Name__c = projExternal.pse_Project_Manager_c__r.Name__c;
                                        PsaProj.Project_Manager_Name_User__c = projExternal.ProjectManagerUser_c__r.Name__c;
                                        PsaProj.Opportunity__c = OpportunityMap.get(projExternal.pse_Opportunity_c__c);
                                        PsaProj.Org62_Account_Id__c = projExternal.pse_Account_c__c;
                                        PsaProj.Org62_Opportunity_Id__c = projExternal.pse_Opportunity_c__c;
                                        
                                        PSAProjectUpsert.add(PsaProj);
                                        
                                    }
                                    
                                    Upsert PSAProjectUpsert Org62_Id__c;                                  
    // ProjectMethodCalculationsBatchHandler.processMethodforProjectRecCreation(projIds,extProjList);
    
} catch(Exception e) {
    System.debug(e);
}
}
    
global void finish(Database.BatchableContext BC) {
Org62ProjectOpportunityAccountSyncBatch OptyAccountSync = new Org62ProjectOpportunityAccountSyncBatch();
//OptySync.execute();
Database.executeBatch(OptyAccountSync);
}
}