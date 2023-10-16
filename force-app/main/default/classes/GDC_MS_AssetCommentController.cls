public with sharing class GDC_MS_AssetCommentController {
    
    @AuraEnabled
    public static List<gdc_ms_Reusable_Asset_Comments__c> getAllComments(String assetId){
        try {
            if(String.isNotBlank(assetId)){
                return [SELECT Id, gdc_ms_Comment_Body__c, CreatedBy.Name, CreatedById, LastModifiedDate, CreatedDate 
                        FROM gdc_ms_Reusable_Asset_Comments__c 
                        WHERE gdc_ms_Reusable_Asset__c = :assetId
                        ORDER BY CreatedDate DESC];
            }
            return NULL;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static gdc_ms_Reusable_Asset_Comments__c getRecord(String assetId){
        if(String.isNotBlank(assetId)){
            return [SELECT Id, gdc_ms_Comment_Body__c, CreatedBy.Name, CreatedById, LastModifiedDate, CreatedDate 
                    FROM gdc_ms_Reusable_Asset_Comments__c 
                    WHERE Id = :assetId];
        }
        return NULL;   
    }
    
    @AuraEnabled
    public static String createComment(CustomWrapper wrapper){
        List<gdc_ms_Reusable_Asset_Comments__c> listOfComments = new List<gdc_ms_Reusable_Asset_Comments__c>();
        System.debug('wrapper => '+wrapper);
        gdc_ms_Reusable_Asset_Comments__c obj = new gdc_ms_Reusable_Asset_Comments__c();
        obj.gdc_ms_Comment_Body__c = wrapper.commentBody;
        obj.gdc_ms_Reusable_Asset__c = wrapper.assetId;
        obj.gdc_ms_Recipient_Email_Ids__c = wrapper.recipientEmailIds;
        
        listOfComments.add(obj);
        
        Database.SaveResult[] srList = Database.insert(listOfComments, false);
        System.debug('Save Result => '+ srList);
        for (Database.SaveResult sr : srList){
            
            if (sr.isSuccess()){
                System.debug('Successfully inserted record. ID: ' + sr.getId());
                //return getRecord(sr.getId());
                return sr.getId();
            }else{
                System.debug('The following error has occurred.' + sr.getErrors());     
                return NULL;
            }
        }
        return NULL;
    }
    
    @AuraEnabled
    public static boolean updateComment(String recordId, String commentBody){
        gdc_ms_Reusable_Asset_Comments__c obj = getRecord(recordId);
        if(obj != NULL){
            obj.gdc_ms_Comment_Body__c = commentBody;
        }
        Database.SaveResult[] srList = Database.update(new List<gdc_ms_Reusable_Asset_Comments__c> {obj}, false);
        for (Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                System.debug('Successfully updated record. ID: ' + sr.getId());
                return true;
            }else{
                System.debug('The following error has occurred.' + sr.getErrors());     
                return false;
            }
        }
        return false;
        
    }
    
    @AuraEnabled
    public static boolean deleteComment(String recordId){
        if(String.isNotBlank(recordId)){
            gdc_ms_Reusable_Asset_Comments__c obj = getRecord(recordId);
            if(obj != NULL){
                Database.DeleteResult[] srList = Database.delete(new List<gdc_ms_Reusable_Asset_Comments__c> {obj}, false);
                for (Database.DeleteResult  sr : srList){
                    if (sr.isSuccess()){
                        System.debug('Successfully deleted record. ID: ' + sr.getId());
                        return true;
                    }else{
                        System.debug('The following error has occurred.' + sr.getErrors());     
                        return false;
                    }
                }
            }
        }
        return false;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<assetMembersWrapper> getAssetMembers(String assetId){
        try {
            if(String.isNotBlank(assetId)){
                List<assetMembersWrapper> listMembers = new List<assetMembersWrapper>();
                for(gdc_ms_AssetMember__c member : [SELECT Id, gdc_ms_TeamMember__r.gdc_ms_MappedUser__r.Email, gdc_ms_TeamMember__r.Name,gdc_ms_Role__c 
                                                    FROM gdc_ms_AssetMember__c
                                                    WHERE gdc_ms_ReusableAsset__c = :assetId]){
                                                        if(String.isNotBlank(member.gdc_ms_TeamMember__r.gdc_ms_MappedUser__r.Email) && 
                                                           String.isNotBlank(member.gdc_ms_TeamMember__r.Name) && 
                                                           String.isNotBlank(member.gdc_ms_Role__c)){
                                                               String label = member.gdc_ms_TeamMember__r.Name + ' ('+ member.gdc_ms_Role__c +')';
                                                               assetMembersWrapper obj = new assetMembersWrapper(label,
                                                                                                                 member.gdc_ms_TeamMember__r.gdc_ms_MappedUser__r.Email
                                                                                                                );
                                                               listMembers.add(obj);
                                                           }
                                                    }
                System.debug('listMembers => '+listMembers);
                return listMembers;
            }
            return NULL;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @InvocableMethod(label='Get Experience site base URL' description='This apex method helps to get the experience site base URL of Global Delivery Site. gdc')
    public static List<String> generatePortalURL(){
        Site siteRecord = [SELECT Id, Name, UrlPathPrefix, Subdomain FROM site WHERE name = 'Global_Delivery_Center' LIMIT 1];
        SiteDetail detailRecord = [select SecureUrl from SiteDetail where DurableId = :siteRecord.Id];
        String URL = detailRecord.SecureUrl+'/s/detail/';
        return new List<String>{URL};
            
            }
    
    
    public class CustomWrapper{
        @AuraEnabled
        public String commentBody {get; set;}
        @AuraEnabled
        public String assetId {get; set;}
        @AuraEnabled
        public String recipientEmailIds {get; set;}
    }
    
    public class assetMembersWrapper{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        
        assetMembersWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}