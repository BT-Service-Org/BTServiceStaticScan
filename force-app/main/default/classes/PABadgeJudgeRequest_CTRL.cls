/**
 * @author Jonathan Cohen - Salesforce.com
 * @date   September 2016
 * @group  Services Org
 * @Ticket W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service
 *
 * @description Controller for the "PABadgeJudgeRequest" VF Page.
 *      The controller will manage the judge request process and verify that the user requesting to be a 9 domain badge has
 *      a PA_Onbording related and that there is no request pending approval.
 *          - If there is no PA_Onboarding related -> the page will display an error message.
 *          - If there is a request pending approval -> the page will display an error message.
 *          - Otherwise the page will allow the user to choose and fill the following information:
 *              -   The domains in which he wants to be a judge.
 *              -   The region supported.
 *              -   The additional languages supported.
 *
 *      Once submitted by the user, the following validation will be applied:
 *          - The user must own every domain badge he is requesting to be a judge for.
 *          - The domain badges tenure recommended > 1 year byt not blocking.
 *              - If the validation is correct, the Judge_Sign_Up_Request__c will be inserted/updated with the selected elements.
 *                  - A success message will be displayed.
 *                  - The judge record will be submitted for approval.
 *              - Otherwise an error message will be displayed.
 *
 *          - If the user requesting to be a judge is a CTA -> there is no need to verify domain propriety neither tenure and the judge record will be submitted for approval.
 *
 *      Upon approval, the Judge record will be activated and the requesting user will receive the "PA - mentor & badge approver" permission set.
 */
