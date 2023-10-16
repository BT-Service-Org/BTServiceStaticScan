trigger CTA_Board_Candidate_Trigger on CTA_Board_Candidate__c (before insert, before update, after insert, after update) {

    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        // update the pa onboarding record
        System.debug('Testing');
        Set <Id> relatedPAIds = new Set <Id> ();
        Map <Id, PA_Onboarding__c> relatedPAs = new Map <Id, PA_Onboarding__c>(); 
        List <CTA_Board_Candidate__c> candidatesToDefault = new List <CTA_Board_Candidate__c>();
        
        for (CTA_Board_Candidate__c candidate : trigger.new) {
            if (candidate.PA_Onboarding__c != null && candidate.Candidate__c == null) {
                relatedPAIds.add(candidate.PA_Onboarding__c);
                candidatesToDefault.add(candidate);
            }
        }
        
        relatedPAs = new Map<Id, PA_Onboarding__c>([Select Contact__c 
                                            from PA_Onboarding__c where Id in :relatedPAIds]);
        
        for (CTA_Board_Candidate__c candidate : candidatesToDefault) {
            PA_Onboarding__c pa = relatedPAs.get(candidate.PA_Onboarding__c);
            
            if (candidate!=null) {
                candidate.Candidate__c = pa.Contact__c;
            }
        }
        
        
    }
        if (trigger.isAfter)
        {
 	       System.debug('In the After INsert loop');
     	   CTABoardCandidateSharing.RecordShare(trigger.new,trigger.newmap);
    	}

}