/**
Class Name      : tf_TriggerHandlerRegistryDAO
@description    : tf_TriggerHandlerRegistryDAO cls
*/
public with sharing class tf_TriggerHandlerRegistryDAO {
    /**
    @description : getTriggerHandlerRegistryEntries method
    @return      : List<Trigger_Handler_Registry__mdt>
    @param sObjectName - String
    */
    public List<Trigger_Handler_Registry__mdt> getTriggerHandlerRegistryEntries(String sObjectName){
        return [SELECT Trigger_Event__c,
            Trigger_Handler_Name__c,
            Execution_Order_of_the_Handler__c  
            FROM Trigger_Handler_Registry__mdt 
            WHERE Sobject_Name__c = :sObjectName AND Is_Active__c  = true
            ORDER BY Trigger_Event__c, Execution_Order_of_the_Handler__c ASC];
    }

}