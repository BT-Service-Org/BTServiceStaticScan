/*------------------------------------------------------------------------------------
Author:      	Sumit Gupta
Company:     	Salesforce
Description: 	MAP Meta Utility

History
Date            Author             Comments
--------------------------------------------------------------------------------------
01-03-2018     Sumit Gupta         Initial Release
------------------------------------------------------------------------------------*/

public class MAPMetaUtility {

    public static List<PicklistValue> getPicklistValues(String objectName, String fieldName) {
        List<PicklistValue> picklistValues = new List<PicklistValue>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        if(globalDescribe.containsKey(objectName)){
        	Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(objectName).getDescribe().fields.getMap();
            if(fieldMap.containsKey(fieldName)) {
            	Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
	            if(fieldResult.getType() ==  DisplayType.Picklist || fieldResult.getType() ==  DisplayType.MultiPicklist) {
	                List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
	                for(PicklistEntry pe: picklistEntries) {
	                    picklistValues.add(new PicklistValue(pe.getLabel(), pe.getValue()));
	                }
	            }
            }
        }
        return picklistValues;
    }  

    public with sharing class PicklistValue {
		@AuraEnabled public String label;
	    @AuraEnabled public String value;
	    
	    public PicklistValue(String label, String value) {
	        this.label = label;
	        this.value = value;
	    }
	}
}