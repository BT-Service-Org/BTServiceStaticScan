public with sharing class PSCPlaybookDetailLandingCtrl {
    @AuraEnabled(cacheable=true)
    public static PlaybookDetailWrapper getPlaybookData(String playbookName){
        List<Stage__c> mStages = new List<Stage__c>();
        List<Stage__c> oStages = new List<Stage__c>();
        PlaybookDetailWrapper playbookDetailWrapperobj = new PlaybookDetailWrapper();
        List<Playbook__c> pbList = [SELECT Id,Name,Description__c,
                                        (SELECT Id,Description__c,Name,StageNumber__c,MandatoryStage__c,StageDuration__c
                                        FROM Stages__r
                                        WHERE RecordType.DeveloperName = 'Playbook'
                                        ORDER BY StageNumber__c ASC)
                                    FROM Playbook__c
                                    WHERE Name =:playbookName
                                    AND Status__c = 'Live'
                                    LIMIT 1];

        if(pbList != null && !pbList.isEmpty()){
            //playbookDetailWrapperobj.playbook = pbList[0];
            for(Playbook__c each:pbList){
                PlaybookDetailWrapperInner playbookDetailWrapperInnerObj = new PlaybookDetailWrapperInner();
                playbookDetailWrapperobj.playbookData = each;
                for(Stage__c innerEach:each.Stages__r){
                    
                    if(innerEach.MandatoryStage__c){
                        mStages.add(innerEach);
                    }
                    else{
                        oStages.add(innerEach);
                    }
                }
                playbookDetailWrapperInnerObj.mandatoryStages = mStages;
                playbookDetailWrapperInnerObj.optionalStages = oStages;
                playbookDetailWrapperobj.stageData = playbookDetailWrapperInnerObj;
            }
        }
        return playbookDetailWrapperobj;
    }

    public class PlaybookDetailWrapper{
        @auraEnabled
        public Playbook__c playbookData{get;set;}
        @auraEnabled
        public PlaybookDetailWrapperInner stageData{get;set;}
    }
    public class PlaybookDetailWrapperInner{
        @auraEnabled
        public List<Stage__c> mandatoryStages{get;set;}
        @auraEnabled
        public List<Stage__c> optionalStages{get;set;}
    }
}