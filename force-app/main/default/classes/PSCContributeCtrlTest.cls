@isTest
public class PSCContributeCtrlTest {
    @TestSetup
    static void makeData(){  
        Test.startTest();
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser FROM User 
                           WHERE Id=:userinfo.getUserId() LIMIT 1];
        if(user != null && !user.isEmpty()){
            user[0].UserPermissionsKnowledgeUser = true;
            update user;
        }
		Test.stopTest();   
        
        //Creating the knowledge
        Knowledge__kav knowledge = PSCTestDataFactory.createKnowledge();
        insert knowledge;
        //Creating the industry
        Product_Custom__c prod = PSCTestDataFactory.createProduct('Product');
        prod.RecordTypeId = Schema.getGlobalDescribe().get(PSCConstants.PRODUCT_CUSTOM_SOBJECT)?.getDescribe()?.getRecordTypeInfosByDeveloperName()?.get(PSCConstants.PRODUCT_RECORDTYPE)?.getRecordTypeId();
        insert prod;
        //Creating the product 
        Industry__c industry = PSCTestDataFactory.createIndustry('Industry', 1);
        insert industry;
        //Creating content document
        ContentVersion file = PSCTestDataFactory.createFile();
        insert file;
    }

    @isTest
    public static void getDependentPicklistValuesTest(){
        System.assertEquals(true, PSCContributeCtrl.getDependentPicklistValues().size() > 0,'Resouce And associated Asset values List should be returned');
        System.assertEquals(true, PSCContributeCtrl.getKnowlegdeRecordType() != null, 'Knowlegde__kav should have PSC Contribute Record Type');
    }

    @isTest
    public static void getContributeDataTest(){
        Test.startTest();
            List<PSCContributeCtrl.ContributeWrapper> contributeDataList = PSCContributeCtrl.getContributeData();
        Test.stopTest();

        System.assertEquals(true, contributeDataList != null,'Contribution data should return the list');
        System.assertEquals(PSCConstants.CONTRIBUTE_INDUSTRY_LABEL, contributeDataList[0].key, 'Contribution should contain industry');
        System.assertEquals(PSCConstants.CONTRIBUTE_PRODUCT_LABEL, contributeDataList[1].key, 'Contribution should contain product');
    }

    @isTest
    public static void updateContributeDataTest1(){
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser FROM User WHERE Id = :userinfo.getUserId() LIMIT 1];
        List<ContentDocument> conDocList = new List<ContentDocument>([SELECT Id FROM ContentDocument LIMIT 1]);
        List<Knowledge__kav> knowledgeList = [SELECT Id, urlName FROM Knowledge__kav LIMIT 1];
        List<Id> productList = new List<Id>();
        List<Id> industryList = new List<Id>();

        for (Product_Custom__c product : [SELECT Id FROM Product_Custom__c]) {
            productList.add(product.Id);
        }
        for (Industry__c industry : [SELECT Id FROM Industry__c]) {
            industryList.add(industry.Id);
        }
        String urlName;
        System.runAs(user[0]){
            PSCContributeCtrl.updateContributeData(knowledgeList[0].Id, true, JSON.serialize(productList), JSON.serialize(industryList), JSON.serialize(new List<Id>{conDocList[0].Id}));
        }
        knowledgeList = [SELECT Id, urlName, PublishStatus FROM Knowledge__kav WHERE Id = :knowledgeList[0].Id];
        System.assertEquals('Online', knowledgeList[0].PublishStatus , 'Knowledge Article should be published');
    }

    @isTest
    public static void updateContributeDataTest2(){
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser FROM User WHERE Id = :userinfo.getUserId() LIMIT 1];
        List<ContentDocument> conDocList = new List<ContentDocument>([SELECT Id FROM ContentDocument LIMIT 1]);
        List<Knowledge__kav> knowledgeList = [SELECT Id, urlName FROM Knowledge__kav LIMIT 1];
        List<Id> productList = new List<Id>();
        List<Id> industryList = new List<Id>();

        for (Product_Custom__c product : [SELECT Id FROM Product_Custom__c]) {
            productList.add(product.Id);
        }
        for (Industry__c industry : [SELECT Id FROM Industry__c]) {
            industryList.add(industry.Id);
        }
        String urlName;
        System.runAs(user[0]){
            urlName = PSCContributeCtrl.updateContributeData(knowledgeList[0].Id, false, JSON.serialize(productList), JSON.serialize(industryList), JSON.serialize(new List<Id>{conDocList[0].Id}));
        }
        knowledgeList = [SELECT Id, urlName, PublishStatus FROM Knowledge__kav WHERE Id = :knowledgeList[0].Id];
        System.assertEquals('Draft', knowledgeList[0].PublishStatus , 'Knowledge Article should be Draft');    
    }

    @isTest
    public static void deleteContentDocument(){
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser FROM User WHERE Id = :userinfo.getUserId() LIMIT 1];
        List<ContentDocument> conDocList = new List<ContentDocument>([SELECT Id FROM ContentDocument LIMIT 1]);
        Test.startTest();
            PSCContributionService.deleteContentDocument(JSON.serialize(new List<Id>{conDocList[0].Id}));
        Test.stopTest();
        List<ContentDocument> conDocListAfter = new List<ContentDocument>([SELECT Id FROM ContentDocument LIMIT 1]);
        System.assertEquals(true, conDocListAfter.isEmpty() , 'Content Document should not exist');    
    }
}