public without sharing class PABadgeJudgeRequest_CTRL
{
    /**
     * Private Final Class Members
     */
    private final Integer DOMAIN_BADGED             = 1;
    private final String PENDING_APPROVAL_STATUS    = 'Pending';
    private final String APPROVAL_PROCESS_NAME      = 'Judge_Sign_Up_Request_Approval_Process';

    /**
     * Private Class Members
     */
    @TestVisible private List<Learning_Domain__c>   learningDomainsRelatedToPa_List;
    @TestVisible private Id                         redirecBackButtontId;
    private Map<String, Learning_Domain__c>         learningDomainBySkill_Map;
    private String                                  judgePreviousSkills;  
    private String                                  domainsRequiredAndNotOwned;

    /**
     * Public Class Members
     */
    public PA_Onboarding__c                         paRelatedToRequest      {get; private set;}
    public Boolean                                  noErrorOnPageLoad       {get; private set;}
    public Boolean                                  showSubmitRequestButton {get; private set;}
    public Judge__c                                 newJudgeRequest         {get; set;}
    
    public PABadgeJudgeRequest_CTRL(ApexPages.StandardController stdController)
    {
        try{
            Id judgeId          = stdController.getId();
            Id paOnboardingId   = ApexPages.currentPage().getParameters().get('paoid');
            
            if(judgeId != Null){
                this.redirecBackButtontId = judgeId;
                init(judgeId, true);
            }
            else if(paOnboardingId != Null){
                this.redirecBackButtontId = paOnboardingId;
                init(ApexPages.currentPage().getParameters().get('paoid'), false);
            }
            else{
                init(Userinfo.getUserId(), false);
            }
        }
        catch(Exception ex){
            this.noErrorOnPageLoad = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.lbl_JudgeSignUpProcessError));
        } 
    }
    
    /**
     *  @name        - init()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - The method init the required processes.
     */
    private void init(Id paOnboardinOrJudgeId, Boolean judgeSource)
    {
        if(judgeSource){
            this.newJudgeRequest                        = retreiveJudgeRelatedToRequest(paOnboardinOrJudgeId);
            this.paRelatedToRequest                     = retreiveRelatedPaOnboardingRecord(this.newJudgeRequest.User__c);
        }
        else{
            this.paRelatedToRequest                     = retreiveRelatedPaOnboardingRecord(paOnboardinOrJudgeId);
            this.newJudgeRequest                        = retreiveJudgeRelatedToRequest(this.paRelatedToRequest.Candidate__c);
        }
        this.learningDomainsRelatedToPa_List            = retreiveRelatedLearningDomains();
        this.newJudgeRequest.Nine_Domain_Badges__c      = this.newJudgeRequest.Judging_Skills__c;
        this.judgePreviousSkills                        = this.newJudgeRequest.Nine_Domain_Badges__c;
        buildLearningDomainByDomainSkillNameMap();
        this.noErrorOnPageLoad                          = true;
        this.showSubmitRequestButton                    = true;
        
        if(isRecordLockPendingApprovalProcess()){
            this.noErrorOnPageLoad = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.lbl_JudgePendingApproval));
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.lbl_JudgeRequestSubmissionExplanation));
        }        
    }

    /**
     *  @name        - submitJudgeRequest()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - The method will launch the request validation process calling the "validateJudgeRequest" method as explained below:
     *                  - The user must own every domain badge he is requesting to be a judge for.
     *                      - If true, the judge record will be inserted/updated with the selected elements.
     *                          - A success message will be displayed.
     *                      - Otherwise an error message will be displayed.
     *
     *                  - If the user requesting to be a judge is a CTA -> there is no need to verify domain propriety neither tenure.
     *                      - A success message will be displayed.
     */
    public PageReference submitJudgeRequest()
    {
        try{
            if(verifyThatNoApprovedDomainsWereRemoved(this.newJudgeRequest.Nine_Domain_Badges__c, this.judgePreviousSkills)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.lbl_DomainRemoval));
            }
            else{
                if(validateJudgeRequest()){
                    upsert this.newJudgeRequest;
                    this.showSubmitRequestButton = false;
                    
                    if(! this.newJudgeRequest.Is_Active__c || this.newJudgeRequest.Nine_Domain_Badges__c != this.judgePreviousSkills || this.newJudgeRequest.Judging_Skills__c != this.judgePreviousSkills){
                        sumbitJudgeRequestForApproval();
                    }
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.lbl_RequestSubmittedForApproval));
                    return redirectBackToPaOnboardingPage();
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.lbl_BadgeOwnershipAndTenureRequirement + this.domainsRequiredAndNotOwned));
                }
            }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.lbl_JudgeSubmissionErrorOccurred));
        }
        return Null;
    }

    /**
     *  @name        - verifyThatNoApprovedDomainsWereRemoved()
     *  @param       - newNineDomainsValues: New domains wanted.
     *  @param       - previousSkillsValues: Previous Domains already approved.
     *  @return      - Boolean.
     *  @description - The method verify that no previously approved domains were removed from the list.
     */
    private Boolean verifyThatNoApprovedDomainsWereRemoved(String newNineDomainsValues, String previousSkillsValues)
    {
        Boolean approvedDomainsRemoved = false;

        if(previousSkillsValues != Null){
            List<String> previousSkillsValues_List = new List<String>();
            previousSkillsValues_List.addAll(previousSkillsValues.split(';'));
            Set<String> previousSkillsValues_Set = new Set<String>(previousSkillsValues_List);

            List<String> newNineDomainsValues_List = new List<String>();
            newNineDomainsValues_List.addAll(newNineDomainsValues.split(';'));
            Set<String> newNineDomainsValues_Set = new Set<String>(newNineDomainsValues_List);

            approvedDomainsRemoved = !newNineDomainsValues_Set.Containsall(previousSkillsValues_Set);
        }
        return approvedDomainsRemoved;
    }

    /**
     *  @name        - redirectBackToPaOnboardingPage()
     *  @param       - N.A.
     *  @return      - PageReference.
     *  @description - The method redirect to the PA_Onboarding, the Judge record or the judge basic page according to the source destination.
     */
    public PageReference redirectBackToPaOnboardingPage()
    {
        if(this.redirecBackButtontId != Null){
            return new PageReference('/' + this.redirecBackButtontId);
        }
        else{
            return new PageReference('/' + Judge__c.sObjectType.getDescribe().getKeyPrefix());
        }
    }

    /**
     *  @name        - sumbitJudgeRequestForApproval()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - The method will submit the judge created/updated for approval through the "Judge_Sign_Up_Request_Approval_Process" Approval Process.
     */
    private void sumbitJudgeRequestForApproval()
    {
        Approval.ProcessSubmitRequest judgeSignUpRequestApprovalProcess = new Approval.ProcessSubmitRequest();
        judgeSignUpRequestApprovalProcess.setObjectId(this.newJudgeRequest.Id);
        judgeSignUpRequestApprovalProcess.setSubmitterId(UserInfo.getUserId()); 
        judgeSignUpRequestApprovalProcess.setProcessDefinitionNameOrId(this.APPROVAL_PROCESS_NAME);
        Approval.ProcessResult result = Approval.process(judgeSignUpRequestApprovalProcess);
    }

    /**
     *  @name        - retreiveRelatedPaOnboardingRecord()
     *  @param       - Id paOnboardingId.
     *  @return      - PA_Onboarding__c: The PA_onboarding record related to the requesting user.
     *  @description - The method will retreive the PA_Onboarding__c record related to the requesting user. Previous where condition:Candidate__c = :userId
     */
    private PA_Onboarding__c retreiveRelatedPaOnboardingRecord(Id paOnboardingOrUserId)
    {
        List<PA_Onboarding__c> paOnboardingRelatedToUser_List = [SELECT Id,
                                                                        Name,
                                                                        Candidate__c,
                                                                        Candidate__r.Email,
                                                                        Candidate__r.Name,
                                                                        Has_CTA__c,
                                                                        Mentor__c
                                                                FROM PA_Onboarding__c
                                                                WHERE Id = :paOnboardingOrUserId OR Candidate__c = :paOnboardingOrUserId
                                                                LIMIT 1];
        if(paOnboardingRelatedToUser_List.Size() > 0){
            return paOnboardingRelatedToUser_List[0];
        }
        return Null;
    }

    /**
     * The method will retreive the Learning_Domain__c records related to his PA_Onboarding__c.
     */
     /**
     *  @name        - retreiveRelatedLearningDomains()
     *  @param       - N.A.
     *  @return      - List<Learning_Domain__c>: List of Learning_Domain__c records related to the PA_Onboarding__c related to the requesting user.
     *  @description - The method will retreive the list of Learning_Domain__c records related to the PA_Onboarding__c related to the requesting user.
     */
    private List<Learning_Domain__c> retreiveRelatedLearningDomains()
    {
        List<Learning_Domain__c> relatedLearningDomains_List = [SELECT Id,
                                                                        Skill__c,
                                                                        Badged__c,
                                                                        End_Date__c
                                                                FROM Learning_Domain__c
                                                                WHERE PA_Onboarding__c = :this.paRelatedToRequest.Id];
        return relatedLearningDomains_List;
    }

    /**
     * The method will retreive the Judge__c record related.
     */
     /**
     *  @name        - retreiveJudgeRelatedToRequest()
     *  @param       - N.A.
     *  @return      - Judge__c: Juge record related to the PA_Onboarding__c or the user.
     *  @description - The method will retreive the judge related to the PA_Onboarding__c or the user.
     */
    private Judge__c retreiveJudgeRelatedToRequest(Id judgeOrUserId)
    {
        List<Judge__c> relatedJudge_List = [SELECT Id, 
                                                    Name,
                                                    Additional_Languages__c,
                                                    Judging_Skills__c,
                                                    Nine_Domain_Badges__c,
                                                    Supported_Regions__c,
                                                    Is_Active__c,
                                                    Is_CTA__c,
                                                    User__c
                                                FROM Judge__c
                                                WHERE User__c = :judgeOrUserId OR Id =: judgeOrUserId LIMIT 1];
        if(relatedJudge_List.Size() > 0){
            return relatedJudge_List[0];
        }
        else{
            Judge__c newJudge = new Judge__c(Name = this.paRelatedToRequest.Candidate__r.Name, User__c = this.paRelatedToRequest.Candidate__c, Is_CTA__c = this.paRelatedToRequest.Has_CTA__c, Is_Active__c = false);
            return newJudge;
        }
    }
    
    /**
     *  @name        - buildLearningDomainByDomainSkillNameMap()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - The method will build a map "Map<String, Learning_Domain__c>"
     *                 The map will contain the PA_Onboarding__c's related list of Learning_Domain__c records by their Skill__c.
     *                 The Skill__c field is used to map between learning domains from the "Judge_Sign_Up_Request__c" and "Learning_Domain__c" objects.
     */
    private void buildLearningDomainByDomainSkillNameMap()
    {
        this.learningDomainBySkill_Map = new Map<String, Learning_Domain__c>();
        for(Learning_Domain__c domain : learningDomainsRelatedToPa_List){
            this.learningDomainBySkill_Map.put(domain.Skill__c, domain);
        }
    }

    /**
     *  @name        - validateJudgeRequest()
     *  @param       - N.A.
     *  @return      - Boolean: True if the validation pass, false otherwise.
     *  @description - The method will apply the following validation:
     *                  - The user must own every domain badge he is requesting to be a judge for and badges tenure must be > 1 year.
     *                      - If true, the Judge_Sign_Up_Request__c will be inserted with the selected elements.
     *                          - A success message will be displayed.
     *                      - Otherwise an error message will be displayed.
     *
     *                  - If the user requesting to be a judge is a CTA -> there is no need to verify domain propriety neither tenure.
     *                      - A success message will be displayed.
     */
    @Testvisible private Boolean validateJudgeRequest()
    {
        Boolean validationResult        = true;
        this.domainsRequiredAndNotOwned = '';

        List<String> selectedSkills_List = new List<String>();
        selectedSkills_List.addAll(this.newJudgeRequest.Nine_Domain_Badges__c.split(';'));

        if(! this.paRelatedToRequest.Has_CTA__c){
            for(String selectedSkill : selectedSkills_List){
                if(this.learningDomainBySkill_Map.ContainsKey(selectedSkill)){
                    if(! (this.learningDomainBySkill_Map.get(selectedSkill).Badged__c == DOMAIN_BADGED)){
                        validationResult = false;
                        this.domainsRequiredAndNotOwned += (' ' + selectedSkill + ',');
                    }
                }
                else{
                    validationResult = false;
                    this.domainsRequiredAndNotOwned += (' ' + selectedSkill + ',');
                }
            }
        }
        if(this.domainsRequiredAndNotOwned != ''){
            this.domainsRequiredAndNotOwned = this.domainsRequiredAndNotOwned.removeEnd(',');
        }
        return validationResult;
    }
    
    /**
     *  @name        - isRecordLockPendingApprovalProcess()
     *  @param       - N.A.
     *  @return      - Boolean.
     *  @description - The method verified if the judge record related to the requesting user is pending approval.
     */
    private Boolean isRecordLockPendingApprovalProcess()
    {
        Boolean recordPendingApproval = false;
        list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId, Status 
                                                    FROM ProcessInstance 
                                                    WHERE TargetObjectId = :this.newJudgeRequest.Id];
        
        for(ProcessInstance approvalProcessInstance : existingApprovals){
            if(approvalProcessInstance.Status == PENDING_APPROVAL_STATUS){
                recordPendingApproval = true;
            }
        }
        return recordPendingApproval;
    }
}