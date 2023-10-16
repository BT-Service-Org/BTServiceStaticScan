@isTest
public with sharing class GDC_MS_HeadCountTest {
    
    static testMethod void getTeamMemberCountTest() {
        test.startTest();
        Integer intSize = GDC_MS_HeadCount.getTeamMemberCount();
        System.assert(intSize==0);
        test.stopTest();
    }
}