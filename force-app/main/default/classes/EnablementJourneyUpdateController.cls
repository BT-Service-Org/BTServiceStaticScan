//This controller contains code for the publishing functionality
public with sharing class EnablementJourneyUpdateController {
   
    @InvocableMethod(label='Update Enablement Journey' description='updates the enablement journey, domain relationship , activity group, enablement activity, and enablement RACI')
    public static List<FlowOutputForUpdate> updateEnablementJourney(List<FlowInputForUpdate> flowInputs) {
        String journeyId = flowInputs[0].originalEnablementJourneyId;
        List<String> newJourneyIds = new List<String>();
        Set<String> newJourneyIdsSet = new Set<String>();
        FlowOutputForUpdate flowOutput;
        //Enablement Journey record type id
        Id journeyRecordTypeId = Schema.SObjectType.Enablement_Journey__c.getRecordTypeInfosByDeveloperName().get('Enablement_Journey').getRecordTypeId();

        //get related journeys
        if(flowInputs[0].isCriteriaBased) {
            //get parent template record
            Enablement_Journey__c enJourneyTemplate = [ SELECT  id, Region__c, Hire_Type__c, Job_Level__c, Worker_Type__c, Contributor_Type__c 
                                                        FROM    Enablement_Journey__c 
                                                        WHERE Id = :journeyId AND IsActive__c = true ];
            
                                                        
            //Get journey records matching the fields
            if(String.isNotBlank(enJourneyTemplate.Region__c) || String.isNotBlank(enJourneyTemplate.Hire_Type__c) 
            || String.isNotBlank(enJourneyTemplate.Job_Level__c) || String.isNotBlank(enJourneyTemplate.Worker_Type__c)
            || String.isNotBlank(enJourneyTemplate.Contributor_Type__c)) {
                
                String query = 'SELECT Id FROM Enablement_Journey__c WHERE Id != :journeyId AND RecordTypeId = :journeyRecordTypeId  AND IsActive__c = true ';
                if(String.isNotBlank(enJourneyTemplate.Region__c)) {
                    query += ' AND Region__c = \'' + enJourneyTemplate.Region__c +'\'';
                }
                if(String.isNotBlank(enJourneyTemplate.Hire_Type__c)) {
                    query += ' AND Hire_Type__c = \'' + enJourneyTemplate.Hire_Type__c +'\'';
                }
                if(String.isNotBlank(enJourneyTemplate.Job_Level__c)) {
                    query += ' AND Job_Level__c = \'' + enJourneyTemplate.Job_Level__c +'\'';
                }
                if(String.isNotBlank(enJourneyTemplate.Worker_Type__c)) {
                    query += ' AND Worker_Type__c = \'' + enJourneyTemplate.Worker_Type__c +'\'';
                }
                if(String.isNotBlank(enJourneyTemplate.Contributor_Type__c)) {
                    query += ' AND Contributor_Type__c = \'' + enJourneyTemplate.Contributor_Type__c +'\'';
                }
                
                for(Enablement_Journey__c enJourney : (List<Enablement_Journey__c>) Database.query(query)){
                    newJourneyIdsSet.add(enJourney.Id);
                }
            }

            //Get journey records matching the domains
            //Get all the domain Ids associated with the template
            List<String> domainIds = new List<String>();
            for(Enablement_Journey_Domain__c enJourneyDomain :[SELECT Enablement_Domain__c FROM Enablement_Journey_Domain__c WHERE Enablement_Journey__c = :enJourneyTemplate.Id] )
            {
                domainIds.add(enJourneyDomain.Enablement_Domain__c);
            }

            //Get all the journey Ids associated with the domains
            for(Enablement_Journey_Domain__c enJourneyDomain :[SELECT Enablement_Journey__c FROM Enablement_Journey_Domain__c WHERE Enablement_Domain__c IN :domainIds AND Enablement_Journey__r.IsActive__c = true AND Enablement_Journey__r.RecordTypeId = :journeyRecordTypeId ] )
            {
                newJourneyIdsSet.add(enJourneyDomain.Enablement_Journey__c);
            }

            newJourneyIds.addAll(newJourneyIdsSet);
        }
        else {
            for(Enablement_Source__c enSource :[select Enablement_Journey__c from Enablement_Source__c where Parent_Template__c = :journeyId AND Enablement_Journey__r.IsActive__c = true]){
                newJourneyIds.add(enSource.Enablement_Journey__c);
            }
        }
        //try {
            //Invoke clone logic if "Publish Entire Template" is selected
            if(!flowInputs[0].publishSpecifiedActivities) {
                //Clone/Update Domain Relationships -----------------------------------------------------
                EnablementJourneyFlowHelper.cloneEnablementJourneyDomain(newJourneyIds, journeyId);

                //Clone/Update Activity Groups + Enablement Activities + Enablement RACI -----------------------------------------------------
                EnablementJourneyFlowHelper.cloneEnablementRelatedRecords(newJourneyIds, journeyId);
            }
            //If "Publish Specified Activities" is selected
            else {
                //Clone/Update Domain Relationships -----------------------------------------------------
                EnablementJourneyFlowHelper.cloneEnablementJourneyDomain(newJourneyIds, journeyId);
                publishSpecifiedActivities(newJourneyIds, journeyId);
            }

            //Create Enablement Source records in case of criteria based push
            if(flowInputs[0].isCriteriaBased) {
                List<Enablement_Source__c> enSources = new List<Enablement_Source__c>();
                for(String newJourneyId : newJourneyIds) {

                    enSources.add(new Enablement_Source__c(Enablement_Journey__c=newJourneyId, Parent_Template__c=journeyId, Unique_Id__c = newJourneyId +'_'+journeyId));
                }
                upsert enSources Unique_Id__c;
            }

            flowOutput = new FlowOutputForUpdate();
            flowOutput.isSuccess = true;
            flowOutput.newJourneyIds = newJourneyIds;
        /*} catch(Exception e) {
            flowOutput = new FlowOutputForUpdate();
            flowOutput.isSuccess = false;
        }*/
        return new List<FlowOutputForUpdate> {flowOutput};

    }

    public static void publishSpecifiedActivities(List<String> newJourneyIds, String journeyId) {
        //Query all the related journeys
        Map<Id, Enablement_Journey__c> newJourneyMap = new Map<Id, Enablement_Journey__c> ([SELECT Id, Start_Date__c FROM Enablement_Journey__c WHERE Id IN :newJourneyIds]);
        
        //-----------------------------Clone Activity Groups -----------------------------------------------------
        Map<String, Schema.SObjectField> fieldMap = Enablement_Activity_Group__c.sObjectType.getDescribe().fields.getMap();
        List<String> fieldNamesList = new List<String>();
        fieldNamesList.addAll(fieldMap.keySet());
        
        //Get a list of activity groups from the template
        List< Enablement_Activity_Group__c > originalActGroupList = (List< Enablement_Activity_Group__c >) Database.query('select ' + String.join(fieldNamesList, ',')  + ', (select id from Enablement_Activities__r where Publish__c = true) from Enablement_Activity_Group__c where Enablement_Journey__c = :journeyId' );
        List< Enablement_Activity_Group__c > clonedActGroupList = new List< Enablement_Activity_Group__c >();
        //map of original activity group id to the cloned activity group id
        Map<String, Enablement_Activity_Group__c > originalIdToNewRecordMapActGrp = new Map<String, Enablement_Activity_Group__c >();
        List<Enablement_Activity_Group__c> actGroupToUpdate = new List<Enablement_Activity_Group__c>();
        List<Enablement_Activity_Group__c> actGroupToUsert = new List<Enablement_Activity_Group__c>();

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
                //check if there are activities with publish = true
                if(originalActGroup.Enablement_Activities__r != null && originalActGroup.Enablement_Activities__r.size() > 0) {
                
                    clonedActGroup = originalActGroup.clone(false, false, false, false);
                    clonedActGroup.Enablement_Journey__c = clonedEnJourneyRecId;
                    clonedActGroup.Template_Group_Id__c = clonedEnJourneyRecId + '_' + originalActGroup.Id;

                    //Set dates based on offsets on the template
                    if(originalActGroup.Days_Until_Start__c != null && originalActGroup.Days_To_Complete__c != null && newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c != null) {
                        clonedActGroup.Start_Date__c = newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c.addDays(Integer.valueOf(originalActGroup.Days_Until_Start__c));
                        clonedActGroup.End_Date__c = newJourneyMap.get(clonedEnJourneyRecId).Start_Date__c.addDays(Integer.valueOf(originalActGroup.Days_Until_Start__c + originalActGroup.Days_To_Complete__c));
                    }

                    //if the act group exits (check by group name), add it to update list; else add it to upsert list
                    if(journeyToActGroupsMap.containsKey(clonedEnJourneyRecId) && (journeyToActGroupsMap.get(clonedEnJourneyRecId)).containsKey(originalActGroup.Name)){
                        clonedActGroup.Id = (journeyToActGroupsMap.get(clonedEnJourneyRecId)).get(originalActGroup.Name);
                        actGroupToUpdate.add(clonedActGroup);
                    } else {
                        //these activity groups may or may not exist; so upsert
                        actGroupToUsert.add(clonedActGroup);
                    }
                    
                    originalIdToNewRecordMapActGrp.put(clonedActGroup.Template_Group_Id__c, clonedActGroup);
                }
            }
        }

        if(actGroupToUsert.size() > 0) {
            upsert actGroupToUsert Template_Group_Id__c;
        }
        if(actGroupToUpdate.size() > 0) {
            update actGroupToUpdate;
        }


        //--------------------------------Clone Enablement Activities -----------------------------------------------------

        fieldMap = Enablement_Activity__c.sObjectType.getDescribe().fields.getMap();
        fieldNamesList = new List<String>();
        fieldNamesList.addAll(fieldMap.keySet());
        String query = 'select ' + String.join(fieldNamesList, ',')  + ', Activity_Group__r.Template_Group_Id__c ';
        query += ' from Enablement_Activity__c where Activity_Group__r.Enablement_Journey__c = :journeyId AND Publish__c = true' ;
        List<Enablement_Activity__c> originalActivitiesList = (List<Enablement_Activity__c>) Database.query(query);

        Map<String, Enablement_Activity__c> clonedActivitiesMap = new Map<String, Enablement_Activity__c>();
        Enablement_Activity__c clonedActivity;
        
        for(String clonedEnJourneyRecId :newJourneyIds) {
            for(Enablement_Activity__c originalAct :originalActivitiesList) {
            
                clonedActivity = originalAct.clone(false, false, false, false);
                clonedActivity.Activity_Group__c = originalIdToNewRecordMapActGrp.get(clonedEnJourneyRecId + '_' + originalAct.Activity_Group__c).Id;
                clonedActivity.Template_Activity_Id__c = clonedEnJourneyRecId + '_' + originalAct.Id;

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

        //if activities already exist, do not update/insert
        /*List<String> activityExternalIds = new List<String>();
        activityExternalIds.addAll(clonedActivitiesMap.keySet());
        //check if activities already exist, then remove from the map that will be upserted
        for(Enablement_Activity__c enAct :[SELECT Id, Template_Activity_Id__c FROM Enablement_Activity__c WHERE Template_Activity_Id__c IN :activityExternalIds]) {
            clonedActivitiesMap.remove(enAct.Template_Activity_Id__c);
        }*/

        upsert clonedActivitiesMap.values() Template_Activity_Id__c;
        uncheckPublishFlag(originalActivitiesList);

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

    public static void uncheckPublishFlag(List<Enablement_Activity__c> originalActivitiesList) {
        for(Enablement_Activity__c originalAct :originalActivitiesList) {
            originalAct.Publish__c = false;
            originalAct.Published_Date__c = System.today();
        }
        update originalActivitiesList;
    }

    public static void processActivityGroups() {

    }

    //input details that comes to apex from flow
    public class FlowInputForUpdate{

        @InvocableVariable
        public String originalEnablementJourneyId;
        
        @InvocableVariable
        public Boolean isCriteriaBased;
        
        @InvocableVariable
        public Boolean publishSpecifiedActivities;
    }

    //flow output
    public class FlowOutputForUpdate{

        @InvocableVariable
        public Boolean isSuccess;

        @InvocableVariable
        public List<String> newJourneyIds;
        
        
    }
}