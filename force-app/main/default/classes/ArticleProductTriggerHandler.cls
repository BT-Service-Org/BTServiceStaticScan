/**
 * 
 * @author anurag.suman
 * @since July 2023
 */
public class ArticleProductTriggerHandler {
    
    public static void isUniqueRecord(List<Article_Product__c> records,Map<Id,Article_Product__c> oldRecords) {
        Map<Id, Map<Id,Article_Product__c>>  reusableArticleToProductListMap    = new Map<Id, Map<Id,Article_Product__c>>();
        Set<Id> productSet                                                      = new Set<Id>();
        List<Article_Product__c> articleProductList                             = new List<Article_Product__c>();
        
        for (Article_Product__c reusableArticleProductObj : records) {
            if(oldRecords == null 
            || oldRecords.get(reusableArticleProductObj.Id).Product__c != reusableArticleProductObj.Product__c 
            || oldRecords.get(reusableArticleProductObj.Id).Knowledge__c != reusableArticleProductObj.Knowledge__c ){

                productSet.add(reusableArticleProductObj.Product__c);

                if(!reusableArticleToProductListMap.containsKey(reusableArticleProductObj.Knowledge__c)){
                    reusableArticleToProductListMap.put(reusableArticleProductObj.Knowledge__c, new Map<Id,Article_Product__c>{reusableArticleProductObj.Product__c=>reusableArticleProductObj});
                } else if(!reusableArticleToProductListMap.get(reusableArticleProductObj.Knowledge__c).containsKey(reusableArticleProductObj.Product__c)){
                    reusableArticleToProductListMap.get(reusableArticleProductObj.Knowledge__c).put(reusableArticleProductObj.Product__c,reusableArticleProductObj);
                }
            }
        }

        if(reusableArticleToProductListMap != null && !reusableArticleToProductListMap.isEmpty()){
            articleProductList = [SELECT Knowledge__c, Product__c, Product__r.Name 
                                FROM Article_Product__c 
                                WHERE Knowledge__c IN :reusableArticleToProductListMap.keySet() 
                                AND Product__c IN :productSet];

            for (Article_Product__c reusableArticleProductObj : articleProductList) {
                if(reusableArticleToProductListMap.containsKey(reusableArticleProductObj.Knowledge__c) 
                && reusableArticleToProductListMap.get(reusableArticleProductObj.Knowledge__c).containsKey(reusableArticleProductObj.Product__c)){
                    reusableArticleToProductListMap.get(reusableArticleProductObj.Knowledge__c).get(reusableArticleProductObj.Product__c).addError('[' + reusableArticleProductObj.Product__r.Name + '] is already associated with this Article and cannot be added again.');
                }
            }
        }
    }
}