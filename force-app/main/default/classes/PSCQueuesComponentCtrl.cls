/**
 * 
 * @author anurag.suman
 * @since July 2023
 */
public with sharing class PSCQueuesComponentCtrl {
    @AuraEnabled(cacheable=true)
    public static List<GroupDataWrapper> getGroupMemberData(){
        Map<Id,String> mapOfGroupIdToGroupName  = new Map<Id,String>();
        Map<Id,List<GroupMember>> mapOfGroupIdToUsers    = new Map<Id,List<GroupMember>>();
        Set<Id> setOfUserId                     = new Set<Id>();
        Set<Id> setOfChildGroupId               = new Set<Id>();
        List<GroupDataWrapper> gdqWarpList      = new List<GroupDataWrapper>();

        List<Group> listOfAllGroupData = [SELECT Id, Name 
                                            FROM Group
                                            WHERE type ='Regular' 
                                            AND DeveloperName like 'PSC_%'];

        List<GroupMember> queueData = [SELECT Id, GroupId,Group.Name, UserOrGroupId 
                                        FROM GroupMember 
                                        WHERE GroupId IN :listOfAllGroupData];

        for(GroupMember each:queueData){
            if(mapOfGroupIdToUsers.containsKey(each.GroupId)){
                mapOfGroupIdToUsers.get(each.GroupId).add(each);
            }
            else{
                mapOfGroupIdToUsers.put(each.GroupId,new List<GroupMember>{each});
            }
            if(String.valueOf(each.UserOrGroupId).startsWith('005')){
                setOfUserId.add(each.UserOrGroupId);
            }
            else if(String.valueOf(each.UserOrGroupId).startsWith('00G')){
                setOfChildGroupId.add(each.UserOrGroupId);
            }
        }
            

        Map<id,User> userMap = new Map<Id,User>([SELECT Id,Name,Email
                                                FROM User 
                                                WHERE Id IN :setOfUserId]);


        Map<id,Group> groupMap = new Map<Id,Group>([SELECT Id,Name
                                                    FROM Group 
                                                    WHERE Id IN :setOfChildGroupId]);

        for(Group each:listOfAllGroupData){
            GroupDataWrapper gdwObj = new GroupDataWrapper();
            gdwObj.groupId = each.Id;
            gdwObj.groupName = each.Name;
            if(mapOfGroupIdToUsers.containsKey(each.Id)){
                for(GroupMember eachGM:mapOfGroupIdToUsers.get(each.Id)){
                    GroupMemberDataWrapper gmdwWrap = new GroupMemberDataWrapper();
                    gmdwWrap.groupMemberRecId = eachGM.Id;
                    gmdwWrap.userId = eachGM.UserOrGroupId;
                    if(userMap.containsKey(eachGM.UserOrGroupId)){
                        gmdwWrap.userName = userMap.get(eachGM.UserOrGroupId).Name;
                        gmdwWrap.userEmail = userMap.get(eachGM.UserOrGroupId).Email;
                    }
                    else if(groupMap.containsKey(eachGM.UserOrGroupId)){
                        gmdwWrap.userName = groupMap.get(eachGM.UserOrGroupId).Name;
                    }
                    if(gdwObj.groupMemberWrapperList != null && !gdwObj.groupMemberWrapperList.isEmpty()){
                        gdwObj.groupMemberWrapperList.add(gmdwWrap);
                    }
                    else{
                        gdwObj.groupMemberWrapperList = new List<GroupMemberDataWrapper>{gmdwWrap};
                    }
                }
            }
            gdqWarpList.add(gdwObj);
        }

        return gdqWarpList;                                
    }
    
     @AuraEnabled
    public static void deleteGroupMember(String groupMemberId){
        List<PSC_Utility__e> pscUtilities = new List<PSC_Utility__e>();
        pscUtilities.add(new PSC_Utility__e(Event_Type__c='Delete Group Member', Parent_Id__c=groupMemberId));
        EventBus.publish(pscUtilities);   
    }
    
    @AuraEnabled
    public static void addGroupMember(String userId, String groupId){
        List<PSC_Utility__e> pscUtilities = new List<PSC_Utility__e>();
        pscUtilities.add(new PSC_Utility__e(Event_Type__c='Create Group Member', Parent_Id__c=groupId, Child_Id__c=userId));
        EventBus.publish(pscUtilities);   
    }

    public class GroupDataWrapper {
        @auraEnabled
        public String groupName{get;set;}
        @auraEnabled
        public String groupId{get;set;}
        @auraEnabled
        public List<GroupMemberDataWrapper> groupMemberWrapperList{get;set;}

    }

    public class GroupMemberDataWrapper {
        @auraEnabled
        public String groupMemberRecId{get;set;}
        @auraEnabled
        public String userId{get;set;}
        @auraEnabled
        public String userName{get;set;}
        @auraEnabled
        public String userEmail{get;set;}
    }
}