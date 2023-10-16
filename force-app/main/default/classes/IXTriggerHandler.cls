/*****************************************
* File: IXTriggerHandler
* Author: William Steele-Salesforce PA
* Description: Interface for TriggerHandler classes
******************************************/
public interface IXTriggerHandler {
    /**
     * Implement this method with either a custom setting or a static variable at the top of your handler
     * to implement bypass through configuration or through code e.g. unit tests
     */
    Boolean isDisabled();

    void beforeInsert(List<SObject> newItems);

    void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

    void beforeDelete(Map<Id, SObject> oldItems);

    void afterInsert(List<SObject> newItems);

    void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

    void afterDelete(Map<Id, SObject> oldItems);

    void afterUndelete(Map<Id, SObject> oldItems);
}