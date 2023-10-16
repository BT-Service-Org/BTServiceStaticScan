/*
 * Description: This Class is used to run sync of external Project to Custom Project
 * Date: 01-03-2023
 * */
global class Org62ProjectSyncBatch implements Database.Batchable<sObject>,Schedulable {

   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Get Last Modified date from metadata.
        String ModifyFilter = System.Label.Org62_Project_and_Assignment_Sync != null ? System.Label.Org62_Project_and_Assignment_Sync : '1';
        System.debug('ModifyFilter ' +ModifyFilter);
        
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT id,Name__c,pse_Account_c__c,pse_Is_Active_c__c,Project_ID__c,pse_Billing_Type_c__c, pse_Bookings_c__c,pse_Start_Date_c__c, OwnerId__c,ExternalId,RecordTypeId__c,pse_Stage_c__c, ' + 
        'pse_End_Date_c__c,pse_Opportunity_c__c, pse_Project_Manager_c__c,pse_Project_Manager_c__r.Name__c, ProjectManagerUser_c__c,ProjectManagerUser_c__r.Name__c,LastModifiedDate__c,ProjectManagerUser_c__r.ExternalId,pse_Project_Manager_c__r.ExternalId ' +
        'FROM pse_Proj_c__x WHERE LastModifiedDate__c >= LAST_N_DAYS:'+ModifyFilter;
        
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<pse_Proj_c__x> externalProjList) {
        
        // process each batch of project records 
        try {
            Set<Id> opportunityIds = New Set<Id>();
            Set<Id> accountIds = New Set<Id>();
            Set<Id> contactsIds = New Set<Id>();
            Set<Id> userIds = New Set<Id>();
            Map<Id,Id> AcctMap =  new Map <Id, Id>();
            Map<Id,Id> OpportunityMap = new Map<Id,Id>();
            Map<Id,Id> org62ContactMap = new Map<Id,Id>();
            Map<Id,Id> org62UserMap = new Map<Id,Id>();

            for (pse_Proj_c__x projExternal :externalProjList){
                if(projExternal.pse_Opportunity_c__c != null){
                opportunityIds.add(projExternal.pse_Opportunity_c__c);}
                
                if(projExternal.pse_Account_c__c!= null){
                accountIds.add(projExternal.pse_Account_c__c);}
                
                if(projExternal.pse_Project_Manager_c__c !=null){
                contactsIds.add(projExternal.pse_Project_Manager_c__c);}
                
                if(projExternal.ProjectManagerUser_c__c !=null){
                userIds.add(projExternal.ProjectManagerUser_c__c);}
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
        
        
        for (pse_Proj_c__x projExternal :externalProjList)
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
            PSaProj.ProjectManagerUser__c = org62UserMap.get(projExternal.ProjectManagerUser_c__r.ExternalId);
            PsaProj.Start_Date__c = projExternal.pse_Start_Date_c__c;
            PsaProj.Project_Manager_Name__c = projExternal.pse_Project_Manager_c__r.Name__c;
            PsaProj.Project_Manager_Name_User__c = projExternal.ProjectManagerUser_c__r.Name__c;
            PsaProj.Org62_RecordTypeId__c = projExternal.RecordTypeId__c;
            PsaProj.pse_stage__c = projExternal.pse_Stage_c__c;
            PsaProj.Opportunity__c = OpportunityMap.get(projExternal.pse_Opportunity_c__c);
            PsaProj.Org62_Account_Id__c = projExternal.pse_Account_c__c;
            PsaProj.Org62_Opportunity_Id__c = projExternal.pse_Opportunity_c__c;
            
            PSAProjectUpsert.add(PsaProj);
            
        }
        
        Upsert PSAProjectUpsert Org62_Id__c;
          
         
       } catch(Exception e) {
           System.debug(e);
        }
        }
         
    global void finish(Database.BatchableContext BC) {
        Org62ProjectOpportunityAccountSyncBatch OptyAccountSync = new Org62ProjectOpportunityAccountSyncBatch();
        Database.executeBatch(OptyAccountSync,100);
    }

    global void execute(SchedulableContext sc) {
        Org62ProjectSyncBatch cls = new Org62ProjectSyncBatch ();
        Database.executebatch(cls,100);
    }
}