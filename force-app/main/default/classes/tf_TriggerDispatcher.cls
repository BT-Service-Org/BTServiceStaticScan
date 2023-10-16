/**
* @description :    > This is the main dispatcher class. It has methods to handle the trigger execution.
*/
public class tf_TriggerDispatcher {
    
    private static final String TRIGGER_DISABLED = 'Trigger has been disabled';
    private static final String TRIGGER_OPERATION_NOT_SUPPORTED_EXCEPTION = 'Trigger operation not supported';

    public static final String BEFORE_INSERT = TriggerOperation.BEFORE_INSERT.name();
    public static final String BEFORE_UPDATE = TriggerOperation.BEFORE_UPDATE.name();
    public static final String AFTER_INSERT = TriggerOperation.AFTER_INSERT.name();
    public static final String AFTER_UPDATE = TriggerOperation.AFTER_UPDATE.name();
    public static final String BEFORE_DELETE = TriggerOperation.BEFORE_DELETE.name();
    public static final String AFTER_DELETE = TriggerOperation.AFTER_DELETE.name();

    private static Boolean doNotRunTrigger = false; //Once set to True - No trigger is executed (if implemeted using this framework)
    private Map<String,List<String>> triggerHandlerEventMap;
    /**
    @description : method
    
    */
    public tf_TriggerDispatcher() {
        String triggerObjectName = getTriggerSObjectTypeName();
        triggerHandlerEventMap = tf_TriggerHandlerRegistryUtil.getEventHandlerMap(triggerObjectName);
    }
    
    /**
    * @description : Execute Method runs and controls the entire Trigger Execution!     
    */
    public void execute() {
        if(doNotRunTrigger) {
            System.debug(LoggingLevel.ERROR, TRIGGER_DISABLED);
            return; 
        }
        //execute Handlers
        handleTriggerEvents();
    }
        
    /**
    * @param : Boolean - to swap the flag, reason and from which class this is being called
    * @param : String - reason for swapping the flag
    * @param : Name of the class from where the flag is being set - for debugging
    * @description :  Trigger run can be set, not to run - through code as required - when this happens this needs to be logged clearly
    *                   as this message need be passed to other teams that are depending on the trigger.
    */
    public static void setDoNotRunTriggerFlag(Boolean flag, 
                                              String reasonForFlag, 
                                              String sourceClass)
    {
        if(String.isNotBlank(reasonForFlag) && String.isNotBlank(sourceClass)) {
            doNotRunTrigger = flag;
            System.debug(logginglevel.ERROR,'Reason for Setting Flag :: '+reasonForFlag + ' Source Class Name :: '+sourceClass);
        }
        else{
            if(!String.isNotBlank(sourceClass)){
                throw new tf_TriggerException('Setting Do Not Run Trigger Flag Requires a Source Class');
            }
            if(!String.isNotBlank(sourceClass)){
                throw new tf_TriggerException('Setting Do Not Run Trigger Flag Requires a Reason For Flag');
            }
        }
    }
     /**
    * @description : method  
    */
    private void handleTriggerEvents(){
        switch on Trigger.operationType  {
            when BEFORE_INSERT {       
                handleBeforeInsert();
            }
            when BEFORE_UPDATE {       
                handleBeforeUpdate();
            }
            when BEFORE_DELETE {       
                handleBeforeDelete();
            }
            when AFTER_INSERT {        
                handleAfterInsert();
            }
            when AFTER_UPDATE {        
                handleAfterUpdate();
            }
            when AFTER_DELETE {        
                handleAfterDelete();
            }
            when else {       
                throw new tf_TriggerException(TRIGGER_OPERATION_NOT_SUPPORTED_EXCEPTION);
            }
        }
    }
     /**
    * @description : method  
    */
    private void handleBeforeInsert() {
        if (!triggerHandlerEventMap.containsKey(BEFORE_INSERT)) {
            return;
        }
        for(String eachProcess : triggerHandlerEventMap.get(BEFORE_INSERT)) {
            tf_TriggerHandler handler = tf_TriggerHandlerRegistryUtil.getHandlerInstance(eachProcess);
            if(handler.runTriggerHandler()) {
                handler.handleBeforeInsert();
            }
        }
    }
     /**
    * @description : method  
    */
    private void handleBeforeUpdate() {
        if (!triggerHandlerEventMap.containsKey(BEFORE_UPDATE)) {
            return;
        }
        for(String eachProcess : triggerHandlerEventMap.get(BEFORE_UPDATE)) {
            tf_TriggerHandler handler = tf_TriggerHandlerRegistryUtil.getHandlerInstance(eachProcess);
            if(handler.runTriggerHandler()) {
                handler.handleBeforeUpdate();
            }
        }
    }
     /**
    * @description : method  
    */
    private void handleBeforeDelete() {
        if (!triggerHandlerEventMap.containsKey(BEFORE_DELETE)) {
            return;
        }
        for(String eachProcess : triggerHandlerEventMap.get(BEFORE_DELETE)) {
            tf_TriggerHandler handler = tf_TriggerHandlerRegistryUtil.getHandlerInstance(eachProcess);
            if(handler.runTriggerHandler()) {
                handler.handleBeforeDelete();
            }
        }
    }
     /**
    * @description : method  
    */
    private void handleAfterInsert() {
        if (!triggerHandlerEventMap.containsKey(AFTER_INSERT)) {
            return;
        }
        for(String eachProcess : triggerHandlerEventMap.get(AFTER_INSERT)) {
            tf_TriggerHandler handler = tf_TriggerHandlerRegistryUtil.getHandlerInstance(eachProcess);
            if(handler.runTriggerHandler()) {
                handler.handleAfterInsert();
            }
        }
    }
     /**
    * @description : method  
    */
    private void handleAfterUpdate() {
        if (!triggerHandlerEventMap.containsKey(AFTER_UPDATE)) {
            return;
        }
        for(String eachProcess : triggerHandlerEventMap.get(AFTER_UPDATE)) {
            tf_TriggerHandler handler = tf_TriggerHandlerRegistryUtil.getHandlerInstance(eachProcess);
            if(handler.runTriggerHandler()) {
                handler.handleAfterUpdate();
            }
        }
    }
     /**
    * @description : method  
    */
    private void handleAfterDelete() {
        if (!triggerHandlerEventMap.containsKey(AFTER_DELETE)) {
            return;
        }
        for(String eachProcess : triggerHandlerEventMap.get(AFTER_DELETE)) {
            tf_TriggerHandler handler = tf_TriggerHandlerRegistryUtil.getHandlerInstance(eachProcess);
            if(handler.runTriggerHandler()) {
                handler.handleAfterDelete();
            }
        }
    }
     /**
    * @description : method  
    */
    private String getTriggerSObjectTypeName() {
        SObjectType triggerObjectType;
        if (Trigger.new != null) {
            triggerObjectType = Trigger.new.getSObjectType();
        } else {
            triggerObjectType = Trigger.old.getSObjectType();
        }

        return triggerObjectType.getDescribe().getName();
    }
}