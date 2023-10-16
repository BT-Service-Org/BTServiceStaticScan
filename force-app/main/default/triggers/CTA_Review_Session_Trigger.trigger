trigger CTA_Review_Session_Trigger on CTA_Review_Session__c (before insert, before update, after insert) {

    Folder FolderName = [Select Id from Folder where Name = 'CTA Scenarios' limit 1];
	Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.CTA_Review_Session__c.getRecordTypeInfosById();  
    
    
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        // update the candidate and pa onboarding record
        Set <Id> relatedBoardCandidateIds = new Set <Id> ();
        Map <Id, CTA_Board_Candidate__c> relatedCandidates = new Map <Id, CTA_Board_Candidate__c>(); 
        List <CTA_Review_Session__c> sessionsToDefault = new List <CTA_Review_Session__c>();
        
        
        for (CTA_Review_Session__c session : trigger.new) {
            if (session.CTA_Board_Candidate__c != null && 
                    (session.Candidate__c == null || session.PA_Onboarding__c == null)) {
                relatedBoardCandidateIds.add(session.CTA_Board_Candidate__c);
                sessionsToDefault.add(session);

            }
          
  
           
            String oldscenarioval ='';
            Boolean oldsendnow=false;
            if (trigger.isUpdate)
            {    
                CTA_Review_Session__c OldreviewsessionId =  trigger.oldmap.get(session.Id);
                 oldscenarioval =   OldreviewsessionId.Scenario__c;
                 oldsendnow = OldreviewsessionId.Send_Scenario_Now__c;
            }
            
           if (session.Attempt_Time__c == null) 
          {
	          System.Debug ('Record Types' +rtMap.get(session.RecordTypeId).getName());
	          System.Debug ('Scenario' +session.Scenario__c);
	          session.Attempt_Time__c = CTAReviewSessionDefaultTime.AttemptTime(session.Scenario__c, rtMap.get(session.RecordTypeId).getName());
	          session.Present_QA_Time__c =CTAReviewSessionDefaultTime.PresentTime(session.Scenario__c, rtMap.get(session.RecordTypeId).getName());
          }   
            
            if ((oldsendnow == false && session.Send_Scenario_Now__c == True) ||
                ((oldscenarioval == '' || oldscenarioval != session.Scenario__c) && session.Send_Scenario_Now__c == True))
            {
                List<Document> scenariodoc = [select name,contentType,developername,type,body 
                from Document where folderId = :foldername.Id and name = :session.Scenario__c limit 1];

                String scenarioKeyName = 'Key:'+session.Scenario__c ;
                List<Document> scenariokey = [select name,contentType,developername,type,body 
                from Document where folderId = :foldername.Id and name = :scenarioKeyName limit 1];
                     
                CTA_Board_Candidate__c BoardCandidate = [select Id,Candidate__r.Email,
                                                Coach__r.Email,
                                                Secondary_Coach__r.Email
                                                        from CTA_Board_Candidate__c
                                        where Id = :session.CTA_Board_Candidate__c limit 1];
                
                
                session.Status__c = 'Scenario Sent';
                
              CTAReviewSessionEmails.SendEmail(scenariodoc, BoardCandidate.Coach__r.Email, BoardCandidate.Secondary_Coach__r.Email,
                                                  BoardCandidate.Candidate__r.Email, 'Scenario',session.Attempt_time__c,session.Present_QA_Time__c);
                
                 CTAReviewSessionEmails.SendEmail(scenariokey, BoardCandidate.Coach__r.Email, BoardCandidate.Secondary_Coach__r.Email,
                                                  null, 'Solution',session.Attempt_time__c,session.Present_QA_Time__c);
            }                                     

        }
        
        relatedCandidates = new Map<Id, CTA_Board_Candidate__c>([Select PA_Onboarding__c, Candidate__c 
                                            from CTA_Board_Candidate__c where Id in :relatedBoardCandidateIds]);
        
        for (CTA_Review_Session__c session : sessionsToDefault) {
            CTA_Board_Candidate__c candidate = relatedCandidates.get(session.CTA_Board_Candidate__c);
            
            if (candidate!=null) {
                session.Candidate__c = candidate.Candidate__c;
                session.PA_Onboarding__c = candidate.PA_Onboarding__c;
            }
        }
                
    }
    
    
  

    // Added additional conditions as trigger handles more events
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
    // Add Rating Criteria to Review Session Record 
            CTAReviewUtilities.CreateReviewRatings(Trigger.New);
        }
        if (trigger.isInsert | TRigger.isUpdate) {
            CTAMockJudgeShare.createShares(Trigger.new);
        }
    }


}