public without sharing class GDCMS_NominationScreenController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter ) {
        String myQuery = null;

        if(filter != null && filter != ''){
            myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter;
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC';
            }
            else {
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' ';
            }
        }
        System.debug('Query ::::: ' + myQuery);
        List<sObject> lookUpList = Database.query(myQuery);
        return lookUpList;
    }

    @AuraEnabled
    public static List<gdc_ms_Nomination__c> getRecordDetials(){
        try {
            GDC_MS_RewardsAndRecognition__c currentQuarter = getCurrentQuarter();
            return [SELECT Id,gdc_ms_Year__c,gdc_ms_RewardsAndRecognition__r.gdc_ms_Quarter__c,gdc_ms_RewardsAndRecognition__r.gdc_ms_QuarterStartDate__c,gdc_ms_RewardsAndRecognition__r.gdc_ms_QuarterEndDate__c, gdc_ms_Nominee__c, gdc_ms_Nominee__r.Name, gdc_ms_Winner__c, gdc_ms_AwardCategory__c, gdc_ms_CustomerAppreciationHighCSATScore__c, gdc_ms_CustomerGeoFeedback__c, gdc_ms_DriveGDCGoalsAsPerVision__c, gdc_ms_GreatCharacteristic__c, gdc_ms_MeasurableContributionToGDC__c, gdc_ms_ProjectComplexityValueDelivered__c, gdc_ms_PersonalAchievements__c, gdc_ms_TeamName__c, gdc_ms_TeamOwner__c, gdc_ms_TeamPlayerRecognisedMentor__c, gdc_ms_TeamSize__c, gdc_ms_WinAsTeamCharacteristic__c, gdc_ms_Quarter__c,  gdc_ms_Manager__c, gdc_ms_SuccessTeamName__r.Name,gdc_ms_SuccessTeamName__c  FROM gdc_ms_Nomination__c WHERE gdc_ms_Manager__r.gdc_ms_MappedUser__c =:UserInfo.getUserId() AND RecordType.DeveloperName = 'gdc_ms_QuarterlyAward' AND gdc_ms_RewardsAndRecognition__c =:currentQuarter.Id ];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static gdc_ms_Nomination__c getRecordAchevierDetials(String recordId){
        try {
            return [SELECT Id,gdc_ms_RewardsAndRecognition__r.gdc_ms_Quarter__c,gdc_ms_RewardsAndRecognition__r.gdc_ms_QuarterStartDate__c,gdc_ms_RewardsAndRecognition__r.gdc_ms_QuarterEndDate__c, gdc_ms_Nominee__c, gdc_ms_Nominee__r.Name, gdc_ms_Winner__c, gdc_ms_AwardCategory__c, gdc_ms_CustomerAppreciationHighCSATScore__c, gdc_ms_CustomerGeoFeedback__c, gdc_ms_DriveGDCGoalsAsPerVision__c, gdc_ms_GreatCharacteristic__c, gdc_ms_MeasurableContributionToGDC__c, gdc_ms_ProjectComplexityValueDelivered__c, gdc_ms_PersonalAchievements__c, gdc_ms_TeamName__c, gdc_ms_TeamOwner__c, gdc_ms_TeamPlayerRecognisedMentor__c, gdc_ms_TeamSize__c, gdc_ms_WinAsTeamCharacteristic__c, gdc_ms_Quarter__c,  gdc_ms_Manager__c,gdc_ms_SuccessTeamName__r.Name,gdc_ms_SuccessTeamName__c FROM gdc_ms_Nomination__c WHERE gdc_ms_Manager__r.gdc_ms_MappedUser__c =:UserInfo.getUserId() AND Id =: recordId];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static GDC_MS_RewardsAndRecognition__c getCurrentQuarter() {
        return [SELECT Id, gdc_ms_Quarter__c,gdc_ms_Year__c, gdc_ms_QuarterStartDate__c,gdc_ms_QuarterEndDate__c FROM GDC_MS_RewardsAndRecognition__c ORDER ORDER BY CreatedDate DESC LIMIT 1];
    }

    @AuraEnabled
    public static string setCurrentQuarter(String startDate, String endDate){
        try {
            System.debug('Dates :::: ' + startDate + ' :::::::: ' + endDate);
            if (String.isNotEmpty(startDate) && String.isNotEmpty(endDate) && Date.valueOf(startDate) < Date.valueOf(endDate)) {
                Integer startMonth = Date.valueOf(startDate).month();
                Integer endDateMonth = Date.valueOf(endDate).month();
                string quarter = '';

                Set<Integer> q4Set = new Set<Integer>{11,12,1};
                Set<Integer> q3Set = new Set<Integer>{2,3,4};
                Set<Integer> q2Set = new Set<Integer>{5,6,7};
                Set<Integer> q1Set = new Set<Integer>{8,9,10};

                if (q4Set.contains(startMonth) && q4Set.contains(endDateMonth)) {//Nov, Dec, Jan
                    quarter = 'Q4';
                } else if (q3Set.contains(startMonth) && q3Set.contains(endDateMonth)) {//Feb,Mar,Apr
                    quarter = 'Q3';
                } else if (q2Set.contains(startMonth) && q2Set.contains(endDateMonth)) {//May,June,July
                    quarter = 'Q2';
                } else if (q1Set.contains(startMonth) && q1Set.contains(endDateMonth)) {//Aug,Sep,Oct
                    quarter = 'Q1';
                } else {
                    quarter = 'Dates are not in current range. Please re-verify the dates.';
                }
                System.debug('Return value  ::::::::  ' + quarter);
                return quarter;
            } else {
                return 'Incorret Dates, Please re-verify the dates';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createManagerRecords(String startDate, String endDate, String quarter){
        try {
            if (String.isNotEmpty(startDate) && String.isNotEmpty(endDate) && String.isNotEmpty(quarter)) {
                GDC_MS_RewardsAndRecognition__c record = new GDC_MS_RewardsAndRecognition__c();
                record.gdc_ms_QuarterStartDate__c = Date.valueOf(startDate);
                record.gdc_ms_QuarterEndDate__c =  Date.valueOf(endDate);
                record.gdc_ms_Quarter__c = quarter;
                record.gdc_ms_Year__c = String.valueOf(Date.valueOf(startDate).year());
                record.gdc_ms_QuarterYear__c = quarter + '_'+String.valueOf(Date.valueOf(startDate).year());
                Database.UpsertResult sr =  Database.upsert(record, GDC_MS_RewardsAndRecognition__c.gdc_ms_QuarterYear__c, false);

                if (sr.isSuccess()) {
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    return sr.getId();
                } else {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                    return null;
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String saveNominationRecord(gdc_ms_Nomination__c nomination){
        try {
            if (nomination != null) {
                GDC_MS_RewardsAndRecognition__c dates = getCurrentQuarter();
                if (Date.today() > dates.gdc_ms_QuarterEndDate__c && nomination.gdc_ms_AwardCategory__c != 'Achievers Award') {
                    return 'The nomination for this quarter have been closed. You cannot edit this records anymore';
                } else {
                    System.debug('Nomination Record :::: ' + nomination);
                    String managerId = [SELECT Id FROM gdc_ms_TeamMember__c WHERE gdc_ms_MappedUser__c =:UserInfo.getUserId() LIMIT 1].Id;

                    if (String.isNotEmpty(managerId)) {
                        nomination.gdc_ms_RewardsAndRecognition__c = dates.Id;
                        nomination.gdc_ms_Manager__c = managerId;
                        nomination.gdc_ms_Quarter__c = dates.gdc_ms_Quarter__c;
                        nomination.gdc_ms_Year__c = dates.gdc_ms_Year__c;
                        if (nomination.gdc_ms_AwardCategory__c == 'Achievers Award') {
                            nomination.gdc_ms_Month__c = String.valueOf(Date.today().month());
                            nomination.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Monthly Award').getRecordTypeId();
                        } else {
                            nomination.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Quarterly Award').getRecordTypeId();
                        }
                        return upsertRecrods(nomination);
                    }
                    System.debug('Data ====>>>> ' + nomination);
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static string upsertRecrods(gdc_ms_Nomination__c records) {
        if (records != null) {
            try {
                Database.UpsertResult sr = Database.upsert(records, gdc_ms_Nomination__c.Id);

                if (sr.isSuccess()) {
                    System.debug('Successfully inserted nomination. ID: ' + sr.getId());
                    if (sr.created) {
                        return 'Created,'+sr.getId();
                    } else {
                        return 'Updated';
                    }
                } else {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                    return null;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return null;
    }

    @AuraEnabled
    public static string getTeamMemberId(){
        try {
            return [SELECT Id FROM gdc_ms_TeamMember__c WHERE gdc_ms_MappedUser__c =:UserInfo.getUserId() LIMIT 1].Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static lIST<gdc_ms_Success_Story_Members__c> getTeamMembers(String successStoryId){
        try {
            return [SELECT Id,gdc_ms_Team_Member__r.Name, gdc_ms_Success_Stories__r.Name, gdc_ms_Role__c FROM gdc_ms_Success_Story_Members__c where gdc_ms_Success_Stories__c =: successStoryId ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}