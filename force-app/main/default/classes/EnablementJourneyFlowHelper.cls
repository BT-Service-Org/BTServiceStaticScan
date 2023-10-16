public with sharing class EnablementJourneyFlowHelper {

    //This method clones the enablement journey record and its child records - domain relationship , activity group, enablement activity, and enablement RACI
    @InvocableMethod(label='Clone Enablement Journey' description='clones the enablement journey, domain relationship , activity group, enablement activity, and enablement RACI')
    public static List<FlowOutputForClone> cloneEnablementJourney(List<FlowInputForClone> flowInputs) {
        List<String> clonedEnablementJourneyId;
        String journeyId = flowInputs[0].originalEnablementJourneyId;

        //Clone Enablement Journey -----------------------------------------------------
        Map<String, Schema.SObjectField> fieldMap = Enablement_Journey__c.sObjectType.getDescribe().fields.getMap();
        List<String> fieldNamesList = new List<String>();
        fieldNamesList.addAll(fieldMap.keySet());

        List<Enablement_Journey__c> originalRec = (List<Enablement_Journey__c>) Database.query('select ' + String.join(fieldNamesList, ',')  + ' from Enablement_Journey__c where Id = :journeyId' );
        Enablement_Journey__c clonedEnJourneyRec = originalRec[0].clone(false, false, false, false);
        
        //if user id is blank, it is assumed to be a template creation flow
        if(flowInputs[0].isTemplate) {
            clonedEnJourneyRec.recordTypeId = Schema.SObjectType.Enablement_Journey__c.getRecordTypeInfosByDeveloperName().get('Template').getRecordTypeId();
        } else {
            clonedEnJourneyRec.recordTypeId = Schema.SObjectType.Enablement_Journey__c.getRecordTypeInfosByDeveloperName().get('Enablement_Journey').getRecordTypeId();
        }
        
        clonedEnJourneyRec.Name = flowInputs[0].newEnablementJourneyName;
        clonedEnJourneyRec.OwnerId = UserInfo.getUserId();
        clonedEnJourneyRec.Start_Date__c = flowInputs[0].journeyStartDate;
        clonedEnJourneyRec.Region__c = flowInputs[0].region;
        clonedEnJourneyRec.Hire_Type__c = flowInputs[0].hireType;
        clonedEnJourneyRec.Worker_Type__c = flowInputs[0].workerType;
        clonedEnJourneyRec.Contributor_Type__c = flowInputs[0].contributorType;
        clonedEnJourneyRec.Job_Level__c = flowInputs[0].jobLevel;
        insert clonedEnJourneyRec;

        if(!flowInputs[0].isTemplate) {
            //Create Enablement Source record --------------------------------------------------
            Enablement_Source__c enSource = new Enablement_Source__c();
            enSource.Enablement_Journey__c = clonedEnJourneyRec.Id;
            enSource.Parent_Template__c = journeyId;
            insert enSource;
        }

        //Clone Domain Relationships -----------------------------------------------------
        cloneEnablementJourneyDomain(new List<String>{clonedEnJourneyRec.Id}, journeyId);


        //Clone Activity Groups + Enablement Activities + Enablement RACI -----------------------------------------------------
        cloneEnablementRelatedRecords(new List<String>{clonedEnJourneyRec.Id}, journeyId);
            

        //Create return value
        List<FlowOutputForClone> results = new List<FlowOutputForClone>();
        FlowOutputForClone result = new FlowOutputForClone();
        result.clonedEnablementJourneyId = clonedEnJourneyRec.Id;
        results.add(result);
        return results;

    }

    //This method clones Enablement Journey Domain records
    public static void cloneEnablementJourneyDomain(List<String> newJourneyIds, String journeyId) {
        Map<String, Schema.SObjectField> fieldMap = Enablement_Journey_Domain__c.sObjectType.getDescribe().fields.getMap();
        List<String> fieldNamesList = new List<String>();
        fieldNamesList.addAll(fieldMap.keySet());
        
        List< Enablement_Journey_Domain__c > domRelOriginalList = (List< Enablement_Journey_Domain__c >) Database.query('select ' + String.join(fieldNamesList, ',')  + ' from Enablement_Journey_Domain__c where Enablement_Journey__c = :journeyId' );
        List< Enablement_Journey_Domain__c > clonedDomRelList = new List< Enablement_Journey_Domain__c >();

        Enablement_Journey_Domain__c clonedDomRel;
        for(String clonedEnJourneyRecId :newJourneyIds) {
            for(Enablement_Journey_Domain__c domRelOriginalRec :domRelOriginalList) {
            
                clonedDomRel = domRelOriginalRec.clone(false, false, false, false);
                clonedDomRel.Enablement_Journey__c = clonedEnJourneyRecId;
                clonedDomRel.Template_Domain_Id__c = clonedEnJourneyRecId + '_' + domRelOriginalRec.Id;
                clonedDomRelList.add(clonedDomRel);
            }
        }

        upsert clonedDomRelList Template_Domain_Id__c;
    }

    //This method clones Enablement Activity Group + Enablement Activities + Enablement RACI records
    public static void cloneEnablementRelatedRecords(List<String> newJourneyIds, String journeyId) {
        
        //Query all the related journeys
        Map<Id, Enablement_Journey__c> newJourneyMap = new Map<Id, Enablement_Journey__c> ([SELECT Id, Start_Date__c FROM Enablement_Journey__c WHERE Id IN :newJourneyIds]);
        
        //-----------------------------Clone Activity Groups -----------------------------------------------------
        Map<String, Schema.SObjectField> fieldMap = Enablement_Activity_Group__c.sObjectType.getDescribe().fields.getMap();
        List<String> fieldNamesList = new List<String>();
        fieldNamesList.addAll(fieldMap.keySet());
        
        //Get a list of activity groups from the template
        List< Enablement_Activity_Group__c > originalActGroupList = (List< Enablement_Activity_Group__c >) Database.query('select ' + String.join(fieldNamesList, ',')  + ' from Enablement_Activity_Group__c where Enablement_Journey__c = :journeyId' );
        List< Enablement_Activity_Group__c > clonedActGroupList = new List< Enablement_Activity_Group__c >();
        //map of original activity group id to the cloned activity group id
        Map<String, Enablement_Activity_Group__c > originalIdToNewRecordMapActGrp = new Map<String, Enablement_Activity_Group__c >();
        //the 2 separate maps for update and upsert are created so that activity groups can be matched by name
        Map<String, Enablement_Activity_Group__c> actGroupToUpdate = new Map<String, Enablement_Activity_Group__c>();
        Map<String, Enablement_Activity_Group__c> actGroupToUsert = new Map<String, Enablement_Activity_Group__c>();

        //Get activity groups related to the journeys being updated
        //this will be used to match based on activity group name
        //creates a map of journey id to a map of activity group name to activity group id
        Map<String, Map<String, String>> journeyToActGroupsMap = new Map<String, Map<String, String>>();
        for(Enablement_Activity_Group__c actGrp :[SELECT Id, Name, Enablement_Journey__c FROM Enablement_Activity_Group__c WHERE Enablement_Journey__c IN :newJourneyIds]) {
            if(!journeyToActGroupsMap.containsKey(actGrp.Enablement_Journey__c)){
                journeyToActGroupsMap.put(actGrp.Enablement_Journey__c, new Map<String, String>());
            }
            journeyToActGroupsMap.get(actGrp.Enablement_Journey__c).put(actGrp.Name, actGrp.Id);
        }

        //iterate for each related journey and upsert the records
        Enablement_Activity_Group__c clonedActGroup;
        for(String clonedEnJourneyRecId :newJourneyIds) {
            for(Enablement_Activity_Group__c originalActGroup :originalActGroupList) {
                
                clonedActGroup = originalActGroup.clone(false, false, false, false);
                clonedActGroup.Enablement_Journey__c = clonedEnJourneyRecId;
                clonedActGroup.Template_Group_Id__c = clonedEnJourneyRecId + '_' + originalActGroup.Id;

                //Set dates based on offsets on the template
                if(originalActGroup.Days_Until_Start__c != null && originalActGroup.Days_To_Complete__c != null && newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c != null) {
                    clonedActGroup.Start_Date__c = newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c.addDays(Integer.valueOf(originalActGroup.Days_Until_Start__c));
                    clonedActGroup.End_Date__c = newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c.addDays(Integer.valueOf(originalActGroup.Days_Until_Start__c + originalActGroup.Days_To_Complete__c));
                }

                //if the act group exits, add it to update list; else add it to upsert list
                if(journeyToActGroupsMap.containsKey(clonedEnJourneyRecId) && (journeyToActGroupsMap.get(clonedEnJourneyRecId)).containsKey(originalActGroup.Name)){
                    clonedActGroup.Id = (journeyToActGroupsMap.get(clonedEnJourneyRecId)).get(originalActGroup.Name);
                    actGroupToUpdate.put(clonedActGroup.Template_Group_Id__c, clonedActGroup);
                } else {
                    actGroupToUsert.put(clonedActGroup.Template_Group_Id__c, clonedActGroup);
                }
                
                originalIdToNewRecordMapActGrp.put(clonedActGroup.Template_Group_Id__c, clonedActGroup);
            }
        }
        /*
        if(actGroupToUsert.size() > 0) {
            upsert actGroupToUsert.values() Template_Group_Id__c;
        }
        if(actGroupToUpdate.size() > 0) {
            update actGroupToUpdate.values();
        }
        */

        //--------------------------------Clone Enablement Activities -----------------------------------------------------
        fieldMap = Enablement_Activity__c.sObjectType.getDescribe().fields.getMap();
        fieldNamesList = new List<String>();
        fieldNamesList.addAll(fieldMap.keySet());
        Set<String> actGroupExtIds = new Set<String>();
        Set<String> existingActivitiesExtIds = new Set<String>();
        Map<String, String> actToActGrpExtIds = new Map<String, String>();
        
        //Query all the actiities with all fields on the template
        List<Enablement_Activity__c> originalActivitiesList = (List<Enablement_Activity__c>) Database.query('select ' + String.join(fieldNamesList, ',')  + ' from Enablement_Activity__c where Activity_Group__r.Enablement_Journey__c = :journeyId' );
        //if activities already exist, do not update/insert
        for(Enablement_Activity__c enAct :[SELECT Id, Template_Activity_Id__c FROM Enablement_Activity__c WHERE Activity_Group__r.Enablement_Journey__c IN :newJourneyIds]) {
            existingActivitiesExtIds.add(enAct.Template_Activity_Id__c);
        }

        Map<String, Enablement_Activity__c> clonedActivitiesMap = new Map<String, Enablement_Activity__c>();

        Enablement_Activity__c clonedActivity;
        String activityGroupExtId;
        String activityExtId;
        for(String clonedEnJourneyRecId :newJourneyIds) {
            for(Enablement_Activity__c originalAct :originalActivitiesList) {
                activityGroupExtId = clonedEnJourneyRecId + '_' + originalAct.Activity_Group__c;
                activityExtId = clonedEnJourneyRecId + '_' + originalAct.Id;

                if(!existingActivitiesExtIds.contains(activityExtId)) {
                    clonedActivity = originalAct.clone(false, false, false, false);
                    clonedActivity.Template_Activity_Id__c = activityExtId;

                    actGroupExtIds.add(activityGroupExtId);
                    actToActGrpExtIds.put(clonedActivity.Template_Activity_Id__c, activityGroupExtId);

                    //Set dates based on offsets on the template
                    if(originalAct.Expected_Start_Date__c == null && originalAct.Expected_Completion_Date__c == null 
                        && originalAct.Days_Until_Start__c != null && originalAct.Days_To_Complete__c != null  
                        && newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c != null) {
                        
                        clonedActivity.Expected_Start_Date__c = newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c.addDays(Integer.valueOf(originalAct.Days_Until_Start__c));
                        clonedActivity.Expected_Completion_Date__c = newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c.addDays(Integer.valueOf(originalAct.Days_Until_Start__c + originalAct.Days_To_Complete__c));
                    } 

                    clonedActivitiesMap.put(clonedActivity.Template_Activity_Id__c, clonedActivity);
                }
            }
        }

        List<String> activityExternalIds = new List<String>();
        activityExternalIds.addAll(clonedActivitiesMap.keySet());

        
        //check if the activity group is required to be inserted/updated
        for(String actGrpKey :actGroupToUsert.keySet()) {
            if(!actGroupExtIds.contains(actGrpKey)){
                actGroupToUsert.remove(actGrpKey);
            }
        }
        for(String actGrpKey :actGroupToUpdate.keySet()) {
            if(!actGroupExtIds.contains(actGrpKey)){
                actGroupToUpdate.remove(actGrpKey);
            }
        }
        //upsert/update activity groups
        if(actGroupToUsert.size() > 0) {
            upsert actGroupToUsert.values() Template_Group_Id__c;
        }
        if(actGroupToUpdate.size() > 0) {
            update actGroupToUpdate.values();
        }

        //set Activity Group lookup on Activities
        for(Enablement_Activity__c enAct :clonedActivitiesMap.values()) {
            if(originalIdToNewRecordMapActGrp.containsKey(actToActGrpExtIds.get(enAct.Template_Activity_Id__c))) {
                enAct.Activity_Group__c = originalIdToNewRecordMapActGrp.get(actToActGrpExtIds.get(enAct.Template_Activity_Id__c)).Id;
            }
        }

        upsert clonedActivitiesMap.values() Template_Activity_Id__c;

        //---------------------------Clone RACI records -----------------------------------------------------
        fieldMap = Enablement_RACI__c.sObjectType.getDescribe().fields.getMap();
        fieldNamesList = new List<String>();
        fieldNamesList.addAll(fieldMap.keySet());
        
        List<Enablement_RACI__c> originalRACIList = (List<Enablement_RACI__c>) Database.query('select ' + String.join(fieldNamesList, ',')  + ' from Enablement_RACI__c where Enablement_Activity__r.Activity_Group__r.Enablement_Journey__c = :journeyId' );
        List<Enablement_RACI__c> clonedRACIList = new List<Enablement_RACI__c>();

        Enablement_RACI__c clonedRACI;
        for(String clonedEnJourneyRecId :newJourneyIds) {
            for(Enablement_RACI__c originalRACI :originalRACIList) {
                if(clonedActivitiesMap.containsKey(clonedEnJourneyRecId + '_' + originalRACI.Enablement_Activity__c)) {
                    clonedRACI = originalRACI.clone(false, false, false, false);
                    clonedRACI.Enablement_Activity__c = clonedActivitiesMap.get(clonedEnJourneyRecId + '_' + originalRACI.Enablement_Activity__c).Id;
                    clonedRACI.Template_RACI_Id__c = clonedEnJourneyRecId + '_' + originalRACI.Id;
                    clonedRACIList.add(clonedRACI);
                }
            }
        }

        upsert clonedRACIList Template_RACI_Id__c;

    }


    //input details that comes to apex from flow
    public class FlowInputForClone{

        @InvocableVariable
        public String originalEnablementJourneyId;
        
        @InvocableVariable
        public Boolean isTemplate;

        @InvocableVariable
        public String newEnablementJourneyName;

        @InvocableVariable
        public Date journeyStartDate;

        @InvocableVariable
        public String region;

        @InvocableVariable
        public String hireType;

        @InvocableVariable
        public String workerType;

        @InvocableVariable
        public String contributorType;

        @InvocableVariable
        public String jobLevel;
    }

    //flow output
    public class FlowOutputForClone{

        @InvocableVariable
        public String clonedEnablementJourneyId;
        
        
    }





}