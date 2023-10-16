@isTest
public class PSCBadgesCtrlTest {
    @testSetup
    static void createData() {
        Id recordTypeIdBadge = Schema.SObjectType.Achievement__c.getRecordTypeInfosByDeveloperName().get('Badge').getRecordTypeId();
        List<Achievement__c> achievementList = New List<Achievement__c>();
        Achievement__c achievementOne = PSCTestDataFactory.createAchievement();
        achievementOne.Description__c = 'Test Description One';
        achievementOne.RecordTypeId = recordTypeIdBadge;
        achievementList.add(achievementOne);
        
        Achievement__c achievementTwo = PSCTestDataFactory.createAchievement();
        achievementTwo.Description__c = '';
        achievementTwo.RecordTypeId = recordTypeIdBadge;
        achievementList.add(achievementTwo);
        
        List<User_Achievement_Activity__c> uaaList = new List<User_Achievement_Activity__c>();
        User_Achievement_Activity__c uaaOne = PSCTestDataFactory.createUAA();
        uaaOne.Achievement__c = achievementOne.Id;
        uaaList.add(uaaOne);
        
        User_Achievement_Activity__c uaaTwo = PSCTestDataFactory.createUAA();
        uaaTwo.Achievement__c = achievementTwo.Id;
        uaaList.add(uaaTwo);
        
        Test.startTest();
        insert achievementList;
        insert uaaList;
        Test.stopTest();
        
        
    }
    @isTest    
    public static void getBadgesTest(){
        List<Achievement__c> achievementList = [SELECT Id,Name,Description__c,Activity__c,
                                                (SELECT Id,name,User__c 
                                                 FROM User_Achievement_Activities__r 
                                                 WHERE User__c=:userinfo.getUserId())
                                                FROM Achievement__c 
                                                WHERE RecordType.DeveloperName = 'Badge'
                                                ORDER BY Activity__c,Count_Needed__c ASC NULLS LAST ]   ; 
        Test.startTest();
        PSCBadgesCtrl.getbadges('myBadges');
        Test.StopTest();
        System.assertNotEquals(null, achievementList);
    }
}