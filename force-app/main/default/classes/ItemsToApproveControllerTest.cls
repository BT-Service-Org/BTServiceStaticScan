@isTest
private class ItemsToApproveControllerTest {
    @isTest static void testGetWorkItems(){
        
        String userID = UserInfo.getUserID();
        
        Headcount_Request_New__c hcr = new Headcount_Request_New__c();
        insert hcr;
        
        /*
        // Create an approval request for the request
        Approval.processSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(hcr.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(userID);
        
        //Submit the record to a specific process and skip the criteria
        req1.setProcessDefinitionNameOrId('Approval Test Step');
        req1.setSkipEntryCriteria(true);
        
        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req1);
        
        //Verify the result
        System.assert(result.isSuccess());
		*/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(hcr);
        ItemsToApproveController itac = new ItemsToApproveController();
        
        PageReference pageRef = Page.ItemsToApprove;
        Test.setCurrentPage(pageRef);
       	itac.getWorkItems();
     
    }

}