public class RubricExtensionController
{
    public class RubricAssessment
    {
        public string scoreString
        {
            get
            {
                if(objective.Score__c != null)
                {
                    return (objective.Score__c == 4 ? 3 : objective.Score__c).format();
                }
                else
                {
                    return '';
                }
            }
            set
            {
                if(value != '')
                {
                    objective.Score__c = integer.valueOf(value);
                }
            }
        }

        public Rubric_Objective__c objective { get; set; }

        public RubricAssessment(Rubric_Objective__c ro)
        {
            objective = ro;
        }
    }

    public Rubric__c rubric { get; set; }
    public List<Rubric_Objective__c> objectives { get; set; }
    public List<RubricAssessment> assessments { get; set; }
    private boolean isGradeMode = false;
    private boolean specialPage = false;
   
    private ApexPages.StandardController stdCtrl;
    
    public boolean getIsGradeMode() {
        return isGradeMode;
    }

    public Domain_Rubric_Scoring__c rubricScores { get; private set; }
    public List<SelectOption> ratings
    {
        get
        {
            if(ratings == null)
            {
                ratings = new List<SelectOption>();
                // Change to static 0 - 3 - 5 for Bedrock. rubricScores has configured values of 1 - 2 - 3
                // Bedrock only has 3 ratings (CQ)
                if (rubric.BedRock__c) {
                        ratings.add(new SelectOption('0', rubricScores.Rating1_Score_Label__c));
                        ratings.add(new SelectOption('3', rubricScores.Rating2_Score_Label__c));
                        ratings.add(new SelectOption('5', rubricScores.Rating3_Score_Label__c));
                } else {
                        // Legacy rating has 4 values
                        ratings.add(new SelectOption(rubricScores.Rating1_Score_Value__c.format(), rubricScores.Rating1_Score_Label__c));
                        ratings.add(new SelectOption(rubricScores.Rating2_Score_Value__c.format(), rubricScores.Rating2_Score_Label__c));
                        ratings.add(new SelectOption(rubricScores.Rating3_Score_Value__c.format(), rubricScores.Rating3_Score_Label__c));
                        ratings.add(new SelectOption(rubricScores.Rating4_Score_Value__c.format(), rubricScores.Rating4_Score_Label__c));
                }
            }
            return ratings;
        }
        set;
    }

    private Rubric_Passing_Score__c passingScoreSetting
    {
        get
        {
            if (rubric != null && passingScoreSetting == null)
            {
                passingScoreSetting = Rubric_Passing_Score__c.getInstance(rubric.Learning_Domain__r.Skill__c.left(35));
            }
            return passingScoreSetting;
        }
        private set;
    }

    private Map<Decimal, Decimal> objectiveMinScores
    { //map of objectives to minimum scores
        get
        {
            // build array of minimum scores
            if (objectives != null && passingScoreSetting != null && objectiveMinScores == null)
            {
                objectiveMinScores = new Map<Decimal, Decimal>();
                String[] defaultMinScores = passingScoreSetting.Objective_Passing_Scores__c.split(',');
                for (Rubric_Objective__c ro : objectives)
                {
                    if (defaultMinScores.size() >= ro.Objective__c)
                    {
                        objectiveMinScores.put(ro.Objective__c, Decimal.valueOf(defaultMinScores[ro.Objective__c.intValue()-1]));
                    }
                    else
                    {
                        objectiveMinScores.put(ro.Objective__c, 3);
                    }
                }
            }
            return objectiveMinScores;
        }
        private set;
    }

    public Decimal averageScore
    {
        get
        {
            if (rubric != null && rubric.id != null)
            {
                averageScore = [select Average_Score__c from Rubric__c where id = :rubric.id limit 1].Average_Score__c;
            }
            return averageScore;
        }
        private set;
    }

