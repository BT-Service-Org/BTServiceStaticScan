@isTest
public class StationindividualProfileControllerTest {
    
    @isTest
    public static void TestconnectedUser(){
        Test.startTest();
        StationindividualProfileController.connectedUser();
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void TestfetchCases(){
        Test.startTest();
        StationindividualProfileController.fetchCases('The Station Content Request' , 'content');
        StationindividualProfileController.fetchCases('The Station Content Request' , 'submit');
        StationindividualProfileController.fetchCases('The Station Feedback' , '');
        StationindividualProfileController.fetchCases('The Station SP Record Feedback' , '');
        Test.stopTest();
    }
    
}