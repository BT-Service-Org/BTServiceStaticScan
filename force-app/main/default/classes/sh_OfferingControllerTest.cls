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
private class sh_OfferingControllerTest {
    static testMethod void testOffering() {
        Id pracId = sh_TestDataSetup.createKeyPresentation('Some Practice', 'some-practice', 'practice');
        
        sh_Offering__c offering = sh_TestDataSetup.createOffering(pracId);
        
        Test.startTest();
	        PageReference pageRef = Page.sh_Offering;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put('name',offering.Offering_Name__c) ;
	        sh_OfferingController pc = new sh_OfferingController();
	        System.assertEquals(pc.offering.Offering_Name__c, offering.Offering_Name__c);
	        System.assertNotEquals(pc.staticImageId, null);
        Test.stopTest();
        
        
    }
    
}