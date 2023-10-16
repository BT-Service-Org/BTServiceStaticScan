@IsTest
public with sharing class SolutionFinderCompareController_Test {

    testMethod public static void testController() {

        PageReference pageRef = Page.SolutionFinderCompare;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('namespace', 'Example');
        ApexPages.currentPage().getParameters().put('name', 'Example');

        Test.startTest();
        SolutionFinderCompareController controller = new SolutionFinderCompareController();
        Test.stopTest();
    }
}