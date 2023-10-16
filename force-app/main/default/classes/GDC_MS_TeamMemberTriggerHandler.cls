public without sharing class GDC_MS_TeamMemberTriggerHandler {

   /* public static void updateTeamMember(List<gdc_ms_TeamMember__c> newList){

        Set<Id> inactiveUserIdSet = new Set<Id>();
        List<gdc_ms_TeamMember__c> listToUpdate = new List<gdc_ms_TeamMember__c>();

        List<GDC_Inactive_Team_Members__mdt > listOfCustomMetadata = [SELECT Id,gdc_ms_User_Ids__c  FROM GDC_Inactive_Team_Members__mdt WITH SECURITY_ENFORCED];

        if(!listOfCustomMetadata.isEmpty()){
            for(GDC_Inactive_Team_Members__mdt inactiveUsers:listOfCustomMetadata){
                if(String.isNotEmpty(inactiveUsers.gdc_ms_User_Ids__c )){
                    list<Id> listOfUserIds = inactiveUsers.gdc_ms_User_Ids__c .deleteWhitespace().split(',');
                    inactiveUserIdSet.addAll(listOfUserIds);
                }
            }
        }
        if(!inactiveUserIdSet.isEmpty() || Test.isRunningTest()){
            for(gdc_ms_TeamMember__c teamMember : newList){
                if(inactiveUserIdSet.contains(teamMember.gdc_ms_MappedUser__c) && teamMember.gdc_ms_isActive__c==true){
                    teamMember.gdc_ms_isActive__c = false;
                }
            }
        }
    }*/
    public static void checkTeamMemberStatus(Map<Id,gdc_ms_TeamMember__c> newMap , List<gdc_ms_TeamMember__c> newObjList){

        for(gdc_ms_TeamMember__c teamMember:newObjList){

            if(teamMember.gdc_ms_isActive__c){
                GDC_MS_Inactive_Team_Members__c  mc = GDC_MS_Inactive_Team_Members__c.getInstance(teamMember.gdc_ms_MappedUser__c);

                if(mc.SetupOwnerId == teamMember.gdc_ms_MappedUser__c && !mc.gdc_ms_Is_Active__c && mc.gdc_ms_User_Email_Id__c !=null){
                    teamMember.gdc_ms_isActive__c = false;
                }
            }
        }

    }

    public static void updateLastbioUpdatedDate(Map<Id,gdc_ms_TeamMember__c> newMap, Map<Id,gdc_ms_TeamMember__c> oldMap) {
        if (!newMap.isEmpty() && !oldMap.isEmpty()) {
            for (gdc_ms_TeamMember__c tm : newMap.values()) {
                gdc_ms_TeamMember__c oldTm = oldMap.get(tm.id);
                if (tm.gdc_ms_SalesforceCertifications__c != oldTm.gdc_ms_SalesforceCertifications__c ||
                    tm.gdc_ms_SkillHighlights__c != oldTm.gdc_ms_SkillHighlights__c ||
                    tm.gdc_ms_Summary__c != oldTm.gdc_ms_Summary__c ||
                    tm.gdc_ms_VerticalExpertise__c != oldTm.gdc_ms_VerticalExpertise__c ||
                    tm.gdc_ms_Customer_Credentials__c != oldTm.gdc_ms_Customer_Credentials__c
                    ) {
                        tm.gdc_ms_LastBioUpdatedDate__c = system.now();
                }
            }
        }
    }
}