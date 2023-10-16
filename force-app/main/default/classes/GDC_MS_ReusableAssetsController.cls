public with sharing class GDC_MS_ReusableAssetsController {
    
    @AuraEnabled
    public static List<gdc_ms_ReusableAsset__c> getNonPublishedAssets(){
        try {
            return [SELECT Id, gdc_ms_Benefits__c,gdc_ms_CloudCompetency__c,gdc_ms_DemoLink__c,
                    gdc_ms_Description__c,gdc_ms_DesignLink__c,gdc_ms_IdeaClassification__c,
                    gdc_ms_IntendedDomainIndustries__c,gdc_ms_IsDesignReady__c,
                    gdc_ms_ProblemSolvedByThisAsset__c,gdc_ms_Proposed_By__c, 
                    gdc_ms_Proposed_By_User__c,gdc_ms_Proposed_By_User__r.Name,
                    gdc_ms_Proposed_By__r.Name,gdc_ms_RepositoryLink__c,
                    gdc_ms_Status__c,gdc_ms_Title__c 
                    FROM gdc_ms_ReusableAsset__c
                    WHERE gdc_ms_Status__c !='Delivered'];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<gdc_ms_ReusableAsset__c> getPublishedAssets(){
        try {
            return [SELECT Id, gdc_ms_Benefits__c,gdc_ms_CloudCompetency__c,gdc_ms_DemoLink__c,
                    gdc_ms_Description__c,gdc_ms_DesignLink__c,gdc_ms_IdeaClassification__c,
                    gdc_ms_IntendedDomainIndustries__c,gdc_ms_IsDesignReady__c,
                    gdc_ms_ProblemSolvedByThisAsset__c,gdc_ms_Proposed_By__c, 
                    gdc_ms_Proposed_By__r.Name,gdc_ms_Proposed_By_User__c,gdc_ms_Proposed_By_User__r.Name,
                    gdc_ms_RepositoryLink__c,gdc_ms_Status__c,gdc_ms_Title__c,gdc_ms_Asset_Rating__c ,
                    gdc_ms_Download_Count__c, gdc_ms_Feedback_Count__c
                    FROM gdc_ms_ReusableAsset__c
                    WHERE gdc_ms_Status__c ='Delivered'];
            
        } catch (Exception e) {
            system.debug('exception '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static gdc_ms_ReusableAsset__c getAssetDetails (String assetId){
        if(String.isEmpty(assetId)){
            return null;
        }
        return [SELECT id,gdc_ms_Benefits__c,gdc_ms_CloudCompetency__c,gdc_ms_DemoLink__c,
                gdc_ms_Description__c,gdc_ms_DesignLink__c,gdc_ms_IdeaClassification__c,
                gdc_ms_IntendedDomainIndustries__c,gdc_ms_IsDesignReady__c,
                gdc_ms_ProblemSolvedByThisAsset__c,gdc_ms_Proposed_By__c, 
                gdc_ms_Proposed_By__r.Name,gdc_ms_Proposed_By_User__c,gdc_ms_Proposed_By_User__r.Name,
                gdc_ms_RepositoryLink__c,gdc_ms_Status__c,
                gdc_ms_Title__c,gdc_ms_Asset_Rating__c,gdc_ms_Feedback_Count__c,gdc_ms_Download_Count__c,
                (SELECT id, gdc_ms_TeamMember__c, gdc_ms_Role__c,gdc_ms_TeamMember__r.Name FROM Asset_Members__r)
                FROM gdc_ms_ReusableAsset__c WHERE Id =: assetId];
    }
    
    @AuraEnabled
    public static String updateAssetMembers(List<gdc_ms_AssetMember__c> assetTeamMembers){
        String finalResult;
        String assetId;
        try{
            if(assetTeamMembers.isEmpty()){
                return 'No records to update';
            }
            assetId = assetTeamMembers.get(0)?.gdc_ms_ReusableAsset__c;
            List<gdc_ms_AssetMember__c> oldAssetMembers = [SELECT Id,Name FROM gdc_ms_AssetMember__c
                                                           WHERE gdc_ms_ReusableAsset__c =: assetId];
            Set<Id> updatedAssetMembersId = new Set<Id>();
            for (Integer i = (assetTeamMembers.size()-1) ; i>= 0 ; i--){
                gdc_ms_AssetMember__c assetMember = assetTeamMembers.get(i);
                if(String.isBlank(assetMember.gdc_ms_role__c) || String.isBlank(assetMember.gdc_ms_TeamMember__c)){
                    assetTeamMembers.remove(i);
                }
                String memberId = assetMember.Id;
                if(memberId.isNumeric()){
                    assetMember.Id = null;
                }else{
                    updatedAssetMembersId.add(memberId);
                }
            }
            upsert assetTeamMembers;
            List<gdc_ms_AssetMember__c> assetMembersToDelete = new List<gdc_ms_AssetMember__c>();
            for(gdc_ms_AssetMember__c assetMember : oldAssetMembers){
                if(!updatedAssetMembersId.contains(assetMember.Id)){
                    assetMembersToDelete.add(assetMember);
                }
            }
            delete assetMembersToDelete;
            finalResult = 'Records Updated Successfully';
            
        }catch(Exception ex){
            System.debug('Error while updating asset: '+ex.getMessage()+': '+ex.getStackTraceString());
            finalResult = 'Error while updating asset: '+ex.getMessage();
        }
        return finalResult;
    }

    @AuraEnabled
    public static gdc_ms_Feedback__c getFeedbackRecord(String userId, String assetId){
        System.debug('getFeedbackRecord '+userId+' '+assetId);
        if(String.isBlank(userId) || String.isBlank(assetId)){
            return null;
        }
        List<gdc_ms_Feedback__c> feedbackRecords = [SELECT Id, gdc_ms_AssetUsageRating__c, 
                                                    gdc_ms_ProjectName__c, gdc_ms_AssetSuggestion__c 
                                                    FROM gdc_ms_Feedback__c
                                                    WHERE gdc_ms_logged_in_user__c =: userId
                                                    AND gdc_ms_AssetTitle__c =: assetId];
        if(feedbackRecords.size()>0){
            return feedbackRecords.get(0);
        }else{
            return null;
        }
    }
}