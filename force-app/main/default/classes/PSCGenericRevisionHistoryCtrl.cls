public with sharing class PSCGenericRevisionHistoryCtrl {
    @AuraEnabled(Cacheable=true)
    public static List<sObject> getHistoryData(Id key){
        HistoryWrapper historyWrapper = new HistoryWrapper();
        String sObjName = key.getSObjectType().getDescribe().getName();
        
        String query = 'SELECT Id,LastModifiedDate,LastModifiedBy.FirstName,LastModifiedBy.LastName,Name FROM ';
        query += sObjName;
        query += ' WHERE Id =  :key';
        System.debug('query=>'+query);
	    List<sObject> sobjList = Database.query(query); 
        System.debug('sobjList->'+sobjList);

        return sobjList;
    }

    public class HistoryWrapper{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public Date lastModifiedDate;
        @AuraEnabled
        public String lastModifiedUserName;
    }
}