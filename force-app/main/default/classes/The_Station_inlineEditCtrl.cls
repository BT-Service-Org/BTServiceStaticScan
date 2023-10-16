public with sharing class The_Station_inlineEditCtrl {

    @AuraEnabled
    public static String getLexOriginUrl() {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    }
    
    @AuraEnabled
    public static Integer fetchAssociationCount(Id recordId) {
        Integer count = 0;
        count = [SELECT count() FROM StationGroupingAssociation__c  WHERE Station_Page__c =:recordId];
        return count;
    }
    
    // method for fetch StationGroupingAssociation__c records list  
    @AuraEnabled
    public static List<StationGroupingAssociation__c> fetchAssociation(Id recordId) {
        
        List < StationGroupingAssociation__c  > lstOfAssociation = new List < StationGroupingAssociation__c > ();
		lstOfAssociation = [Select Order__c , Name, Station_Content__c, Station_Content__r.Id, Station_Content__r.Name, Station_Content__r.Content_Type__c   from StationGroupingAssociation__c  Where Station_Page__c  =:recordId Limit 10];
        
        return lstOfAssociation;
    }
    
  // method for update records after inline editing  
    @AuraEnabled
    public static List<StationGroupingAssociation__c> saveAssociation(List<StationGroupingAssociation__c > lstAssociation) {
        update lstAssociation;
        return lstAssociation;
    }
    
    //method for deleting a record 
    @Auraenabled
    public static List<StationGroupingAssociation__c> delteAssociationBId(String recordId)
    {
        StationGroupingAssociation__c delAssociation=[Select Id from StationGroupingAssociation__c where id=:recordId];
        delete delAssociation;
        return [Select Order__c , Name, Station_Content__c, Station_Content__r.Id, Station_Content__r.Name, Station_Content__r.Content_Type__c   from StationGroupingAssociation__c  Where Station_Page__c  =:recordId Limit 10];
    }
  


}