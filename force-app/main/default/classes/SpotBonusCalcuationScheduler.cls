/********************************************************************************** 
File Name: SpotBonusCalcuationScheduler
Description: Apex Schedulable Class using SpotBonusBatchable.
@author : anarasimhan

Modification Log 
GR 7/19/17: Updated to always run the spot bonus program with 1st of month as the effective date.
=============================================================== 

**********************************************************************************/
global class SpotBonusCalcuationScheduler  implements Schedulable{

    global void execute(SchedulableContext ctx) {
      PA_Onboarding_Property__c  paOP;
      
      Date currDt = Date.today();
      
      /* GR:/ Get the dates that the scheduler needs to run 
      // (typically 1st day of the last month of the quarter)
      paOP = PA_Onboarding_Property__c.getValues('Spot Bonus Schedule Dates');
      String[] dateToRun = paOP.Value__c.split(',');
      
      //Check if today's date matches the run date in PA_Onboarding_Property
      Boolean runBatch = false;
      for(String dtMMDD :dateToRun){
        runBatch = currDt.isSameDay(Date.parse(dtMMDD+'/'+currDt.year()));
            
      } */
      
      //GR: Get 1st day of the month
      Date effDt = currDt.toStartOfMonth();
      
      //if(runBatch){  
          System.debug('>>> Running spot bonus as of :'+effDt);           
          paOP = PA_Onboarding_Property__c.getValues('Spot Bonus Query');
          String query = paOP.Value__c;
          SpotBonusBatchable lpCMBatch = new SpotBonusBatchable(query,effDt);
          Database.executeBatch(lpCMBatch,1);
      //}else{
          //System.debug('>>> Not running spot bonus as of :'+currDt);           
        
      //}
   }

}