    public RubricExtensionController(ApexPages.StandardController stdCtrl)
    {
        //System.debug('pageurl '+ApexPages.currentPage().getUrl() );
        //System.debug(':--RubricEdit--:'+Page.RubricEdit.getUrl());
        specialPage = ApexPages.currentPage().getUrl().ContainsIgnoreCase(Page.RubricEdit.getUrl());
        // grant special page also to RubricBedrockEdit page, addition 04 June stw
        if (!specialPage) {
                specialPage= ApexPages.currentPage().getUrl().ContainsIgnoreCase(Page.RubricBedrockEdit.getUrl());
        }
        
        rubricScores = Domain_Rubric_Scoring__c.getOrgDefaults();

        List<String> rubricFields = new List<String>();
        rubricFields.add('learning_domain__r.PA_Onboarding__r.Candidate_Email__c');
        rubricFields.add('Learning_Domain__r.Skill__c');
        rubricFields.add('Learning_Domain__r.Status__c');
        rubricFields.add('Primary_Evaluator__r.email');
        rubricFields.add('Rebuild_Objectives__c');
        rubricFields.add('Status__c');
        rubricFields.add('Learning_Domain__r.Quiz_Complete__c');
        rubricFields.add('BedRock__c'); //added by CQ for BedRock

        if (!Test.isRunningTest())
        {
            stdCtrl.addFields(rubricFields);
        }

        rubric = (Rubric__c)stdCtrl.getRecord();
        this.stdCtrl = stdCtrl;
        System.debug('special page' + specialPage);
        System.debug('Rubric Id: ' + rubric.Id);
        String rubricskill = [SELECT skill__c FROM rubric__c WHERE id =:  rubric.Id].skill__c;
        System.debug('Rubric skill: ' + rubricskill);
        boolean orderbyreq = false;
        if (rubricskill.equalsIgnoreCase('Development Lifecycle & Deployment')) orderbyreq = true;
        System.debug('orderbyreq: ' + orderbyreq);
        if(specialPage)
        {
            assessments = new List<RubricAssessment>();
            if(orderbyreq)
            {
                objectives = [select Id, Score__c, Score_Comments__c, Special_Objective__c,
                          Domain_Rubric_Objective__r.Sort_Order__c,
                          Domain_Rubric_Objective__r.Mandatory_For_Pass__c,                          
                          Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Mandatory_For_Pass__c,
                          Domain_Rubric_Objective__r.Objective__c,
                          Domain_Rubric_Objective__r.Solution__c,  //added by CQ for BedRock Record
                          Domain_Rubric_Objective__r.Solution_Consideration__c,//added by CQ for BedRock Record
                          Domain_Rubric_Objective__r.Rating1_Definition__c,
                          Domain_Rubric_Objective__r.Rating2_Definition__c,
                          Domain_Rubric_Objective__r.Rating3_Definition__c,
                          Domain_Rubric_Objective__r.Rating4_Definition__c,
                          Domain_Rubric_Objective__r.Scenario_Requirements__c,
                          Domain_Rubric_Objective__r.Suggested_Questions__c
                          from Rubric_Objective__c
                          where Rubric__c =: rubric.Id
                          and Domain_Rubric_Objective__c != null
                          and Domain_Rubric_Objective__r.Active__c = true
                          order by Domain_Rubric_Objective__r.Sort_Order__c nulls last];
            } else {
            objectives = [select Id, Score__c, Score_Comments__c, Special_Objective__c,
                          Domain_Rubric_Objective__r.Sort_Order__c,
                          Domain_Rubric_Objective__r.Mandatory_For_Pass__c,                          
                          Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Mandatory_For_Pass__c,
                          Domain_Rubric_Objective__r.Objective__c,
                          Domain_Rubric_Objective__r.Solution__c,  //added by CQ for BedRock Record
                          Domain_Rubric_Objective__r.Solution_Consideration__c,//added by CQ for BedRock Record
                          Domain_Rubric_Objective__r.Rating1_Definition__c,
                          Domain_Rubric_Objective__r.Rating2_Definition__c,
                          Domain_Rubric_Objective__r.Rating3_Definition__c,
                          Domain_Rubric_Objective__r.Rating4_Definition__c,
                          Domain_Rubric_Objective__r.Scenario_Requirements__c,
                          Domain_Rubric_Objective__r.Suggested_Questions__c
                          from Rubric_Objective__c
                          where Rubric__c =: rubric.Id
                          and Domain_Rubric_Objective__c != null
                          and Domain_Rubric_Objective__r.Active__c = true
                          order by Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Sort_Order__c nulls last,
                                   Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Sort_Order__c nulls last,
                                   Domain_Rubric_Objective__r.Sort_Order__c nulls last];
            }
            for(Rubric_Objective__c ro : objectives)
            {
                assessments.add(new RubricAssessment(ro));
            }
        }
        else
        {
            objectives = [select Id, Objective__c, Skill_Definition__c,
                          Score_Definition_1__c,Score_Definition_3__c,
                          Score_Definition_5__c,Score_Comments__c,
                          Score__c , Grade_Status__c
                          from Rubric_Objective__c
                          where Rubric__c =: rubric.Id
                          and Domain_Rubric_Objective__c = null
                          order by Objective__c ];
        }
        // Sriram Venkatraman - Alert Message if the rubric was canceled for whatever reason; Block from saving and grading;
        if (rubric.Status__c == 'Cancel') {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Rubric has been canceled. You can\'t grade or save any changes'));         
        }
        if (!rubric.Bedrock__c) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This is not a Bedrock Rubric. You can\'t grade or save any changes'));         
        }
    }

    public PageReference saveScores()
    {
        if (rubric.Status__c != 'Pass' || rubric.Status__c == null)
        {
           rubric.Status__c = 'In Progress';
        }

        try
        {
            doSave(false);
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Scores saved successfully!!!'));
        return null;
    }
    
    // Sriram Venkatraman 3/19/2018 - Begin Changes
    /*
     * Grading function for the updated Bedrock Domain grading function
     * modeled after the original grade() function, but specific to Bedrock functionality
     */
    public void gradeBedrock() {
        
        Decimal passingScore = 3;
        // Set Max MQC Fail
        Decimal MAXMQCFAIL = 2;
        String evalFeedback = '';

        if(passingScoreSetting != null)
        {
            if (passingScoreSetting.Overall_Passing_Score__c != null) {
                passingScore = passingScoreSetting.Overall_Passing_Score__c;
            }
            
            if (passingScoreSetting.Max_MQC_Fails__c != null) {
                MAXMQCFAIL = passingScoreSetting.Max_MQC_Fails__c;
            }
        }
        
        // Set the page to grade mode
        isGradeMode = true;
        
        // Save results before further processing
        try {
            doSave(true);
        } catch (Exception e) {
            // Save failed, sending back to UI
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }
        
        Rubric__c r = [select Average_Score__c, Comments__c from Rubric__c where id = :rubric.id limit 1];
        Decimal score = r.Average_Score__c;
        
        // Get count of Failed Requirements under each MQC
        List<AggregateResult> failRO = [select  Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Id,
                                                COUNT(Id)
                                        from    Rubric_Objective__c
                                        where   Rubric__c = :rubric.Id
                                        and     Domain_Rubric_Objective__c != null
                                        and     Domain_Rubric_Objective__r.Active__c = true
                                        and     Score__c = 0
                                        group by Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Id,
                                        Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Mandatory_For_Pass__c];
        System.debug('failRO' + failRO);

        // Get the failed reqs in a Map for later convenient usage
        Map<Id, Decimal> fRO = new Map<Id, Decimal>();
        for (AggregateResult ar : failRO) {
            fRO.put((Id) ar.get('Id'), (Decimal) ar.get('expr0'));
        }

        // Get Avg requirement scores grouped by MQC
        List<AggregateResult> thisRO = [select  Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Id,
                                                Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Objective__c,
                                                Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Mandatory_For_Pass__c, 
                                                MAX(Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Passing_Average_Score__c), 
                                                SUM(Score__c), 
                                                AVG(Score__c), 
                                                COUNT(Id)
                                        from    Rubric_Objective__c
                                        where   Rubric__c = :rubric.Id
                                        and     Domain_Rubric_Objective__c != null
                                        and     Domain_Rubric_Objective__r.Active__c = true
                                        group by Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Id,Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Objective__c,
                                        Domain_Rubric_Objective__r.Parent_Domain_Rubric_Objective__r.Mandatory_For_Pass__c];
        System.debug(thisRO);
        
        Integer MandatoryMQCFails = 0;
        Integer MQCFails = 0;
        String thisMQC = 'Pass';
        String obj = '';
        evalFeedback = '<table style="width:100%;"><tr><th>MQC</th><th>Mandatory</th><th>Average</th><th># Reqs</th><th>Failed</th><th>Result</th></tr>';
 
        for (AggregateResult ar : thisRO) {
            thisMQC = 'Pass';
            if ( (Decimal) ar.get('expr2') < (Decimal) ar.get('expr0') ) {
                MQCFails++;
                thisMQC = 'Fail';
                if ((ar.get('Mandatory_For_Pass__c') == true)) {
                    MandatoryMQCFails++;
                }
            }
            obj = String.valueof(ar.get('Objective__c'));
            evalFeedback += '<tr>' +
                            '<td>' + obj + '</td>' +
                            '<td>' + ((Boolean) ar.get('Mandatory_For_Pass__c') ? 'Yes' : '') + '</td>' +
                            '<td>' + ((Decimal) ar.get('expr2')).setScale(1) + '</td>' +
                            '<td>' + ar.get('expr3') + '</td>' +
                            '<td>' + (fRO.get((Id) ar.get('Id')) == null ? 0 : fRO.get((Id) ar.get('Id'))) + '</td>' +
                            '<td>' + thisMQC + '</td>' +
                            '</tr>';
                            
            System.debug('MQC Id: ' + ar.get('Id') + 
                         'MQC: ' + obj +
                         ' | Mandatory: ' + ar.get('Mandatory_For_Pass__c') + 
                         ' | Average: ' + ar.get('expr2') + 
                         ' | No. of Requirements: ' + ar.get('expr3') + 
                         ' | Failed Reqs: ' + fRO.get((Id) ar.get('Id')) +
                         ' | MQC Outcome: ' + thisMQC );
        
        }

        evalFeedback += '</table>';
        rubric.Mandatory_Fail__c = false;
        rubric.Status__c = 'Pass';
        if (MQCFails > MAXMQCFAIL || score < passingScore || MandatoryMQCFails > 0) {
            rubric.Status__c = 'Fail';
            rubric.Mandatory_Fail__c = true;
        }

        System.debug('No. of MQC Fails: ' + MQCFails);
        System.debug('No. of Mandatory MQC Fails: ' + MandatoryMQCFails);
        System.debug('Overall Avg Score: ' + score);
        System.debug('Result: ' + rubric.Status__c);

        evalFeedback += '<table style="width:100%"><tr>';
        evalFeedback += '<tr><td><b>' + 'No. of MQC Fails:</b></td><td>' + MQCFails + '</td></tr>';
        evalFeedback += '<tr><td><b>' + 'No. of Mandatory MQC Fails:</b></td><td>' + MandatoryMQCFails + '</td></tr>';
        evalFeedback += '<tr><td><b>' + 'Overall Avg Score:</b></td><td>' + score.setScale(1) + '</td></tr>';
        evalFeedback += '<tr><td><b>' + 'Result:</b></td><td>' + rubric.Status__c + '</td></tr>';
        evalFeedback += '<tr><td><b>' + 'Overall Comments:</b></td><td>' + r.Comments__c.replaceAll('\n', '<br/>') + '</td></tr>';
        evalFeedback += '</table>';
        
        // Set return messages to UI
        if (rubric.Status__c == 'Pass') {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Congratulations the candidate has passed the scenario presentation. The badge should be lit up in 62 org shortly.'));         
        } else {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unfortunately the candidate has failed. Please schedule a full retake of the scenario presentation.'));
        }
        
        // First save this rubric in the Lastest Rubric Id in Learning Domain
        Learning_Domain__c thisLD = [select Id, Last_Evaluation_Feedback__c, Skill__c from Learning_Domain__c where Id in (select Learning_Domain__c from Rubric__c where Id = :rubric.Id)];
        thisLD.Last_Evaluation_Feedback__c = evalFeedback;
        update thisLD;
        
        // Save results back into object
        try {
            rubric.Locked__c = true;
            doSave(false);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }

        // Light up the badge and tell the world
        // Sriram 8/23/2019 - No need for lighting Org62 badges for MuleSoft badges
        if (rubric.Status__c == 'Pass' && !thisLD.Skill__c.startsWithIgnoreCase('MuleSoft:')) {
            lightBadge();
            if (!rubric.Suppress_Chatter_Post__c) {
                chatterPost();
            }
        }
    }
// Sriram Venkatraman 3/19/2018 - End Changes
 
    public void grade()
    {
/* This is a defunct grading; No one should be executing this;
        Decimal passingScore = 3;
        if(specialPage)
        {
            passingScore = rubricScores.Rating3_Score_Value__c;
        }
        else if(passingScoreSetting != null)
        {
            passingScore = passingScoreSetting.Overall_Passing_Score__c;
        }

        try
        {
            doSave(true);
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }

        //if (!rubric.Learning_Domain__r.Quiz_Complete__c)
        //{
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The quiz must be completed for the badge to be graded.'));
        //    return ;
        //}

        Decimal score = [select Average_Score__c from Rubric__c where id = :rubric.id limit 1].Average_Score__c;

        // overall pass or fail
        if(specialPage)
        {
            rubric.Status__c = 'Pass';
            rubric.Mandatory_Fail__c = false;
            if(score < passingScore)
            {
                rubric.Status__c = 'Fail - Full Retake';
            }
            else
            {
                for(Rubric_Objective__c ro: objectives)
                {
                    if(ro.Score__c < passingScore && ro.Domain_Rubric_Objective__r.Mandatory_For_Pass__c)
                    {
                        rubric.Mandatory_Fail__c = true;
                        rubric.Status__c = 'Fail - Section Retake';
                    }
                }
            }
        }
        else
        {
            system.debug(objectiveMinScores);
            gradeObjectives();
            if (score < passingScore)
            {
                rubric.Status__c = 'Fail - Full Retake';
            }
        }

        if (rubric.Status__c == 'Pass')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Congratulations the candidate has passed the scenario presentation. The badge should be lit up in 62 org shortly.'));
        }
        else if (rubric.Status__c == 'Fail - Section Retake')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unfortunately the candidate has failed individual section(s) of the presentation. Please schedule an offline retake of the failed sections indicated below.'));
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unfortunately the candidate has failed. Please schedule a full retake of the scenario presentation.'));
        }

        try
        {
            if(specialPage)
            {
                rubric.Locked__c = true;
            }
            doSave(false);
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }

        if (rubric.Status__c == 'Pass')
        {
            lightBadge();
            if (!rubric.Suppress_Chatter_Post__c)
            {
                chatterPost();
            }
        }
*/
    }

    public PageReference cloneRubric()
    {
        Rubric__c clonedRubric = new Rubric__c();
        clonedRubric.Evaluation_Date__c = Date.today();
        clonedRubric.Learning_Domain__c = rubric.Learning_Domain__c;
        clonedRubric.Primary_Evaluator__c = rubric.Primary_Evaluator__c;
        clonedRubric.BedRock__c = rubric.BedRock__c;
        insert clonedRubric;

        List<Rubric_Objective__c> clonedObjectives = objectives.deepClone();
        for(Rubric_Objective__c ro: clonedObjectives)
        {
            ro.Rubric__c = clonedRubric.Id;
        }
        insert clonedObjectives;

// Sriram Venkatraman: 8/5/2017 - We should always use the RubricChooser so it knows which VF page should be launched
//      PageReference clonedPage = Page.RubricEdit;
        PageReference clonedPage = Page.RubricChooser;
        clonedPage.getParameters().put('Id', clonedRubric.Id);
        clonedPage.setRedirect(true);
        return clonedPage;
    }

    private void doSave(boolean checkComments)
    {
        if(specialPage)
       {
            objectives.clear();
            for(RubricAssessment ra: assessments)
            {
                objectives.add(ra.objective);
            }
       }

       if(checkComments)
       {
            if (rubric.Comments__c == null || rubric.Comments__c.length() == 0)
            {
                throw new CustomException('Comments must be entered to grade the candidate.');
            }

            for(Rubric_Objective__c ro: objectives)
            {
                if(ro.Score__c == null || ro.Score_Comments__c == null || ro.Score_Comments__c.length() == 0)
                {
                    throw new CustomException('A score and comment must be entered for every objective');
                }
            }
       }

       update rubric;
       update objectives;
    }

/* Sriram Venkatraman 5/1/2018 - Used only by the defunct grade() method; commenting out to improve code coverage
    private void gradeObjectives()
    {
        String finalStatus = 'Pass';

        for (Rubric_Objective__c ro : objectives)
        {
            Decimal minScore=3;
            if (objectiveMinScores != null)
            {
                minScore = objectiveMinScores.get(ro.Objective__c);
            }
            if (ro.Score__c >= minScore)
            {
                ro.Grade_Status__c = 'Pass';
            }
            else
            {
                ro.Grade_Status__c = 'Fail';
                finalStatus = 'Fail - Section Retake';
            }
        }
        rubric.Status__c = finalStatus;
    }
*/

    public PageReference resetObjectives()
    {
        if (rubric.Status__c == 'Pass')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot reset objectives if the candidate has passed'));
            return null;
        }
        isGradeMode = false;
        rubric.Rebuild_Objectives__c = true;
        update rubric;

        PageReference ReturnPage = new PageReference('/' + rubric.id + '/e');
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }

    private void lightBadge()
    {
        system.debug('<== LIGHT BADGE ==>');
        system.debug(rubric);

        // check custom setting
        PA_Onboarding_Property__c p = PA_Onboarding_Property__c.getInstance('Enable62OrgBadgeLighting');

        if (p==null || p.Value__c == null || p.Value__c != '1')
        {
            return;
        }

        if (rubric.Learning_Domain__r.Status__c != 'Badged' || rubric.Learning_Domain__r.Status__c == null )
        {
            //rubric.Learning_Domain__r.Status__c = 'Badged';
            try
            {
                badge62(rubric.id);
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred attempting to light the badge in 62 org'));
                ApexPages.addMessages(e);
            }
        }
    }

   private void chatterPost()
   {
        system.debug('<== Post to Chatter  ==>');
        system.debug(rubric);

        // check custom setting
        PA_Onboarding_Property__c p = PA_Onboarding_Property__c.getInstance('Enable62OrgChatterPosting');

        if ((p==null || p.Value__c == null || p.Value__c != '1') && !Test.isRunningTest())
        {
            return;
        }

        try
        {
            chatterPost62(rubric.id);
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred attempting to chatter post in 62 org'));
            ApexPages.addMessages(e);
        }
    }

    @future (callout=true)
    static void badge62(Id rubricId)
    {
        Rubric__c r = [select Learning_Domain__r.Skill__c,
                        Learning_Domain__r.PA_Onboarding__r.Candidate_Email__c,
                        Primary_Evaluator__r.email,
                        Learning_Domain__r.PA_Onboarding__r.Contact__r.Name,
                        comments__c,
                        Learning_Domain__r.Status__c,
                        average_score__c from Rubric__c where Id = :rubricId LIMIT 1];

        Boolean isSuccess=true;
        //check if Bedrock_Badge_Cert_mapping__mdt inidiate need to do cert sync ops/ light org62 badge
        Bedrock_Badge_Cert_mapping__mdt[] bbcm = [select id  from Bedrock_Badge_Cert_mapping__mdt where org62_badge_name__c != null and MasterLabel = :r.Learning_Domain__r.Skill__c limit 1];	
       
        if (bbcm.size() > 0) {
        isSuccess=false;
        Org62_BadgeLighter  lighter = new Org62_BadgeLighter();
        lighter.skill = r.Learning_Domain__r.Skill__c;
        lighter.candidateEmail = r.Learning_Domain__r.PA_Onboarding__r.Candidate_Email__c;
        lighter.evaluatorEmail = r.Primary_Evaluator__r.email; 
        lighter.comments = r.comments__c.left(255); // Org62 badge can only take a comment field of 255 characters
        lighter.score = r.average_score__c;
        try
        {
            if (!Test.isRunningTest()) {
                lighter.badge();
            }
            else {
                system.debug('Assume badge is lit in org 62 for testing sake');
            }
            isSuccess=true;

            // create exception for code coverage during testing
            if (Test.isRunningTest()) {
                String xs = '18adc  ';
                Integer x = Integer.valueOf(xs);
            }
        }
        catch (Exception e)
        {
            system.debug('Chatter Post Exception: ' + e.getMessage());

            // send email to evaluator and current user
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String[] toAddresses = new String[] {r.Primary_Evaluator__r.email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Error lighting badge ' + r.Learning_Domain__r.Skill__c + ' for ' + r.Learning_Domain__r.PA_Onboarding__r.Contact__r.Name);
            mail.setPlainTextBody('We could not light this badge for the following reasons. Please contact the system administrator. \n' + 
                                    e.getMessage());

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            r.Learning_Domain__r.Integration_Errors__c = e.getMessage();
        }
        } else
        {
            system.debug('Skiping Org62 Badge Lighting');
        }
        // update the learning domain record
        if (isSuccess)
        {
            r.Learning_Domain__r.Integration_Errors__c = null;
            r.Learning_Domain__r.Status__c = 'Badged';
        }
        update r.Learning_Domain__r;
    }

    @future (callout=true)
    static void chatterPost62(Id rubricId)
    {
        Rubric__c r = [select Learning_Domain__r.Skill__c,
                        Learning_Domain__r.PA_Onboarding__r.Candidate_Email__c,
                        Primary_Evaluator__r.email,
                        Learning_Domain__r.PA_Onboarding__r.Contact__r.Name,
                        comments__c,
                        Learning_Domain__r.Status__c,
                        average_score__c,
                        Learning_Domain__r.PA_Onboarding__r.Mentor__r.Email
                        from Rubric__c where Id = :rubricId LIMIT 1];

        Boolean isSuccess=false;
        // Sriram: Post to Chatter Group
        Org62_BadgePoster  poster = new Org62_BadgePoster();
        try
        {
            if (!Test.isRunningTest()) {
                poster.badge(r.Learning_Domain__r.PA_Onboarding__r.Candidate_Email__c,
                             r.Learning_Domain__r.PA_Onboarding__r.Mentor__r.Email,
                             r.Primary_Evaluator__r.email,
                             r.Learning_Domain__r.Skill__c );
            }
            else {
                system.debug('Assume org62 chatter is successful in org 62 for testing sake');
            }
            isSuccess=true;
            
            // create exception for code coverage during testing
            if (Test.isRunningTest()) {
                String xs = '18adc  ';
                Integer x = Integer.valueOf(xs);
            }
        }
        catch (Exception e)
        {
            system.debug('Chatter Post Exception: ' + e.getMessage());
            // send email to evaluator and current user
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String[] toAddresses = new String[] {r.Primary_Evaluator__r.email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Error Posting Chatter message for badge ' + r.Learning_Domain__r.Skill__c + ' for ' + r.Learning_Domain__r.PA_Onboarding__r.Contact__r.Name);
            mail.setPlainTextBody('We could not auto chatter post successful badging for the following reasons. Please contact the system administrator. \n' + 
                                    e.getMessage());

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}