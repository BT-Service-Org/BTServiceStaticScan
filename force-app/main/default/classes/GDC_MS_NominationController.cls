public without sharing class GDC_MS_NominationController {
    @AuraEnabled(cacheable=true)
    public static list<gdc_ms_Nomination__c> getNominations(){
        list<gdc_ms_Nomination__c> nominationList =  [select Id,gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c, gdc_ms_SuccessTeamName__r.Name,gdc_ms_SuccessTeamName__c ,gdc_ms_DriveGDCGoalsAsPerVision__c,gdc_ms_TeamPlayerRecognisedMentor__c,gdc_ms_MeasurableContributionToGDC__c,gdc_ms_WinAsTeamCharacteristic__c,gdc_ms_CustomerAppreciationHighCSATScore__c,gdc_ms_ProjectComplexityValueDelivered__c,
                gdc_ms_Winner__c,gdc_ms_AwardCategory__c,gdc_ms_nominee__r.Name,gdc_ms_nominee__r.gdc_ms_ProfilePhoto__c,gdc_ms_Quarter__c,gdc_ms_CustomerGeoFeedback__c,gdc_ms_PersonalAchievements__c,GDC_MS_GroupLeader__c
               FROM gdc_ms_Nomination__c
               WHERE gdc_ms_Winner__c=false ];
        //System.debug('obj '+obj.gdc_ms_nominee__r.Name+' '+obj.gdc_ms_nominee__r.gdc_ms_ProfilePhoto__c);
        return nominationList;
    }

    @AuraEnabled
    public static string updateWinner(list<string> recordIds){
        try {
            list<gdc_ms_Nomination__c> nominationList = [Select Id,gdc_ms_Winner__c  FROM gdc_ms_Nomination__c where id in:recordIds ];
            list<gdc_ms_Nomination__c> updateNominations = new list<gdc_ms_Nomination__c>();
            for(gdc_ms_Nomination__c nomination:nominationList){
                nomination.gdc_ms_Winner__c = true;
                updateNominations.add(nomination);
            }
            if(!updateNominations.isEmpty()){
                update nominationList;
                return 'successful';
            }
            return 'failed';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string removeWinner(list<string> recordIds){
        try {
            list<gdc_ms_Nomination__c> nominationList = [Select Id,gdc_ms_Winner__c  FROM gdc_ms_Nomination__c where id in:recordIds ];
            list<gdc_ms_Nomination__c> updateNominations = new list<gdc_ms_Nomination__c>();
            for(gdc_ms_Nomination__c nomination:nominationList){
                nomination.gdc_ms_Winner__c = false;
                updateNominations.add(nomination);
            }
            if(!updateNominations.isEmpty()){
                update nominationList;
                return 'successful';
            }
            return 'failed';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static list<gdc_ms_Nomination__c> getWinners(){
        GDC_MS_RewardsAndRecognition__c currentQuarter = GDCMS_NominationScreenController.getCurrentQuarter();
        list<gdc_ms_Nomination__c> nominationList =  [select Id,gdc_ms_DriveGDCGoalsAsPerVision__c,gdc_ms_TeamPlayerRecognisedMentor__c,gdc_ms_MeasurableContributionToGDC__c,gdc_ms_WinAsTeamCharacteristic__c,gdc_ms_CustomerAppreciationHighCSATScore__c,gdc_ms_ProjectComplexityValueDelivered__c,
                gdc_ms_Winner__c,gdc_ms_AwardCategory__c,gdc_ms_nominee__r.Name,gdc_ms_nominee__r.gdc_ms_ProfilePhoto__c,gdc_ms_Quarter__c,gdc_ms_CustomerGeoFeedback__c,gdc_ms_PersonalAchievements__c,GDC_MS_GroupLeader__c
               FROM gdc_ms_Nomination__c
               WHERE gdc_ms_Winner__c=true AND gdc_ms_RewardsAndRecognition__c =:currentQuarter.Id];
        return nominationList;
    }

    @AuraEnabled
    public static List<gdc_ms_Nomination__c> getNominationsRecords(String awardType, String currentTabName){
        try {
            GDC_MS_RewardsAndRecognition__c currentQuarter = GDCMS_NominationScreenController.getCurrentQuarter();
            List<gdc_ms_Nomination__c> nominationList = new List<gdc_ms_Nomination__c>();
            if (String.isNotEmpty(awardType) && String.isNotEmpty(currentTabName)) {
                nominationList = [SELECT Id,gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c, gdc_ms_SuccessTeamName__r.Name,gdc_ms_SuccessTeamName__c ,gdc_ms_DriveGDCGoalsAsPerVision__c,gdc_ms_TeamPlayerRecognisedMentor__c,gdc_ms_MeasurableContributionToGDC__c,gdc_ms_WinAsTeamCharacteristic__c,gdc_ms_CustomerAppreciationHighCSATScore__c,gdc_ms_ProjectComplexityValueDelivered__c,
                                    gdc_ms_Winner__c,gdc_ms_AwardCategory__c,gdc_ms_nominee__r.Name,gdc_ms_nominee__r.gdc_ms_ProfilePhoto__c,gdc_ms_Quarter__c,gdc_ms_CustomerGeoFeedback__c,gdc_ms_PersonalAchievements__c,GDC_MS_GroupLeader__c, gdc_ms_nominee__r.gdc_ms_Designation__c
                                    FROM gdc_ms_Nomination__c
                                    WHERE gdc_ms_AwardCategory__c =: awardType AND gdc_ms_Winner__c=: Boolean.valueOf(currentTabName) AND gdc_ms_RewardsAndRecognition__c =:currentQuarter.Id ];
            }

            return nominationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}