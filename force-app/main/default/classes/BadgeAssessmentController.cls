public without sharing class BadgeAssessmentController {
    public Learning_Domain__c learningDomain {public get; public set;}
    public String assignedJudge {get; set;}
    public Judge__c judge {get; set;}
    public Case createdCase {get; set;}
    BadgeAssessmentRequestUtil badgeAssessmentRequestUtil;
    public boolean validLearningDomain {get;set;}
    public boolean allowOtherRegionJudges {get;set;} { allowOtherRegionJudges = false; }
    public boolean overrideJudge {get; set;} {overrideJudge=false;}

    public BadgeAssessmentController() {
        this(ApexPages.currentPage().getParameters().get('id'));
    }

    public BadgeAssessmentController(String ld_id) {
        badgeAssessmentRequestUtil = new BadgeAssessmentRequestUtil();
        learningDomain = [select Id, Name, skill__c, Eligible_For_Badge_Assessment__c, Quiz_Complete__c, of_Build__c, 
                                  of_Learn__c, Build_Percent_Complete__c, Learn_Percent_Complete__c,
                                  PA_Onboarding__r.Contact__r.Id, PA_Onboarding__r.region__c, PA_Onboarding__r.Geo__c, 
                                  PA_Onboarding__r.Contact__r.Name,
                                  PA_Onboarding__r.Candidate__r.TimeZoneSidKey,
                                  PA_Onboarding__r.Mentor__r.Id, PA_Onboarding__r.Mentor__r.Name,PA_Onboarding__r.Mentor__r.Email,
                                  (Select Id From Badge_Assessment_Request__r where isClosed=false),
                                  (Select Id From Rubrics__r) 
                          from Learning_Domain__c
                          where id = :ld_id];

    }

    public PageReference checkPreConditions() {
        validLearningDomain = true;
        // Quiz integration issues, instead of checking for pass, remind candidates to make sure they have passed the quiz
        //  ApexPages.Message quizMsg = new ApexPages.Message(ApexPages.Severity.Warning,'Make sure the candidate has passed the quiz in 62org. You can continue with the request but the badge cannot be lit until the quiz is passed in 62org.');
        //  ApexPages.addMessage(quizMsg);

        // Sriram Venkatraman: 1/23/2020 If no rubric exists then no need to schedule a badge assessment
        if (learningDomain.Rubrics__r == null || learningDomain.Rubrics__r.size() <= 0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'This Domain doesn\'t require any badge assessment.');
            ApexPages.addMessage(myMsg);
            validLearningDomain = false;
            
            return null;
        }

        //Sriram Venkatraman 4/27/2019        if (!learningDomain.Quiz_Complete__c) {
        if (!learningDomain.Eligible_For_Badge_Assessment__c) {
        // Sriram Venkatraman 6/19/2018 - Re-instating the blocker if Quiz is not complete.
        //    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'The Candidate has not completed Quiz yet. If the candidate has completed the quiz recently, you can continue with the request but the badge cannot be lit until the quiz is passed in 62org.');
        //Sriram Venkatraman 4/27/2019            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'The Candidate has not completed Quiz yet. Please complete the quiz before submitting a Badge Assessment Request. If you have completed the quiz please give it a day for the nightly batch process to catchup. You will get a chatter notification.');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'The Candidate has not completed relevant Salesforce Designer Certificaiton yet. Please complete it before submitting a Badge Assessment Request. If you completed the Designer Cert recently, please wait for 48 hours before submitting the request.');
            ApexPages.addMessage(myMsg);
            validLearningDomain = false;
        } else if (learningDomain.Badge_Assessment_Request__r!=null && learningDomain.Badge_Assessment_Request__r.size() > 0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Badge Assessment Request has already been created.');
            ApexPages.addMessage(myMsg);
            validLearningDomain = false;

        } 
        /* Not relevant any more
        else if ((learningDomain.of_build__c > 0 && learningDomain.Build_Percent_Complete__c != 100) ||
                   (learningDomain.of_learn__c > 0 && learningDomain.Learn_Percent_Complete__c !=100)) {
                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'The Learn and Build exercises have not been completed. We STRONGLY recommend that you review these before you request a badging session.');
                       ApexPages.addMessage(myMsg);
                       validLearningDomain=true;
                   }*/ 
        return null;

    }

    public boolean getAutoAssignEnabled() {
        PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('Enable Auto Judge Trigger');
        String autoJudgeAssignmentEnabled='0';
        if (paTemplate!=null)
            autoJudgeAssignmentEnabled = paTemplate.Value__c;

        // Newly introduced field replacing region__c. Geo__c is a formula field derived directly from User record.
        if (learningDomain.PA_Onboarding__r.Geo__c != null && learningDomain.PA_Onboarding__r.Geo__c != '')
            return validLearningDomain && autoJudgeAssignmentEnabled.contains(learningDomain.PA_Onboarding__r.Geo__c);

        return validLearningDomain && autoJudgeAssignmentEnabled.contains(learningDomain.PA_Onboarding__r.region__c);
    }

    public PageReference feelLucky() {
        List<judge__c> judgesList = badgeAssessmentRequestUtil.getMatchedJudgesList(learningDomain);
        if (!judgesList.isEmpty()) {
            judge = judgesList.get(0);
            createdCase = badgeAssessmentRequestUtil.createCase(learningDomain, judge);
        }

        else
            createdCase = badgeAssessmentRequestUtil.createCase(learningDomain, null);
        insert createdCase;
        //       PageReference caseViewPage = new ApexPages.StandardController(createdCase).view();
        //        caseViewPage.setRedirect(true);
        //        return caseViewPage;
        return Page.BadgeAssessmentCaseView;

    }

    public PageReference fineTune() {

        List<Judge__c> judgeList = badgeAssessmentRequestUtil.getMatchedJudgesList(learningDomain, allowOtherRegionJudges);
        if (judgeList.size() < 1) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to find Judge that satisfies criteria. Please see administrator');
            ApexPages.addMessage(myMsg);
            return null;
        }

        return Page.BadgeAssessmentChooseJudge;
    }

    public PageReference createCaseWithSelectedJudge() {
        if (assignedJudge == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select a Judge from the list.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        judge = badgeAssessmentRequestUtil.getJudgeWithId(assignedJudge);
        createdCase = badgeAssessmentRequestUtil.createCase(learningDomain, judge);
        if(overrideJudge) createdCase.Manually_Assigned__c = true;
        insert createdCase;
        //           PageReference caseViewPage = new ApexPages.StandardController(createdCase).view();
        //           caseViewPage.setRedirect(true);
        //           return caseViewPage;
        return Page.BadgeAssessmentCaseView;

    }

    public List<SelectOption> getJudgeItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<Judge__c> judgeList = badgeAssessmentRequestUtil.getMatchedJudgesList(learningDomain, allowOtherRegionJudges);
        String j;
        for (Judge__c judge: judgeList) {
	        // Allow judges from other TimeZones
            if (allowOtherRegionJudges) {
			j = getTimeZoneDifferenceAndLanguages(judge, false);
            }
            else {
                j = getTimeZoneDifferenceAndLanguages(judge, true);
            }
            if (j != null) {
              System.Debug('Judge Id: ' + judge.Id + '; Name: ' + judge.Name);
              options.add(new SelectOption(judge.Id, judge.Name + j));
              if (!overrideJudge) break;
            }
        }

        if (options.size() <= 0) {
          for (Judge__c judge: judgeList) {
              j = getTimeZoneDifferenceAndLanguages(judge, false);
              if (j != null) {
                System.Debug('Judge Id: ' + judge.Id + '; Name: ' + judge.Name);
                options.add(new SelectOption(judge.Id, judge.Name + j));
                if (!overrideJudge) break;
              }
          }
        }
        return options;
    }

    public PageReference cancel() {
        PageReference pageRef = new PageReference('/'+learningDomain.id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void Noop() {}

    private string getTimeZoneDifferenceAndLanguages(Judge__c judge, Boolean restrictByTZ)
    {
        System.Debug('Getting Time Zone Diff for Judge: ' + judge.Name);

        string strTimeZone = ' hours';
        string strLanguages = '';
        DateTime dt = DateTime.now();
        TimeZone currentUserTimeZone = TimeZone.getTimeZone('America/Los_Angeles'); //GR

        if (learningDomain.PA_Onboarding__r.Candidate__r.TimeZoneSidKey != null) {
            currentUserTimeZone = TimeZone.getTimeZone(learningDomain.PA_Onboarding__r.Candidate__r.TimeZoneSidKey);
        }

        TimeZone judgeTimeZone = TimeZone.getTimeZone(judge.User__r.TimeZoneSidKey);
        decimal timeDifference = ((judgeTimeZone.getOffset(dt) - currentUserTimeZone.getOffset(dt)) / 3600000.0);
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

        //Sriram Venkatraman restrict + or - 4 hours.  There is no proper Region on User or Onboarding record that can restrict Judges by Region. Timezone is the best option available to us for now
        if ((math.abs(timeDifference) <= 4 && restrictByTZ == true) || restrictByTZ == false) {
          return ' (' + strTimeZone + strLanguages + ')';
        }
        else {
          return null;
        }
    }
}