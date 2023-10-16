/*
* Description: This Class is used to run sync of Offering Contribution.
* Date: 04-14-2023
* */
global class Org62OfferingContributionSyncBatch implements Database.Batchable<sObject>,Schedulable {

   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Get Last Modified date from metadata.
        String ModifyFilter = System.Label.Org62_Project_and_Assignment_Sync != null ? System.Label.Org62_Project_and_Assignment_Sync : '1';
        
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT id,Name__c,ExternalId, ' + 
        'LastModifiedDate__c,Services_Opportunity__c,Offering_Family__c,Offering__c,Work_Units__c ' +
        'FROM Practice_Contribution_c__x WHERE LastModifiedDate__c >= LAST_N_DAYS:'+ModifyFilter;
        
        
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Practice_Contribution_c__x> externalOfferingContributionList) {
        
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

            for (Practice_Contribution_c__x OffrngContr :externalOfferingContributionList){
                opportunityIds.add(OffrngContr.Services_Opportunity__c);
                
            }

           
        for (Opportunity opty :[SELECT Id,Org62_Id__c FROM Opportunity WHERE Org62_Id__c IN :opportunityIds]){
            
            OpportunityMap.put(opty.Org62_Id__c, opty.Id);
        }
        
       
        List<Practice_Contribution__c> PSAOfferingContributionUpsert = new List<Practice_Contribution__c>();
        
        
        for (Practice_Contribution_c__x offerngContrExternal :externalOfferingContributionList)
        {
            Practice_Contribution__c PsaOffrngContr = new Practice_Contribution__c();
            
            PsaOffrngContr.Name = offerngContrExternal.Name__c;
			PsaOffrngContr.Org62_Id__c = offerngContrExternal.ExternalId;
 			PsaOffrngContr.Offering__c = offerngContrExternal.Offering__c;
            PsaOffrngContr.Offering_Family__c = offerngContrExternal.Offering_Family__c;
            PsaOffrngContr.Opportunity__c = OpportunityMap.get(offerngContrExternal.Services_Opportunity__c);
            PsaOffrngContr.Org62_Opportunity_Id__c = offerngContrExternal.Services_Opportunity__c;
            PsaOffrngContr.Work_Units__c = offerngContrExternal.Work_Units__c;
            PSAOfferingContributionUpsert.add(PsaOffrngContr);
            
        }
       
             Database.upsert(PSAOfferingContributionUpsert, Practice_Contribution__c.Fields.Org62_Id__c, false) ;
          
         
       } catch(Exception e) {
           System.debug(e);
        }
        }
         
    global void finish(Database.BatchableContext BC) {
        Org62OCOpportunitySyncBatch ocOptySync = new Org62OCOpportunitySyncBatch();
        Database.executeBatch(ocOptySync);
    }

    global void execute(SchedulableContext sc) {
        Org62OfferingContributionSyncBatch cls = new Org62OfferingContributionSyncBatch ();
        Database.executebatch(cls);
    }
}