/**
 * @author piyush.jindal@salesforce.com
 * @since August 2023
 * @description Test class for PSCMembersCtrlTest
 * @group Services Central
 */
@isTest
public class PSCMembersCtrlTest {
    @testSetup
    static void createData() {
        Id practiceRecordTypeId = Schema.SObjectType.Contribution_Team__c.getRecordTypeInfosByDeveloperName().get('Community_of_Practice').getRecordTypeId();
        PSC_Page__c communityPageObj = new PSC_Page__c (Page_Title__c = 'Test Community');
        insert communityPageObj;

        Contribution_Team__c teamMember_1 = new Contribution_Team__c (Community__c = communityPageObj.Id, psc_Role__c = 'Leader', 
                                                                      psc_Team_Member__c = UserInfo.getUserId(), RecordTypeId = practiceRecordTypeId);
        insert teamMember_1;
    }

    @isTest    
    public static void getMembersWithoutSearchTest(){
        Integer memberListCount = [SELECT count()
                                   FROM Contribution_Team__c 
                                   WHERE RecordType.DeveloperName = 'Community_of_Practice'];
        Test.startTest();
        PSCMembersCtrl.getMembers('', '', '');
        Test.StopTest();
        
        System.assertEquals(1, memberListCount);
    }
    
    @isTest    
    public static void getMembersWithSearchTest(){
        Integer memberListCount = [SELECT count()
                                   FROM Contribution_Team__c 
                                   WHERE RecordType.DeveloperName = 'Community_of_Practice'];
        Test.startTest();
        PSCMembersCtrl.getMembers('', '', 'TestName');
        Test.StopTest();
        
        System.assertEquals(1, memberListCount);
    }
    
    @isTest    
    public static void getSettingTest(){
		String tabToMemberRoleSetting = PSCSettingService.getValue('Test Setting');
		String returnedValueStr = null;

        Test.startTest();
        returnedValueStr = PSCMembersCtrl.getSetting('Test Setting');
        Test.StopTest();
        
        System.assertEquals(returnedValueStr, tabToMemberRoleSetting);
    }
}