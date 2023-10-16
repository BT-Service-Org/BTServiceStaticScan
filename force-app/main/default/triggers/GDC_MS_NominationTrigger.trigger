trigger GDC_MS_NominationTrigger on gdc_ms_Nomination__c (before insert, after insert, before update, after update) {
    if (Trigger.isBefore && GDC_MS_PublishWinnerController.isWinnersPublished == false) {
        GDC_MS_RewardsAndRecognition__c dates = GDCMS_NominationScreenController.getCurrentQuarter();

        for (gdc_ms_Nomination__c nomination : Trigger.new) {
            if (Date.today() > dates.gdc_ms_QuarterEndDate__c && nomination.gdc_ms_AwardCategory__c != 'Achievers Award'){
                nomination.addError('The nomination for this quarter have been closed. You cannot edit this records anymore');
            } else {
                nomination.gdc_ms_RewardsAndRecognition__c = dates.Id;
                nomination.gdc_ms_Quarter__c = dates.gdc_ms_Quarter__c;
                nomination.gdc_ms_Year__c = dates.gdc_ms_Year__c;
                if (nomination.gdc_ms_AwardCategory__c == 'Achievers Award') {
                    nomination.gdc_ms_Month__c = String.valueOf(Date.today().month());
                    nomination.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Monthly Award').getRecordTypeId();
                } else {
                    nomination.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Quarterly Award').getRecordTypeId();
                }
            }
        }
    }
}