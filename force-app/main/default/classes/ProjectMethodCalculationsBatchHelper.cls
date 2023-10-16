/*
 * Description: This Class is used to calculate the scheduled hours for the methods on the onboarding Projects
 * Date: 01-03-2023
 * */
public class ProjectMethodCalculationsBatchHelper {

    public static final Integer LOWEST_PRECEDENCE = 99;

    // Method for delete MFEs and Project Product record those are linked with PSA Project
    public static void deleteMfeRecords(Set<Id> projectIds){

        if(projectIds != null && !projectIds.isEmpty()){
            List<Methods__c> deleteMfeList = new List<Methods__c>();
            for (Methods__c mfeRec : [SELECT Id
                                    FROM Methods__c
                                    where PSA_Project__c In : projectIds WITH SECURITY_ENFORCED]){
                deleteMfeList.add(mfeRec);
            }
            if (deleteMfeList.size()>0){
                Database.delete (deleteMfeList, false);
            }
            
        }
    }

    // This method returns the map of project and its highest precedence offering
    public static Map<Id, Practice_Contribution__c> getProjectOfferingMap(List<PSA_Project__c> projList){

        Map<String, DHQ_Product_Offering_Contribution__c> offeringDPOCMap = (Map<String, DHQ_Product_Offering_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_DPOC_MAP);
        Map<String, Practice_Contribution__c> offeringContributionMap = (Map<String, Practice_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_CONTRIBUTION_MAP);
        Map<Id, Practice_Contribution__c> projectOfferingMap = new Map<Id, Practice_Contribution__c>();

        Map<Id, List<String>> projectOfferingListMap = ( Map<Id, List<String>>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_PROJECT_OFFERING_LIST_MAP);
               
        for(PSA_Project__c proj : projList){
            List<String> offeringList = projectOfferingListMap.get(proj.Id);
            String highestOffering = null;
            Integer precendenceCount = LOWEST_PRECEDENCE; 
            if(offeringList != null){
                for(String offering : offeringList){
                    Integer offeringPrecedence = (Integer)offeringDPOCMap.get(offering)?.Preference_Number__c;
                    if(offeringPrecedence == null){
                        offeringPrecedence = LOWEST_PRECEDENCE;
                    }
                    if( offeringPrecedence < precendenceCount){
                        precendenceCount = offeringPrecedence;
                        highestOffering = offering;
                    }
                }
            }

            if(highestOffering != null){
                projectOfferingMap.put(proj.Id, offeringContributionMap.get(highestOffering));
            }
            
        }

        return projectOfferingMap;
    }

    public static void fetchRelatedData(List<PSA_Project__c> projList){

        // Project Assignments for all the projects
        Map<Id, PSA_Project__c> projectMap = new Map<Id, PSA_Project__c>(projList);
        Map<Id, List<Project_Assignment__c>> projectAssgnmentMap = new Map<Id, List<Project_Assignment__c>>();

        for(Project_Assignment__c assignment : [SELECT Id, PSA_Project__c, Scheduled_Hours__c, Project_Role__c, Start_Date__c, End_Date__c, PSA_Project__r.End_Date__c, PSA_Project__r.Start_Date__c 
        FROM Project_Assignment__c WHERE  PSA_Project__c IN : projectMap.keySet() WITH SECURITY_ENFORCED] )  {

            List<Project_Assignment__c> assignmentList = projectAssgnmentMap.get(assignment.PSA_Project__c);
            if(assignmentList == null){
                assignmentList = new List<Project_Assignment__c>();
            }

            assignmentList.add(assignment);
            projectAssgnmentMap.put(assignment.PSA_Project__c, assignmentList);
        }
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_PROJECT_ASSIGNMENT_MAP, projectAssgnmentMap);

        // Opportunities for all the projects
        Set<Id> opportunityIds = new Set<Id>();
        for (PSA_Project__c projRec : projList){
            opportunityIds.add(projRec.Org62_Opportunity_Id__c);
        }

