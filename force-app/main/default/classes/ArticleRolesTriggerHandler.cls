public class ArticleRolesTriggerHandler {
    
    public static void isUniqueRecord(List<Article_Roles__c> records) {
        
        List<String> articleRolesUniqueKeyList = new List<String>();
        Map<String, String> articleRolesUniqueKeyMap = new Map<String, String>();
        for (Article_Roles__c artclRl : records) {
            articleRolesUniqueKeyList.add(String.valueOf(artclRl.Knowledge__c) + String.valueOf(artclRl.Role__c));
           
        }
        List<Article_Roles__c> existingArticleRole =  [SELECT Id, Name, Knowledge__c, Role__c,Role__r.Name, Unique_Key__c FROM Article_Roles__c WHERE Unique_Key__c IN:articleRolesUniqueKeyList];
        
        for(Article_Roles__c eArtRole :existingArticleRole){
            
            articleRolesUniqueKeyMap.put(String.valueOf(eArtRole.Knowledge__c) + String.valueOf(eArtRole.Role__c),eArtRole.Role__r.Name);
        }
        
        for (Article_Roles__c artclRl : records) {
            
            if(articleRolesUniqueKeyMap.containsKey(String.valueOf(artclRl.Knowledge__c) + String.valueOf(artclRl.Role__c))){
                String recordName = articleRolesUniqueKeyMap.get(String.valueOf(artclRl.Knowledge__c) + String.valueOf(artclRl.Role__c));
                artclRl.addError('['+recordName+'] is already associated with this Article and cannot be added again.');
            }
            else{
                artclRl.Unique_Key__c = String.valueOf(artclRl.Knowledge__c) + String.valueOf(artclRl.Role__c);
            }
        }
    }
}