public with sharing class PSCCoveoSearchCtrl {

    @AuraEnabled(cacheable=true)
    public static List<String> getProductRelationship(){
        List<String> resultList                             = new List<String>();
        Map<String, List<String>> parentChildProductMap     = new Map<String, List<String>>();
        for (Product_Custom__c customProduct : [SELECT Id, Name, Parent_Product__c, Parent_Product__r.Name FROM Product_Custom__c ORDER BY Parent_Product__c]) {
            if(customProduct.Parent_Product__c != null && parentChildProductMap != null && !parentChildProductMap.isEmpty() && parentChildProductMap.containskey(customProduct.Parent_Product__r.Name)){
                parentChildProductMap.get(customProduct.Parent_Product__r.Name).add(customProduct.Name);
            } else if(customProduct.Parent_Product__c != null && parentChildProductMap != null && !parentChildProductMap.isEmpty() && !parentChildProductMap.containskey(customProduct.Parent_Product__r.Name)){
                parentChildProductMap.put(customProduct.Parent_Product__r.Name, new List<String>{customProduct.Name});
            } else if (customProduct.Parent_Product__c == null && customProduct.Name != null) {
                parentChildProductMap.put(customProduct.Name, new List<String>());   
            }
        }
        resultList.add(JSON.serialize(parentChildProductMap));

        User userData = [SELECT Id,JobFamily__c,JobProfile__c
                        FROM User
                        WHERE Id=: UserInfo.getUserId()];

        resultList.add(JSON.serialize(userData));
        return resultList;
    }
}