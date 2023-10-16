/********************************************************************************** 
File Name: LP_ConsultantMilestone_Batchable
Description: Apex Batch Processing Class used by LP_ConsultantMilestone_Scheduler
			 that calls LP_ConsultantMilestone_SVC.recalculateMilestoneProgress
@author : DHarris

Modification Log =============================================================== 
1.0	JUL 2014	DHARRIS		Created.
/**********************************************************************************/
global class LP_ConsultantMilestone_Batchable implements Database.Batchable<sObject>{

	global final String query;
   	global String errMsg;
   
   	global LP_ConsultantMilestone_Batchable(String q) {
   		query = q;
   	}
   	
	global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
   	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<PA_Onboarding__c> paos = (List<PA_Onboarding__c>)scope;
      	List<Id> consultantIdList = new List<Id>();
      	for(PA_Onboarding__c pao : paos){
      		consultantIdList.add(pao.Id);
      	}
      	try{
      		LP_ConsultantMilestone_SVC.recalulateMilestoneByConsultant(consultantIdList);
      	}catch (Exception e){
      		errMsg = 'There was an error calling LP_ConsultantMilestone_SVC.recalculateMilestoneProgress : ' + e.getMessage();
		}
	}

	global void finish(Database.BatchableContext BC){
                          
       // Possibly notify if there was an error with processing?
       /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {TODO: Email Address(es)};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Error in ConsultantMilestone Batch Process');
       mail.setPlainTextBody(errMsg);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
   	}

}