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
private class sh_BioTest {
    static testMethod void testSingleBioAndPracticeLeaders() {
        Id practiceId = sh_TestDataSetup.createPractice('analytics-cloud-practice', 'Analytics Practice', true, 1);
        sh_TestDataSetup.createBios(practiceId);
    	
    	Test.startTest();
        
        //Test default bio
        PageReference pageRef = Page.sh_bio;
        Test.setCurrentPage(pageRef);
        sh_BioController bc = new sh_BioController();
        System.assertEquals('justin-waite', bc.bio.Bio_Name__c);
        System.assertEquals('Justin Waite', bc.bio.Name);
        
        //Test specific bio
        pageRef = Page.sh_bio;
        pageRef.getParameters().put('name', 'amisha-goyal');
        Test.setCurrentPage(pageRef);
        bc = new sh_BioController();
        System.assertEquals('Amisha Goyal', bc.bio.Name);
        
        //Test practice leaders
        bc = new sh_BioController();
        bc.practiceCode = 'analytics-cloud-practice';
        List<sh_BioController.PersonInfo> pracLeaders = bc.getPracticeLeaders();
        System.assertEquals('Shashidhar Gurumurthy', pracLeaders.get(0).personName);
        System.assertEquals('Amisha Goyal', pracLeaders.get(1).personName);
        
        Test.stopTest();
    }
    
    static testMethod void testProjectFeaturedTeam() {
        sh_project__c proj = sh_TestDataSetup.createFeaturedTeam();
    	
    	Test.startTest();
        
        sh_featuredTeamController ftc = new sh_featuredTeamController();
        ftc.project = proj;
        List< sh_Bio__c > bios = ftc.getBios();
        
        System.assertEquals('Shashidhar Gurumurthy', bios.get(0).Name);
        
        Test.stopTest();
    }
    
}