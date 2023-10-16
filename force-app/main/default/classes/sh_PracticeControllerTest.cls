/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class sh_PracticeControllerTest {
    static testMethod void testHomePage() {
    	sh_TestDataSetup.createPractices();
    	
    	Test.startTest();
        PageReference pageRef = Page.sh_home;
        Test.setCurrentPage(pageRef);
        sh_PracticeController pc = new sh_PracticeController();
        Test.stopTest();
        
        System.assertEquals('services-1', pc.practice.Practice_Name__c);
        System.assertEquals('services-2', pc.practice2.Practice_Name__c);
        System.assertEquals(sh_TestDataSetup.attachments.get(0).Id, pc.quickFact1Id);
        System.assertEquals(sh_TestDataSetup.attachments.get(1).Id, pc.quickFact2Id);
        System.assertEquals(sh_TestDataSetup.attachments.get(2).Id, pc.quickFact3Id);
        System.assertEquals(sh_TestDataSetup.attachments.get(3).Id, pc.quickFact4Id);
        System.assertEquals(sh_TestDataSetup.attachments.get(4).Id, pc.factSheetId);
        
        //Test practices list data
        System.assertEquals('Analytics Practice', pc.practicesDto.get(0).practiceName);
        System.assertEquals('analytics-cloud-practice', pc.practicesDto.get(0).practiceCode);
        System.assertEquals('CXD', pc.practicesDto.get(1).practiceName);
        System.assertEquals('customer-experience-design', pc.practicesDto.get(1).practiceCode);
    }

    static testMethod void testPracticePage() {
    	sh_TestDataSetup.createPractices();
    	
    	Test.startTest();
        PageReference pageRef = Page.sh_practice;
        pageRef.getParameters().put('name', 'analytics-cloud-practice');
        Test.setCurrentPage(pageRef);
        sh_PracticeController pc = new sh_PracticeController();
        Test.stopTest();
        
        System.assertEquals('analytics-cloud-practice', pc.practice.Practice_Name__c);
    }
}