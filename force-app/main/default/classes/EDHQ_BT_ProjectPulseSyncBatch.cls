/**
 * @description Batch job to mirror Project Pulse records from org62 external object
 */
global class EDHQ_BT_ProjectPulseSyncBatch implements Database.Batchable<sObject>,Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC){

        //Get Last Modified date from metadata.
        String modifyFilter = System.Label.Org62_Project_and_Assignment_Sync != null ? System.Label.Org62_Project_and_Assignment_Sync : '1';
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT id,externalId,Name__c,Methodology_Used_c__c,Reason_for_Other__c,Overall_Health_c__c,Opportunity_Name_c__r.ExternalId,Opportunity_Name_c__r.RecordTypeId__r.Name__c,Project_c__r.ExternalId,Last_Status_Date_c__c FROM Project_Health_Check_c__x WHERE LastModifiedDate__c >= LAST_N_DAYS:' + modifyFilter;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Project_Health_Check_c__x> projList){

        // process each batch of project records
        try{
            Set<Id> opptExtIds = new Set<Id>();
            Set<Id> projExtIds = new Set<Id>();
            Map<Id,Id> org62OpptMapIds = new Map<Id,Id>();
            Map<Id,Id> org62ProjMapIds = new Map<Id,Id>();
            List<Project_Pulse__c> projectPulseUpsert = new List<Project_Pulse__c>();

            for(Project_Health_Check_c__x projPulse: projList)
            {
                if(projPulse.Opportunity_Name_c__r.ExternalId != null)
                {
                    opptExtIds.add(projPulse.Opportunity_Name_c__r.ExternalId);
                }
                if(projPulse.Project_c__r.ExternalId != null)
                {
                    projExtIds.add(projPulse.Project_c__r.ExternalId);
                }
            }

            for(Opportunity opp:[Select id,Org62_Id__c from Opportunity where Org62_Id__c IN :opptExtIds])
            {
                org62OpptMapIds.put(opp.Org62_Id__c,opp.Id);
            }
            for(PSA_Project__c psaProject:[select Id,Org62_Id__c from PSA_Project__c WHERE Org62_Id__c IN :projExtIds])
            {
                org62ProjMapIds.put(psaProject.Org62_Id__c, psaProject.Id);
            }
            for(Project_Health_Check_c__x projPulseRec: projList)
            {
                Project_Pulse__c projPulse = new Project_Pulse__c();
                if(org62ProjMapIds.get(projPulseRec.Project_c__r.ExternalId)!=null && org62OpptMapIds.get(projPulseRec.Opportunity_Name_c__r.ExternalId)!=null)
                {
                    projPulse.PSA_Project__c = org62ProjMapIds.get(projPulseRec.Project_c__r.ExternalId);
                    projPulse.Project_ID__c = org62ProjMapIds.get(projPulseRec.Project_c__r.ExternalId);
                    projPulse.Opportunity__c = org62OpptMapIds.get(projPulseRec.Opportunity_Name_c__r.ExternalId);
                    projPulse.name = projPulseRec.name__c;
                    projPulse.Methodology_Used__c = projPulseRec.Methodology_Used_c__c;
                    projPulse.Reason_for_Other__c = projPulseRec.Reason_for_Other__c;
                    projPulse.Opportunity_Record_Type__c = projPulseRec.Opportunity_Name_c__r.RecordTypeId__r.Name__c;
                    projPulse.Overall_Health__c = projPulseRec.Overall_Health_c__c;
                    projPulse.Org62_Id__c = projPulseRec.externalId;
                    projPulse.Last_Status_Date__c = projPulseRec.Last_Status_Date_c__c;
                    projectPulseUpsert.add(projPulse);
                }
            }
            Database.upsert(projectPulseUpsert,Project_Pulse__c.Fields.Org62_Id__c,false);
            
        } catch (Exception e){
            System.debug(e);
        }
    }

    global void finish(Database.BatchableContext BC){

    }

    global void execute(SchedulableContext sc) {
        EDHQ_BT_ProjectPulseSyncBatch cls = new EDHQ_BT_ProjectPulseSyncBatch ();
        Database.executebatch(cls,100);
    }
}