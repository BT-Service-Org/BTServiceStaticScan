@isTest
public class ProjectMethodTestDataFactory {
    public static final String PROJECT_NAME = 'Test Project 1';

    public static void createBaseData(){
        Opportunity opp = ProjectMethodTestDataFactory.createOpp();
        Contact contact = ProjectMethodTestDataFactory.createContact();
        List<PSA_Project__c> psaProjectList = ProjectMethodTestDataFactory.createPsaProject(opp.Id, contact.Id);
        List<Project_Assignment__c> projectAssignmentList = ProjectMethodTestDataFactory.createProjectAssignment(psaProjectList[0].Id, contact.Id);
        List<Practice_Contribution__c> ocList = ProjectMethodTestDataFactory.createOfferingContributions(opp.Id);
        Playbook__c playbook = ProjectMethodTestDataFactory.createPlaybook();
        List<Stage__c> stageList = ProjectMethodTestDataFactory.createStage(playbook.Id);
        Outcome__c outcome = ProjectMethodTestDataFactory.createOutcome();
        List<Stage_Outcome__c> stageOutcomeList = ProjectMethodTestDataFactory.createStageOutcome(stageList[0].Id, outcome.Id);
        Product_Custom__c productOffering = ProjectMethodTestDataFactory.createProductOffering(playbook.Id);
        List<DHQ_Product_Offering_Contribution__c> dpocList = ProjectMethodTestDataFactory.createDPOC(playbook.Id, stageList[0].Id, productOffering.Id);
        List<Method__c> methodList = ProjectMethodTestDataFactory.createMethod();
        List<Method_Outcome__c> methodOutcomeList = ProjectMethodTestDataFactory.createMethodOutcome(methodList[0].Id);
        List<Stage_Method_Outcome__c> stageMethodOutcomeList = ProjectMethodTestDataFactory.createStageMethodOutcome(stageOutcomeList[0].Id, methodOutcomeList[0].Id);
        List<Methods__c> mfeList = ProjectMethodTestDataFactory.createMFEs(methodList[0].Id, psaProjectList[0].Id);
        List<Method_Timing_Default__c> timingDefaultsList = ProjectMethodTestDataFactory.createTimingDefaults(methodList[0].Id, productOffering.Id);
        
        
    }

    static final string OFFERING_EXPERT_SERVICES = 'Expert Services';

    public static Contact createContact()
    {
        Contact contact     = new Contact();
        contact.LastName    = 'lastNAme';
        contact.FirstName   = 'firstNAme';
        contact.User_Record__c = UserInfo.getUserId();

        insert contact;
        return contact;
    }

    public static PSA_Project__c getProject(String name) {
        PSA_Project__c proj = [SELECT Id, Method_for_Engagement_status__c, Engagement_Size__c, Org62_Opportunity_Id__c, Opportunity__c, Preferred_Methodology__c, Offering__c, Bookings__c, Start_Date__c, End_Date__c, ProjectManagerUser__c, Project_Manager__r.User_Record__c FROM PSA_Project__c WHERE Name = :name limit 1];
        return proj;
    }

    public static List<PSA_Project__c> createPsaProject(String opportunityId, Id contactId) {

        List<PSA_Project__c> psaProjectList = new List<PSA_Project__c>();
        String userId = [SELECT Id FROM User Limit 1].Id;

        PSA_Project__c psaProject1 = new PSA_Project__c();
		psaProject1.Name = ProjectMethodTestDataFactory.PROJECT_NAME;
        psaProject1.SmartSheet_Link__c = 'WWW.Google.Com';
        psaProject1.Start_Date__c = System.today();
        psaProject1.End_Date__c = System.today() + 10;
        psaProject1.Org62_Id__c = 'test1234';
        psaProject1.Opportunity__c = opportunityId;
        psaProject1.Bookings__c = 1000000;
        psaProject1.Org62_Opportunity_Id__c = 'a393C000000APJ6QAO';
        psaProject1.Method_for_Engagement_status__c = MethodologyConstants.PROJECT_STATUS_REFRESH;
        psaProject1.Project_Setup_Status__c = MethodologyConstants.PROJECT_NOT_STARTED;
        psaProject1.Preferred_Methodology__c = MethodologyConstants.METHODOLGY_SPSM_PROJECT;
        psaProject1.Engagement_Size__c = MethodologyConstants.METHOD_TYPE_LARGE;
        psaProject1.Offering__c = MethodologyConstants.OFFERING_CUSTOM_SERVICES;
        psaProject1.Project_Manager__c = contactId;
        psaProject1.ProjectManagerUser__c = userId;
        psaProject1.Smartsheet_ID__c = 'TestId';
        psaProject1.Smartsheet_Creation_Error__c = 'Test';
        psaProjectList.add(psaProject1);

        insert psaProjectList;
        return psaProjectList;
    }

