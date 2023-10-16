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
private class ProjectFeedbackTestClass {

    static testMethod void myUnitTest() {
        
        //CREATE A NEW PROJECT
        Project_Detail__c pd = new Project_Detail__c(
        					Name = 'Test Project',
        					Project_Start_Date__c = date.newinstance(2008, 11, 30),
        					Project_End_Date__c = date.newinstance(2008, 12, 31));
        insert pd;
        
        
        //CREATE PROJECT FEEDBACK RECORDS
        List<Project_Feedback__c> pfList = new List<Project_Feedback__c>();
        for (Integer x = 0; x < 10; x++){
    		Project_Feedback__c p = new Project_Feedback__c(
                            Project__c = pd.Id,
                            Resource_Name__c = '00530000000o7RR',
                            Name = 'Test Project Feedback',
                            OwnerId = '00530000000o7RR',
                            RecordTypeId = '01230000000596u',
                            Start_Date__c = date.newinstance(2008, 11, 30),
                            End_Date__c = date.newinstance(2008, 12, 31));
			pfList.add(p);
        }
        insert pfList;
                  

        //VERIFY RECORDS INSERTED
        for (Project_Feedback__c p : [SELECT Name from Project_Feedback__c WHERE Id IN :pfList]) {
            System.assertEquals(p.Name,'Nathan Crosby - Test Project');
        }
    }
}