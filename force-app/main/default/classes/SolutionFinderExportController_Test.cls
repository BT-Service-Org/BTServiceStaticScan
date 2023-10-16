@IsTest
public with sharing class SolutionFinderExportController_Test {

    testMethod public static void testController() {

        PageReference pageRef = Page.SolutionFinderExport;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('namespace', 'Example');
        ApexPages.currentPage().getParameters().put('name', 'Example');

        Test.startTest();
        SolutionFinderExportController controller = new SolutionFinderExportController();
        Test.stopTest();
    }
}