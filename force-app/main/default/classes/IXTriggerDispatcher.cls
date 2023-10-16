/*****************************************
* File: IXTriggerDispatcher
* Author: William Steele-Salesforce PA
* Description: Dispatches Trigger records
******************************************/
public class IXTriggerDispatcher {
    /**
     * Call this method from your Trigger, passing in an instance of a Trigger handler which implements IXTriggerHandler.
     * This method will fire the appropriate methods on the handler depending on the Trigger context.
     */
    public static void Run(IXTriggerHandler handler) {
        // Check to see if the Trigger has been disabled. If it has, return
        if (handler.isDisabled()) {
            return;
        }

        /* Detect the current Trigger context and fire the relevant methods on the Trigger handler: */

        // Before Trigger logic
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                handler.beforeInsert(Trigger.new);
            }

            if (Trigger.isUpdate) {
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }

            if (Trigger.isDelete) {
                handler.beforeDelete(Trigger.oldMap);
            }
        }

        // After Trigger logic
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                handler.afterInsert(Trigger.new);
            }

            if (Trigger.isUpdate) {
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }

            if (Trigger.isDelete) {
                handler.afterDelete(Trigger.oldMap);
            }

            if (Trigger.isUndelete) {
                handler.afterUndelete(Trigger.oldMap);
            }
        }
    }
}