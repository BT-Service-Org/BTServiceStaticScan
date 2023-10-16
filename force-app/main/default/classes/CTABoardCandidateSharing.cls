public class CTABoardCandidateSharing {

    public static void RecordShare (List<CTA_Board_Candidate__c> BoardCandidate, Map<Id,CTA_Board_Candidate__c> BoardCandidateMap){
        
        System.debug('Sharing Class');
        List<CTA_Board_Candidate__share> NewShares =  new List<CTA_Board_Candidate__share>();
        Map <Id,Id> CandidateUserid = new Map <Id,Id>();
        Map <Id,Id> CoachUserid = new Map <Id,Id>();
        Map <Id,Id> SecCoachUserid = new Map <Id,Id>();
        CTA_Board_Candidate__c OldRecord = null;
        
        for (CTA_Board_Candidate__c a : [select Id, PA_Onboarding__r.Candidate__c,PA_Onboarding__r.Candidate__r.IsActive,
                                         Coach__c,Coach__r.IsActive,
                                         Secondary_Coach__c,Secondary_Coach__r.IsActive
                                         from CTA_Board_Candidate__c
                                        where Id = :BoardCandidateMap.keyset()])
        {
           if (a.PA_Onboarding__r.Candidate__r.IsActive ==  true)
            CandidateUserid.put(a.Id,a.PA_Onboarding__r.Candidate__c);
            
            if (a.Coach__r.IsActive == true)
               CoachUserid.put(a.Id,a.Coach__c);
            
            if (a.Secondary_Coach__r.IsActive == true)
                SecCoachUserid.put(a.Id, a.Secondary_Coach__c);
        }
        
        for (CTA_Board_Candidate__c b : BoardCandidate)
        {
            System.Debug ('Inside the loop');
            
            if (b.Candidate__c != null && CandidateUserId.containskey(b.Id) == true)
            {
                CTA_Board_Candidate__share newrecord =  new CTA_Board_Candidate__share();
                NewShares.add(newrecord);
                newrecord.ParentId = b.Id;
                newrecord.UserOrGroupId = CandidateUserId.get(b.Id);
                newrecord.AccessLevel = 'read';
                newrecord.RowCause = Schema.CTA_Board_Candidate__share.RowCause.Candidate_Access__c;
            }
            if (b.Coach__c != null && CoachUserid.containskey(b.Id) == true )
            {
                CTA_Board_Candidate__share newrecord =  new CTA_Board_Candidate__share();
                NewShares.add(newrecord);
                newrecord.ParentId = b.Id;
                newrecord.UserOrGroupId =  b.Coach__c;
                newrecord.AccessLevel = 'edit';
                newrecord.RowCause = Schema.CTA_Board_Candidate__share.RowCause.Coach_Access__c;
            }
            if (b.Secondary_Coach__c != null && SecCoachUserid.containsKey(b.Id) == true)
            {
                CTA_Board_Candidate__share newrecord =  new CTA_Board_Candidate__share();
                NewShares.add(newrecord);
                newrecord.ParentId = b.Id;
                newrecord.UserOrGroupId = b.Secondary_Coach__c;
                newrecord.AccessLevel = 'edit';
                newrecord.RowCause = Schema.CTA_Board_Candidate__share.RowCause.Secondary_Coach_Access__c;
            }
        }
        insert NewShares;
    }
}