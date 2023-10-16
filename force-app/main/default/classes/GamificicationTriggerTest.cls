@isTest
public class GamificicationTriggerTest {
    @TestSetup
    static void createData(){
        Id recordTypeId = Schema.SObjectType.User_Achievement_Activity__c.getRecordTypeInfosByDeveloperName().get('Tracking').getRecordTypeId();
        Id recordTypeIdBadge = Schema.SObjectType.Achievement__c.getRecordTypeInfosByDeveloperName().get('Badge').getRecordTypeId();
 
        List<Achievement__c> achievementList = new List<Achievement__c>();
        Achievement__c achievementOne = PSCTestDataFactory.createAchievement();
        achievementList.add(achievementOne);
        
        Achievement__c achievementTwo = PSCTestDataFactory.createAchievement();
       
        achievementTwo.Activity__c = 'Contribute';
        achievementTwo.Count_Needed__c = 2;
        achievementTwo.Active__c = true;
        achievementList.add(achievementTwo);
        
        List<User_Achievement_Activity__c> uaaNewList = new List<User_Achievement_Activity__c>();
        User_Achievement_Activity__c uaaObjOne = PSCTestDataFactory.createUAA();
        uaaObjOne.Achievement__c = achievementOne.Id;
        uaaNewList.add(uaaObjOne);
        
        User_Achievement_Activity__c uaaObjTwo = PSCTestDataFactory.createUAA();
        uaaObjTwo.Achievement__c = achievementOne.Id;
        uaaNewList.add(uaaObjTwo);
        
        test.startTest();
        insert achievementList;
        insert uaaNewList;
        test.stopTest();
        
    }
    
    @isTest
    public static void testGamificationTrigger(){
    List<Achievement__c> achievementList = [Select Id from Achievement__c Where RecordType.DeveloperName = 'Badge' 
                                            and Activity__c = 'Contribute' and Active__c = true and Count_Needed__c!= 0
                                           and CreatedById =: UserInfo.getUserId()];
        
    User_Achievement_Activity__c uaa = [Select Id from User_Achievement_Activity__c Where User__c =:UserInfo.getUserId()
                                        and Achievement__c In: achievementList  Limit 1];
    System.assertNotEquals(null, uaa, 'Method should return data');
        
        
    }
    
}