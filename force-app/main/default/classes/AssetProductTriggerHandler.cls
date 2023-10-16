public class AssetProductTriggerHandler {
    
    public static void isUniqueRecord(List<Asset_Product__c> records,Map<Id,Asset_Product__c> oldRecords) {
        Map<Id, Map<Id,Asset_Product__c>>  reusableAssetToProductListMap  = new Map<Id, Map<Id,Asset_Product__c>>();
        Set<Id> productSet                                                 = new Set<Id>();
        List<Asset_Product__c> assetProductList                           = new List<Asset_Product__c>();
        
        for (Asset_Product__c reusableAssetProductObj : records) {
            if(oldRecords == null 
            || oldRecords.get(reusableAssetProductObj.Id).Product__c != reusableAssetProductObj.Product__c 
            || oldRecords.get(reusableAssetProductObj.Id).Reusable_Asset__c != reusableAssetProductObj.Reusable_Asset__c ){

                productSet.add(reusableAssetProductObj.Product__c);

                if(!reusableAssetToProductListMap.containsKey(reusableAssetProductObj.Reusable_Asset__c)){
                    reusableAssetToProductListMap.put(reusableAssetProductObj.Reusable_Asset__c, new Map<Id,Asset_Product__c>{reusableAssetProductObj.Product__c=>reusableAssetProductObj});
                } else if(!reusableAssetToProductListMap.get(reusableAssetProductObj.Reusable_Asset__c).containsKey(reusableAssetProductObj.Product__c)){
                    reusableAssetToProductListMap.get(reusableAssetProductObj.Reusable_Asset__c).put(reusableAssetProductObj.Product__c,reusableAssetProductObj);
                }
            }
        }

        if(reusableAssetToProductListMap != null && !reusableAssetToProductListMap.isEmpty()){
            assetProductList = [SELECT Reusable_Asset__c, Product__c, Product__r.Name 
                                FROM Asset_Product__c 
                                WHERE Reusable_Asset__c IN :reusableAssetToProductListMap.keySet() 
                                AND Product__c IN :productSet];

            for (Asset_Product__c reusableAssetProductObj : assetProductList) {
                if(reusableAssetToProductListMap.containsKey(reusableAssetProductObj.Reusable_Asset__c) 
                && reusableAssetToProductListMap.get(reusableAssetProductObj.Reusable_Asset__c).containsKey(reusableAssetProductObj.Product__c)){
                    reusableAssetToProductListMap.get(reusableAssetProductObj.Reusable_Asset__c).get(reusableAssetProductObj.Product__c).addError('[' + reusableAssetProductObj.Product__r.Name + '] is already associated with this Reusable Asset and cannot be added again.');
                }
            }
        }
    }
}