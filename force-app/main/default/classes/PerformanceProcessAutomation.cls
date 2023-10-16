global class PerformanceProcessAutomation {

	// this inner class represents the return type for the web services contained herein
	global class ResultInfo{
  		// boolean indicating whether an error occurred
  		WebService Boolean isSuccess;
    	// string to contain any generated error message
    	WebService String errorMsg;
  	}


	webService static ResultInfo generateCustomerImpactRecsForScorecard(String scorecardId) {
	
		// define local vars
		List<Project_Feedback__c> feedbackRecs;
		List<Custom_Impact_Project__c> impactRecs;
		ResultInfo result = new ResultInfo();
		
		result.errorMsg = '';
		
		try {
			// retrieve all of the project feedback records that are associated to the received scorecard
			feedbackRecs = [Select Id, FInal_Feedback_Score__c From Project_Feedback__c Where Employee_Scorecard__c = :scorecardId];
			
			if (feedbackRecs.isEmpty() == false) {
			
				// create a new blank collection of customer impact records
				impactRecs = new List<Custom_Impact_Project__c>();
			
				// iterate over the returned feedback records, and create corresponding customer impact records
				for (Project_Feedback__c PFRec : feedbackRecs) {
					
					if (PFRec.FInal_Feedback_Score__c != null) {
						impactRecs.add(new Custom_Impact_Project__c(Project_Feedback__c = PFRec.Id, 
							Employee_Scorecard__c = scorecardId, Final_Score__c = Double.valueOf(PFRec.FInal_Feedback_Score__c)));
					} else {
						impactRecs.add(new Custom_Impact_Project__c(Project_Feedback__c = PFRec.Id, Employee_Scorecard__c = scorecardId));
					}
				}
			
				// create the new customer impact recs
				insert impactRecs;
			}
			
			// packup up the return type
			result.isSuccess = true;
		
		} catch (Exception error) {
			// packup up the return type
			result.isSuccess = false;
			result.errorMsg = error.getMessage();
		}
		
		return result;
	}
	
	public static testMethod void generateCustomerImpactRecsForScorecard_Test() {
	
		// retrieve a source record to steal data from
		Employee_Scorecard__c sourceRec = [Select RecordTypeId, Name, Job_Title__c, Organization_Name__c, Scorecard_Date__c,
			Manager_Name__c, Employee_Name__c From Employee_Scorecard__c LIMIT 1];  
	
		// create a test scorecard record
		Employee_Scorecard__c testEmpScrCrdRec = new Employee_Scorecard__c(RecordTypeId = sourceRec.RecordTypeId, 
			Name = sourceRec.Name, Job_Title__c = sourceRec.Job_Title__c, Scorecard_Date__c = sourceRec.Scorecard_Date__c,
			Organization_Name__c = sourceRec.Organization_Name__c, Employee_Name__c = sourceRec.Employee_Name__c );
		
		// insert it	
		insert testEmpScrCrdRec;
		
		// create a couple of sample projects to test the function
		Project_Detail__c testPrj1 = new Project_Detail__c(Name = 'Test 1', Project_Start_Date__c = System.today(), 
			Project_End_Date__c = System.today());
		Project_Detail__c testPrj2 = new Project_Detail__c(Name = 'Test 2', Project_Start_Date__c = System.today(), 
			Project_End_Date__c = System.today());
		
		// insert test projects
		insert new Project_Detail__c[]{testPrj1, testPrj2};
		
		// create some project feed entries 
		Project_Feedback__c testFeedback1 = new Project_Feedback__c(RecordTypeId = '01230000000596u', Project__c = testPrj1.Id, 
			Resource_Name__c = sourceRec.Employee_Name__c, Name = 'test 1', Start_Date__c = System.today(), 
			End_Date__c = System.today(), FInal_Feedback_Score__c = '5', Employee_Scorecard__c = testEmpScrCrdRec.Id );
		Project_Feedback__c testFeedback2 = new Project_Feedback__c(RecordTypeId = '01230000000596u', Project__c = testPrj2.Id, 
			Resource_Name__c = sourceRec.Employee_Name__c, Name = 'test 2', Start_Date__c = System.today(), 
			End_Date__c = System.today(), FInal_Feedback_Score__c = '3', Employee_Scorecard__c = testEmpScrCrdRec.Id);
		
		// insert the test feedback entries
		insert new Project_Feedback__c[] {testFeedback1, testFeedback2};
		
		// retrieve the ID and call our method
		ResultInfo result = generateCustomerImpactRecsForScorecard(testEmpScrCrdRec.Id);
		
		// validate the response object
		System.assertEquals(result.isSuccess, true);
		
		// retrieve the created records and verify that the final scores match the source records
		Custom_Impact_Project__c [] impactRecs = [Select Id, Final_Score__c, Project_Feedback__c 
			From Custom_Impact_Project__c Where Employee_Scorecard__c = :testEmpScrCrdRec.Id];
			
		// first ensure that both records were created
		System.assert(impactRecs.size() == 2);
		
		// now verify the values on the final score match
		for (Custom_Impact_Project__c record : impactRecs) {
		
			if (record.Project_Feedback__c == testFeedback1.Id) {
				System.assertEquals(record.Final_Score__c, Double.valueOf(testFeedback1.FInal_Feedback_Score__c));
			} else {
				System.assertEquals(record.Final_Score__c, Double.valueOf(testFeedback2.FInal_Feedback_Score__c));
			}
		}
	}
}