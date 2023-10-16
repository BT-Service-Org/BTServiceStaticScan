/**
 * 
 * @author anurag.suman
 * @since Jun 2023
 * @description Handler class for Article Tags Trigger
 * @group Services Central
 */
public class ArticleTagsTriggerHandler {
    public static void isUniqueRecord(List<Article_Tags__c> records,Map<Id,Article_Tags__c> oldRecords) {
        Map<Id, Map<Id,Article_Tags__c>>  articleToTagListMap           = new Map<Id, Map<Id,Article_Tags__c>>();
        Set<Id> dupsIdSet                                               = new Set<Id>();
        Id parentRecId;
        Id dupRecToIdentifyId;

        for (Article_Tags__c articleTagObj : records) { 
            if(oldRecords == null 
            || oldRecords.get(articleTagObj.Id).Tag__c != articleTagObj.Tag__c 
            || oldRecords.get(articleTagObj.Id).Role_Family__c != articleTagObj.Role_Family__c 
            || oldRecords.get(articleTagObj.Id).Knowledge__c != articleTagObj.Knowledge__c
            || oldRecords.get(articleTagObj.Id).Reusable_Asset__c != articleTagObj.Reusable_Asset__c ){
                parentRecId = (articleTagObj.Knowledge__c != null ? articleTagObj.Knowledge__c: (articleTagObj.Reusable_Asset__c != null ? articleTagObj.Reusable_Asset__c: null));
                if(articleTagObj.Tag__c != null){
                    dupsIdSet.add(articleTagObj.Tag__c);
                    if(!articleToTagListMap.containsKey(parentRecId)){
                        articleToTagListMap.put(parentRecId, new Map<Id,Article_Tags__c>{articleTagObj.Tag__c=>articleTagObj});
                    } else if(!articleToTagListMap.get(parentRecId).containsKey(articleTagObj.Tag__c)){
                        articleToTagListMap.get(parentRecId).put(articleTagObj.Tag__c,articleTagObj);
                    }
                }
                else if(articleTagObj.Role_Family__c != null){
                    dupsIdSet.add(articleTagObj.Role_Family__c);
                    if(!articleToTagListMap.containsKey(parentRecId)){
                        articleToTagListMap.put(parentRecId, new Map<Id,Article_Tags__c>{articleTagObj.Role_Family__c=>articleTagObj});
                    } else if(!articleToTagListMap.get(parentRecId).containsKey(articleTagObj.Role_Family__c)){
                        articleToTagListMap.get(parentRecId).put(articleTagObj.Role_Family__c,articleTagObj);
                    }
                }
            }
        }

        if(articleToTagListMap != null && !articleToTagListMap.isEmpty()){
            for (Article_Tags__c articleTagObj : [SELECT Knowledge__c, Tag__c, Tag__r.Name ,Reusable_Asset__c ,Role_Family__c, Role_Family__r.Name
                                                    FROM Article_Tags__c 
                                                    WHERE (Knowledge__c IN :articleToTagListMap.keySet() 
                                                        OR Reusable_Asset__c IN :articleToTagListMap.keySet())
                                                    AND (Tag__c IN :dupsIdSet
                                                         OR Role_Family__c IN :dupsIdSet)]) {
                parentRecId = (articleTagObj.Knowledge__c != null ? articleTagObj.Knowledge__c: (articleTagObj.Reusable_Asset__c != null ? articleTagObj.Reusable_Asset__c: null));
                if(articleToTagListMap.containsKey(parentRecId) 
                && articleToTagListMap.get(parentRecId).containsKey(articleTagObj.Tag__c)){
                    articleToTagListMap.get(parentRecId).get(articleTagObj.Tag__c).addError('[' + articleTagObj.Tag__r.Name  + '] is already associated and cannot be added again.');
                }
				else if(articleToTagListMap.containsKey(parentRecId) 
                && articleToTagListMap.get(parentRecId).containsKey(articleTagObj.Role_Family__c)){
                    articleToTagListMap.get(parentRecId).get(articleTagObj.Role_Family__c).addError('[' + articleTagObj.Role_Family__r.Name  + '] is already associated and cannot be added again.');
                }
            }
        }
    }
}