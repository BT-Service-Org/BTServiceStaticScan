public with sharing class PSCRevisionHistoryDataService {
    public static List<Methodology_Version__c> getData(String key) {
        List<String> strList = new List<String>();
        Decimal methodNumber;
        if(key.isNumeric()){
            methodNumber = decimal.valueOf(key);
        } else{
            strList.add(key);
            strList.add(key.replace(' and ',' & '));
        }
        List<Methodology_Version__c> revisionHistory = [SELECT Major_Release_Number__c, 
                                                        Method__r.Name, Name, LastModifiedBy.firstName, 
                                                        LastModifiedBy.lastName,
                                                        lastmodifieddate FROM Methodology_Version__c
                                                        WHERE Method__r.Method_Number__c=:methodNumber
                                                        OR Method__r.Name IN:strList
                                                        ORDER BY LastModifiedDate DESC];
        
        return revisionHistory;
    }
}