    public static Opportunity createOpp() {
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.today() + 10;
        opp.Amount = 100000;
        opp.Targeted_Clouds__c = 'Core';
        opp.Org62_Id__c = 'a393C000000APJ6QAO';
        
        insert opp;
        return opp;
    }

    public static Opportunity createOpp(String Org62Id) {
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.today() + 10;
        opp.Amount = 100000;
        opp.Targeted_Clouds__c = 'Core';
        opp.Org62_Id__c = Org62Id;
        
        insert opp;
        return opp;
    }
    
    public static List<Project_Assignment__c> createProjectAssignment(String projectId, Id ContactId ) {

        List<Project_Assignment__c> projectAssignmentList = new List<Project_Assignment__c>();


        Project_Assignment__c assignment1 = new Project_Assignment__c();
        assignment1.Resource__c = ContactId;
        assignment1.Project_Role__c = 'Project Manager';
        assignment1.PSA_Project__c = projectId;
        assignment1.Start_Date__c = Date.today();
        assignment1.End_Date__c = Date.today() + 30;
        assignment1.Scheduled_Hours__c = 100;
        assignment1.Org62_Id__c = 'a393C000000APJ6QA1';

        projectAssignmentList.add(assignment1);


        Project_Assignment__c assignment2 = new Project_Assignment__c();
        assignment2.Resource__c = ContactId;
        assignment2.Project_Role__c = 'Delivery Lead';
        assignment2.PSA_Project__c = projectId;
        assignment2.Start_Date__c = Date.today();
        assignment2.End_Date__c = Date.today() + 30;
        assignment1.Scheduled_Hours__c = 300;
        assignment2.Org62_Id__c = 'a393C000000APJ6QA2';
        

        projectAssignmentList.add(assignment2);

        insert projectAssignmentList;
        return projectAssignmentList;
    }
    


    public static List<Practice_Contribution__c> createOfferingContributions(String opportunityId) {

        List<Practice_Contribution__c> ocList = new List<Practice_Contribution__c>();

            Practice_Contribution__c oc1 = new Practice_Contribution__c();
            oc1.Name = 'Test 1';
            oc1.Offering__c = 'Custom Services';
            oc1.Opportunity__c = opportunityId;
            oc1.Work_Units__c = 'Business Value Mapping';
            oc1.Org62_Opportunity_Id__c = 'a393C000000APJ6QAO';
            
            ocList.add(oc1);

            Practice_Contribution__c oc2 = new Practice_Contribution__c();
            oc2.Name = 'Test 2';
            oc2.Offering__c = OFFERING_EXPERT_SERVICES;
            oc2.Opportunity__c = opportunityId;
            oc2.Work_Units__c = null;
            oc2.Org62_Opportunity_Id__c = 'a393C000000APJ6QAO';
            
            ocList.add(oc2);

            Practice_Contribution__c oc3 = new Practice_Contribution__c();
            oc3.Name = 'Test 3';
            oc3.Offering__c = OFFERING_EXPERT_SERVICES;
            oc3.Opportunity__c = opportunityId;
            oc3.Work_Units__c = null;
            oc3.Org62_Opportunity_Id__c = 'a393C000000APJ6QAP';
            
            ocList.add(oc3);

            insert ocList;
        	return ocList;
    }   
        
