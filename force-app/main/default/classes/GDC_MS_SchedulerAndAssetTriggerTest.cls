@isTest
public class GDC_MS_SchedulerAndAssetTriggerTest {
    @testSetup static void createData(){
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
          User u = new User(Alias = 'standt1', Email='temproot123@temproot.com', 
                          EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot12@temproot.com' , Title = 'Director');
        insert u;
        
        gdc_ms_TeamMember__c teamMember = new gdc_ms_TeamMember__c(
                                                                   gdc_ms_ismanager__c=false,
                                                                   gdc_ms_isactive__c=true,
                                                                    Name ='Test Member',
                                                                   gdc_ms_Designation__c='Test',
        															 gdc_ms_MappedUser__c = UserInfo.getUserId());
        insert teamMember;
        gdc_ms_TeamMember__c tm = [SELECT Id FROM gdc_ms_TeamMember__c
                                   WHERE Id=:teamMember.id];
        GDC_MS_ReusableAsset__c asset = new GDC_MS_ReusableAsset__c(gdc_ms_title__c='Testing Asset',
                                                                    gdc_ms_cloudcompetency__c='Core',
                                                                   	gdc_ms_ideaclassification__c='Technical',
                                                                   	gdc_ms_isdesignready__c=true,
        															//gdc_ms_proposed_by__c=tm.Id,
        															gdc_ms_Proposed_By_User__c = u.Id,
                                                                    gdc_ms_Status__c='In Build',
                                                                    gdc_ms_Benefits__c='Time saved',
                                                                    gdc_ms_Proposed_Design_Document__c='http://www.test.com',
                                                                    gdc_ms_IntendedDomainIndustries__c ='Healthcare');
        insert asset;
        
        GDC_MS_Ignore_Status__c customSetting=new GDC_MS_Ignore_Status__c(Name='Ignore Asset Status',GDC_MS_Status_Values__c='Parked,Rejected,Ready for Team Demo,Delivered');
        insert customSetting;
        
        gdc_ms_AssetMember__c assetMember = new gdc_ms_AssetMember__c(gdc_ms_Role__c = 'Developer',gdc_ms_ReusableAsset__c=asset.Id,gdc_ms_TeamMember__c = teamMember.Id);
        insert assetMember;
    }
	@isTest static void sendEmailNotification(){
        String CRON_EXP = '0 0 0 3 9 ? 2035';
        Test.startTest();
          GDC_MS_ReusableAsset__c assetObj = [SELECT GDC_MS_Last_Reminder_Trigger_Date__c,GDC_MS_Next_Reminder_Trigger_date__c,Name,gdc_ms_title__c FROM GDC_MS_ReusableAsset__c where gdc_ms_title__c='Testing Asset'];
          assetObj.GDC_MS_Last_Reminder_Trigger_Date__c = Date.newInstance(2022, 04, 21);
          assetObj.GDC_MS_Next_Reminder_Trigger_date__c = Date.today(); 
          update assetObj;
        
          String jobId = System.schedule('testBasicScheduledApex',CRON_EXP, 
         	new GDC_MS_ScheduleAssetEmailNotification());
        Test.stopTest();
    }
    
    @isTest static void testTrigger(){
        Test.startTest();
        GDC_MS_ReusableAsset__c assetObj = [SELECT gdc_ms_Status__c,Name,gdc_ms_title__c FROM GDC_MS_ReusableAsset__c where gdc_ms_title__c='Testing Asset'];
        if(assetObj!=null){
        System.debug('asset '+assetObj);
        assetObj.gdc_ms_cloudcompetency__c = 'Marketing';
        assetObj.gdc_ms_Status__c ='In Code Review';
        }
        try{
        update assetObj;
        }catch(DmlException e){
            system.debug('e '+e.getLineNumber()+' '+e.getMessage());
        }
        Test.stopTest();
    }
}