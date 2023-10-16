@isTest
public class TestGdcmsCustomerVisitController {
    // Test method to insert test data
    @TestSetup
    static void setupTestData() {

        // Create test Customer Visit records with gdc_ms_Is_Visible_on_Carousel__c set to true
        List<gdc_ms_Customer_Visit__c> customerVisits = new List<gdc_ms_Customer_Visit__c>();
        for (Integer i = 0; i < 5; i++) {
            gdc_ms_Customer_Visit__c engagement = new gdc_ms_Customer_Visit__c(
                gdc_ms_Customer_Logo__c = 'Test Customer Logo ' + i,
                gdc_ms_Designation_of_Visitor__c = 'Test Designation ' + i,
                // Add other required fields here
                gdc_ms_Is_Visible_on_Carousel__c = true
            );
            customerVisits.add(engagement);
        }
        insert customerVisits;
    }

    // Test method for getData() in gdcmsCustomerVisitController
    @isTest
    static void testGetData() {
        // Call the controller method
        List<gdc_ms_Customer_Visit__c> result = gdcmsCustomerVisitController.getData();

        // Assert that the result is not null
        System.assertNotEquals(null, result);

        // Add additional assertions based on your requirements
        // For example, you can check if the correct number of records is returned.
        System.assertEquals(4, result.size());
    }
}