trigger BadgeAssessmentRequestCreatedTrigger on Case(after insert) {
    RecordType BadgeRecordType = [select Id from recordtype where sobjecttype = 'Case'
        and name = 'Badge Assessment Request'
        limit 1
    ].get(0);
    RecordType CaseRecordType = [select Id from recordtype where sobjecttype = 'Case'
        and name = 'CTA Review Assessment Request'
        limit 1
    ].get(0);

    List < Judge__c > impactedJudges = new List < Judge__c > {};
    List < Learning_Domain__c > impactedLearningDomains = new List < Learning_Domain__c > {};
    List < CTA_Review_Session__c > impactedReviewSessions = new List < CTA_Review_Session__c > {};
    List < CTA_Board_Candidate__Share > impactedCTABoardCandidateSh = new List < CTA_Board_Candidate__Share > {};
    

    List < Id > impactedCases = new List < Id > {};

    for (Case thisCase: Trigger.New) {
        //Badge
        if (thisCase.RecordTypeId == BadgeRecordType.id) {
            if (thisCase.Judge_Assigned__c != null)
                impactedJudges.add(new Judge__c(id = thisCase.Judge_Assigned__c, Last_Request_Assigned_Date__c = DateTime.Now()));
            impactedCases.add(thisCase.id);
            Learning_Domain__c thisLearningDomain = new Learning_Domain__c(id = thisCase.Learning_Domain__c,
                assessment_request_date__c = DateTime.now());
             impactedLearningDomains.add(thisLearningDomain);           
            
            if (impactedJudges.size() > 0)
                update impactedJudges;

            if (impactedLearningDomains.size() > 0)
                update impactedLearningDomains;

            if (impactedCases.size() > 0)
                BadgeAssessmentRequestUtil.notifyByEMail(impactedCases);
                

        }
 
        //Cases
        if (thisCase.RecordTypeId == CaseRecordType.id) {
            if (thisCase.Judge_Assigned__c != null)
                impactedJudges.add(new Judge__c(id = thisCase.Judge_Assigned__c, Last_Request_Assigned_Date__c = DateTime.Now()));
            impactedCases.add(thisCase.id);
            CTA_Review_Session__c thisCTAReviewSession = new CTA_Review_Session__c(id = thisCase.CTA_Review_Session__c,
                assessment_request_date__c = DateTime.now());
            impactedReviewSessions.add(thisCTAReviewSession);
            
            CTA_Board_Candidate__Share thisCTABoardCandidateSh = new CTA_Board_Candidate__Share(AccessLevel = 'Edit', RowCause = 'Evaluator_Access__c', ParentId = thisCase.CTA_Board_Candidate__c, UserOrGroupId = thisCase.OwnerId  );
            impactedCTABoardCandidateSh.add(thisCTABoardCandidateSh);           

            if (impactedJudges.size() > 0)
                update impactedJudges;

            if (impactedReviewSessions.size() > 0)
                update impactedReviewSessions;

            if (impactedCases.size() > 0)
                CaseAssessmentRequestUtil.notifyByEMail(impactedCases);

            system.debug('--TJ'+impactedCTABoardCandidateSh);              
            if (impactedCTABoardCandidateSh.size() > 0)
                insert impactedCTABoardCandidateSh;     

        }

    }


}