        Map<String, Opportunity> opptyMap = new Map<String, Opportunity>();
        for(Opportunity opp : [SELECT Id, Targeted_Clouds__c, Org62_Id__c
        FROM Opportunity
        WHERE Org62_Id__c IN :opportunityIds WITH SECURITY_ENFORCED]){
            opptyMap.put(opp.Org62_Id__c, opp);
        }

        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_OPPORTUNITY_MAP, opptyMap);

        // Offering contributions and DPOC for all the projects
        Map<String, DHQ_Product_Offering_Contribution__c> offeringDPOCMap = new Map<String, DHQ_Product_Offering_Contribution__c>();
        Map<String, Practice_Contribution__c> offeringContributionMap = new Map<String, Practice_Contribution__c>();
        Set<String> offerings = new Set<String>();
        Map<Id, List<String>> projectOfferingListMap = new Map<Id, List<String>>();

        for(Practice_Contribution__c oc : [SELECT  Id, Opportunity__c, Offering__c, Work_Units__c, Org62_Opportunity_Id__c FROM Practice_Contribution__c WHERE Org62_Opportunity_Id__c IN :opportunityIds WITH SECURITY_ENFORCED]){

            String offering = oc.Offering__c;
            if(String.isNotBlank(offering)){
                for(PSA_Project__c proj : projList){
                    if(proj.Org62_Opportunity_Id__c == oc.Org62_Opportunity_Id__c){
                        if(projectOfferingListMap.get(proj.Id) == null){
                            projectOfferingListMap.put(proj.Id, new List<String>{offering});
                        }else{
                            projectOfferingListMap.get(proj.Id).add(offering);
                        }
                    }
                }
                if(String.isNotBlank(offering)){
                    offerings.add(offering);
                    offeringContributionMap.put(offering, oc);
                }
            }
        }

        Set<Id> playbookIds = new Set<Id>();
        Set<Id> stageIds = new Set<Id>();
        Map<String, DHQ_Product_Offering_Contribution__c> workUnitDPOCMap = new Map<String, DHQ_Product_Offering_Contribution__c>();

        for(DHQ_Product_Offering_Contribution__c dpoc : [SELECT Id, Name, Offering__c, Playbook__c, Playbook_Stage_Name__c, Playbook_Stage_Name__r.MandatoryStage__c, Work_Unit__c, Work_Unit_or_Offering__c, Mapped_to__c, Preference_Number__c, Product_Offering__c, Product_Offering__r.Name 
                                                            FROM DHQ_Product_Offering_Contribution__c 
                                                            WHERE Offering__c IN :offerings OR Name = :MethodologyConstants.OFFERING_DEFAULT OR Work_Unit_or_Offering__c = :MethodologyConstants.WORK_UNIT WITH SECURITY_ENFORCED]){
            
            if(String.isNotBlank(dpoc.Offering__c)){
                offeringDPOCMap.put(dpoc.Offering__c, dpoc);
            }
            
            if(String.isNotBlank(dpoc.Playbook__c)){
                playbookIds.add(dpoc.Playbook__c);
            }   
                    
            if(String.isNotBlank(dpoc.Playbook_Stage_Name__c)){
                stageIds.add(dpoc.Playbook_Stage_Name__c);
            }

            if(dpoc.Name == MethodologyConstants.OFFERING_DEFAULT){
                EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_DEFAULT_DPOC, dpoc);
            }

            if(dpoc.Work_Unit_or_Offering__c == MethodologyConstants.WORK_UNIT && String.isNotBlank(dpoc.Work_Unit__c)){
                workUnitDPOCMap.put(dpoc.Work_Unit__c, dpoc);
            }
        }

        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_WORK_UNIT_DPOC_MAP, workUnitDPOCMap);

        Map<Id, Stage__c> stageMap = new Map<Id, Stage__c>([SELECT Id, Playbook_Stage__c, MandatoryStage__c FROM Stage__c WHERE Playbook_Stage__c IN :playbookIds OR Id IN :stageIds WITH SECURITY_ENFORCED]);
        Map<Id, List<Stage__c>> playbookStageMap = new Map<Id, List<Stage__c>>();
        for(Stage__c stage: stageMap.values()){
            List<Stage__c> stages = playbookStageMap.get(stage.Playbook_Stage__c);
            if(stages == null){
                stages = new List<Stage__c>();
            }
            stages.add(stage);
            playbookStageMap.put(stage.Playbook_Stage__c, stages);
        }

        Map<Id,List<Stage_Outcome__c>> stageStageOutcomeMap = new Map<Id,List<Stage_Outcome__c>>();
        Set<Id> stageOutcomeIds = new Set<Id>();
        for(Stage_Outcome__c stageOutcome : [SELECT Id, Stage__c FROM Stage_Outcome__c WHERE Stage__c IN :stageMap.keySet() WITH SECURITY_ENFORCED]){
            stageOutcomeIds.add(stageOutcome.Id);
            List<Stage_Outcome__c> stageOutcomes = stageStageOutcomeMap.get(stageOutcome.Stage__c);

            if(stageOutcomes == null){
                stageOutcomes = new List<Stage_Outcome__c>();
            }

            stageOutcomes.add(stageOutcome);
            stageStageOutcomeMap.put(stageOutcome.Stage__c, stageOutcomes);
        }

        Map<Id,List<Stage_Method_Outcome__c>> stageOutcomeStageMethodOutcomeMap = new Map<Id,List<Stage_Method_Outcome__c>>();
        Set<Id> methodOutcomeIds = new Set<Id>();
        for(Stage_Method_Outcome__c stageMethodOutcome : [SELECT Id, Stage_Outcome__c, Method_Outcome__c FROM Stage_Method_Outcome__c WHERE Stage_Outcome__c IN :stageOutcomeIds WITH SECURITY_ENFORCED]){
            methodOutcomeIds.add(stageMethodOutcome.Method_Outcome__c);
            List<Stage_Method_Outcome__c> stageMethodOutcomes = stageOutcomeStageMethodOutcomeMap.get(stageMethodOutcome.Stage_Outcome__c);

            if(stageMethodOutcomes == null){
                stageMethodOutcomes = new List<Stage_Method_Outcome__c>();
            }

            stageMethodOutcomes.add(stageMethodOutcome);
            stageOutcomeStageMethodOutcomeMap.put(stageMethodOutcome.Stage_Outcome__c, stageMethodOutcomes);
        }
        Map<Id, Method__c> methodOutcomeMethodMap =  new Map<Id, Method__c>();
        for(Method_Outcome__c methodOutcome : [SELECT Id, Method__c FROM Method_Outcome__c WHERE Id IN :methodOutcomeIds AND Method__r.Include_in_Slack_Journey__c = true AND Method__r.Status__c = :MethodologyConstants.PUBLISHED WITH SECURITY_ENFORCED]){
            methodOutcomeMethodMap.put(methodOutcome.Id, new Method__c(Id = methodOutcome.Method__c));
        }

        Map<Id, List<Method__c>> stageMethodsMap = new Map<Id, List<Method__c>>();

        for(Stage__c stage: stageMap.values()){
            List<Stage_Outcome__c> stageOutcomeList = stageStageOutcomeMap.get(stage.Id);
            if(stageOutcomeList != null){
                for(Stage_Outcome__c stageOutcome : stageOutcomeList){
                    List<Stage_Method_Outcome__c> stageMethodOutcomeList = stageOutcomeStageMethodOutcomeMap.get(stageOutcome.Id);
                    if(stageMethodOutcomeList != null){
                        for(Stage_Method_Outcome__c stageMethodOutcome : stageMethodOutcomeList){
                            Method__c method = methodOutcomeMethodMap.get(stageMethodOutcome.Method_Outcome__c);

                            if(method != null){
                                List<Method__c> methodList = stageMethodsMap.get(stage.Id);

                                if(methodList == null){
                                    methodList = new List<Method__c>();
                                }

                                methodList.add(method);
                                stageMethodsMap.put(stage.Id, methodList);
                            }
                        }
                    }
                }
            }
            
        }

        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_PLAYBOOK_STAGES_MAP, playbookStageMap);
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_STAGE_METHODS_MAP, stageMethodsMap);

        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_OFFERING_DPOC_MAP, offeringDPOCMap);
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_OFFERING_CONTRIBUTION_MAP, offeringContributionMap);
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_PROJECT_OFFERING_LIST_MAP, projectOfferingListMap);


        // Method lists
        List<String> toUseList = new List<String>();
        toUseList.add(MethodologyConstants.NICE_TO_USE);
        toUseList.add(MethodologyConstants.SHOULD_USE);
        toUseList.add(MethodologyConstants.MUST_USE);

        List<Method__c> microMethodsList = [SELECT Id
                           FROM Method__c
                           WHERE Include_in_Slack_Journey__c = True AND Status__c =  :MethodologyConstants.PUBLISHED AND Micro__c IN:toUseList WITH SECURITY_ENFORCED];



        List<Method__c> smallMethodsList = [SELECT Id
        FROM Method__c
        WHERE Include_in_Slack_Journey__c = True AND Status__c =  :MethodologyConstants.PUBLISHED AND Small__c IN:toUseList WITH SECURITY_ENFORCED];

        List<Method__c> mediumMethodsList = [SELECT Id
        FROM Method__c
        WHERE Include_in_Slack_Journey__c = True AND Status__c =  :MethodologyConstants.PUBLISHED AND Medium__c IN:toUseList WITH SECURITY_ENFORCED];

        List<Method__c> largeMethodsList = [SELECT Id
        FROM Method__c
        WHERE Include_in_Slack_Journey__c = True AND Status__c =  :MethodologyConstants.PUBLISHED AND Large__c IN:toUseList WITH SECURITY_ENFORCED];

        List<Method__c> programMethodsList = [SELECT Id
        FROM Method__c
        WHERE Include_in_Slack_Journey__c = True AND Status__c =  :MethodologyConstants.PUBLISHED AND Program__c IN:toUseList WITH SECURITY_ENFORCED];

        List<Method__c> largeScaleProgramMethodsList = [SELECT Id
        FROM Method__c
        WHERE Include_in_Slack_Journey__c = True AND Status__c =  :MethodologyConstants.PUBLISHED AND Tier_1__c IN:toUseList WITH SECURITY_ENFORCED];

        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.METHOD_TYPE_MICRO, microMethodsList);
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.METHOD_TYPE_SMALL, smallMethodsList);
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.METHOD_TYPE_MEDIUM, mediumMethodsList);
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.METHOD_TYPE_LARGE, largeMethodsList);
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.METHOD_TYPE_PROGRAM, programMethodsList);
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.METHOD_LARGE_SCALE_PROGRAM, largeScaleProgramMethodsList);
    }

    public static void populateDatesInMFEs(List<Methods__c> methods, Map<Id, PSA_Project__c> projectMap){
        Set<Id> methodIds = new Set<Id>();
        for(Methods__c m : methods){
            methodIds.add(m.Method__c);
        }

        Map<String, DHQ_Product_Offering_Contribution__c> offeringDPOCMap = (Map<String, DHQ_Product_Offering_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_DPOC_MAP);
        List<Method_Timing_Default__c> timingDefaults = [SELECT Id, Week_Number__c, Duration_in_Days__c, Method__c, Product_Offering__c FROM Method_Timing_Default__c WHERE Method__c IN :methodIds WITH SECURITY_ENFORCED];

        if(timingDefaults != null){
            Map<String, List<Method_Timing_Default__c>> timingDefaultsByMethodAndProdOffering = new Map<String, List<Method_Timing_Default__c>>();

            for(Method_Timing_Default__c timingDefault : timingDefaults){
                String key = timingDefault.Method__c + '-' + timingDefault.Product_Offering__c;
                if(timingDefaultsByMethodAndProdOffering.get(key) == null){
                    timingDefaultsByMethodAndProdOffering.put(key, new List<Method_Timing_Default__c>{timingDefault});
                }else{
                    timingDefaultsByMethodAndProdOffering.get(key).add(timingDefault);
                }
            }

            for(Methods__c m : methods){
                PSA_Project__c proj = projectMap.get(m.PSA_Project__c);
                Date startDate = proj?.Start_Date__c;
                String key = m.Method__c + '-' + offeringDPOCMap.get(proj?.Offering__c)?.Product_Offering__c;
                
                Method_Timing_Default__c methodTiming = timingDefaultsByMethodAndProdOffering.get(key)?.get(0);
                System.debug('key = '+key+' value = '+methodTiming);
                if(methodTiming != null){
                    m.Start_Date__c = startDate?.addDays(((Integer)methodTiming.Week_Number__c -1)*7);
                    m.End_Date__c = m.Start_Date__c?.addDays((Integer)methodTiming.Duration_in_Days__c);
                }
                
                m.Assigned_Resource__c = proj?.Project_Manager__r?.User_Record__c;
                if(String.isBlank(m.Assigned_Resource__c)){
                    m.Assigned_Resource__c =proj?.ProjectManagerUser__c;
                }
            }

        }

    }

    public static void createMFERecords(List<Method__c> methods, PSA_Project__c proj){

        List<Methods__c> methodEngagementList = (List<Methods__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_MFE_LIST);
        if(methodEngagementList == null){
            methodEngagementList = new List<Methods__c>();
        }
        if (methods != null && methods.size() > 0){
                    
            for (Method__c mt : methods){
                Methods__c mfe = new Methods__c();
                if (mt.Id != null || mt.Id != ''){
                    mfe.Method__c = mt.Id;
                }
                mfe.PSA_Project__c = proj.Id; 
                methodEngagementList.add(mfe);
                
            }
        }
        proj.Method_for_Engagement_status__c = MethodologyConstants.PROJECT_STATUS_DONE;
        EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_MFE_LIST, methodEngagementList);
    }


    /****************************************** Methods related to SOW Scoring calculations ***************************************************** */


    public static Map<Id, Decimal> allAssignmentScoreMap;
    public static Map<Id, Decimal> totalDLAssignmentScoreMap;
    public static Map<Id, Decimal> totalPMAssignmentScoreMap;
    public static Map<Id, Integer> projectBookingAmountCountMap;
    public static Map<Id, Integer> dlScheduleHoursCountMap;
    public static Map<Id, Integer> pmScheduleHoursCountMap;
    public static Map<Id, Integer> totalAssignmentScheduleHoursCountMap;
    public static Map<Id, Decimal> teamMembersScheduleHoursCountMap;
    public static Map<Id, Integer> targetedCloudsCountMap;
    public static List<Project_Assignment__c> projectAssgnmentList;
    
    //Common method to calculate the scheduled hours on the assignments related to the onboarding Project based on the role on the assignments
    public static Decimal calculateTotalScheduleHours(List<Project_Assignment__c> projectAssgnmentList, String role){
        List<Project_Assignment__c> assignmentListToCalculate = new List<Project_Assignment__c>();
        Decimal hours = 0;
        for(Project_Assignment__c assignmentRec : projectAssgnmentList){

            if(assignmentRec.Scheduled_Hours__c != null && ((String.isBlank(role) && assignmentRec.Project_Role__c != null) || (String.isNotBlank(role) && assignmentRec.Project_Role__c?.contains(role)))){
                 hours += assignmentRec.Scheduled_Hours__c;
            }
            
        }
        return hours;
    }

    //common method to get assignment based on role used in calculations 2(Deleivery Lead>) and 3(project manager)
    public static List<Project_Assignment__c> roleSpecificProjectAssignments(List<Project_Assignment__c> projectAssgnmentList, String role){

        List<Project_Assignment__c> projectRoleAssgnmentList = new List<Project_Assignment__c>();
        for (Project_Assignment__c pa : projectAssgnmentList){
            if (pa.Project_Role__c != null && pa.Project_Role__c.contains(role)){
                projectRoleAssgnmentList.add(pa);
            }
        }
        return projectRoleAssgnmentList;
    }

    private static List<Project_Assignment__c> getAssignmentsForProject(Id projId){

        Map<Id, List<Project_Assignment__c>> projAssignmentMap =( Map<Id, List<Project_Assignment__c>>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_PROJECT_ASSIGNMENT_MAP);
        List<Project_Assignment__c> assignments = new List<Project_Assignment__c>();

        if(projAssignmentMap != null && projAssignmentMap.get(projId) != null){
            assignments = projAssignmentMap.get(projId);
        }

        return assignments;
        
    }

    //Method to calculate the total score for a Project, filter methods records for linking and creating Juntion object record
    public static void createMfeRecordsForSOW(PSA_Project__c proj ){

        String methodType = null;
        List<Method__c> projectMethodList;
        if(System.isBatch()){
            List<Project_Assignment__c> projectAssgnmentList = getAssignmentsForProject(proj.Id);

            Decimal allAssignmentScore = 0;
            Integer ProjectBookingAmountCount = 0;
            Integer DLScheduleHoursCount = 0;
            Integer PMScheduleHoursCount = 0;
            Integer TotalAssignmentScheduleHoursCount = 0;
            Decimal TeamMembersScheduleHoursCount = 0;
            Integer TargetedCloudsCount = 0;
            List<Methods__c> methodEngagementList = new List<Methods__c>();

            
            allAssignmentScore = calculateTotalScheduleHours(projectAssgnmentList, '');
            ProjectBookingAmountCount = calculateProjectBookingAmount(proj);
            DLScheduleHoursCount = calculateDLScheduleHours(projectAssgnmentList);
            PMScheduleHoursCount = calculatePMScheduleHours(projectAssgnmentList);
            TotalAssignmentScheduleHoursCount = calculateTotalAssignmentScheduleHours(projectAssgnmentList);

            TeamMembersScheduleHoursCount = calculateTeamMembersScheduleHours(projectAssgnmentList);
            
            TargetedCloudsCount = calculateTargetedClouds(proj);
            
            //Incase of null values to the score assigned 0 value instead of null
            allAssignmentScore = allAssignmentScore == null ? 0 : allAssignmentScore;
            ProjectBookingAmountCount = ProjectBookingAmountCount == null ? 0 : ProjectBookingAmountCount;
            DLScheduleHoursCount = DLScheduleHoursCount == null ? 0 : DLScheduleHoursCount;
            PMScheduleHoursCount = PMScheduleHoursCount == null ? 0 : PMScheduleHoursCount;
            TotalAssignmentScheduleHoursCount = TotalAssignmentScheduleHoursCount == null ? 0 : TotalAssignmentScheduleHoursCount;
            TeamMembersScheduleHourscount = TeamMembersScheduleHourscount == null ? 0 : TeamMembersScheduleHourscount;
            TargetedCloudsCount = TargetedCloudsCount == null ? 0 : TargetedCloudsCount;

            if (allAssignmentScore != 0)
            {                
                methodType = getCountRelatedMethodType(ProjectBookingAmountCount + DLScheduleHoursCount + PMScheduleHoursCount + TotalAssignmentScheduleHoursCount + TeamMembersScheduleHoursCount + TargetedCloudsCount);
                proj.Engagement_Size__c = methodType;
                
            }
        }else{
            methodType = proj.Engagement_Size__c;
        }
        if(String.isNotBlank(methodType)){
            projectMethodList = (List<Method__c>)EDHQ_BT_ApplicationContext.getContextValue(methodType.toLowerCase());
            createMFERecords(projectMethodList, proj);
        }
        
    }

    //Method to determine the size of the methods based on the final score on the onboarding project
    public static String getCountRelatedMethodType(Decimal finalCount){
        String methodType;
        if (finalCount <= 28){
            methodType = MethodologyConstants.METHOD_TYPE_MICRO;
        } else if (finalCount > 28 && finalCount <= 42){
            methodType = MethodologyConstants.METHOD_TYPE_SMALL;
        } else if (finalCount > 42 && finalCount <= 60){
            methodType = MethodologyConstants.METHOD_TYPE_MEDIUM;
        } else if (finalCount > 60 && finalCount <= 82){
            methodType = MethodologyConstants.METHOD_TYPE_LARGE;
        } else if (finalCount > 82 && finalCount <= 100){
            methodType = MethodologyConstants.METHOD_TYPE_PROGRAM;
        } else if (finalCount > 100){
            methodType = MethodologyConstants.METHOD_LARGE_SCALE_PROGRAM;
        }
        return methodType;
    }

    //method used to set the methodology config map
    public static Map<String, Range> getMethodologyConfigMap()
    {
        Map<String, Range> methodologyConfigMap = (Map<String, Range>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_METHODOLOGY_CONFIG_MAP);

        if(methodologyConfigMap == null){
            methodologyConfigMap = new Map<String, Range>();
            List<Methodology_Config__mdt> listMethodConfigs = [SELECT ApexClass__c,Value__c,Label FROM Methodology_Config__mdt WHERE ApexClass__c = :MethodologyConstants.METHODOLOGY_CONFIG_CLASS_NAME WITH SECURITY_ENFORCED];
            for(Methodology_Config__mdt methodConfigRec: listMethodConfigs) 
            {
                methodologyConfigMap.put(methodConfigRec.Label,new Range(methodConfigRec.Value__c));
            }

            EDHQ_BT_ApplicationContext.setContextValue(MethodologyConstants.KEY_METHODOLOGY_CONFIG_MAP, methodologyConfigMap);
        }
       

        return methodologyConfigMap;
    }

    //Calculation 1 :Method to calculate the score based on the onboarding Project booking amount
    public static  Integer calculateProjectBookingAmount(PSA_Project__c projRec){
        Integer projectScore = 0;
       
        Map<String, Range> methodologyConfigMap = getMethodologyConfigMap();

            if (projRec.Bookings__c >= methodologyConfigMap.get('BookingValue1').lowerRange && projRec.Bookings__c < methodologyConfigMap.get('BookingValue1').upperRange){
                projectScore = 1;
            } else if (projRec.Bookings__c >= methodologyConfigMap.get('BookingValue2').lowerRange && projRec.Bookings__c < methodologyConfigMap.get('BookingValue2').upperRange){
                projectScore = 2;
            } else if (projRec.Bookings__c >= methodologyConfigMap.get('BookingValue3').lowerRange && projRec.Bookings__c < methodologyConfigMap.get('BookingValue3').upperRange){
                projectScore = 3;
            } else if (projRec.Bookings__c >= methodologyConfigMap.get('BookingValue4').lowerRange && projRec.Bookings__c < methodologyConfigMap.get('BookingValue4').upperRange){
                projectScore = 4;
            } else if (projRec.Bookings__c >= methodologyConfigMap.get('BookingValue5').lowerRange && projRec.Bookings__c < methodologyConfigMap.get('BookingValue5').upperRange){
                projectScore = 5;
            } else if (projRec.Bookings__c >= methodologyConfigMap.get('BookingValue6').lowerRange){
                projectScore = 6;
            }
        
        return  projectScore * 6;
    }

    //Calculation 2 :Method to calculate the score based on the onboarding Project's assignments having role as Delivery Lead
    public static Integer calculateDLScheduleHours(List<Project_Assignment__c> projectAssgnmentList){
        Integer dlAssignmentScore = 0;
        Decimal totalDLAssignmentScore;
        Decimal totalAssignmentScore;
        Decimal finalDLHours;
        List<Project_Assignment__c> projAssignList = roleSpecificProjectAssignments(projectAssgnmentList, MethodologyConstants.ROLE_DELIVERY_LEAD);
        if(projAssignList.size()>0)
        {
            totalDLAssignmentScore = calculateTotalScheduleHours(projectAssgnmentList, MethodologyConstants.ROLE_DELIVERY_LEAD);
            totalAssignmentScore = calculateTotalScheduleHours(projectAssgnmentList, '');
            for (Project_Assignment__c assignmentRec : projAssignList){
    
                finalDLHours = (totalAssignmentScore == 0 || totalAssignmentScore == null) ? 0 : (totalDLAssignmentScore / totalAssignmentScore) * 40;
    
                if (finalDLHours < 8){
                    dlAssignmentScore = 4;
                } else if (finalDLHours >= 8 && finalDLHours < 16){
                    dlAssignmentScore = 5;
                } else{
                    dlAssignmentScore = 6;
                }

                dlAssignmentScore = dlAssignmentScore * 1;
               
            }
        }
        return dlAssignmentScore;
    }

    //Calculation 3 :Method to calculate the score based on the onboarding Project's assignments having role as Project Manager
    public static Integer calculatePMScheduleHours(List<Project_Assignment__c> projectAssgnmentList){
        Integer pmAssignmentScore = 0;
        Decimal totalPMAssignmentScore;
        Decimal totalAssignmentScore;
        Decimal finalPMHours;
        List<Project_Assignment__c> projAssignList = roleSpecificProjectAssignments(projectAssgnmentList, MethodologyConstants.ROLE_PROJECT_MANAGER);
        if(projAssignList.size()>0)
        {
            totalPMAssignmentScore = calculateTotalScheduleHours(projectAssgnmentList, MethodologyConstants.ROLE_PROJECT_MANAGER);
            totalAssignmentScore = calculateTotalScheduleHours(projectAssgnmentList, '');
            for (Project_Assignment__c assignmentRec : projAssignList){
                finalPMHours = (totalAssignmentScore == 0 || totalAssignmentScore == null) ? 0 : (totalPMAssignmentScore / totalAssignmentScore) * 100;
    
                if (finalPMHours < 20){
                    pmAssignmentScore = 2;
                } else if (finalPMHours >= 20 && finalPMHours < 50){
                    pmAssignmentScore = 3;
                } else if (finalPMHours >= 50 && finalPMHours < 100){
                    pmAssignmentScore = 5;
                } else if (finalPMHours >= 100){
                    pmAssignmentScore = 6;
                }
                pmAssignmentScore = pmAssignmentScore * 3;
                
            }
        }
        return pmAssignmentScore;
    }

    //Calculation 4 :Method to calculate the score based on the the scheduled hours for all the related assignment on the onboarding Project
    public static Integer calculateTotalAssignmentScheduleHours(List<Project_Assignment__c> projectAssgnmentList){
        Map<Id, Integer> totalAssignmentScoreMap = new Map<Id, Integer>();
        Decimal finalAssignmentScore;
        Integer totalAssignmentScore = 0;
        finalAssignmentScore = calculateTotalScheduleHours(projectAssgnmentList, '');
        
        for (Project_Assignment__c assignmentRec : projectAssgnmentList){
            

            if (finalAssignmentScore < 100){
                totalAssignmentScore = 3;
            } else if (finalAssignmentScore >= 100 && finalAssignmentScore < 250){
                totalAssignmentScore = 5;
            } else if (finalAssignmentScore >= 250){
                totalAssignmentScore = 6;
            }

            totalAssignmentScore = totalAssignmentScore * 5;
        }
        return totalAssignmentScore;
    }

    //Calculation 5 : Method to calculate the score based on the all assignemnts with out role
    public static Decimal calculateTeamMembersScheduleHours(List<Project_Assignment__c> projectAssgnmentList){
        Decimal totalAssignmentScore = 0;
        Decimal result = 0;
        Decimal finalAssignmentScore = 0;
        Decimal totalHours;

        totalAssignmentScore = calculateTotalScheduleHours(projectAssgnmentList, '');
        for (Project_Assignment__c assignmentRec : projectAssgnmentList){
            if (assignmentRec != null){
                
                totalHours = ((assignmentRec.PSA_Project__r.End_Date__c).daysBetween(assignmentRec.PSA_Project__r.Start_Date__c) / 7) * 40;
                if (totalHours > 0){
                    finalAssignmentScore = (totalAssignmentScore / totalHours) * 100;
                }
                if (finalAssignmentScore <= 50){
                    result = 3;
                } else if (finalAssignmentScore > 50){
                    result = 4;
                }
                result =  result * 4;
            }
        }
        return result;
    }

    //Calculation 16 :Method to calculate the no of targetted clouds on the Opportunity related to the onboarding Project
    public static  Integer calculateTargetedClouds(PSA_Project__c proj){
        
                Map<String, Opportunity> oppMap = (Map<String, Opportunity>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OPPORTUNITY_MAP);
                Opportunity oppty = oppMap.get(proj.Org62_Opportunity_Id__c);
                Integer count = 0;
                if (oppty != null && !string.isEmpty(oppty.Targeted_Clouds__c)){
                    List<String> targetCloudList = oppty.Targeted_Clouds__c.split(';');

                    if (targetCloudList.size() == 1){
                        count = 2 * 2;
                    } else if (targetCloudList.size() > 1 && targetCloudList.size() < 3){
                        count = 4 * 2;
                    } else if (targetCloudList.size() >= 3 && targetCloudList.size() < 5){
                        count = 5 * 2;
                    } else if (targetCloudList.size() >= 5){
                        count = 6 * 2;
                    }
                }
            
        return count;
    }

    //This is a wrapper class will be used to store the range
    public class Range
    {
        public Decimal upperRange;
        public Decimal lowerRange;
        public Range(String rangeString){
            Decimal maxValue = 9999999999999999999999999999999.0;
            String[] parts = rangeString.split(',');
            this.lowerRange = parts[0]!=''?Decimal.valueOf(parts[0]):0;
            this.upperRange = (parts.size()>1)?Decimal.valueOf(parts[1]):maxValue;
        }
    }

}