/**
 * The purpose of the apex batch is to create temporary data for EA. This batch apex will get all Onbording record and create a TempLearning Record (Onbording ID, Certification details).
 * This data will be augmented with Learning Domain data in Einstein Analytics
 * Created Date: June 18th,2020
 **/

global class createOnboardingBadgeData implements Database.Batchable<SObject>,Database.Stateful, Database.AllowsCallouts  {
    
	global String query;
    global String selectString; 
    private String sessionId;

	global System.LoggingLevel level = LoggingLevel.ERROR;
    static List<Badge__c> badges = [
        Select Id, Name 
        from Badge__c 
        where Include_In_Reports__c = true
    ];
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
		String query;
        if(Test.isRunningTest()){
            query ='Select Id, Name, Candidate_Email__c from PA_Onboarding__c where Name like \'Test%\'';
        }else{
            query = 'Select Id, Name, Candidate_Email__c from PA_Onboarding__c where Candidate__r.IsActive = true';
        System.debug(query);
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<PA_Onboarding__c > scope){
    	if(badges.size()>0){
            System.debug(LoggingLevel.INFO, badges);
            List<Onboarding_Badge_Data__c> tempList = new List<Onboarding_Badge_Data__c>();
            for (PA_Onboarding__c eachOnboarding: scope){
            	for (Badge__c eachBadge:badges){
                    Onboarding_Badge_Data__c obd = new Onboarding_Badge_Data__c ();
                    obd.Onboarding__c = eachOnboarding.Id;
                    obd.Badge__c = eachBadge.Id;
                    obd.Name__c = '' + eachOnboarding.Candidate_Email__c + eachBadge.Name;
                    obd.Unique_Id__c = '' + eachOnboarding.Candidate_Email__c + eachBadge.Name;
                    tempList.add(obd);
            	}
        	}
        	System.debug('***'+tempList);
        	insert tempList;
        } else {
            System.debug('No Badges');
        }
  
    }
    global void finish(Database.BatchableContext BC){
		// Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.debug('Job Status' +a.status);
        //then use the active job id and abort it
    	// kick off replication from here
        if(a.status =='Completed'){
            String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();   
            String restAPIURL = sfdcURL + '/services/data/v48.0/wave/dataConnectors/'+System.Label.expertiseAppJobID+'/ingest';
            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());       
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            request.setEndpoint(restAPIURL); 
           	// String sessionId= UserInfo.getSessionId();
            request.setHeader('Content-Type' , 'application/json');
            request.setBody('{}');
            request.setMethod('POST');
            System.debug(request );
            Http http = new Http(); 
            HttpResponse response = new HttpResponse();
             if(!Test.isRunningTest ())
        {
             response = http.send(request);
        }
            System.debug(response );
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            } else {
                if (response.getStatusCode() == 200) {
                	// Deserialize the JSON string into collections of primitive data types.
                	Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                	// Cast the values in the 'animals' key as a list
                	List<Object> message = (List<Object>) results.get('message');
                	System.debug('Received the following message :');
                	System.debug(message );
        		}
			}
       
		}
    }
}