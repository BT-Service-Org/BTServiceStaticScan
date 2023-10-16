global with sharing class OrgRefresh_BatchFetcher implements Schedulable, Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {

    private string orgAppName;
    private OrgRefresh_BatchInterface implClass; 
    private Id jobId;
    private String errorLog = '';
    /* Error inner class */
    public class OrgRefresh_BatchFetcher_Exception extends Exception {}

    public OrgRefresh_BatchFetcher() 
    {
        
    }
    
    public OrgRefresh_BatchFetcher(String orgAppName)
    {
        System.debug('Sriram inside my constructor '+orgAppName);
        this.orgAppName = orgAppName;
    }
    
     
    global Org_Refresh_Profile__c refreshProfInstance {get; set;} {  
//          OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
//          refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();          
    }

    private String determineOrgAppName(String jobId){
        System.debug('===jobIdin pollscores===' + jobId);
        //convert 18 digit id to 15 digits as that is what is stored in custom settings
        jobId=jobId.substring(0,15);
        System.debug('===15 digit jobIdin pollscores===' + jobId);
        
        //query custom settings to find the org app combination for this id.
        List<Org_Refresh_Profile__c> refreshProfInstances=[select Name from Org_Refresh_Profile__c where Job_Id__c=:jobId];
        System.debug('===refreshProfInstances in pollscores===' + refreshProfInstances);
        
        //there should be one and only entry for the intended job Id
        
        if(refreshProfInstances!=null && refreshProfInstances.size()==1){
           return refreshProfInstances[0].Name;
        }
        else{
            return null;
        }
    }
    
    global void setOrgAppName(String orgAppName) {
        this.orgAppName = orgAppName;
    }

 
    /* Batch Starter */  
    global Database.QueryLocator start(Database.BatchableContext BC){
        // get the profile instance
        System.debug('start: orgAppName '+orgAppName);
        /* Added by SD to add to job status log - 2/9/2015 */
        jobId = lp_JobStatus_SVC.createJobStatus(orgAppName);
        /* End of changes to update job status log */
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();          
        
        System.debug(refreshProfInstance);  
        implClass = OrgRefresh_QueryUtils.getBatchInstance(orgAppName); 
        return Database.getQueryLocator(implClass.constructSourceQuery());
    }

    /* Batch Execute */
    global void execute(Database.BatchableContext BC, 
                       List<SObject> candidateList){
        System.debug('<== execute: ' + orgAppName);
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();          
        implClass = OrgRefresh_QueryUtils.getBatchInstance(orgAppName); 
        System.debug(refreshProfInstance);      
        // login and set access token
        String accessToken=OrgRefresh_AuthUtils.authenticateUser(refreshProfInstance);
        System.debug('accessToken:' + accessToken);
        if (accessToken == null)
            throw new OrgRefresh_BatchFetcher_Exception('Could not retrieve access token.');
        List<OrgRefresh_BatchResult> results = implClass.fetchAndUpdateData(candidateList, accessToken, orgAppName, true);  
        
        /* Added by SD to add to job status log - 2/12/2015 */
        //lp_JobStatus_SVC.updateJobStatus(jobId, 'Processing', 'CandidateList: \n' + candidateList);
        //lp_JobStatus_SVC.updateJobStatus(jobId, 'Processing', 'BatchResults: \n' + results);
        //System.Debug('*************OrgReferesh_BatchResult***************: ' + results);
        
        /*if (results != null)
        {
            for (OrgRefresh_BatchResult r :results)
            {
                if (r.Success == false)
                {
                    if (r.errors != null)
                    {
                        errorLog = errorLog + r.errors + '\n';
                    }
                }
            }   
            
        }*/
        
        errorLog = errorLog + updateErrorLog(results);
        /* End of changes add by SD */
    }
  
    /* Batch Finish */
    global void finish(Database.BatchableContext BC){  
        
        refreshProfInstance.Last_Refreshed__c=System.now();
        upsert refreshProfInstance Name;
        
        /* Added by SD to add to job status log - 2/11/2015 */
        //System.Debug('*************Sandip****************');
        String resultString = '';
        
        /*
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                          
        // Construct results string
        // Add First Error
        if (a.ExtendedStatus != null)
            resultString = a.ExtendedStatus + '\n\n';
        else
            resultString = '';
            
        // Add Rest of Errors
        if (errorLog != '')
            resultString = resultString + 'ErrorLog: \n' + errorLog + '\n\n';
        
        // Add Final Results
        resultString = resultString + 'The batch Apex job processed ' + a.TotalJobItems +
                         ' batches with '+ a.NumberOfErrors + ' failures.';
                         
        // Construct status string
        String status = a.NumberOfErrors > 0 ? 'Failed' : 'Completed';
         
        // Update Job Status Job 
        lp_JobStatus_SVC.finishJobStatus(jobId, status, resultString, a.TotalJobItems, a.NumberOfErrors);
        */
        
        updateJobStatusLog(jobId, BC, errorLog);
        /* End of changes to update job status log */

    }
    
    /* Batch schedule */
    global void execute(SchedulableContext sc) {
        String jobId=sc.getTriggerId();
        System.debug('===jobId====' + jobId);       
        
        String orgAppName = determineOrgAppName(jobId);
        System.debug('schedule execute : org app name is '+orgAppName);
        refreshProfInstance=Org_Refresh_Profile__c.getInstance(orgAppName);
        Decimal batchSize = refreshProfInstance.Batch_Size__c;
        if (batchSize == null || batchSize==0) batchSize=50; // default to 50 just in case
    
          Database.executeBatch(new OrgRefresh_BatchFetcher(orgAppName), batchSize.intvalue());        

    } //end execute
    
    /* Update error Log */
    private static String updateErrorLog(List<OrgRefresh_BatchResult> res)
    {
        String errLog = '';
        
        if (res != null)
        {
            for (OrgRefresh_BatchResult r :res)
            {
                if (r.Success == false)
                {
                    if (r.errors != null)
                    {
                        errLog = errLog + r.errors + '\n';
                    }
                }
            }   
            
        }
        
        return errLog;
    }
    
    public static void updateJobStatusLog(Id jobId, Database.BatchableContext BC, String errorLog)
    {
        String resultString = '';
        
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                          
        // Construct results string
        // Add First Error
        if (a.ExtendedStatus != null)
            resultString = a.ExtendedStatus + '\n\n';
        else
            resultString = '';
            
        // Add Rest of Errors
        if (errorLog != '')
            resultString = resultString + 'ErrorLog: \n' + errorLog + '\n\n';
        
        // Add Final Results
        resultString = resultString + 'The batch Apex job processed ' + a.TotalJobItems +
                         ' batches with '+ a.NumberOfErrors + ' failures.';
                         
        // Construct status string
        String status = a.NumberOfErrors > 0 ? 'Failed' : 'Completed';
        
        // Update Job Status Job 
        lp_JobStatus_SVC.finishJobStatus(jobId, status, resultString, a.TotalJobItems, a.NumberOfErrors);
    }

    
    
}