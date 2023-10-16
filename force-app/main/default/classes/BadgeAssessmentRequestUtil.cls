public without sharing class BadgeAssessmentRequestUtil {
    
    RecordType caseRecordType = [select id from RecordType where SobjectType = 'Case' and Name='Badge Assessment Request']; 
    Map<Id, Judge__c> judges = new Map<Id, Judge__c>([select Id,Judge__c.Name, Judge__c.User__c, Judge__c.User__r.Email, Judge__c.User__r.TimeZoneSidKey, Judge__c.Judging_Skills__c,Judge__c.Supported_Regions__c, Judge__c.Last_Request_Assigned_Date__c, Judge__c.Additional_Languages__c 
                                                      from Judge__c
                                                      where is_active__c = true and Judge__c.User__r.isActive = true]); 
    Map<String, Learning_Domain_Skill__c> skillsMap = new Map<String, Learning_Domain_Skill__c>();
    String incompleteBuildEmailTemplate;
    String manualBadgeAssessmentTemplate;
    String unassignedQueue;
    // Sortable Judge class for round-robin
    class SortableJudge implements Comparable {
        Judge__c judge;
        
        SortableJudge(Judge__c judge){
            this.judge = judge;
        }
        
        public Judge__c getJudge() {
            return judge;
        }
        
        public Integer compareTo(Object otherObject) {
            SortableJudge otherJudge = (SortableJudge)otherObject;
            
            if (judge.Last_Request_Assigned_Date__c != null && otherJudge.getJudge().Last_Request_Assigned_Date__c !=null &&
                    judge.Last_Request_Assigned_Date__c.getTime() - otherJudge.getJudge().Last_Request_Assigned_Date__c.getTime() > 0)
                return 1;
            else
                return -1;
        }
    }       
    
    public void closeAssociatedCases(List<Id> learningDomainIds) {
        List<Case> cases = [select id from Case where learning_Domain__c in :learningDomainIds];
        for (Case caseToBeClosed: cases) 
            caseToBeClosed.Status='Completed';
        update cases;
    } 
    
    public BadgeAssessmentRequestUtil() {
        for (Learning_Domain_Skill__c obj: [Select l.Skill__c, l.Name, l.Id, l.Category__c, l.Region__c, l.primary_judge__c, l.primary_judge__r.User__r.Email, l.Candidate_E_Mail_Template__c From Learning_Domain_Skill__c l]) 
            skillsMap.put(obj.Skill__c+obj.Region__c, obj); //GR may 2nd
        PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('Unassigned Queue');
        if (paTemplate!=null)
            unassignedQueue = paTemplate.value__c;
    }
    
    
    public void notifyUser(List<Learning_Domain__c> manualLearningDomains, String templateId) {
        List<Messaging.SingleEMailMessage> messageList = new List<Messaging.SingleEmailMessage>{};
            
            for (Learning_Domain__c learningDomain: manualLearningDomains) {
                Messaging.SingleEmailmessage candidateMail = new Messaging.SingleEmailMessage();
                candidateMail.setTargetObjectId(learningDomain.PA_Onboarding__r.Contact__c);
                candidateMail.setTemplateId(templateId);
                candidateMail.setWhatId(learningDomain.id);     
                messageList.add(candidateMail);
            }
        Messaging.sendEmail(messageList);   
    }
    
    @future
    public static void notifyByEMail(List<Id> badgeAssessmentRequests) {
        BadgeAssessmentRequestUtil thisUtil = new BadgeAssessmentRequestUtil();
        List<Case> retrievedCases = [Select id, judge_Assigned__r.User__r.Email, Learning_Domain__r.PA_Onboarding__r.Region__c, Learning_Domain__r.PA_Onboarding__r.Mentor__r.Email, Learning_Domain__r.Skill__c, Judge_Assigned__c, ContactId from Case where Id in :badgeAssessmentRequests];
        for (case retrievedCase: retrievedCases)
            thisUtil.notifyByEMail(retrievedCase);
    }
    
    public void notifyByEMail(Case badgeAssessmentRequest) {  
        System.debug('notify case '+badgeAssessmentRequest.id+': skill '+badgeAssessmentRequest.Learning_Domain__r.Skill__c);
        String skill = badgeAssessmentRequest.Learning_Domain__r.Skill__c;
        //GR-May 2nd
        String region = badgeAssessmentRequest.Learning_Domain__r.PA_Onboarding__r.Region__c;
        Learning_Domain_Skill__c skillTemplates = null;
        if (region == 'Japan') {
            skillTemplates = skillsMap.get(skill+region);
        } 
        
        if (skillTemplates == null) {
            skillTemplates = skillsMap.get(skill+null); 
        }//GR
        String candidateEmailTemplate;
        if (skillTemplates != null) 
            candidateEmailTemplate = skillTemplates.Candidate_E_Mail_Template__c;
        else
            candidateEmailTemplate = incompleteBuildEmailTemplate;
        System.debug('found templates for skill' + skill + ' candidate ' + candidateEmailTemplate);
        List<Messaging.SingleEMailMessage> messageList = new List<Messaging.SingleEmailMessage>{};
            Messaging.SingleEmailmessage candidateMail = new Messaging.SingleEmailMessage();
        candidateMail.setTargetObjectId(badgeAssessmentRequest.ContactId);
        candidateMail.setTemplateId(candidateEmailTemplate);
        candidateMail.setWhatId( badgeAssessmentRequest.Id);    
        List<String> ccEmailList = new List<String>();
        if (badgeAssessmentRequest.Learning_Domain__r.PA_Onboarding__r.Mentor__r.Email!=null)
            ccEmailList.add(badgeAssessmentRequest.Learning_Domain__r.PA_Onboarding__r.Mentor__r.Email);
        if (badgeAssessmentRequest.Judge_Assigned__r.User__r.Email!=null) 
            ccEmaillist.add(badgeAssessmentRequest.Judge_Assigned__r.User__r.Email); 
        
        
        if (skillTemplates.primary_judge__c!=null && skillTemplates.primary_judge__r.User__r.Email!=null)
            ccEmaillist.add(skillTemplates.primary_judge__r.User__r.Email);
        
        //ccEmaillist.add('dthong@salesforce.com');
        
        if (ccEmaillist.size() > 0) 
            candidateMail.setCcAddresses(ccEmaillist);                  
        messageList.add(candidateMail);
        System.debug('sending email to '+badgeAssessmentRequest.ContactId+' cc includes');
        Messaging.sendEmail(messageList);   
    }
    
    
    public Case createCase(Learning_Domain__c learningDomain, Judge__c assignedJudge) {
        Case newCase = new Case(RecordTypeId = caseRecordType.Id);
        newCase.Learning_Domain__c = learningDomain.id;
        newCase.PA_Onboarding__c = learningDomain.PA_Onboarding__c;
        if (assignedJudge!=null) {
            Judge__c judge = judges.get(assignedJudge.id);
            newCase.Judge_Assigned__c = judge.id;
            // update the time so next record will not re-use the same judge
            assignedJudge.Last_Request_Assigned_Date__c = DateTime.Now();    
            newCase.OwnerId = judge.User__c;   
            System.debug('Owner assigned is '+judge.User__c); 
        }
        else {
            newCase.status='Unassigned';
            newCase.OwnerId = unassignedQueue;          
        }
        newCase.ContactId = learningDomain.PA_Onboarding__r.Contact__r.Id;
        newCase.Subject = 'Badge Assessment Request for '+learningDomain.Skill__c + ' ' + 
            learningDomain.PA_Onboarding__r.Contact__r.Name;
        newCase.Description = 'Learning Domain ' + learningDomain.Name + ': Skill ' + learningDomain.Skill__c;
        return newCase;
    }
    
    public List<Judge__c> getMatchedJudgesList(Learning_Domain__c learningDomain) {
        return getMatchedJudgesList( learningDomain, false);
    }
    
    public List<Judge__c> getMatchedJudgesList(Learning_Domain__c learningDomain, boolean allowOtherRegionJudges) {
        String skill = learningDomain.Skill__c;
        String region = learningDomain.PA_Onboarding__r.region__c;  
        System.debug('Looking for Judge with skill '+skill+ ' and in region '+region);
        Integer counter = 0;
        Boolean found = false;
        List<Judge__c> matchedList = new List<Judge__c>{};
            List<SortableJudge> sortableList = new List<SortableJudge>{};
                System.debug('judges list ' + judges.values());
                for(Judge__c judge: judges.values())
                if ((skill == null || (judge.Judging_Skills__c!=null && judge.Judging_Skills__c.contains(skill))) &&
                    (region == null || allowOtherRegionJudges || (judge.Supported_Regions__c!=null && judge.Supported_Regions__c.contains(region))))
                sortableList.add(new SortableJudge(judge));      
        sortableList.sort(); // Sorting here to make sure round-robin is done during bulk trigger operations  
        for (SortableJudge sortableJudge:sortableList) {
            matchedList.add(sortableJudge.getJudge());
        }           
        return matchedList;
    }
    
    public List<Case> createBadgeAssessmentRequests(List<Learning_Domain__c> learningDomains) {
        List<Case> casesToBeCreated = new List<Case>();
        List<Judge__c> judgesToBeUpdated = new List<Judge__c>();
        
        for(Learning_Domain__c learningDomain: learningDomains){
            List<Judge__c> matchedJudges = getMatchedJudgesList(learningDomain);
            if (matchedJudges.size() > 0) {
                Judge__c assignedJudge = matchedJudges.get(0);
                casesToBeCreated.add(createCase(learningDomain, assignedJudge));
            }       
            else {
                System.debug('Unable to find match between judges and skill/region');
                casesToBeCreated.add(createCase(learningDomain, null));                         
            }
        } //for
        return casesToBeCreated;
    } 
    
    public Judge__c getJudgeWithId(String judgeId) {
        return judges.get(judgeId);
    }
    
}