/********************************************************************************** 
File Name: LP_ConsultantMilestone_Scheduler
Description: Apex Schedulable Class using LP_ConsultantMilestone_Batchable.
@author : DHarris

Modification Log =============================================================== 
1.0	JUL 2014	DHARRIS		Created.
/**********************************************************************************/
global class LP_ConsultantMilestone_Scheduler implements Schedulable{
	
	global void execute(SchedulableContext ctx) {
      PA_Onboarding_Property__c paOP = PA_Onboarding_Property__c.getValues('ConsultantMilestone Batchable Query');
	  String query = paOP.Value__c;
                   
      LP_ConsultantMilestone_Batchable lpCMBatch = new LP_ConsultantMilestone_Batchable(query);
      Database.executeBatch(lpCMBatch);
   }
    
}