/**
 * 
 * @author anurag.suman
 * @since July 2023
 */
public class ArticleIndustryTriggerHandler {
    /**
     * 
     * @param records : Trigger.new records
     * @param oldRecords Trigger.oldmap records
     */
    public static void isUniqueRecord(List<Article_Industry__c> records,Map<Id,Article_Industry__c> oldRecords) {
        Map<Id, Map<Id,Article_Industry__c>>  reusableArticleToIndustryListMap      = new Map<Id, Map<Id,Article_Industry__c>>();
        Set<Id> industrySet                                                         = new Set<Id>();
        List<Article_Industry__c> ArticleIndustryList                               = new List<Article_Industry__c>();
        
        for (Article_Industry__c reusableArticleIndustryObj : records) {
            if(oldRecords == null 
            || oldRecords.get(reusableArticleIndustryObj.Id).Industry__c != reusableArticleIndustryObj.Industry__c 
            || oldRecords.get(reusableArticleIndustryObj.Id).Knowledge__c != reusableArticleIndustryObj.Knowledge__c ){

                industrySet.add(reusableArticleIndustryObj.Industry__c);

                if(!reusableArticleToIndustryListMap.containsKey(reusableArticleIndustryObj.Knowledge__c)){
                    reusableArticleToIndustryListMap.put(reusableArticleIndustryObj.Knowledge__c, new Map<Id,Article_Industry__c>{reusableArticleIndustryObj.Industry__c=>reusableArticleIndustryObj});
                } else if(!reusableArticleToIndustryListMap.get(reusableArticleIndustryObj.Knowledge__c).containsKey(reusableArticleIndustryObj.Industry__c)){
                    reusableArticleToIndustryListMap.get(reusableArticleIndustryObj.Knowledge__c).put(reusableArticleIndustryObj.Industry__c,reusableArticleIndustryObj);
                }
            }
        }

        if(reusableArticleToIndustryListMap != null && !reusableArticleToIndustryListMap.isEmpty()){
            articleIndustryList = [SELECT Knowledge__c, Industry__c, Industry__r.Name 
                                FROM Article_Industry__c 
                                WHERE Knowledge__c IN :reusableArticleToIndustryListMap.keySet() 
                                AND Industry__c IN :industrySet];

            for (Article_Industry__c reusableArticleIndustryObj : articleIndustryList) {
                if(reusableArticleToIndustryListMap.containsKey(reusableArticleIndustryObj.Knowledge__c) 
                && reusableArticleToIndustryListMap.get(reusableArticleIndustryObj.Knowledge__c).containsKey(reusableArticleIndustryObj.Industry__c)){
                    reusableArticleToIndustryListMap.get(reusableArticleIndustryObj.Knowledge__c).get(reusableArticleIndustryObj.Industry__c).addError('[' + reusableArticleIndustryObj.Industry__r.Name + '] is already associated with this article and cannot be added again.');
                }
            }
        }
    }
}