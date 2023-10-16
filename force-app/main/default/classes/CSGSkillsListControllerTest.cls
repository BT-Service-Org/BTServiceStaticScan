@isTest(SeeAllData=true)
public with sharing class CSGSkillsListControllerTest {
    public static User createUser() {
        String hostname = '@sfservices.com.qa';//swap out for prod
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User testUser = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + hostname
        );
        insert testUser;
        return testUser;
    }

    static testMethod void testGetAllUserSkillsList() {
        User testUser = createUser();
        List<CSGSkillsListController.UserSkillWrapper> userSkillWrapperList = new List<CSGSkillsListController.UserSkillWrapper>();
        System.runAs(testUser){
            Test.startTest();
            userSkillWrapperList = CSGSkillsListController.getAllUserSkillsList(testUser.id);
            Test.stopTest();
        }   
        System.assert(userSkillWrapperList.size() > 0);
    }
}