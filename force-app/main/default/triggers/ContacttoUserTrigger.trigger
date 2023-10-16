trigger ContacttoUserTrigger on Contact (after update) {
    
    if (!Util.inFutureContext) {
        Map<Id,String> muserArgs = new Map<Id,String>();
        Integer idx=0;
        for(Contact c:trigger.new){
            Contact oc = trigger.old[idx++];
            String oldContactStr = oc.FirstName + '~' + oc.LastName + '~' + oc.Email + '~' + oc.Title__c + '~' + oc.Role__c + '~' + oc.Organization__c;
            String newContactStr = c.FirstName + '~' + c.LastName + '~' + c.Email + '~' + c.Title__c + '~' + c.Role__c + '~' + c.Organization__c;
            if(oldContactStr!=newContactStr){
                muserArgs.put(c.UserId__c,c.FirstName + '~' + c.LastName + '~' + c.Email + '~' + c.Title__c + '~' + c.Role__c + '~' + c.Organization__c);
            }   
        }
        if(!muserArgs.isEmpty()){
            try{
                UserContactUtil.updateUser(muserArgs);
            } catch (AsyncException e){
                system.assertequals('Future method cannot be called from a future method: updateUser(MAP:Id,String)',e.getMessage());
            }
        }
    }
}