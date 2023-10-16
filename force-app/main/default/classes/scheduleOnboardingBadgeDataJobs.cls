/**
  * Schedulable Apex for batch job deleteOnboardingBadgeData. For CSG Aprtice Expertise App.
  * Created Date - Sept 17,2020
  **/
global class scheduleOnboardingBadgeDataJobs implements Schedulable

            {

                        global void execute(SchedulableContext sc)

                        {
                            deleteOnboardingBadgeData myBatchObject = new deleteOnboardingBadgeData(); 
                            Id batchId = Database.executeBatch(myBatchObject);


                        }

}