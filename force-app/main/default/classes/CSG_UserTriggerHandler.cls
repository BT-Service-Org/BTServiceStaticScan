/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-02-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CSG_UserTriggerHandler {
    
    public static void setUserHierarchyChangeFlag(Map<Id,User> newMap, Map<Id,User> oldMap) {
         for(User newUserRec : newMap.values()) {
            if(newUserRec.Mgmt_Chain_Hierarchy_Level_02__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_02__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_03__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_03__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_04__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_04__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_05__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_05__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_06__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_06__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_07__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_07__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_08__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_08__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_09__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_09__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_10__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_10__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_11__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_11__c
            || newUserRec.Mgmt_Chain_Hierarchy_Level_12__c <> oldMap.get(newUserRec.Id).Mgmt_Chain_Hierarchy_Level_12__c) {
                newUserRec.Mgmt_Hierarchy_Changed__c = true;
            }
        }
        
    }    
}