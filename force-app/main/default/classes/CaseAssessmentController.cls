public without sharing class CaseAssessmentController {
    //TJ public Learning_Domain__c ctaReviewSession {public get; public set;}
    public CTA_Review_Session__c ctaReviewSession {public get; public set;}
    public String assignedJudge {get; set;}  
    public Judge__c judge {get; set;}
    public Case createdCase {get; set;}
    CaseAssessmentRequestUtil caseAssessmentRequestUtil;
    public boolean validctaReviewSession {get;set;}
    public boolean allowOtherRegionJudges {get;set;} { allowOtherRegionJudges = false; }
    public boolean overrideJudge {get; set;} {overrideJudge=false;}
    
    public CaseAssessmentController() {
        this(ApexPages.currentPage().getParameters().get('id'));
    }
    
    public CaseAssessmentController(String ld_id) {
        caseAssessmentRequestUtil = new caseAssessmentRequestUtil();
        /*
        ctaReviewSession = [select Id, Name, skill__c, Quiz_Complete__c, of_Build__c, of_Learn__c, Build_Percent_Complete__c, Learn_Percent_Complete__c, 
                          PA_Onboarding__r.Contact__r.Id, PA_Onboarding__r.region__c, PA_Onboarding__r.Contact__r.Name,
                          PA_Onboarding__r.Candidate__r.TimeZoneSidKey,
                          PA_Onboarding__r.Mentor__r.Id, PA_Onboarding__r.Mentor__r.Name,PA_Onboarding__r.Mentor__r.Email,
                          (Select Id From Badge_Assessment_Request__r where isClosed=false) from Learning_Domain__c 
                          where id = :ld_id];
        */
        system.debug(ld_id);
        ctaReviewSession = [Select Id,Name,Skill__c,PA_Onboarding__r.Contact__r.Id, PA_Onboarding__r.region__c, PA_Onboarding__r.Contact__r.Name,
                          PA_Onboarding__r.Candidate__r.TimeZoneSidKey,
                          PA_Onboarding__r.Mentor__r.Id, PA_Onboarding__r.Mentor__r.Name,PA_Onboarding__r.Mentor__r.Email,Scenario__c  from CTA_Review_Session__c where id = :ld_id ];
        
    }
    
    public PageReference checkPreConditions() {
        validctaReviewSession = true;
          return null;    
        
    }
    
    public boolean getAutoAssignEnabled() {
        PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('Enable Auto Judge Trigger'); 
        String autoJudgeAssignmentEnabled='0';
        if (paTemplate!=null)
            autoJudgeAssignmentEnabled = paTemplate.Value__c;
        return validctaReviewSession && autoJudgeAssignmentEnabled.contains(ctaReviewSession.PA_Onboarding__r.region__c);    
    }
    
    public PageReference feelLucky() {      
        List<judge__c> judgesList = caseAssessmentRequestUtil.getMatchedJudgesList(ctaReviewSession);
        if (!judgesList.isEmpty()) {
            judge = judgesList.get(0);
            createdCase = caseAssessmentRequestUtil.createCase(ctaReviewSession, judge);
        }
        
        else
            createdCase = caseAssessmentRequestUtil.createCase(ctaReviewSession, null);          
        insert createdCase;
        //       PageReference caseViewPage = new ApexPages.StandardController(createdCase).view();         
        //        caseViewPage.setRedirect(true);
        //        return caseViewPage;      
        return Page.caseAssessmentCaseView;
        
    }
    
    public PageReference fineTune() {
        
        List<Judge__c> judgeList = caseAssessmentRequestUtil.getMatchedJudgesList(ctaReviewSession, allowOtherRegionJudges);
        if (judgeList.size() < 1) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to find Judge that satisfies criteria. Please see administrator');
            ApexPages.addMessage(myMsg);
            return null;            
        }
        system.debug(judgeList);
        return Page.caseAssessmentChooseJudge;
    }
    
    public PageReference createCaseWithSelectedJudge() {  
        if (assignedJudge == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select a Judge from the list.');
            ApexPages.addMessage(myMsg);
            return null;            
        }
        judge = caseAssessmentRequestUtil.getJudgeWithId(assignedJudge);
        createdCase = caseAssessmentRequestUtil.createCase(ctaReviewSession, judge);
        if(overrideJudge) createdCase.Manually_Assigned__c = true;
        insert createdCase;
        //           PageReference caseViewPage = new ApexPages.StandardController(createdCase).view();
        //           caseViewPage.setRedirect(true);
        //           return caseViewPage;    
        return Page.caseAssessmentCaseView;
        
    }
    
    public List<SelectOption> getJudgeItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<Judge__c> judgeList = caseAssessmentRequestUtil.getMatchedJudgesList(ctaReviewSession, allowOtherRegionJudges);
        for (Judge__c judge: judgeList) {
            options.add(new SelectOption(judge.Id, judge.Name + getTimeZoneDifferenceAndLanguages(judge)));
            if (!overrideJudge) break;
        }
        return options;
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/'+ctaReviewSession.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void Noop() {}
    
    private string getTimeZoneDifferenceAndLanguages(Judge__c judge)
    {
        System.debug('entering getTimeZoneDifferenceAndLanguages ' + judge);
        string strTimeZone = ' hours';
        string strLanguages = '';
        DateTime dt = DateTime.now();
        TimeZone currentUserTimeZone = TimeZone.getTimeZone('America/Los_Angeles'); //GR
        
        if (ctaReviewSession.PA_Onboarding__r.Candidate__r.TimeZoneSidKey != null) {
            currentUserTimeZone = TimeZone.getTimeZone(ctaReviewSession.PA_Onboarding__r.Candidate__r.TimeZoneSidKey);
        }
        System.debug('judge ' + judge);
        System.debug('judge user ' + judge.User__c);
        System.debug('judge user ' + judge.User__r.TimeZoneSidKey);
        TimeZone judgeTimeZone = TimeZone.getTimeZone(judge.User__r.TimeZoneSidKey);
        System.debug('judgeTimeZone ' + judgeTimeZone);
        decimal timeDifference = ((judgeTimeZone.getOffset(dt) - currentUserTimeZone.getOffset(dt)) / 3600000.0);
        System.debug('timeDifference ' + timeDifference);
        if(timeDifference != 0)
        {
            strTimeZone = (timeDifference > 0 ? '+' : '') + timeDifference + strTimeZone;
        }
        else
        {
            strTimeZone = '0' + strTimeZone;
        }
        
        if(judge.Additional_Languages__c != null)
        {
            strLanguages = ', ' + judge.Additional_Languages__c;
        }
        return ' (' + strTimeZone + strLanguages + ')';
    }
}