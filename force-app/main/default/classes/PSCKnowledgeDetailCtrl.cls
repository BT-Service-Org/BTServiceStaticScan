public with sharing class PSCKnowledgeDetailCtrl {
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getArticleDetail(Id recordId){
        Map<String,Object> result;
        List<String> fields = new List<String>{'Title', 'KnowledgeArticleId', 'RecordType.Name', 'IsVisibleInPrm', 'IsVisibleInCsp'};
        Set<String> articleIds = new Set<String>{recordId};
        Knowledge__kav article = PSCKnowledgeArticlesService.getArticleById(articleIds, fields)[0];

        if (article != null) {
            result = new Map<String,Object>();
            result.put('Title', article.Title);
            result.put('RecordTypeName', article.RecordType.Name);
            result.put('KnowledgeArticleId', article.KnowledgeArticleId);

           

            String fieldsFromSettings = '';
            fieldsFromSettings  = PSCSettingService.getValue('PSC_Article_Fields');
            
            fields = new List<String>(fieldsFromSettings.deleteWhitespace().split(','));
            Knowledge__kav articleWithAdditionalFields = PSCKnowledgeArticlesService.getArticleById(articleIds, fields)[0];
            Map<String, SObjectField> sObjectFieldMap = Schema.getGlobalDescribe().get('Knowledge__kav').getDescribe().fields.getMap();

            List<Object> displayFields = new List<Object>();

            for (String field : fields) {
                String value = (String) articleWithAdditionalFields.get(field);
                if(value!=null){
                    displayFields.add(new Map<String,String> {
                        'label' => sObjectFieldMap.get(field).getDescribe().getLabel(),
                        'value' => sObjectFieldMap.get(field).getDescribe().getLabel() +' : '+ value?.replaceAll('\r\n', '<br>')
                    });
                }
            }

            result.put('Fields', displayFields);
        }
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getArticleRecordDetail(Id recordId){
        return [SELECT Id,LastPublishedDate,Nxt_Maintenance_Date__c, Title,Summary,Body__c,Owner.FirstName,Owner.LastName,OwnerId,KnowledgeArticleId,
                Curation_Level__c,Article_Indications__c,Visual_The_Salesforce_Way__c,Reviewer__r.FirstName, Reviewer__r.LastName,
                Additional_Author__r.FirstName,Additional_Author__r.LastName,
                    (SELECT Id, Link_Text__c, Link_Url__c
                    FROM Article_Links__r),
                    (SELECT Id,Name,Product__r.Name
                    FROM Article_Products__r),
                    (SELECT Id,Name,Industry__r.Name
                    FROM Article_Industries__r),
                    (SELECT Id,Name,Role__r.Name
                    FROM Article_Roles__r),
                    (SELECT Id,Name,Method__r.Name, Method__r.Method_Number__c
                    FROM Article_Methods__r
                    WHERE Method__r.Status__c = 'Published'
                    AND Method__r.Method_Number__c != NULL),
                    (SELECT Id,Tag__r.Name,Role_Family__r.Name,RecordType.DeveloperName
                    FROM Article_Tags__r)
                FROM Knowledge__kav
                WHERE Id=:recordId
                WITH SECURITY_ENFORCED];
    }

}