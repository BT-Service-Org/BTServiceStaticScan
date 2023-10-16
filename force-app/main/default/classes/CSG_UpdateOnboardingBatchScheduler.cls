/**
Class Name      : CSG_UpdateOnboardingBatchScheduler
@description    : This is the scheduler class to schedule the CSG_UpdateOnboardingDetailsBatch batch to update Onboarding records
*/
public class CSG_UpdateOnboardingBatchScheduler implements Schedulable {
  /**
      @description : This is the scheduler execute method
      @param   sc - schedulableContext
     */
  public void execute(SchedulableContext sc) {
    CSG_UpdateOnboardingDetailsBatch btch = new CSG_UpdateOnboardingDetailsBatch();
    database.executebatch(btch);
  }
}