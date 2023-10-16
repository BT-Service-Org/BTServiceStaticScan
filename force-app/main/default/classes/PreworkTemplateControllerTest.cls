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
private class PreworkTemplateControllerTest {

    static testMethod void myUnitTest() {
		Academy_Prework__c prework;
		List<Academy_Prework__c> toInsert = new List<Academy_Prework__c>();
		prework = new Academy_Prework__c(	Subject_Area__c='Portals',
											Content_Link__c='http://content.com',
											Exercise_Link__c='http://exercise.com',
											Video_Recording_Link__c='http://video.com');
											
		toInsert.add(prework);
		prework = new Academy_Prework__c(	Subject_Area__c='Portals',
											Content_Link__c='http://content.com',
											Exercise_Link__c='http://exercise.com',
											Video_Recording_Link__c='http://video.com');
											
		toInsert.add(prework);
		prework = new Academy_Prework__c(	Subject_Area__c='Portals',
											Content_Link__c='http://content.com',
											Exercise_Link__c='http://exercise.com',
											Video_Recording_Link__c='http://video.com');
											
		toInsert.add(prework);
		insert toInsert;
		PreworkTemplateController ctlr = new PreworkTemplateController();
		System.assertEquals(3,ctlr.preworkTopics.size(),'PreworkTEmplate controller returned incorrect records');
    }
}