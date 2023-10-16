trigger TagTrigger on Tag__c (before insert) {
if(Trigger.isbefore && Trigger.isInsert){
      TagTriggerHandler.preventProductinTag(Trigger.new);
    }
}