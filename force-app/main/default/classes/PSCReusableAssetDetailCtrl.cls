public with sharing class PSCReusableAssetDetailCtrl {
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getReusableAssetDetail(Id recordId){
        Map<String,Object> result;
        List<String> fields = new List<String>{'Title', 'KnowledgeArticleId', 'RecordType.Name', 'IsVisibleInPrm', 'IsVisibleInCsp'};
        Set<String> articleIds = new Set<String>{recordId};
     //   Knowledge__kav article = PSCKnowledgeArticlesService.getArticleById(articleIds, fields)[0];
        
        Reusable_Asset__c  reusableAsset = [SELECT id,Asset_Type__c, Benefits__c, Demo_Link__c, Description__c, Design_Link__c, Github_Handle__c, Maintenance_Cycle__c, 
                                             Name, Next_Maintenance_Date__c, Owner.FirstName, Owner.LastName, Project_Description__c, Project_Name__c, Project_Org62_URL__c, 
                                             RecordType.Name, Repository_Link__c, Resource_Type__c, Reviewed_By__c, Reviewed_By__r.FirstName, Reviewed_By__r.LastName, 
                                             Status__c, Title__c,CreatedDate  from Reusable_Asset__c WHERE Id =:recordId];

        if (reusableAsset != null) {
            result = new Map<String,Object>();
            result.put('Title', reusableAsset.Title__c);
            result.put('RecordTypeName', reusableAsset.RecordType.Name);
            result.put('KnowledgeArticleId', reusableAsset.Id);

           

            String fieldsFromSettings = '';
            fieldsFromSettings  = PSCSettingService.getValue('PSC_Article_Fields');
            
            fields = new List<String>(fieldsFromSettings.deleteWhitespace().split(','));
           // Knowledge__kav articleWithAdditionalFields = PSCKnowledgeArticlesService.getArticleById(articleIds, fields)[0];
            Map<String, SObjectField> sObjectFieldMap = Schema.getGlobalDescribe().get('Reusable_Asset__c').getDescribe().fields.getMap();

            List<Object> displayFields = new List<Object>();

            for (String field : fields) {
                String value = (String) reusableAsset.get(field);
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
    public static List<Reusable_Asset__c> getReusableAssetRecordDetail(Id recordId){
        return [SELECT id,Asset_Type__c, Benefits__c, Demo_Link__c, Description__c, Design_Link__c, Github_Handle__c, Maintenance_Cycle__c, 
                                             Name, Next_Maintenance_Date__c,Owner.Name, Project_Description__c, Project_Name__c, Project_Org62_URL__c, 
                                             RecordType.Name, Repository_Link__c, Resource_Type__c, Reviewed_By__c, Reviewed_By__r.FirstName, Reviewed_By__r.LastName, 
                                             Status__c, Title__c, CreatedDate, Asset_Indications__c, Curation_Level__c,
                    (SELECT Id,Name,Product__r.Name
                    FROM Asset_Products__r),
                    (SELECT Id,Name,Industry__r.Name
                    FROM Asset_Industries__r),
                    (SELECT Id,Tag__r.Name,Role_Family__r.Name,RecordType.DeveloperName
                    FROM Reusable_Asset_Tags__r)
                FROM Reusable_Asset__c
                WHERE Id=:recordId
                WITH SECURITY_ENFORCED];
    }

}