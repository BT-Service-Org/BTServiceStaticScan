public with sharing class PSCPlaybookDetailCtrl {
    @AuraEnabled(cacheable=true)
    public static PlaybookDetailWrapper getPlaybookData(String playbookName,String stageName){
        PlaybookDetailWrapper playbookDetailWrapperobj = new PlaybookDetailWrapper();
        List<Playbook__c> pbList = [SELECT Id,Name,
                                        (SELECT Id,Objective__c,Description__c,Key_Questions__c,Activities__c,Name,StageNumber__c
                                        FROM Stages__r
                                        WHERE Name =:stageName
                                        AND RecordType.DeveloperName = 'Playbook'
                                        ORDER BY StageNumber__c ASC)
                                    FROM Playbook__c
                                    WHERE Name =:playbookName
                                    AND Status__c = 'Live'
                                    LIMIT 1];

        List<Stage_Outcome__c> soList = [SELECT Id,Outcome__r.Title__c, Outcome__r.Description__c, Order__c,
                                            (SELECT Id,Method_Outcome__r.Outcome__r.Title__c, Method_Outcome__r.Method__r.Name, 
                                            Method_Outcome__r.Method__r.Method_Number__c, Order__c
                                            FROM Stage_Method_Outcome__r
                                            WHERE Method_Outcome__r.Method__r.Status__c = 'Published'
                                            ORDER BY Order__c ASC NULLS LAST
                                            )
                                        FROM Stage_Outcome__c
                                        WHERE Stage__r.Playbook_Stage__r.Name =: playbookName
                                        AND Stage__r.Name =:stageName
                                        ORDER BY Order__c ASC NULLS LAST];


        if(pbList != null && !pbList.isEmpty()){
            playbookDetailWrapperobj.playbook = pbList[0];
        }
        if(soList != null && !soList.isEmpty()){
            playbookDetailWrapperobj.stageOutcomes = soList;
        }
        return playbookDetailWrapperobj;
    }

    public class PlaybookDetailWrapper{
        @auraEnabled
        public Playbook__c playbook{get;set;}
        @auraEnabled
        public List<Stage_Outcome__c> stageOutcomes{get;set;}
    }
}