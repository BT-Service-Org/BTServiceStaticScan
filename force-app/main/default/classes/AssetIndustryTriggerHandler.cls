public class AssetIndustryTriggerHandler {
    
    public static void isUniqueRecord(List<Asset_Industry__c> records,Map<Id,Asset_Industry__c> oldRecords) {
        Map<Id, Map<Id,Asset_Industry__c>>  reusableAssetToIndustryListMap  = new Map<Id, Map<Id,Asset_Industry__c>>();
        Set<Id> industrySet                                                 = new Set<Id>();
        List<Asset_Industry__c> assetIndustryList                           = new List<Asset_Industry__c>();
        
        for (Asset_Industry__c reusableAssetIndustryObj : records) {
            if(oldRecords == null 
            || oldRecords.get(reusableAssetIndustryObj.Id).Industry__c != reusableAssetIndustryObj.Industry__c 
            || oldRecords.get(reusableAssetIndustryObj.Id).Reusable_Asset__c != reusableAssetIndustryObj.Reusable_Asset__c ){

                industrySet.add(reusableAssetIndustryObj.Industry__c);

                if(!reusableAssetToIndustryListMap.containsKey(reusableAssetIndustryObj.Reusable_Asset__c)){
                    reusableAssetToIndustryListMap.put(reusableAssetIndustryObj.Reusable_Asset__c, new Map<Id,Asset_Industry__c>{reusableAssetIndustryObj.Industry__c=>reusableAssetIndustryObj});
                } else if(!reusableAssetToIndustryListMap.get(reusableAssetIndustryObj.Reusable_Asset__c).containsKey(reusableAssetIndustryObj.Industry__c)){
                    reusableAssetToIndustryListMap.get(reusableAssetIndustryObj.Reusable_Asset__c).put(reusableAssetIndustryObj.Industry__c,reusableAssetIndustryObj);
                }
            }
        }

        if(reusableAssetToIndustryListMap != null && !reusableAssetToIndustryListMap.isEmpty()){
            assetIndustryList = [SELECT Reusable_Asset__c, Industry__c, Industry__r.Name 
                                FROM Asset_Industry__c 
                                WHERE Reusable_Asset__c IN :reusableAssetToIndustryListMap.keySet() 
                                AND Industry__c IN :industrySet];

            for (Asset_Industry__c reusableAssetIndustryObj : assetIndustryList) {
                if(reusableAssetToIndustryListMap.containsKey(reusableAssetIndustryObj.Reusable_Asset__c) 
                && reusableAssetToIndustryListMap.get(reusableAssetIndustryObj.Reusable_Asset__c).containsKey(reusableAssetIndustryObj.Industry__c)){
                    reusableAssetToIndustryListMap.get(reusableAssetIndustryObj.Reusable_Asset__c).get(reusableAssetIndustryObj.Industry__c).addError('[' + reusableAssetIndustryObj.Industry__r.Name + '] is already associated with this Reusable Asset and cannot be added again.');
                }
            }
        }
    }
}