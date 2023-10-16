global with sharing class OrgRefresh_org62_ProjectsBatchFetch implements Schedulable, Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {

    // this query drives the selection of pa onboarding records
    /* TODO MOVE THIS TO CUSTOM SETTING */
    
    private static string querySelectStatement ='select  id, Contact__c, Contact__r.Email,  name ' +
                    'from PA_Onboarding__c ';

    private static string orgAppName='org62_Projects'; 
    global Org_Refresh_Profile__c refreshProfInstance {get; set;} {
            OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
            refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();          
        }

    /* Error inner class */
    public class OrgRefresh_org62_ProjectsBatchFetch_Exception extends Exception {}

    /* Batch Starter */
    global Database.QueryLocator start(Database.BatchableContext BC){
        // get the profile instance
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        System.debug('Project Batch Start: ' + refreshProfInstance);
        System.debug('************* ' + querySelectStatement + refreshProfInstance.Batch_Query_Where_Statement__c);
        return Database.getQueryLocator(querySelectStatement + refreshProfInstance.Batch_Query_Where_Statement__c);
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
            throw new OrgRefresh_org62_ProjectsBatchFetch_Exception('Could not retrieve access token.');
        
        OrgRefresh_org62_ProjectsFetchImpl fetcher = new OrgRefresh_org62_ProjectsFetchImpl();
        //fetcher.fetchAndUpdateData(paList, accessToken, orgAppName);
        fetcher.fetchAndUpdateData(accessToken, orgAppName); // Updated by SD - 06/24/2014
    }

    /* Batch schedule */
    global void execute(SchedulableContext sc) {
        
        Decimal batchSize = refreshProfInstance.Batch_Size__c;
        if (batchSize == null || batchSize==0) batchSize=50; // default to 50 just in case
        
        Database.executeBatch(new OrgRefresh_org62_ProjectsBatchFetch(), batchSize.intvalue());        

    } //end execute

    /* Batch Finish */
    global void finish(Database.BatchableContext BC){
        refreshProfInstance.Last_Refreshed__c=System.now();
        upsert refreshProfInstance Name;

    }

}