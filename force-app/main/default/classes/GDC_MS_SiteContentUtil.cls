public without sharing class GDC_MS_SiteContentUtil {
    @AuraEnabled(cacheable=true)
    public static List<gdc_ms_Site_Content__c> getSitecontent(String SiteContentId){
        try {
            if(String.isNotBlank(SiteContentId)){
                return [SELECT Id,gdc_ms_Body_Content__c,gdc_ms_Header_Content__c,gdc_ms_Sort_Number__c,gdc_ms_Contains_iframe__c,gdc_ms_iframe_Link__c,gdc_ms_ParentId__r.gdc_ms_Contains_Accordion__c,gdc_ms_ParentId__r.gdc_ms_Accordion_Heading__c
                        FROM gdc_ms_Site_Content__c 
                        WHERE gdc_ms_ParentId__r.gdc_ms_ContentId__c =:SiteContentId AND gdc_ms_IsActive__c = true AND gdc_ms_ParentId__r.gdc_ms_IsActive__c =true
                        ORDER BY gdc_ms_Sort_Number__c];
            }
            return NULL;} catch (Exception e) {throw new AuraHandledException(e.getMessage());
        }
}

@AuraEnabled(cacheable=true)
public static List<gdc_ms_Site_Content_Placeholder__c> fetchplaceholderValues(List<gdc_ms_Site_Content__c> sitecontentData){
    try {
        list<string> sitecontentIds = new list<string>();
        for(gdc_ms_Site_Content__c con : sitecontentData)
        {
            sitecontentIds.add(con.id);
        }
        if(sitecontentIds.size()>0){
            return [SELECT id,gdc_ms_Site_Content__c ,gdc_ms_Placeholder_Key__c, gdc_ms_Placeholder_Value__c from gdc_ms_Site_Content_Placeholder__c 
            WHERE gdc_ms_Site_Content__c  in : sitecontentIds];
        }
     return NULL ;} catch (Exception e) {throw new AuraHandledException(e.getMessage());
    }
}

}