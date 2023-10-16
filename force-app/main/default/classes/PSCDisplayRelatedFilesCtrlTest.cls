@isTest
public class PSCDisplayRelatedFilesCtrlTest {
    @isTest
    public static void positiveAllRecommendationsTest1(){
        
        Product_Custom__c prod = PSCTestDataFactory.createProduct('Product');
        insert prod;
        
        ContentVersion file = PSCTestDataFactory.createFile();
        insert file;
        
        List<ContentDocument> conDoc = [SELECT Id
                                       FROM ContentDocument
                                       LIMIT 1];
            
        ContentDocumentLink conDocLink = PSCTestDataFactory.createContentDocLink(conDoc[0].Id,prod.Id);
        insert conDocLink;
        
        Test.startTest();
        
        PSCDisplayRelatedFilesCtrl.getContentDocumentIDs(prod.Id);
        
        Test.stopTest();
    }
}