/**
 * @description : This class is used as controller for contribute component
 * @author : anurag.suman
 * @since : November 2022
 * @group : Services Central
 * @version : 1.0
 */
public with sharing class PSCContributeCtrl {
    public static Id productRecordTypeId = Schema.getGlobalDescribe().get(PSCConstants.PRODUCT_CUSTOM_SOBJECT)?.getDescribe()?.getRecordTypeInfosByDeveloperName()?.get(PSCConstants.PRODUCT_RECORDTYPE)?.getRecordTypeId();
    
    /**
     * @description : This method is used to get the dependent picklist values
     * @return  `List<ContributeWrapper>`
     */
    @AuraEnabled(cacheable=true)
    public static List<ContributeWrapper> getDependentPicklistValues(){
        List<String> resourceTypeExcludes = new List<String>();
        List<String> assetTypeExcludes = new List<String>();

        List<ContributeWrapper> contributeWrapperList = new List<ContributeWrapper>();
        Schema.DescribeFieldResult assetFieldResult = Knowledge__kav.Asset_Type__c.getDescribe();
        Schema.sObjectField assetField = assetFieldResult.getSObjectField();

        resourceTypeExcludes = PSCSettingService.getValue('Contribute_Resource_Type_Exclude')?.split(',');
        assetTypeExcludes = PSCSettingService.getValue('Contribute_Asset_Type_Exclude')?.split(',');
        
        Map<String,List<ContributeWrapperInner>> options = getDependentPicklistValues(assetField);
        String resourceTypeValue, resourceTypeLabel;
        for(String resourceTypeKey: options.keySet()){
            resourceTypeLabel = resourceTypeKey.split('::')[0];
            resourceTypeValue = resourceTypeKey.split('::')[1];
            if(resourceTypeExcludes == null || !resourceTypeExcludes.contains(resourceTypeValue)){
                List<ContributeWrapperInner> contributeWrapperInnerList = new List<ContributeWrapperInner>();
                for(ContributeWrapperInner assetType : options.get(resourceTypeKey)){
                    if(assetTypeExcludes == null || !assetTypeExcludes.contains(assetType.value)){
                        contributeWrapperInnerList.add(assetType);
                    }
                }
                contributeWrapperList.add(new ContributeWrapper(resourceTypeValue, resourceTypeLabel, contributeWrapperInnerList));
            }
        }
        return contributeWrapperList;
    }

    /**
     * @description : This method is used to get the dependent picklist values
     * @param dependentField 
     * @return  `Map<String, List<ContributeWrapperInner>>`
     */
    public static Map<String, List<ContributeWrapperInner>> getDependentPicklistValues(Schema.sObjectField dependentField){
        Map<String,List<ContributeWrapperInner>> dependentPicklistValues = new Map<String,List<ContributeWrapperInner>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
        if(controllerField == null){
            return null;
        } 
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        //Get controlling field picklist options if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
        
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        String label,controllerValueKey;

        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry)))?.get('validFor')))){
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i] : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    }
                    controllerValueKey = (PSCConstants.PSC_CONTRIBUTE_RESOURCE_TYPE_LABEL_MAP.containsKey(controllerValues[i].getLabel()) ? PSCConstants.PSC_CONTRIBUTE_RESOURCE_TYPE_LABEL_MAP.get(controllerValues[i].getLabel()) : controllerValues[i].getValue()) +'::'+controllerValues[i].getValue();
                    if (!dependentPicklistValues.containsKey((String)controllerValueKey)){
                        dependentPicklistValues.put((String)controllerValueKey,  new List<ContributeWrapperInner>());
                    }
                    label = PSCConstants.PSC_CONTRIBUTE_ASSET_TYPE_LABEL_MAP.containsKey(entry.getLabel()) ? PSCConstants.PSC_CONTRIBUTE_ASSET_TYPE_LABEL_MAP.get(entry.getLabel()) : entry.getLabel();
                    dependentPicklistValues.get((String)controllerValueKey).add(new ContributeWrapperInner(label, entry.getValue()));
                    
                }
            }
        }
        return dependentPicklistValues;
    }

    /**
     * @description : This method is used to get the contribute data
     * @return  `List<ContributeWrapper>`
     */
    @AuraEnabled(cacheable=true)
    public static List<ContributeWrapper> getContributeData(){
        
        List<Product_Custom__c> allProductList = new List<Product_Custom__c>([SELECT Id, Name 
                                                                                FROM Product_Custom__c 
                                                                                WHERE recordTypeId = :productRecordTypeId
                                                                                AND Include_in_Create__c = TRUE]);

        List<Role_Family__c> allRoleList = new List<Role_Family__c>([SELECT Id, Name 
                                                        FROM Role_Family__c]);


        List<Industry__c> allIndustries = new List<Industry__c>([SELECT Id, Name 
                                                                 FROM Industry__c 
                                                                 ORDER BY Order__c, Name]);

        List<ContributeWrapper> contributeWrapperList = new List<ContributeWrapper>{new ContributeWrapper(PSCConstants.CONTRIBUTE_INDUSTRY_LABEL, (List<SObject>) allIndustries), 
                                new ContributeWrapper(PSCConstants.CONTRIBUTE_PRODUCT_LABEL, (List<SObject>)allProductList),
                                new ContributeWrapper(PSCConstants.CONTRIBUTE_AUDIENCE_LABEL, (List<SObject>)allRoleList)
                            };
        return contributeWrapperList;
    }

    /**
     * @description : This method is used to get the Knowledge Record Type Id
     * @return  `Id` of Knowledge Record Type
     */
    @AuraEnabled(cacheable=true)
    public static Id getKnowlegdeRecordType(){
        Id knowledgeRecordTypeId = Schema.getGlobalDescribe().get(PSCConstants.KNOWLEDGE_SOBJECT)?.getDescribe()?.getRecordTypeInfosByDeveloperName()?.get(PSCConstants.PSC_KNOWLEDGE_RECORDTYPE)?.getRecordTypeId();
        return knowledgeRecordTypeId;
    }
    @AuraEnabled
    public static String getTagName(String tagId) {
        String tag = [SELECT Name
                      FROM Tag__c 
                      WHERE Id=:tagId]?.Name;
        return tag;
    }

    /**
     * @description : creates child record of Knowledge related objects
     * @param knowledgeId - Knowledge id of the record created
     * @param isAutoPublish - boolean variable to decide if the record is auto published or not
     * @param productIdString 
     * @param industryIdString 
     * @param contentIdString 
     * @param roleIdString 
     * @param acticleLinks 
     * @param articleTags
     * @return  `String`
     * @exception 
     */

    @AuraEnabled
    public static String updateContributeData(Id knowledgeId, Boolean isAutoPublish, String productIdString, String industryIdString, String contentIdString, String roleIdString,List<Article_Link__c> acticleLinks, List<Article_Tags__c> articleTags){
        try {
            List<Id> productIds= (List<Id>) JSON.deserialize(productIdString, List<Id>.class);
            List<Id> industryIds= (List<Id>) JSON.deserialize(industryIdString, List<Id>.class);
            List<Id> roleIds= (List<Id>) JSON.deserialize(roleIdString, List<Id>.class);
            List<Id> parentProductIdList = new List<Id>();
            List<sObject> relatedObjects1 = new List<sObject>();
            List<sObject> relatedObjects2= new List<sObject>();


            if(knowledgeId != null && String.isNotBlank(contentIdString)){
                PSCContributionService.updateContentDocumentLink(contentIdString, knowledgeId);
            }
            
            if(productIds != null && !productIds.isEmpty()){
                List<Article_Product__c> articleProductList = new List<Article_Product__c>();
                List<Article_Product__c> articleParentProductList = new List<Article_Product__c>();
                for(Id productId : productIds){
                    articleProductList.add(new Article_Product__c(Knowledge__c = knowledgeId,Product__c = productId)); 
                }
                if(!articleProductList.isEmpty()){
                    relatedObjects1.addAll(articleProductList);
                }
                List<Product_Custom__c> allParentProductList = new List<Product_Custom__c>([SELECT Id, Name ,Parent_Product__c
                                                                                            FROM Product_Custom__c 
                                                                                            WHERE recordTypeId = :productRecordTypeId
                                                                                            AND Id IN :productIds
                                                                                            AND Parent_Product__c != NULL]);
                // 2 DMLs are done intentionally to maintain order of the records
                // 1 DML is done to create child records first
                // 1 DML is done to create the parent products
                for(Product_Custom__c each:allParentProductList){
                    if(!parentProductIdList.contains(each.Parent_Product__c)){
                        parentProductIdList.add(each.Parent_Product__c);
                        articleParentProductList.add(new Article_Product__c(Knowledge__c = knowledgeId,Product__c = each.Parent_Product__c)); 
                    }
                }
                if(articleParentProductList != null && !articleParentProductList.isEmpty()){
                    relatedObjects2.addAll(articleParentProductList);
                }
            }

            if(industryIds != null && !industryIds.isEmpty()){
                List<Article_Industry__c> articleIndustryList = new List<Article_Industry__c>();
                for(Id industryId : IndustryIds){
                    articleIndustryList.add(new Article_Industry__c(Knowledge__c = knowledgeId,Industry__c = industryId)); 
                }
                if(!articleIndustryList.isEmpty()){
                    relatedObjects1.addAll(articleIndustryList);
                }
            }

            if(roleIds != null && !roleIds.isEmpty()){
                List<Article_Tags__c> articleRolesList = new List<Article_Tags__c>();
                Id roleFamilyRecordtypeId = Schema.getGlobalDescribe().get('Article_Tags__c')?.getDescribe()?.getRecordTypeInfosByDeveloperName()?.get('Role_Family_Relationship')?.getRecordTypeId();

                for(Id each : roleIds){
                    articleRolesList.add(new Article_Tags__c(Knowledge__c = knowledgeId,Role_Family__c = each,RecordTypeId = roleFamilyRecordtypeId)); 
                }
                if(!articleRolesList.isEmpty()){
                    relatedObjects1.addAll(articleRolesList);
                }
            }

            for(Article_Link__c each:acticleLinks){
                each.Knowledge__c = knowledgeId;
            }
            if(acticleLinks != null && !acticleLinks.isEmpty()){
                relatedObjects2.addAll(acticleLinks);
            }

            for(Article_Tags__c each:articleTags){
                each.Knowledge__c = knowledgeId;
            }
            if(articleTags != null && !articleTags.isEmpty()){
                relatedObjects2.addAll(articleTags);
            }

            if(relatedObjects1 != null && !relatedObjects1.isEmpty()){
                insert relatedObjects1;
            }
            if(relatedObjects2 != null && !relatedObjects2.isEmpty()){
                insert relatedObjects2;
            }
            

            if(!isAutoPublish && knowledgeId != null){
                Knowledge__kav knowledge =  [SELECT KnowledgeArticleId, Reviewer__c, Id, OwnerId, Resource_Type__c, Curation_Level__c
                                            FROM Knowledge__kav 
                                            WHERE Id = :knowledgeId];
                KbManagement.PublishingService.publishArticle(knowledge.KnowledgeArticleId, true);
                PSCGamificationService.createKnowledgeRelatedUAA(new List<Knowledge__kav>{knowledge});
            } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return Url.getOrgDomainUrl().toExternalForm();
    }

    /**
     * 
     * @param reusableAssetId 
     * @param isAutoPublish 
     * @param productIdString 
     * @param industryIdString 
     * @param contentIdString 
     * @param roleIdString 
     * @param articleTags
     * @return  `String`
     * @exception 
     */
    @AuraEnabled
    public static String updateContributeRAData(Id reusableAssetId, Boolean isAutoPublish, String productIdString, String industryIdString, String contentIdString, String roleIdString,List<Article_Tags__c> articleTags){
        try {
            List<Id> productIds = (List<Id>) JSON.deserialize(productIdString, List<Id>.class);
            List<Id> industryIds = (List<Id>) JSON.deserialize(industryIdString, List<Id>.class);
            List<Id> roleIds= (List<Id>) JSON.deserialize(roleIdString, List<Id>.class);
            List<sObject> relatedObjects1= new List<sObject>();
            List<sObject> relatedObjects2= new List<sObject>();
            List<Id> parentProductIdList= new List<Id>();
            List<Asset_Product__c> assetParentProductList= new List<Asset_Product__c>();

            if(isAutoPublish){
                Reusable_Asset__c raObj = new Reusable_Asset__c();
                raObj.Id = reusableAssetId;
                raObj.Status__c = 'In Review';
                update raObj;
            } else {
                Reusable_Asset__c raObj = new Reusable_Asset__c();
                raObj.Id = reusableAssetId;
                raObj.Status__c = 'Published';
                update raObj;

            }

            if(reusableAssetId != null && String.isNotBlank(contentIdString)){
                PSCContributionService.updateContentDocumentLink(contentIdString, reusableAssetId);
            }


            if(industryIds != null && !industryIds.isEmpty()){
                List<Asset_Industry__c> assetIndustryList = new List<Asset_Industry__c>();
                for(Id industryId : IndustryIds){
                    assetIndustryList.add(new Asset_Industry__c(Reusable_Asset__c = reusableAssetId,Industry__c = industryId)); 
                }
                relatedObjects1.addAll(assetIndustryList);
            }
            
            if(productIds != null && !productIds.isEmpty()){
                List<Asset_Product__c> assetProductList = new List<Asset_Product__c>();
                
                for(Id productId : productIds){
                    assetProductList.add(new Asset_Product__c(Reusable_Asset__c = reusableAssetId,Product__c = productId)); 
                }
                relatedObjects1.addAll(assetProductList);

                List<Product_Custom__c> allParentProductList = new List<Product_Custom__c>([SELECT Id, Name ,Parent_Product__c
                                                                                            FROM Product_Custom__c 
                                                                                            WHERE recordTypeId = :productRecordTypeId
                                                                                            AND Id IN :productIds
                                                                                            AND Parent_Product__c != NULL]);

                for(Product_Custom__c each:allParentProductList){
                    if(!parentProductIdList.contains(each.Parent_Product__c)){
                        parentProductIdList.add(each.Parent_Product__c);
                        assetParentProductList.add(new Asset_Product__c(Reusable_Asset__c = reusableAssetId,Product__c = each.Parent_Product__c)); 
                    }
                }
                insert assetParentProductList;
            }

            if(roleIds != null && !roleIds.isEmpty()){
                List<Article_Tags__c> articleRolesList = new List<Article_Tags__c>();
                Id roleFamilyRecordtypeId = Schema.getGlobalDescribe().get('Article_Tags__c')?.getDescribe()?.getRecordTypeInfosByDeveloperName()?.get('Role_Family_Relationship')?.getRecordTypeId();

                for(Id each : roleIds){
                    articleRolesList.add(new Article_Tags__c(Reusable_Asset__c = reusableAssetId,Role_Family__c = each,RecordTypeId = roleFamilyRecordtypeId)); 
                }
                if(!articleRolesList.isEmpty()){
                    relatedObjects2.addAll(articleRolesList);
                }
            }

            for(Article_Tags__c each:articleTags){
                each.Reusable_Asset__c = reusableAssetId;
            }
            if(articleTags != null && !articleTags.isEmpty()){
                relatedObjects2.addAll(articleTags);
            }


            if(relatedObjects1 != null && !relatedObjects1.isEmpty()){
                insert relatedObjects1;
            }
            if(relatedObjects2 != null && !relatedObjects2.isEmpty()){
                insert relatedObjects2;
            }
            // Do a null check on assetParentProductList variable and update if not null
            if(assetParentProductList != null && !assetParentProductList.isEmpty()){
                update assetParentProductList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return Url.getOrgDomainUrl().toExternalForm();
    }

    /**
     * @author anurag.suman
     * @description Wrapper class for Contribute component
     */
    public class ContributeWrapper{
        @AuraEnabled
        public String key{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public List<ContributeWrapperInner> options{get;set;}
        @AuraEnabled
        public List<SObject> recordList;
        public ContributeWrapper(String key, String label, List<ContributeWrapperInner> options){
            this.key = key;
            this.label = label;
            this.options = options;
        }
        public ContributeWrapper(String key, List<SObject> recordList){
            this.key = key;
            this.recordList = recordList;
        }
    }

    public class ContributeWrapperInner{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        public ContributeWrapperInner(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}