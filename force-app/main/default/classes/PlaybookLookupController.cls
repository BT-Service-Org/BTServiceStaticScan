public without sharing class PlaybookLookupController {
    public PlaybookLookupController() {
    }

    // Method to fetch lookup search result
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey, string sObjectApiName, string recordType , boolean statusCondition ) {
        List<sObject> returnList = new List<sObject>();

        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name From ' + String.escapeSingleQuotes(sObjectApiName) + ' Where Name Like \'%'+String.escapeSingleQuotes(sWildCardText)+'%\' ';
        if(statusCondition == true){
            sQuery = sQuery + 'AND Status__c = \'Published\'';
        } 
        if(recordType!='')
        {
            sQuery = sQuery +' and recordtype.name=:recordType';
        }
        sQuery = sQuery + ' order by createdDate DESC LIMIT 5';
        for (sObject obj : database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }

    // Method to fetch lookup default value
    @AuraEnabled(cacheable=true)
    public static sObject fetchDefaultRecord(string recordId, string sObjectApiName) {
        string sRecId = recordId;
        string sQuery = 'Select Id,Name From ' + String.escapeSingleQuotes(sObjectApiName) + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj : database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}