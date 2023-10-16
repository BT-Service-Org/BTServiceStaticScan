public with sharing class GDC_MS_HeadCount {

    @Auraenabled(cacheable=true)
    public static integer getTeamMemberCount() {
        List<gdc_ms_TeamMember__c> lstTeamMembers = [SELECT Name,Id FROM gdc_ms_TeamMember__c WHERE gdc_ms_isActive__c = true];
        return lstTeamMembers.size();
    }
}