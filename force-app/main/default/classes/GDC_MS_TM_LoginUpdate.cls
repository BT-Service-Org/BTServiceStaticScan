public without sharing class GDC_MS_TM_LoginUpdate {
    @AuraEnabled
    public static string updateTeamMemberRecord() {
        try {
            gdc_ms_TeamMember__c tm = [SELECT Id FROM gdc_ms_TeamMember__c WHERE gdc_ms_MappedUser__r.Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED];

            if (tm != null) {
                tm.gdc_ms_LastLoginDate__c = String.valueOf(Datetime.now());
                Database.update(tm);
            }
            return UserInfo.getName();
        } catch (Exception ex) {
            System.debug('Error updating the timestamp on team member record  ::: ' + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
}