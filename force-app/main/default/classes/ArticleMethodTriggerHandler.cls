public class ArticleMethodTriggerHandler {
    
    public static void isUniqueRecord(List<Article_Method__c> records) {
        
        List<String> articleMethodUniqueKeyList = new List<String>();
        Map<String, String> articleMethodUniqueKeyMap = new Map<String, String>();
        for (Article_Method__c artclMethd : records) {
            articleMethodUniqueKeyList.add(String.valueOf(artclMethd.Knowledge__c) + String.valueOf(artclMethd.Method__c));
            
        }
        List<Article_Method__c> existingArticleMethod =  [SELECT Id, Name, Knowledge__c, Method__c,Method__r.Name, Unique_Key__c FROM Article_Method__c WHERE Unique_Key__c IN:articleMethodUniqueKeyList];
        
        for(Article_Method__c eArtMthd :existingArticleMethod){
            
            articleMethodUniqueKeyMap.put(String.valueOf(eArtMthd.Knowledge__c) + String.valueOf(eArtMthd.Method__c),eArtMthd.Method__r.Name);
        }
        
        for (Article_Method__c artclMethd : records) {
            
            if(articleMethodUniqueKeyMap.containsKey(String.valueOf(artclMethd.Knowledge__c) + String.valueOf(artclMethd.Method__c))){
                String recordName = articleMethodUniqueKeyMap.get(String.valueOf(artclMethd.Knowledge__c) + String.valueOf(artclMethd.Method__c));
                artclMethd.addError('['+recordName+'] is already associated with this Article and cannot be added again.');
            }
            else{
                artclMethd.Unique_Key__c = String.valueOf(artclMethd.Knowledge__c) + String.valueOf(artclMethd.Method__c);
            }
        }
    }
}