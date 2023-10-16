@isTest (SeeAllData=true)
public class BedrockSyncCert2LearningDomainTest {
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void testScheduledJob() {
        Id paRecordType = Schema.SObjectType.PA_Onboarding__c.getRecordTypeInfosByName().get('PA').getRecordTypeId();
        
        Map<String, String> sfuCertSkillMap = new Map<String, String>();
        List<Bedrock_Badge_Cert_Mapping__mdt> bbcList = [select Label, External_Certification__c, Org62_Badge_Name__c from Bedrock_Badge_Cert_Mapping__mdt];
        for (Bedrock_Badge_Cert_Mapping__mdt bbc : bbcList) {
            sfuCertSkillMap.put(bbc.External_Certification__c, bbc.Label);
        }
        
        System.Debug('External Cert Chosen: ' + bbcList[0].External_Certification__c);
        Decimal preCount = [select count() from Learning_Domain__c where Badge_Data__c != null];
        List<PA_Onboarding__c> paRecs = [select  Id,
                                                 Name
                                         from    PA_Onboarding__c
                                         where	 RecordTypeId = :paRecordType
                                         and     Candidate__r.IsActive = true
                                         and	 Id not in (select  PA_Onboarding__c
                                                            from 	Badge_Data__c
                                                            where 	Name = :bbcList[0].External_Certification__c)
                                         limit 2];
        System.Debug('Target PA Recs: ' + paRecs);
        
        List<Badge_Data__c> bdgList = new List<Badge_Data__c>();
        for (PA_Onboarding__c pa : paRecs) {
            Badge_Data__c bdg = new Badge_Data__c();
            bdg.Name = bbcList[0].External_Certification__c;
            bdg.PA_Onboarding__c = pa.Id;
            bdg.State__c = 'Acquired';
            bdgList.add(bdg);
        }
        insert bdgList;
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
                                       CRON_EXP, 
                                       new BedrockSyncCert2LearningDomain());         
        
        // Verify the scheduled job has not run yet.
        Decimal postCount = [select count() from Learning_Domain__c where Badge_Data__c != null];
        System.Debug('Pre Count: ' + preCount + '; Post Count: ' + postCount);
        System.assertEquals(0, postCount-preCount, 'Job is still running');
  
        // Stopping the test will run the job synchronously
        Test.stopTest();

        // Verify expected results.
        postCount = [select count() from Learning_Domain__c where Badge_Data__c != null];
        System.Debug('Pre Count: ' + preCount + '; Post Count: ' + postCount);
        System.assertEquals(2, postCount-preCount, 'Test Failed');
    }
}