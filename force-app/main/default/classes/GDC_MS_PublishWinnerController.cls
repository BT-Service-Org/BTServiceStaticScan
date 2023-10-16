public without sharing class GDC_MS_PublishWinnerController {

    public static Boolean isWinnersPublished = false;

    @AuraEnabled
    public static string publishTheWinners() {

        GDC_MS_RewardsAndRecognition__c currentQuarter = GDCMS_NominationScreenController.getCurrentQuarter();
        List<gdc_ms_Nomination__c> upsertList = new List<gdc_ms_Nomination__c>();

        if (currentQuarter != null && currentQuarter.gdc_ms_QuarterEndDate__c < Date.today()) {
            for (gdc_ms_Nomination__c nom : [SELECT Id,gdc_ms_Nominee__c, gdc_ms_Nominee__r.Name, gdc_ms_Winner__c, gdc_ms_AwardCategory__c, gdc_ms_DriveGDCGoalsAsPerVision__c, gdc_ms_Quarter__c,  gdc_ms_Manager__c, gdc_ms_SuccessTeamName__r.Name,gdc_ms_SuccessTeamName__c,gdc_ms_WinAsTeamCharacteristic__c, gdc_ms_Year__c,Publish_On_WallOfFame__c  FROM gdc_ms_Nomination__c WHERE gdc_ms_RewardsAndRecognition__c =:currentQuarter.Id AND gdc_ms_Winner__c = true]) {
               
                nom.Publish_On_WallOfFame__c = true;
                upsertList.add(nom);
            }

            List<gdc_ms_Nomination__c> updateList = uncheckDisplay();

            if (!updateList.isEmpty()) {
                upsertList.addAll(updateList);
            }
        } else {
            System.debug('We cannot publish the winners as the nominations are still open');
            return 'We cannot publish the winners as the nominations are still open';
        }

        if (!upsertList.isEmpty()) {
            try {
                isWinnersPublished = true;
                Database.update(upsertList,gdc_ms_Nomination__c.Id);
                return '';
            } catch (Exception e) {
                System.debug('There was an error ::: ' + e.getMessage());
                return e.getMessage();
            }
        }
        return 'Error';
    }

    public static List<gdc_ms_Nomination__c> uncheckDisplay() {
        List<gdc_ms_Nomination__c> updateList = new List<gdc_ms_Nomination__c>();
        for (gdc_ms_Nomination__c wof : [SELECT Id, Publish_On_WallOfFame__c FROM gdc_ms_Nomination__c WHERE Publish_On_WallOfFame__c = TRUE]) {
            wof.Publish_On_WallOfFame__c = false;
            updateList.add(wof);
        }
        return updateList;
    }
}