global with sharing class  CTAReviewCreateRecords {
    
    webservice static void CreateRecords(Id BoardCandidateId) {
        
 
        List<CTA_Review_Session__c> ReviewRecds = new List<CTA_Review_Session__c>();
        RecordType GovernanceType = [select Id,Name from RecordType where Name = 'Hypothetical Scenario with Governance'];
        RecordType NonGovernanceType = [select Id,Name from RecordType where Name = 'Hypothetical Scenario without Governance'];
        
        
        Integer dayscounter = 1;
		CTA_Board_Candidate__c BoardCandidate = [Select Id,Coach__c from CTA_Board_Candidate__c where Id = :BoardCandidateId] ;  
		
		
		Map<String, CTA_Review_Session__c> mapexistrecd= New Map<String, CTA_Review_Session__c>();   										
		for (CTA_Review_Session__c Existingrecord :[select Id,Scenario__c
												from CTA_Review_Session__c where CTA_Board_Candidate__c =:BoardCandidateId])
		{
			mapexistrecd.put(Existingrecord.Scenario__c,Existingrecord)	;										
		}
												
		System.Debug(mapexistrecd);    
        
        for(CTA_Review_Create__c record :[Select Name,Id,Type__c,Attempt_Time__c,Present_QA_Time__c from CTA_Review_Create__c order by Sequence__c] )
        {
            
            if (record.Type__c == 'Governance' && !(mapexistrecd.containsKey(record.name)))
            {
               dayscounter = dayscounter + 7;
               ReviewRecds.add(new CTA_Review_Session__c(RecordTypeId=GovernanceType.Id,Scenario__c=record.name,
                                                      CTA_Board_Candidate__c=BoardCandidate.Id,Evaluator__c=BoardCandidate.Coach__c,
                                                      Attempt_Time__c =record.Attempt_Time__c,
                                                      Present_QA_Time__c = record.Present_QA_Time__c,
                                                      Evaluation_Date__c=date.today().adddays(dayscounter))); 
            }
            else if (!(mapexistrecd.containsKey(record.name)))
            {
               dayscounter = dayscounter + 7;
               ReviewRecds.add(new CTA_Review_Session__c(RecordTypeId=NonGovernanceType.Id,Scenario__c=record.name,
                                                      CTA_Board_Candidate__c=BoardCandidate.Id,Evaluator__c=BoardCandidate.Coach__c,
                                                      Attempt_Time__c =record.Attempt_Time__c,
                                                      Present_QA_Time__c = record.Present_QA_Time__c,
                                                      Evaluation_Date__c=date.today().adddays(dayscounter))); 
            }
  
        }
        insert ReviewRecds;
    }

}