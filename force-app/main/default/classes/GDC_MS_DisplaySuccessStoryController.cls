public without sharing class GDC_MS_DisplaySuccessStoryController {

    @AuraEnabled(cacheable=true)
    public static List<StoryWrapper> getStories(){

        List<StoryWrapper> wrapperList = new List<StoryWrapper>();

        try {

            for (gdc_ms_Engagement__c story: [SELECT Id, gdc_ms_CompanyLogo__c, GDC_MS_Created_By_User__r.Name, Name, gdc_ms_EngagementSummary__c, gdc_ms_EngagementTitle__c, gdc_ms_Feedback__c, gdc_ms_SolutionComplexity__c, gdc_ms_BusinessValueDelivered__c,
                                              GDC_MS_Geographies__c, GDC_MS_Industry__c, GDC_MS_Complexity__c,(Select Id, gdc_ms_Team_Member__r.Name,gdc_ms_Role__c
                                                                                                               from Success_Story_Members__r)
                                              FROM gdc_ms_Engagement__c WHERE gdc_ms_DisplayonSuccessStories__c = TRUE AND (gdc_ms_CompanyLogo__c != null OR gdc_ms_CompanyLogo__c !='')]){
                                                  gdc_ms_Engagement__c obj = new gdc_ms_Engagement__c();
                                                  obj.Id = story.Id;
                                                  obj.gdc_ms_CompanyLogo__c = story.gdc_ms_CompanyLogo__c;
                                                  obj.Name = story.Name;
                                                  obj.gdc_ms_EngagementSummary__c = story.gdc_ms_EngagementSummary__c;
                                                  obj.gdc_ms_EngagementTitle__c = story.gdc_ms_EngagementTitle__c;
                                                  obj.gdc_ms_Feedback__c = story.gdc_ms_Feedback__c;
                                                  obj.gdc_ms_SolutionComplexity__c = story.gdc_ms_SolutionComplexity__c;
                                                  obj.gdc_ms_BusinessValueDelivered__c = story.gdc_ms_BusinessValueDelivered__c;
                                                  obj.GDC_MS_Complexity__c	= story.GDC_MS_Complexity__c;
                                                  obj.GDC_MS_Geographies__c   = story.GDC_MS_Geographies__c;
                                                  obj.GDC_MS_Industry__c      = story.GDC_MS_Industry__c;
                                                  StoryWrapper sw = new StoryWrapper();
                                                  sw.username = story.GDC_MS_Created_By_User__r.Name;
                                                  sw.successobj = obj;
                                                  sw.hasStoryMembers= !story.Success_Story_Members__r.isEmpty();
                                                  wrapperList.add(sw);

                                              }


        } catch (Exception e) {
            System.debug('Exception: '+e);

        }
        return wrapperList;
    }
    @AuraEnabled(cacheable=true)
    public static List<gdc_ms_Engagement__c> getActiveSuccessStories(){
        try {
                return [SELECT Id,Name,gdc_ms_Carousel_Image_Link__c
                        FROM gdc_ms_Engagement__c
                        WHERE gdc_ms_Is_Visible_on_Carousel__c = true];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class StoryWrapper{
        @AuraEnabled
        public String username;
        @AuraEnabled
        public  gdc_ms_Engagement__c successobj;
        @AuraEnabled
        public Boolean hasStoryMembers;
    }

    @AuraEnabled
    public static List<picklistValue> getPicklistValues(String fieldString) {
        Schema.SobjectField field = Schema.getGlobalDescribe().get('gdc_ms_Engagement__c').getDescribe().fields.getMap().get(fieldString);
        List<Schema.PicklistEntry> entries = field.getDescribe().getPickListValues();
        List<picklistValue> activeEntries = new List<picklistValue>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                picklistValue var = new picklistValue();
                var.label = entry.label;
                var.value = entry.value;
                activeEntries.add(var);
            }
        }
        return activeEntries;
    }

    @AuraEnabled(cacheable=true)
    public static list<gdc_ms_Success_Story_Members__c> getStoryMembers(String successStoryId){

        List<gdc_ms_Success_Story_Members__c> listOfSuccessStoryMembers = new List<gdc_ms_Success_Story_Members__c>();

        try{
            for(gdc_ms_Success_Story_Members__c successStoryMembers: [Select Id, gdc_ms_Team_Member__r.Name, gdc_ms_Success_Stories__c,gdc_ms_Role__c, gdc_ms_Team_Member__r.gdc_ms_ProfilePhoto__c from gdc_ms_Success_Story_Members__c
                                                                      where gdc_ms_Success_Stories__c=:successStoryId AND gdc_ms_Team_Member__c!=NULL]){

                                                                          listOfSuccessStoryMembers.add(successStoryMembers);
                                                                      }
        }

        catch (Exception e) {
            System.debug('Exception: '+e);
        }
        System.debug('@@listOfSuccessStoryMembers::'+listOfSuccessStoryMembers);
        return listOfSuccessStoryMembers;
    }
    public class PicklistValue{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

    }


}