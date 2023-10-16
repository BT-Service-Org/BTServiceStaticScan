/*
 * Description: This Class is used to run Sync of External Assignment to Project Assignment 
 * Date: 01-03-2023
 * */
global class Org62AssignmentSyncBatch implements Database.Batchable<sObject>,Schedulable {

   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Get Last Modified date from metadata.
        String ModifyFilter = System.Label.Org62_Project_and_Assignment_Sync != null ? System.Label.Org62_Project_and_Assignment_Sync : '1';
        System.debug('ModifyFilter ' +ModifyFilter);
        // collect the batches of records or objects to be passed to execute
        String query = 'Select id,pse_Billable_Hours_Submitted_c__c,pse_Description_c__c,pse_End_Date_c__c,Name__c,Project_Name_c__c,Project_Region_c__c,pse_Role_c__c, '+
        'pse_Project_c__c,pse_Resource_c__c,pse_Start_Date_c__c,pse_Status_c__c,ExternalId,pse_Project_c__r.ExternalId,pse_Resource_c__r.ExternalId,pse_Resource_c__r.Email__c,pse_Scheduled_Days_c__c,pse_Scheduled_Hours_c__c '+
        'FROM pse_Assignment_c__x WHERE LastModifiedDate__c >= LAST_N_DAYS:'+ModifyFilter;   
      
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<pse_Assignment_c__x> externalAssignmentList) {
        
        // process each batch of project records 
        try {
          
            Set<Id> contactsIds = New Set<Id>();
            Set<Id> projectIds = New Set<Id>();
            Map<Id,Id> AcctMap =  new Map <Id, Id>();
            Map<Id,Id> org62ContactMap = new Map<Id,Id>();
            Map<Id,Id> org62ProjectMap = new Map<Id,Id>();
            Map<String,Id> emailToOrg62IdMap = new Map<String,Id>();

            for (pse_Assignment_c__x asgmntExternal :externalAssignmentList){
                if(asgmntExternal.pse_Resource_c__c != null){
                contactsIds.add(asgmntExternal.pse_Resource_c__c);
                }
                if(asgmntExternal.pse_Project_c__c != null){
                projectIds.add(asgmntExternal.pse_Project_c__c);
                }
                emailToOrg62IdMap.put(asgmntExternal.pse_Resource_c__r.Email__c, asgmntExternal.pse_Resource_c__r.ExternalId);
            }
            
        for(Contact con :[SELECT Id,Org62_Contact_ID__c from Contact WHERE Org62_Contact_ID__c IN :contactsIds ]){
             org62ContactMap.put(con.Org62_Contact_ID__c,con.Id);
        }
        
        for(PSA_Project__c proj :[select Id,Org62_Id__c from PSA_Project__c WHERE Org62_Id__c IN :projectIds]){
            org62ProjectMap.put(proj.Org62_Id__c,proj.Id);
        }
        
        List<Project_Assignment__c> psaAssignmentUpsert = new List<Project_Assignment__c>();
        Set<String> contactsEmailListToUpdate = new Set<String>();
        
        //Fetching all the contacts having blank resource org62 id
        for (pse_Assignment_c__x assignmentExternal :externalAssignmentList)
        {
            if(org62ContactMap.get(assignmentExternal.pse_Resource_c__r.ExternalId)==null)
            {
                contactsEmailListToUpdate.add(assignmentExternal.pse_Resource_c__r.Email__c);
            }            
        }

        List<Contact> contactsToUpdate = [SELECT id,Org62_Contact_ID__c,email from Contact where Email IN:contactsEmailListToUpdate];

        //updating org62 id of contact
        for(Contact conRec: contactsToUpdate)
        {
            if(emailToOrg62IdMap.get(conRec.email)!=null)
            {
                conRec.Org62_Contact_ID__c = emailToOrg62IdMap.get(conRec.email);
                org62ContactMap.put(conRec.Org62_Contact_ID__c, conRec.Id);
            }
        }
        
        for (pse_Assignment_c__x assignmentExternal :externalAssignmentList)
        {            
            Project_Assignment__c psaAssignment = new Project_Assignment__c();
            
            psaAssignment.Billable_Hours_Submitted__c = assignmentExternal.pse_Billable_Hours_Submitted_c__c;
            psaAssignment.Description__c = assignmentExternal.pse_Description_c__c;
            psaAssignment.End_Date__c =assignmentExternal.pse_End_Date_c__c;
            psaAssignment.Name = assignmentExternal.Name__c;
            psaAssignment.Project_Name__c = assignmentExternal.Project_Name_c__c;
            psaAssignment.Project_Region__c = assignmentExternal.Project_Region_c__c;
            psaAssignment.Start_Date__c = assignmentExternal.pse_Start_Date_c__c;
            psaAssignment.PSA_Project__c = org62ProjectMap.get(assignmentExternal.pse_Project_c__r.ExternalId);
            psaAssignment.Status__c = assignmentExternal.pse_Status_c__c;
            psaAssignment.Scheduled_Hours__c = assignmentExternal.pse_Scheduled_Hours_c__c;
            psaAssignment.Scheduled_Days__c = assignmentExternal.pse_Scheduled_Days_c__c ;
            psaAssignment.Project_Role__c = assignmentExternal.pse_Role_c__c ;
            psaAssignment.Org62_Id__c = assignmentExternal.ExternalId;
            psaAssignment.Org62_Project_Id__c = assignmentExternal.pse_Project_c__r.ExternalId;
            psaAssignment.Resource__c = org62ContactMap.get(assignmentExternal.pse_Resource_c__r.ExternalId);       
            psaAssignmentUpsert.add(psaAssignment);
        }

        if(contactsToUpdate.size()>0)
        {
            Database.update(contactsToUpdate,false);
        }
        if(psaAssignmentUpsert.size()>0)
        {
            Database.upsert(psaAssignmentUpsert, Project_Assignment__c.Fields.Org62_Id__c, false);
        }   
         
       } catch(Exception e) {
           System.debug(e);
        }
        }
         
    global void finish(Database.BatchableContext BC) {
       Org62AssignmentProjectSyncBatch projectSync = new Org62AssignmentProjectSyncBatch();
        Database.executeBatch(projectSync,100);
    }

    global void execute(SchedulableContext sc) {
        Org62AssignmentSyncBatch cls = new Org62AssignmentSyncBatch ();
        Database.executebatch(cls,100);
    }
}