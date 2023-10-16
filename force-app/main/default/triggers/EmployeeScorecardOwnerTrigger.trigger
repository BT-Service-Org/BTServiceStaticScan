trigger EmployeeScorecardOwnerTrigger on Employee_Scorecard__c (before insert, before update) {

	For (Employee_Scorecard__c es:Trigger.New){
        Id userId = UserInfo.getUserId();
        //RETRIEVE THE PROPER ID FOR THE MANAGER
        Id mId = es.Manager_Name__c;
        //RETRIEVE THE PROPER ID FOR THE EMPLOYEE
        Id eId = es.Employee_Name__c;
           
        /*CHANGE THE RECORD OWNER IF THE STATUS EQUALS SUBMITTED TO MANAGER OR MANAGER APPROVED*/
        if((es.Status__c == 'Submitted to Manager' || es.Status__c == 'Manager Approved') && es.Manager_Name__c == userId){
            //CHANGE THE RECORD OWNER
            es.OwnerId = mId;
        }
        /*CHANGE THE RECORD OWNER IF THE STATUS EQUALS COMPLETE*/
        else if (es.Status__c == 'Complete' || es.Status__c == 'Self Assessment'){
                       
            //CHANGE THE RECORD OWNER
            es.OwnerId = eId;
            
            //SHARE THE RECORD BACK WITH THE PM/EM
            EmployeeScorecardSharing.manualShareAll(es.Id, mId);
        }
    }

}