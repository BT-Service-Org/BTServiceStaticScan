/**
 * @author Jonathan Cohen - Salesforce.com
 * @date   September 2016
 * @group  Services Org
 */
trigger Judge_Trigger on Judge__c (before insert,
		                            before update,
		                            before delete,
		                            after insert,
		                            after update,
		                            after delete,
		                            after undelete)
{
	if(Trigger.IsBefore){
        /**
         * Trigger Before Insert
         */
        if(Trigger.IsInsert){}
        /**
         * Trigger Before Update
         */
        else if(Trigger.IsUpdate){
        	Judge_TriggerHelper.assignJudgeDomainsAndUsersPermissionSet(Trigger.newMap);
        }
        /**
         * Trigger Before Delete
         */
        else if(Trigger.IsDelete){}
    }
    else if(Trigger.IsAfter){
        /**
         * Trigger After Insert
         */
        if(Trigger.IsInsert){}    
        /**
         * Trigger After Update
         */
        else if(Trigger.IsUpdate){}
        /**
         * Trigger After Delete
         */
        else if(Trigger.IsDelete){}
    }
}