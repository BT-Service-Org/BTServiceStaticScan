public without sharing class GDC_MS_DisplayWallOfFame {

    @AuraEnabled(cacheable=true)
    public static List<gdc_ms_Nomination__c> getWallOfFameRecords(String awardCategory){

        list<gdc_ms_Nomination__c> wofLst = [SELECT Id,gdc_ms_Nominee__c, gdc_ms_Nominee__r.Name, gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c, gdc_ms_Nominee__r.gdc_ms_Designation__c, gdc_ms_Winner__c, gdc_ms_AwardCategory__c, gdc_ms_DriveGDCGoalsAsPerVision__c, gdc_ms_Quarter__c,  gdc_ms_Manager__c, gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c, gdc_ms_SuccessTeamName__r.Name,gdc_ms_SuccessTeamName__c,gdc_ms_WinAsTeamCharacteristic__c, gdc_ms_Year__c,Publish_On_WallOfFame__c  FROM gdc_ms_Nomination__c WHERE Publish_On_WallOfFame__c = true AND gdc_ms_AwardCategory__c =: awardCategory];

        if(wofLst.size() > 0){
            return wofLst;
        }

        return null;

}

}