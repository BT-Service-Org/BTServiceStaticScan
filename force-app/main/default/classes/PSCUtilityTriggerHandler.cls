/**
 * 
 * @author anurag suman
 * @since July 2023
 */
public with sharing class PSCUtilityTriggerHandler {
    public static void performUtilityActions(List<PSC_Utility__e> newRecords){
        Map<String,List<PSC_Utility__e>> mapOfEventTypeToEvent      = new Map<String,List<PSC_Utility__e>>();
        
        for(PSC_Utility__e each:newRecords){
            if(mapOfEventTypeToEvent.containsKey(each.Event_Type__c)){
                mapOfEventTypeToEvent.get(each.Event_Type__c).add(each);
            }
            else{
                mapOfEventTypeToEvent.put(each.Event_Type__c,new List<PSC_Utility__e>{each});
            }
        }

        for(String each:mapOfEventTypeToEvent.keySet()){
            if(each == 'Queue Recalculate'){
                calculateQueue(mapOfEventTypeToEvent.get(each));
            }
            else if(each == 'Create Group Member'){
                createGroupMembers(mapOfEventTypeToEvent.get(each));
            }
            else if(each == 'Delete Group Member'){
                deleteGroupMembers(mapOfEventTypeToEvent.get(each));
            }
        }
    }

    /**
     * 
     * @param parentRecs 
     */
    private static void calculateQueue(List<PSC_Utility__e> parentRecs){
        Map<Id,Id> mapOfKnowledgeToQueue = new Map<Id,Id>();

        for(PSC_Utility__e each:parentRecs){
            Map<String, Object> inputs = new Map<String, Object>();
            inputs.put('KnowledgeArticleID', each.Parent_Id__c);
            Flow.Interview.PSC_Calculate_Queue flow1 = new Flow.Interview.PSC_Calculate_Queue(inputs);
            flow1.start();
            mapOfKnowledgeToQueue.put(each.Parent_Id__c,String.valueOf(flow1.getVariableValue('QueueID')));
        }

        if(!mapOfKnowledgeToQueue.isEmpty()){
            List<ProcessInstanceWorkItem> pi = [SELECT Id, ActorId ,ProcessInstance.TargetObjectId
                                                FROM ProcessInstanceWorkItem 
                                                WHERE  ProcessInstance.Status = 'Pending'
                                                AND ProcessInstance.TargetObjectId IN :mapOfKnowledgeToQueue.keyset()];

            for(ProcessInstanceWorkItem each:pi){
                each.ActorId = mapOfKnowledgeToQueue.get(each.ProcessInstance.TargetObjectId);
            }
            
            update pi;
        }
    }

    /**
     * 
     * @param parentRecs 
     */
    private static void createGroupMembers(List<PSC_Utility__e> parentRecs){
        List<GroupMember> gmList = new List<GroupMember>();

        for(PSC_Utility__e each:parentRecs){
            GroupMember gm = new GroupMember(GroupId = each.Parent_Id__c,UserOrGroupId = each.Child_Id__c);
            gmList.add(gm);
        }

        insert gmList;
    }

    /**
     * 
     * @param parentRecs 
     */
    private static void deleteGroupMembers(List<PSC_Utility__e> parentRecs){
        List<GroupMember> gmList = new List<GroupMember>();

        for(PSC_Utility__e each:parentRecs){
            GroupMember gm = new GroupMember(Id = each.Parent_Id__c);
            gmList.add(gm);
        }

        delete gmList;
    }
}