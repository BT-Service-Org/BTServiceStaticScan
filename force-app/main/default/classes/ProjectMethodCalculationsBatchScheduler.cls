/*
 * Description: This Class is used to schedule the batch class (ProjectMethodCalculationsBatch)
 * Date: 01-03-2023
 * */
global class ProjectMethodCalculationsBatchScheduler implements Schedulable
{
     global void execute(SchedulableContext sc)
     {
     ProjectMethodCalculationsBatch b = new ProjectMethodCalculationsBatch();
     database.executeBatch(b,10);
     }
}