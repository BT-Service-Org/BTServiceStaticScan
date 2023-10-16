global class SpotBonusBatchable implements Database.Batchable<sObject>{

	global final String query;
   	global final Date runAsDate;
   	global String errMsg;
   
   	global SpotBonusBatchable(String q,Date runAsDate) {
   		query = q;
   		this.runAsDate = runAsDate;
   	}
   	
	global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
   	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<PA_Onboarding__c> paos = (List<PA_Onboarding__c>)scope;
		Contact theContact;
		PABonusCalcResult result;
      	try{
			for(PA_Onboarding__c paRec : paos){
				theContact = paRec.Contact__r;
				result = PABonusCalcUtils.calcBonus(theContact, runAsDate,true);
				System.debug('>>>>>>result = '+result);	
			}

      	}catch (Exception e){
      		errMsg = 'There was an error calling PABonusCalcUtils.calcBonus : ' + e.getMessage();
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