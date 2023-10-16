//######################################################
// This class enables to load data extracted via SOQL
// into custom datasets in Analytics.
// It relies on the WAV_DataLoad_CFG__mdt custom metadata
// for configuration and requires Analytics JSON dataset
// metadata files to be loaded as static resources.
// Author : P-E GROS - July 2018
// Update : P-E GROS - Nov 2018 (@future to Queuable migration)
// #####################################################

public class WAV_DataLoad_UTL implements Schedulable {

    //######################################################
    // Entry for schedulable trigger.
    //######################################################
    public static void execute(SchedulableContext context) {
        
        WAV_DataLoad_CFG__mdt[] datasetList;
        if (Test.isRunningTest()) {
            // Test case mode - only test config element used
            datasetList = [select DeveloperName
                           from WAV_DataLoad_CFG__mdt
                           where DeveloperName = 'WAV_Test'];
        } else {
            // Normal operation mode - only active config elements used
            datasetList = [select DeveloperName
                           from WAV_DataLoad_CFG__mdt
                           where isActive__c = true];
        }
        system.debug('execute datasetList fetched / size ' + datasetList.size());
        
        
        for (WAV_DataLoad_CFG__mdt iterDS : datasetList) {
            WAV_DataLoad_UTL.executeSynch(iterDS.DeveloperName);
        }
        system.debug('execute all dataset synch requested ');
    }
        
    //######################################################
    // Main process execution : iterates on all datasets
    // declared in the configuration.
    //###################################################### 
    //@future
    public static void executeSynch(String dataSetName) {
        System.debug('executeSynch for dataset ' + dataSetName);
        
        WAV_DataLoad_CFG__mdt configElt = [select DeveloperName, MasterLabel, FieldMapping__c, Operation__c,
                                                  MaxRowsPerFile__c, MetaJson__c, Query__c, OrderBy__c 
                                           from WAV_DataLoad_CFG__mdt
                                           where DeveloperName = :dataSetName ][0];
        system.debug('executeSynch configElt fetched ' + configElt);
        
        WAV_DataLoad_QUE processJob = new WAV_DataLoad_QUE(configElt);
        ID jobID = System.enqueueJob(processJob);
        system.debug('executeSynch processing job launched: ' + jobID);
        
        return;
    }
}