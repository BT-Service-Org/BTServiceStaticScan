public with sharing class ReusableAssetTriggerHandler {
    public static void createUAATrackingRecord(List<Reusable_Asset__c> newRecordsList,Map<Id,Reusable_Asset__c> oldRecordsMap){
        List<Reusable_Asset__c> raList = new List<Reusable_Asset__c>();

        for(Reusable_Asset__c each:newRecordsList){
            if(each.Status__c != oldRecordsMap.get(each.Id).Status__c 
            && each.Status__c == 'Published'
            && each.First_Publish_Date__c != null 
            && oldRecordsMap.get(each.Id).First_Publish_Date__c == null ){
                raList.add(each);
            }
        }

        if(raList != null && !raList.isEmpty()){
            List<Reusable_Asset__c> raDataList = [SELECT Id,Resource_Type__c,Curation_Level__c,CreatedbyId,
                                                        (SELECT Id,psc_Team_Member__c,psc_Role__c
                                                        FROM Contribution_Teams__r)
                                                    FROM Reusable_Asset__c
                                                    WHERE ID IN :raList];
            PSCGamificationService.createReusableAssetRelatedUAA(raDataList);
        }
    }
    /*
   * @Method:      addContributionTeam
   * @Created by:  Rohan Saxena
   * @Description: This method is to add Reviewer in CT record.(SC-970)
   * @Param:       List < Reusable_Asset__c >, Map<Id,Reusable_Asset__c>
   * @Return:      
   */
    public static void addContributionTeam(List<Reusable_Asset__c> newRecordsList,Map<Id,Reusable_Asset__c> oldRecordsMap){
        List<Contribution_Team__c> lstnewCT = new List<Contribution_Team__c>();
        Id reusableRecordId = Schema.SObjectType.Contribution_Team__c.getRecordTypeInfosByName().get('Reusable Asset').getRecordTypeId();
        for(Reusable_Asset__c RA: newRecordsList){
            if((RA.Status__c != oldRecordsMap.get(RA.Id).Status__c) && RA.Status__c =='Published' || RA.Status__c =='Draft'){
                Contribution_Team__c CT = new Contribution_Team__c();
                CT.RecordTypeId=reusableRecordId;
                CT.psc_Reusable_Asset__c=RA.Id;
                CT.Contribution_Date__c=System.today();
                CT.psc_Role__c='Reviewer';
                CT.psc_Team_Member__c=UserInfo.getUserId();
                lstnewCT.add(CT);
            }
        }
        insert lstnewCT;
    }
}