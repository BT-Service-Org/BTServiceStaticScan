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
private class sh_ProjectControllerTest {
    static testMethod void testProjectListForProject() {
        sh_TestDataSetup.createPractices();
    	
    	Test.startTest();
        sh_ProjectListController plc = new sh_ProjectListController();
        plc.practiceId = sh_TestDataSetup.acPracId;
        List<sh_ProjectListController.ProjectInfo> projInfo = plc.getProjectData();
        
        Test.stopTest();
        
        System.assertEquals('CSG Analytics', projInfo.get(0).Name);
        System.assertEquals('Home Depot Paint', projInfo.get(1).Name);
        System.assertEquals('csg-analytics', projInfo.get(0).projectName);
        System.assertEquals('home-depot-paint', projInfo.get(1).projectName);
    }
    
    static testMethod void testProjectListForBio() {
        sh_TestDataSetup.createBios(null);
    	
    	Test.startTest();
        sh_ProjectListController plc = new sh_ProjectListController();
        plc.userId = sh_TestDataSetup.bioId;
        List<sh_ProjectListController.ProjectInfo> projInfo = plc.getProjectData();
        
        Test.stopTest();
        
        System.assertEquals('CSG Analytics', projInfo.get(0).Name);
        System.assertEquals('Home Depot Paint', projInfo.get(1).Name);
        System.assertEquals('csg-analytics', projInfo.get(0).projectName);
        System.assertEquals('home-depot-paint', projInfo.get(1).projectName);
        
    }
    
    static testMethod void testProject() {
    	sh_TestDataSetup.createPractices();
    	
    	Test.startTest();
    	
    	//Test default project 
        PageReference pageRef = Page.sh_project;
        Test.setCurrentPage(pageRef);
        sh_ProjectController pc = new sh_ProjectController();
 
        System.assertEquals('CSG Analytics', pc.project.Name);
        System.assertEquals('csg-analytics', pc.projectName);
        System.assertEquals(sh_TestDataSetup.singleAttachment, pc.staticImageId);
        
        pageRef = Page.sh_project;
        pageRef.getParameters().put('name', 'home-depot-paint');
        Test.setCurrentPage(pageRef);
        pc = new sh_ProjectController();
 
        System.assertEquals('Home Depot Paint', pc.project.Name);

        Test.stopTest();
    }
    
    static testMethod void testKeyPresentations() {
    	Id projId = sh_TestDataSetup.createKeyPresentation('Some Project', 'some-project', 'project');
    	Id pracId = sh_TestDataSetup.createKeyPresentation('Some Practice', 'some-practice', 'practice');
    	
    	Test.startTest();
    	
    	//Test Practice Presentation
    	sh_PresentationController pc = new sh_PresentationController();
    	pc.practiceId1 = pracId;
    	List<sh_PresentationController.PresentationInfo> presentations = pc.getPresentationDto();
    	System.assertEquals(1, presentations.size());
    	System.assertEquals('practice-Some Name', presentations.get(0).presentationName);
    	System.assertEquals('Some Description', presentations.get(0).description);
    	System.assert(presentations.get(0).attachmentId != null);
    	
    	//Test Project Presentation
    	pc = new sh_PresentationController();
    	pc.projectId1 = projId;
    	presentations = pc.getPresentationDto();
    	System.assertEquals(1, presentations.size());
    	System.assertEquals('project-Some Name', presentations.get(0).presentationName);
    	System.assertEquals('Some Description', presentations.get(0).description);
    	System.assert(presentations.get(0).attachmentId != null);
    	
    	Test.stopTest();
    }
}