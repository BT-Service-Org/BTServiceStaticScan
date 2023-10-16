public class GamificationTriggerHandler {
    public static Id recordTypeId = Schema.SObjectType.User_Achievement_Activity__c.getRecordTypeInfosByDeveloperName().get('Award').getRecordTypeId();
    public static void pscGamification(List<Gamification__e> gamePlatEvents){
        Map<String,User_Achievement_Activity__c> uaaNewMap  = new Map<String,User_Achievement_Activity__c>();
        List<Id> recordIds                                  = new List<Id>();
        Set<Id> usersInContext                              = new Set<Id>();
        Set<String> activityInContext                       = new Set<String>();
        Map<String,Map<Id,Double>> mapOfActToUserActCount   = new Map<String,Map<Id,Double>>();
        Set<String> alreadyExistingUAAs                     = new Set<String>();
        
        for(Gamification__e each:gamePlatEvents){
            recordIds.add(each.Record_Id__c);
        }
        System.debug('recordIds->>'+recordIds);

        // this gets the records which are in context of the platform event
        for(User_Achievement_Activity__c each:[SELECT Id,Activity__c,User__c
                                                FROM User_Achievement_Activity__c
                                                WHERE Id IN :recordIds]){
            usersInContext.add(each.User__c);
            activityInContext.add(each.Activity__c);
        }

        // This gets the map which has the data for a user's activity count
        for(AggregateResult agg:[SELECT sum(Activity_Count__c) actCount,Activity__c,User__c 
                                FROM User_Achievement_Activity__c 
                                WHERE RecordType.DeveloperName ='Tracking'
                                AND User__c IN :usersInContext
                                AND Activity__c IN :activityInContext
                                GROUP BY Activity__c,User__c]){
            usersInContext.add((Id)agg.get('User__c'));
            if(mapOfActToUserActCount.containsKey((String)agg.get('Activity__c'))){
                mapOfActToUserActCount.get((String)agg.get('Activity__c')).put((Id)agg.get('User__c'),(Decimal)agg.get('actCount'));
            }
            else{
                mapOfActToUserActCount.put((String)agg.get('Activity__c'),new Map<Id,Double>{(Id)agg.get('User__c')=>(Decimal)agg.get('actCount')});
            }
        }

        Double pointsOnlyRecsToAdd = 0;
        Integer userPointsOnlyExistingCount = 0;
        // This gets all the badges data and the corresponding user's uaa records
        for(Achievement__c ach:[SELECT Id,Name,Activity__c,Count_Needed__c,Points__c,Points_Only_Award__c,
                                (SELECT Id,User__c,Activity_Count__c,Activity__c
                                FROM User_Achievement_Activities__r 
                                WHERE User__c IN :usersInContext
                                AND RecordType.DeveloperName = 'Award'
                                AND Activity__c IN :mapOfActToUserActCount.keyset()
                                ORDER BY Activity__c DESC NULLS LAST,Activity_Count__c DESC NULLS LAST)
                            FROM Achievement__c
                            WHERE Activity__c IN :mapOfActToUserActCount.keyset()
                            AND Active__c = true
                            AND RecordType.DeveloperName = 'Badge'
                            ORDER BY Activity__c DESC NULLS LAST,Count_Needed__c ASC NULLS LAST]){
            if(mapOfActToUserActCount.containsKey(ach.Activity__c)){
                for(Id userId:mapOfActToUserActCount.get(ach.Activity__c).keyset()){
                    if(mapOfActToUserActCount.get(ach.Activity__c).get(userId) >= ach.Count_Needed__c && ach.User_Achievement_Activities__r.size()>0){
                        if(ach.Points_Only_Award__c){
                            userPointsOnlyExistingCount = 0;
                            pointsOnlyRecsToAdd = 0;
                            for(User_Achievement_Activity__c uaa:ach.User_Achievement_Activities__r){
                                if(uaa.User__c == userId){
                                    userPointsOnlyExistingCount++;
                                }
                            }
                            pointsOnlyRecsToAdd = mapOfActToUserActCount.get(ach.Activity__c).get(userId)-userPointsOnlyExistingCount;
                            if(pointsOnlyRecsToAdd > 0){
                                for(Integer i=0;i<pointsOnlyRecsToAdd;i++){
                                    uaaNewMap.put(String.valueOf(userId)+ach.Id+String.valueOf(i),createAwardUAAInstance(ach,userId));
                                }
                            }
                        }
                        else{
                            for(User_Achievement_Activity__c uaa:ach.User_Achievement_Activities__r){
                                if(uaa.User__c == userId){
                                    alreadyExistingUAAs.add(String.valueOf(userId)+ach.Id);
                                    continue;
                                }
                                else{
                                    uaaNewMap.put(String.valueOf(userId)+ach.Id,createAwardUAAInstance(ach,userId));
                                }
                            }
                        }
                    }
                    else if(mapOfActToUserActCount.get(ach.Activity__c).get(userId) >= ach.Count_Needed__c){
                        uaaNewMap.put(String.valueOf(userId)+ach.Id,createAwardUAAInstance(ach,userId));
                    }
                }
            }
        }

        for(String each:alreadyExistingUAAs){
            uaaNewMap.remove(each);
        }

        if(uaaNewMap.values() != null){
            insert uaaNewMap.values();
        }
        
    }

    private static User_Achievement_Activity__c createAwardUAAInstance(Achievement__c ach,Id userId){
        // create uaa award instance here
        User_Achievement_Activity__c uaaObj = new User_Achievement_Activity__c();
        uaaObj.Achievement__c = ach.Id;
        uaaObj.Activity__c = ach.Activity__c;
        uaaObj.Activity_Count__c = ach.Count_Needed__c;
        uaaObj.Points__c = ach.Points__c;
        uaaObj.RecordTypeId = recordTypeId;
        uaaObj.Award_Date__c = System.now();
        uaaObj.User__c = userId;
        return uaaObj;
    }
}