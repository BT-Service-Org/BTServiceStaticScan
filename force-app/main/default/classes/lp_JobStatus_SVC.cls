public class lp_JobStatus_SVC
{
    // Creates a job status record, should be done for each job at the beginning of execute method
    public static Id createJobStatus(String jobName)
    {
        lp_Job_Status__c jobStatus = new lp_Job_Status__c();
        jobStatus.Job_Name__c = jobName;
        jobStatus.Start_Date__c = DateTime.now();
        jobStatus.Job_Status__c = 'New';
        insert jobStatus;
        return jobStatus.Id;
        
    }

    public static void updateJobStatus(Id jobStatusId, String status, String results)
    {
        lp_Job_Status__c jobStatusResult = [SELECT Id, Start_Date__c, End_Date__c, Job_Results__c, Job_Status__c 
                                            FROM lp_Job_Status__c
                                            WHERE Id = :jobStatusId
                                            LIMIT 1];
        if (jobStatusResult != NULL)
        {
            jobStatusResult.Job_Status__c = status;
            //jobStatusResult.End_Date__c = DateTime.now();
            jobStatusResult.Job_Results__c = (jobStatusResult.Job_Results__c!=null) ? jobStatusResult.Job_Results__c + '\n' + results : results;
            update jobStatusResult;
        }
    }
    
    public static void finishJobStatus(Id jobStatusId, String status, String results, Integer TotalProcessed, Integer Failed)
    {
        lp_Job_Status__c jobStatusResult = [SELECT Id, Start_Date__c, End_Date__c, Job_Results__c, Job_Status__c,
                                            TotalJobItems__c, JobItemsProcessed__c, NumberOfErrors__c
                                            FROM lp_Job_Status__c
                                            WHERE Id = :jobStatusId
                                            LIMIT 1];
        if (jobStatusResult != NULL)
        {
            jobStatusResult.Job_Status__c = status;
            jobStatusResult.End_Date__c = DateTime.now();
            jobStatusResult.Job_Results__c = (jobStatusResult.Job_Results__c!=null) ? jobStatusResult.Job_Results__c + '\n' + results : results;
            jobStatusResult.TotalJobItems__c = TotalProcessed;
            jobStatusResult.JobItemsProcessed__c = TotalProcessed;
            jobStatusResult.NumberOfErrors__c = Failed;
            if (jobStatusResult.Job_Results__c != null && jobStatusResult.Job_Results__c.length() > 32000) {
                jobStatusResult.Job_Results__c = jobStatusResult.Job_Results__c.substring(0,32000);
            }
            
            update jobStatusResult;
        }
    }
    
    public static void completeJobStatus(Id jobId, Database.BatchableContext BC)
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
        
        // Add Final Results
        resultString = resultString + 'The batch Apex job processed ' + a.TotalJobItems +
                         ' batches with '+ a.NumberOfErrors + ' failures.';
                         
        // Construct status string
        String status = a.NumberOfErrors > 0 ? 'Failed' : 'Completed';
         
        // Update Job Status Job 
        lp_JobStatus_SVC.finishJobStatus(jobId, status, resultString, a.TotalJobItems, a.NumberOfErrors);
    }

}