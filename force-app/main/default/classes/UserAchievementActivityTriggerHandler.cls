/**
 * 
 * @author anurag.suman
 * @since April 2023
 * @group Services Central
 * @description : This class is handler class class for User_Achievement_Activity__c trigger
 */
public with sharing class UserAchievementActivityTriggerHandler {
    /**
     * 
     * @param newUAAList 
     * @param oldUAAMap 
     */
    public static void updateUserCompetency(List<User_Achievement_Activity__c> newUAAList, Map<Id,User_Achievement_Activity__c> oldUAAMap){
        Set<Id> userIds                             = new Set<Id>();
        List<UserCompetencies__c> newUserCmpList    = new List<UserCompetencies__c>();
        Map<Id,UserCompetencies__c> newUserCmpMap   = new Map<Id,UserCompetencies__c>();

        for(User_Achievement_Activity__c each:newUAAList){
            if(each.Points__c != null && (oldUAAMap != null && !oldUAAMap.isEmpty() && each.Points__c != oldUAAMap.get(each.Id).Points__c) || oldUAAMap == null){
                userIds.add(each.User__c);
            }
        }
        
        if(userIds != null && !userIds.isEmpty()){
            List<AggregateResult> pointsUserCompetencies = [SELECT SUM(Points__c) totalPoints,count(Id) totalBadges, User__c,Achievement__r.Points_Only_Award__c
                                                            FROM User_Achievement_Activity__c 
                                                            WHERE RecordType.DeveloperName ='Award'
                                                            AND User__c IN :userIds
                                                            GROUP BY User__c,Achievement__r.Points_Only_Award__c
                                                            ORDER BY User__c];
            
            List<UserCompetencies__c> existingUserCmpList = [Select Id,Total_Points__c,User__c,Badge_Count__c,Rating__c
                                                            FROM UserCompetencies__c
                                                            WHERE User__c IN:userIds];
            
            Map<Id,UserCompetencies__c> userCmpToUserMap = new Map<Id,UserCompetencies__c>();
            
            for(UserCompetencies__c uc:existingUserCmpList){
                userCmpToUserMap.put(uc.User__c,uc);
            }
            
            Decimal userTotalPoints = 0;
            Id prevUserId = null;
            //check if User competency records exist, then update else create.
            for(AggregateResult agg:pointsUserCompetencies){
                if(prevUserId == null || (prevUserId != null && (Id)agg.get('User__c') != prevUserId)){
                    prevUserId = (Id)agg.get('User__c');
                    userTotalPoints= 0;
                }
                userTotalPoints += (Decimal)agg.get('totalPoints');
                if(userCmpToUserMap.containsKey((Id)agg.get('User__c'))){
                    UserCompetencies__c uC = userCmpToUserMap.get((Id)agg.get('User__c'));
                    uC.Total_Points__c = userTotalPoints;
                    uC.User__c = (Id)agg.get('User__c');
                    uC.OwnerId = (Id)agg.get('User__c');
                    if(!(Boolean)agg.get('Points_Only_Award__c')){
                        uC.Badge_Count__c = (Integer)agg.get('totalBadges');
                    }
                    uC.Rating__c = 0;
                    newUserCmpMap.put(uC.Id,uC);
                } 
                else {
                    UserCompetencies__c userCompetency = new UserCompetencies__c();
                    userCompetency.Total_Points__c = userTotalPoints;
                    userCompetency.User__c = (Id)agg.get('User__c');
                    userCompetency.OwnerId = (Id)agg.get('User__c');
                    if(!(Boolean)agg.get('Points_Only_Award__c')){
                        userCompetency.Badge_Count__c = (Integer)agg.get('totalBadges');
                    }
                    userCompetency.Rating__c = 0;
                    newUserCmpList.add(userCompetency);                    
                }
            }
            
            // check if newUserCmpMap is not empty, then add all the values to newUserCmpList
            if(!newUserCmpMap.isEmpty()){
                newUserCmpList.addAll(newUserCmpMap.values());
            }
            upsert newUserCmpList;
        }
    }
/*
* @Method:      preventDuplicate
* @Created by:  Rohan Saxena
* @Description: This method will prevent the duplicate insertion of records //GKC-1019
*/
    public static void preventDuplicate(List<User_Achievement_Activity__c> newUAAList){
        set<Id> userid = new set<Id>();
        Map<Id, List<User_Achievement_Activity__c>> mapIdandUSerActivity = new Map<Id, List<User_Achievement_Activity__c>>();
        for(User_Achievement_Activity__c userActivity: newUAAList){
            if(userActivity.User__c != null){
            userid.add(userActivity.User__c);
        }
        }
        if(!userid.isEmpty()){
        List<User_Achievement_Activity__c> lstUserAct= [SELECT Id,Activity__c,Achievement__c,User__c,RecordTypeId FROM User_Achievement_Activity__c
                                                                                                 WHERE  RecordType.DeveloperName='Award' 
                                                                                                     AND Achievement__r.RecordType.DeveloperName='Badge'
                                                                                                     AND User__c IN: userid
                                                                                                     AND Achievement__r.Points_Only_Award__c=false
                                                                                                     AND Achievement__r.One_Time_Award__c=true];
        for(User_Achievement_Activity__c userActivity: lstUserAct){
            List<User_Achievement_Activity__c> lstuserActivity = new List<User_Achievement_Activity__c>();
            if(mapIdandUSerActivity.containskey(userActivity.User__c)){
                lstuserActivity= mapIdandUSerActivity.get(userActivity.User__c);
                }
                lstuserActivity.add(userActivity);
                mapIdandUSerActivity.put(userActivity.User__c,lstuserActivity);
        }
        for(User_Achievement_Activity__c userActivity: newUAAList){
            if(mapIdandUSerActivity.containskey(userActivity.User__c)){
                for(User_Achievement_Activity__c inneruaa: mapIdandUSerActivity.get(userActivity.User__c)){
                    if(userActivity.Achievement__c==inneruaa.Achievement__c && userActivity.RecordTypeId ==inneruaa.RecordTypeId){
                        userActivity.addError('The badge was already assigned to the person.');
                    }
                }
            }
        }
      }
    }
/*
* @Method:      preventDuplicate
* @Created by:  Rohan Saxena
* @Description: This method will prevent the duplicate insertion of records //GKC-1019
*/
    public static void preventDuplicate(List<User_Achievement_Activity__c> newUAAList, Map<Id,User_Achievement_Activity__c> oldUAAMap){
        List<User_Achievement_Activity__c> lstnewUAA =new List<User_Achievement_Activity__c>();
        for(User_Achievement_Activity__c UAA: newUAAList){
            if(oldUAAMap.get(UAA.Id).Achievement__c != UAA.Achievement__c){
                lstnewUAA.add(UAA);
            }
        }
        UserAchievementActivityTriggerHandler.preventDuplicate(lstnewUAA);
    }
}