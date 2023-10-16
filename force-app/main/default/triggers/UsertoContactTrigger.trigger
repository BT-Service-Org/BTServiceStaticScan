trigger UsertoContactTrigger on User (after insert, after update, before update) {

    if ( ! UserContactUtil.doNotExecuteTrigger) { 
    
        if(trigger.isInsert){
            Id acctId = [select id, name from Account where name = 'Salesforce.com - DO NOT TOUCH'].Id;
            Set<Id> ids = new Set<Id>(); 
            
            for(User u:trigger.new){
              ids.add(u.Id);
            }
            if (!Util.inFutureContext) {
                UserContactUtil.createContactAsync(ids, acctId);
            } else {
                UserContactUtil.createContact(ids, acctId);
            } 
            
        } else {
            
            Set<Id> ids = new Set<Id>(); 
            
            for(User u:trigger.new){
              ids.add(u.Id);
            }
            
            try{
                if (!Util.inFutureContext) {
                    UserContactUtil.updateContactAsync(ids);
                } else {
                    UserContactUtil.updateContact(ids);
                }
            } catch (AsyncException e){
                //system.assertequals('Future method cannot be called from a future method: updateContact(MAP:Id,String)',e.getMessage());
                System.assert( e.getMessage().contains('Future method cannot be called from a future method'), e.getMessage());
            }
        }
    }
    
    if(trigger.isBefore && trigger.isUpdate) {
        
        System.debug('Trigger.operationType ===> ' + Trigger.operationType);
		CSG_UserTriggerHandler.setUserHierarchyChangeFlag(Trigger.newMap, Trigger.oldMap);  
    }

}