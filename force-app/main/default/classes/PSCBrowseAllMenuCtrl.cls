public with sharing class PSCBrowseAllMenuCtrl {
    @AuraEnabled(cacheable=true)
    public static BrowseAllWrapper getMenuItemsByCategory(String categoryName){
        List<Product_Custom__c> productList = [SELECT Id,Name,Status__c,
                                                    (SELECT Id, Name, Status__c
                                                    FROM Parent_Product__r
                                                    WHERE RecordType.developerName = 'Product'
                                                    AND Status__c != 'Hidden'
                                                    ORDER BY Order__c ASC NULLS LAST)
                                                FROM Product_Custom__c
                                                WHERE RecordType.developerName = 'Product'
                                                AND Parent_Product__c = NULL
                                                AND Status__c != 'Hidden'
                                                ORDER BY Order__c ASC NULLS LAST];
        
        BrowseAllWrapper browseAllWrapperObj = new BrowseAllWrapper();
        browseAllWrapperObj.menuItems = productList;
        browseAllWrapperObj.imagePath = PSCSettingService.getValue(categoryName); 
        return browseAllWrapperObj;
    }

    public class BrowseAllWrapper{
        @auraEnabled
        public List<Product_Custom__c> menuItems{get;set;}
        @auraEnabled
        public String imagePath{get;set;}
    }
}