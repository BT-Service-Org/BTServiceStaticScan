/**
     * @description This class is controller class of LwcLookup component
 */
public with sharing class LwcMultiLookupController { 

    /**
     * @description This method fetches results based on user input for a particular sobject
     * @return List<SObJectResult> 
      @param objectName - string 
      @param fieldName - string 
      @param value - string 
      @param selectedRecId - List 
      @param includerecordsIds - List 
     */
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResults(String objectName, String fieldName, String value, List<String> selectedRecId,List<string> includerecordsIds) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        if(selectedRecId == null){
            selectedRecId = new List<String>();
        }
    
        if(String.isNotEmpty(value)) {
            string fieldsearch = '%' + value.trim() + '%'; 
            string fieldquery = String.escapeSingleQuotes(fieldName);
            string objectquery= String.escapeSingleQuotes(objectName);
            String query = 'Select Id,'+fieldquery+' FROM '+objectquery+' WHERE '+ fieldquery + ' LIKE:fieldsearch and ID NOT IN: selectedRecId';
                
            if(includerecordsIds != null){
              query = query + ' and Id In:includerecordsIds';
            }
            for(sObject so : Database.Query(query)) {
                String fieldvalue = (String)so.get(fieldName);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }
        }
        return sObjectResultList;
    }
    /**
     * @description wrapperclass
    */
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        /**
         * @description constructor
         * @param  recNameTemp - recname
         * @param recIdTemp - recid
         */
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
        /**
         * @description constructor
         */
        public SObJectResult() {
          
        }
    }
}