    public static List<DHQ_Product_Offering_Contribution__c> createDPOC(Id playbookId, Id playbookStageId, Id productOfferingId ) {
        
        List<DHQ_Product_Offering_Contribution__c> dpocList = new List<DHQ_Product_Offering_Contribution__c>();

        Product_Custom__c po = new Product_Custom__c(Name = MethodologyConstants.OFFERING_SOW_PROJECT);
        insert po;

        DHQ_Product_Offering_Contribution__c dpoc1 = new DHQ_Product_Offering_Contribution__c();
        dpoc1.Name = 'Test DPOC 1';
        dpoc1.Offering__c = 'Custom Services';
        dpoc1.Preference_Number__c = 1;
        dpoc1.Playbook__c = playbookId;
        dpoc1.Playbook_Stage_Name__c = playbookStageId;
        dpoc1.Work_Unit__c = null;
        dpoc1.Work_Unit_or_Offering__c = 'Offering';
        dpoc1.Mapped_to__c = 'Playbook';
        dpoc1.Product_Offering__c = productOfferingId;
        dpocList.add(dpoc1);
        
        
        DHQ_Product_Offering_Contribution__c dpoc2 = new DHQ_Product_Offering_Contribution__c();
        dpoc2.Name = 'Test DPOC 2';
        dpoc2.Offering__c = OFFERING_EXPERT_SERVICES;
        dpoc2.Preference_Number__c = 2;
        dpoc2.Playbook__c = playbookId;
        dpoc2.Playbook_Stage_Name__c = null;
        dpoc2.Work_Unit__c = 'Business Value Mapping';
        dpoc2.Work_Unit_or_Offering__c = 'Work Unit';
        dpoc2.Mapped_to__c = '';
        dpoc2.Product_Offering__c = po.Id;
        dpocList.add(dpoc2);

        DHQ_Product_Offering_Contribution__c dpoc3 = new DHQ_Product_Offering_Contribution__c();
        dpoc3.Name = 'Default';
        dpoc3.Offering__c = '';
        dpoc3.Preference_Number__c = null;
        dpoc3.Playbook__c = playbookId;
        dpoc3.Playbook_Stage_Name__c = null;
        dpoc3.Work_Unit__c = '';
        dpoc3.Work_Unit_or_Offering__c = '';
        dpoc3.Mapped_to__c = 'Playbook';
        dpoc3.Product_Offering__c = productOfferingId;
        dpocList.add(dpoc3);

        DHQ_Product_Offering_Contribution__c dpoc4 = new DHQ_Product_Offering_Contribution__c();
        dpoc4.Name = 'Test DPOC 4';
        dpoc4.Offering__c = MethodologyConstants.OFFERING_PHASE_0_STRATEGIC_PLANNING;
        dpoc4.Preference_Number__c = 1;
        dpoc4.Playbook__c = playbookId;
        dpoc4.Playbook_Stage_Name__c = playbookStageId;
        dpoc4.Work_Unit__c = null;
        dpoc4.Work_Unit_or_Offering__c = 'Offering';
        dpoc4.Mapped_to__c = MethodologyConstants.PLAYBOOK_STAGE;
        dpoc4.Product_Offering__c = productOfferingId;
        dpocList.add(dpoc4);


        insert dpocList;
        return dpocList;

    }
    
    public static Playbook__c createPlaybook() {

        Playbook__c playbook = new Playbook__c();
        playbook.Name = 'Test Playbook';

        insert playbook;
        return playbook;

    }
    
