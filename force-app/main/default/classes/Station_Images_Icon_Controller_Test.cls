@isTest (SeeAllData=true)
private class Station_Images_Icon_Controller_Test{
    @isTest
    static void TestgetDetails()
    {
        // query test Data
        Station_Pages__c sp= new Station_Pages__c(Name='Test Page for Image',Cloud_Product__c='	Evergreen',Tab_Name__c='Technical Readout'); 
        insert sp;
        String strStationPageId=sp.id;
        // Get RecordType Id for Leadership Team record Type
        RecordType sRecordTypeURL=[Select Id from recordType where Name='URL'and SobjectType='Station_Content__c'];
        Id sRecordTypeIdURL=sRecordTypeURL.Id;
        RecordType sRecordTypeAE=[Select Id from recordType where Name='App Exchange'and SobjectType='Station_Content__c'];
        Id sRecordTypeIdAE=sRecordTypeAE.Id;
        // Add Content records and set Station Page Id
        Station_Content__c scu= new Station_Content__c(RecordTypeId=sRecordTypeIdURL,Name='Test URL1',Content_Type__c='URL');
        insert scu;
        Station_Content__c sca= new Station_Content__c(RecordTypeId=sRecordTypeIdAE,Name='Test AppExchange',Content_Type__c='App Exchange');
        insert sca;
        StationGroupingAssociation__c scg1= new StationGroupingAssociation__c(Station_Content__c=scu.id,Station_Page__c=sp.id,order__c=1);
        StationGroupingAssociation__c scg2= new StationGroupingAssociation__c(Station_Content__c=sca.id,Station_Page__c=sp.id,order__c=2);
        insert scg1;
        insert scg2;
       
        Test.startTest();
        List<Station_Images_Icons_Controller.StationImageContent> ImageList=Station_Images_Icons_Controller.getContentDetails(strStationPageId);
        Test.stopTest();
   }
}