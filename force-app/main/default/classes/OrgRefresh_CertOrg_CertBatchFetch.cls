global with sharing class OrgRefresh_CertOrg_CertBatchFetch implements Schedulable, Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {

    // this query drives the selection of pa onboarding records
    /* TODO MOVE THIS TO CUSTOM SETTING */
    
    private static string query='select  id, Contact__c, Contact__r.Email, Mentor__c, Mentor__r.Email, name ' +
                    'from PA_Onboarding__c ' +
                    'where Contact__c!=null ' + 
                    'and Contact__r.Email!=null ' +
                    'and Contact__r.Email!=\'\'' +
                    'and Program__c in (\'Accelerated Onboarding\', \'PA Track\', \'CTA Prep\', \'Existing PA\',\'Existing CSE\',\'CSE Ramp\',\'Former CST\',\'MC Advisor\') ' +
                    'and (not Name like \'%Template%\')';

    private static string orgAppName='Cert Org_Cert'; 
    global Org_Refresh_Profile__c refreshProfInstance {get; set;} {
            OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
            refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();          
        }

    /* Error inner class */
    public class OrgRefresh_CertOrg_CertBatchFetch_Exception extends Exception {}

    /* Batch Starter */
    global Database.QueryLocator start(Database.BatchableContext BC){
        // get the profile instance
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        System.debug(refreshProfInstance);
                
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
            throw new OrgRefresh_CertOrg_CertBatchFetch_Exception('Could not retrieve access token.');
            
        OrgRefresh_CertOrg_CertFetchImpl fetcher = new OrgRefresh_CertOrg_CertFetchImpl();
        //fetcher.fetchAndUpdateData(paList, accessToken, orgAppName);
        fetcher.fetchAndUpdateData(accessToken, orgAppName); // Updated by SD - 06/24
    }

    /* Batch schedule */
    global void execute(SchedulableContext sc) {
        
        Decimal batchSize = refreshProfInstance.Batch_Size__c;
        if (batchSize == null || batchSize==0) batchSize=50; // default to 50 just in case
        
        Database.executeBatch(new OrgRefresh_CertOrg_CertBatchFetch(), batchSize.intvalue());        

    } //end execute

    /* Batch Finish */
    global void finish(Database.BatchableContext BC){
        refreshProfInstance.Last_Refreshed__c=System.now();
        upsert refreshProfInstance Name;

    }

}