    public static List<Stage__c> createStage(Id playbookId) {

        List<Stage__c> stageList = new List<Stage__c>();
        Id recTypeId = Schema.SObjectType.Stage__c.getRecordTypeInfosByDeveloperName().get('Playbook').getRecordTypeId();

        Stage__c stage1 = new Stage__c();
        stage1.Name = 'Test Stage 1';
        stage1.Activities__c = 'Activity 1';
        stage1.Description__c = 'Stage 1 Description';
        stage1.Key_Questions__c = 'What are the key questions for Stage 1?';
        stage1.StageDuration__c = '1 Week';
        stage1.Objective__c = 'Stage 1 Objectives';
        stage1.StageNumber__c = 0001;
        stage1.Playbook_Stage__c = playbookId;
        stage1.MandatoryStage__c = True;
        stage1.RecordTypeId = recTypeId;

        stageList.add(stage1);


        Stage__c stage2 = new Stage__c();
        stage2.Name = 'Test Stage 2';
        stage2.Activities__c = 'Activity 2';
        stage2.Description__c = 'Stage 2 Description';
        stage2.Key_Questions__c = 'What are the key questions for Stage 2?';
        stage2.StageDuration__c = '2 Week';
        stage2.Objective__c = 'Stage 2 Objectives';
        stage2.StageNumber__c = 0002;
        stage2.Playbook_Stage__c = playbookId;
        stage2.MandatoryStage__c = False;
        stage2.RecordTypeId = recTypeId;

        stageList.add(stage2);

        insert stageList;
        return stageList;
    }
    public static Outcome__c createOutcome() {
        
        Outcome__c outco = new Outcome__c();
        outco.Name = 'Test Outcome';
        outco.Order__c = 1;
        insert outco;
        return outco;
    }
    

    public static List<Stage_Outcome__c> createStageOutcome(Id stageId, Id outcomeId) {

        List<Stage_Outcome__c> stageOutcomeList = new List<Stage_Outcome__c>();
        
        Stage_Outcome__c so1 = new Stage_Outcome__c();
        so1.Name = 'Test Stage Outcome 1';
        so1.Outcome__c = outcomeId;
        so1.Order__c = 0001;
        so1.Stage__c = stageId;
        stageOutcomeList.add(so1);


        Stage_Outcome__c so2 = new Stage_Outcome__c();
        so2.Name = 'Test Stage Outcome 2';
        so2.Outcome__c = outcomeId;
        so2.Order__c = 0002;        
        so2.Stage__c = stageId;

        stageOutcomeList.add(so2);

        insert stageOutcomeList;
        return stageOutcomeList;
    }

    public static List<Method__c> createMethod() {

        List<Method__c> methodList = new List<Method__c>();
        
        Method__c method1 = new Method__c();
        method1.Name = 'Test Method 1';
        method1.Include_in_Slack_Journey__c = True;
        method1.Method_Number__c = 0001;
        method1.Smart_Sheet__c = 'Method';
        method1.Status__c = 'Published';
        method1.Large__c = MethodologyConstants.MUST_USE;
        methodList.add(method1);


        Method__c method2 = new Method__c();
        method2.Name = 'Test Method 2';        
        method2.Include_in_Slack_Journey__c = True;
        method2.Method_Number__c = 0002;   
        method2.Smart_Sheet__c = 'Activity';
        method2.Status__c = 'Published';
        method2.Micro__c = MethodologyConstants.MUST_USE;
        methodList.add(method2);

        insert methodList;
        return methodList;
    }

    public static List<Method_Outcome__c> createMethodOutcome(Id methodId) {

        List<Method_Outcome__c> methodOutcomeList = new List<Method_Outcome__c>();
        
        Method_Outcome__c mo1 = new Method_Outcome__c();
        mo1.Name = 'Test Method Outcome 1';
        mo1.Method__c = methodId;
        methodOutcomeList.add(mo1);


        Method_Outcome__c mo2 = new Method_Outcome__c();
        mo2.Name = 'Test Method Outcome 2';     
        mo2.Method__c = methodId;
        methodOutcomeList.add(mo2);

        insert methodOutcomeList;
        return methodOutcomeList;
    }
    
