global with sharing class OrgRefresh_org62_AvailStaffBatchFetch implements Schedulable, Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {

    // this query drives the selection of pa onboarding records
    /* TODO MOVE THIS TO CUSTOM SETTING */
    private static string query='select  id '+
                                ', Contact__c '+
                                ', Contact__r.Email '+
                                ', name ' +
                                ', Next_Available_Date__c ' +
                                ', Available_to_Staff_as_PA__c ' +
                                'from PA_Onboarding__c '+ 
                                'where Contact__c!=null '+ 
                                'and Contact__r.Email!=null '+ 
                                'and Contact__r.Email!=\'\' '+
                                'and Program__c in (\'Accelerated Onboarding\', \'PA Track\', \'CTA Prep\', \'Existing PA\')';

    private static string orgAppName='org62_AvailStaff'; 

    global Org_Refresh_Profile__c refreshProfInstance {get; set;} {
            OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
            refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();          
        }

    /* Error inner class */
    public class OrgRefresh_org62_AvailStaffBatchFetch_Exception extends Exception {}

    /* Batch Starter */
    global Database.QueryLocator start (Database.BatchableContext BC){
        // get the profile instance
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        System.debug(refreshProfInstance);
        //append any additional where clause for testing purpose.
        query = refreshProfInstance.Batch_Source_Query__c + ' ' +
                refreshProfInstance.Batch_Query_Where_Statement__c ;
        
        System.debug('Starting query ===> ' + query);        
        return Database.getQueryLocator(query);
    }

    /* Batch Execute */
    global void execute(Database.BatchableContext BC, 
                       List<PA_Onboarding__c> paList){
        System.debug('<== execute: ' + orgAppName);
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);

        // login and set access token
        String accessToken=OrgRefresh_AuthUtils.authenticateUser(refreshProfInstance);
        System.debug('accessToken:' + accessToken);
        if (accessToken == null)
            throw new OrgRefresh_org62_AvailStaffBatchFetch_Exception('Could not retrieve access token.');
        
        OrgRefresh_org62_AvailStaffFetchImpl fetcher = new OrgRefresh_org62_AvailStaffFetchImpl();
        
        fetcher.fetchAndUpdateData(paList, accessToken, orgAppName, true); 
    }

    /* Batch schedule */
    global void execute(SchedulableContext sc) {
        
        Decimal batchSize = refreshProfInstance.Batch_Size__c;
        if (batchSize == null || batchSize==0) batchSize=50; // default to 50 just in case
        
        Database.executeBatch(new OrgRefresh_org62_AvailStaffBatchFetch(), batchSize.intvalue());        

    } //end execute

    /* Batch Finish */
    global void finish(Database.BatchableContext BC){
        refreshProfInstance.Last_Refreshed__c=System.now();
        upsert refreshProfInstance Name;

    }




}