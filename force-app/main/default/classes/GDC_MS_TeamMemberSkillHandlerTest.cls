/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This is a test class for GDC_MS_TeamMemberSkillHandler class.
 ****************************/

@isTest
public with sharing class GDC_MS_TeamMemberSkillHandlerTest {

    static testMethod void testretrieveSkillsList() {
        List<String> temp = new List<String>();
        test.startTest();
        temp = GDC_MS_TeamMemberSkillHandler.retrieveSkillsList();
        test.stopTest();
    }


    static testMethod void testRetrieveSkillsApiNames() {
        List<String> temp = new List<String>();
        test.startTest();
        temp = GDC_MS_TeamMemberSkillHandler.retrieveSkillsApiNames();
        test.stopTest();
    }
     
}