    public static List<Stage_Method_Outcome__c> createStageMethodOutcome(Id stageOutcomeId, Id methodOutcomeId) {

        List<Stage_Method_Outcome__c> stageMethodOutcomeList = new List<Stage_Method_Outcome__c>();

        Stage_Method_Outcome__c smo1 = new Stage_Method_Outcome__c();
        smo1.Method_Outcome__c = methodOutcomeId;
        smo1.Stage_Outcome__c = stageOutcomeId;
        smo1.Order__c = 0001;
        stageMethodOutcomeList.add(smo1);

        Stage_Method_Outcome__c smo2 = new Stage_Method_Outcome__c();
        smo2.Method_Outcome__c = methodOutcomeId;
        smo2.Stage_Outcome__c = stageOutcomeId;
        smo2.Order__c = 0002;
        stageMethodOutcomeList.add(smo2);

        insert stageMethodOutcomeList;
        return stageMethodOutcomeList;

    }

    public static List<Methods__c> getMFEsByProjectId(Id projectId){
        return [Select Id, Method__c, PSA_Project__c FROM Methods__c WHERE PSA_Project__c = :projectId];
    }

    public static List<Methods__c> createMFEs(Id methodId, Id projectId) {

        String userId = [SELECT Id FROM User Limit 1].Id;
        List<Methods__c> mfeList = new List<Methods__c>();

        Methods__c mfe1 = new Methods__c();
        mfe1.Method__c = methodId;
        mfe1.PSA_Project__c = projectId;
        mfe1.Method_in_SOW__c = True;
        mfe1.Deliverable_by__c = 'Salesforce Deliverable';
        mfe1.SmartSheet_Status__c = 'Added from Smartsheet';
        mfe1.LastModifiedById = userId;
        mfe1.Assigned_Resource__c = userId;
        mfe1.Completion_Status__c = 'Complete';
        mfe1.Actual_Start_Date__c = System.today() + 2;
        mfe1.Actual_End_Date__c = System.today() + 12;
        mfe1.End_Date__c = System.today();
        mfe1.Start_Date__c = System.today() + 10;
        mfe1.Smart_Sheet_Link__c = 'testlink1.com';
        mfeList.add(mfe1);

        Methods__c mfe2 = new Methods__c();
        mfe2.Method__c = methodId;
        mfe2.PSA_Project__c = projectId;
        mfe2.Method_in_SOW__c = True;
        mfe2.Deliverable_by__c = 'Salesforce Deliverable';
        mfe2.SmartSheet_Status__c = 'Not Synced to Smartsheet';
        mfe2.LastModifiedById = userId;
        mfe2.Assigned_Resource__c = userId;
        mfe2.Completion_Status__c = 'Pending';
        mfe2.Actual_Start_Date__c = System.today() + 2;
        mfe2.Actual_End_Date__c = System.today() + 12;
        mfe2.End_Date__c = System.today();
        mfe2.Start_Date__c = System.today() + 10;
        mfe2.Smart_Sheet_Link__c = 'testlink2.com';
        mfeList.add(mfe2);
        

        insert mfeList;
        return mfeList;

    }

    public static Product_Custom__c createProductOffering(Id playbookId) {

        Product_Custom__c po = new Product_Custom__c();
        
        po.Name = 'Test Product Offerinh';
        po.Playbook__c = playbookId;
        
        insert po;
        return po;

    }
    

    public static List<Method_Timing_Default__c> createTimingDefaults(Id methodId, Id productOfferingId) {

        List<Method_Timing_Default__c> timingDefaultsList = new List<Method_Timing_Default__c>();

        Method_Timing_Default__c mtd1 = new Method_Timing_Default__c();
        
        mtd1.Name = 'Test MTD 1';
        mtd1.Method__c = methodId;
        mtd1.Product_Offering__c = productOfferingId;
        mtd1.Week_Number__c = 2;
        mtd1.Duration_in_Days__c = 10;
        timingDefaultsList.add(mtd1);

        Method_Timing_Default__c mtd2 = new Method_Timing_Default__c();
        mtd2.Name = 'Test MTD 1';
        mtd2.Method__c = methodId;
        mtd2.Product_Offering__c = productOfferingId;
        mtd2.Week_Number__c = 2;
        mtd2.Duration_in_Days__c = 11;
        timingDefaultsList.add(mtd2);

        

        insert timingDefaultsList;
        return timingDefaultsList;

    }
    

}