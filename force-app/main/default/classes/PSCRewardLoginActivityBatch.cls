/*  * ********************************************************************************************** 
    *  Author:          Mukesh Verma (mverma@salesforce.com)
    *  Created Date:    22 May 2023
    *  Purpose :        Rewards Services Central users with gamification badges for their regular login activities.   
    *                     
    * ************************************************************************************************ */
public  class PSCRewardLoginActivityBatch implements Database.Batchable<sObject>, Database.Stateful {
   public Integer recordsProcessed = 0;
   String samlSsoConfigId='' ;
   public static Id recordTypeId = Schema.SObjectType.User_Achievement_Activity__c.getRecordTypeInfosByDeveloperName().get('Award').getRecordTypeId();
   public PSCRewardLoginActivityBatch (){
        List<SamlSsoConfig> sscList =new List<SamlSsoConfig> ();
        sscList=[Select id from SamlSsoConfig where DeveloperName = :System.Label.PSCOktaAppDevName];
        if(sscList!=null && sscList.size()>0){
            SamlSsoConfigId=sscList[0].id;
            }
        }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query='';
        query='Select id from User where isActive=true and ' ;
        query+='id in (Select userid from LoginHistory where AuthenticationServiceId=\''+SamlSsoConfigId+'\' and logintime=LAST_N_DAYS :31)';
        List<sObject> lst=Database.query(query);
        return Database.getQueryLocator(query);
        }
    public void execute(Database.BatchableContext bc, List<User> users){
        List<User_Achievement_Activity__c> badgesToInsert   = new  List<User_Achievement_Activity__c>  ();
        List<LoginHistory> loginHistoryList                 = new List<LoginHistory> ();
        Map <Id,List<Date>> userToLoginDatesMap             = new Map <Id,List<Date>> ();
        Map<Decimal,Achievement__c> mapOfCountToAch         = new Map<Decimal,Achievement__c>();
        Map<Id,Set<Id>> mapOfAchIdToUsers                   = new Map<Id,Set<Id>>();

        // This query gets the user login achievement records and related awards for the users
        for(Achievement__c each:[SELECT Id,Count_Needed__c,Points__c,Activity__c,
                                    (SELECT Id, User__c
                                    FROM User_Achievement_Activities__r
                                    WHERE User__c IN :users
                                    AND RecordType.DeveloperName = 'Award')
                                FROM Achievement__c
                                WHERE Activity__c = 'Consecutive Login'
                                AND Active__c = TRUE
                                ORDER BY Count_Needed__c DESC]){
            mapOfCountToAch.put(each.Count_Needed__c,each);
            for(User_Achievement_Activity__c eachUAA:each.User_Achievement_Activities__r){
                if(mapOfAchIdToUsers.containsKey(each.Id)){
                    mapOfAchIdToUsers.get(each.Id).add(eachUAA.User__c);
                }
                else{
                    mapOfAchIdToUsers.put(each.Id,new Set<Id>{eachUAA.User__c});
                }
            }
        }

        loginHistoryList= [SELECT userid,logintime 
                            FROM LoginHistory 
                            WHERE userid in :users 
                            AND  logintime = LAST_N_DAYS :31 
                            AND AuthenticationServiceId=:SamlSsoConfigId 
                            ORDER BY userid,LoginTime DESC ];
        
        for(LoginHistory lh:loginHistoryList){
            Date loginDate = date.newinstance(lh.LoginTime.year(), lh.LoginTime.month(), lh.LoginTime.day());
            if(!userToLoginDatesMap.containsKey(lh.userid)){
                userToLoginDatesMap.put(lh.userid, new List<Date>{loginDate});
                
            }
            else if(userToLoginDatesMap.containsKey(lh.userid) && !userToLoginDatesMap.get(lh.userid).contains(loginDate)){ // Additional check is added for deduplication. Here set cannot be added as we need to maintain the order
                userToLoginDatesMap.get(lh.userid).add(loginDate);
            }
        }

        Date date5DaysOld = System.today().addDays(-5);
        Date date20DaysOld = System.today().addDays(-20);

        for(Id userId:userToLoginDatesMap.keySet()){
            Integer user20DaysCount = 0;

            // If the user logs in more than 20 times in 31 days and additional duplicate check
            if(userToLoginDatesMap.get(userId).size()>= 20 
            && mapOfCountToAch.containsKey(20) 
            && (!mapOfAchIdToUsers.containsKey(mapOfCountToAch.get(20).Id) || !mapOfAchIdToUsers.get(mapOfCountToAch.get(20).Id).contains(userId))){
                badgesToInsert.add(createUAAInstance( userId,userToLoginDatesMap.get(userId).size(),mapOfCountToAch.get(20)) );
            }
            // this logic checks the 5th index of user map array to check if that is older than 5 days.
            if(userToLoginDatesMap.get(userId).size()>5 && userToLoginDatesMap.get(userId)[4] >= date5DaysOld
            && mapOfCountToAch.containsKey(5) 
            && (!mapOfAchIdToUsers.containsKey(mapOfCountToAch.get(5).Id) || !mapOfAchIdToUsers.get(mapOfCountToAch.get(5).Id).contains(userId))){
                badgesToInsert.add(createUAAInstance( userId,userToLoginDatesMap.get(userId).size(),mapOfCountToAch.get(5)) ); 
            }
            // This loop is used to count the last 20 days of login and stored to user20DaysCount
            for(Date each:userToLoginDatesMap.get(userId)){
                if(each>=date20DaysOld){
                    user20DaysCount++;
                }
                else{
                    break;
                }
            }
            if(user20DaysCount >=10 
            && mapOfCountToAch.containsKey(10) 
            && (!mapOfAchIdToUsers.containsKey(mapOfCountToAch.get(10).Id) || !mapOfAchIdToUsers.get(mapOfCountToAch.get(10).Id).contains(userId))){
                badgesToInsert.add(createUAAInstance( userId,userToLoginDatesMap.get(userId).size(),mapOfCountToAch.get(10)) ); 
            }
        }
        if(badgesToInsert.size()>0){
            Database.insert(badgesToInsert);
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('###');
    }

    private static User_Achievement_Activity__c createUAAInstance(Id userId,Integer actCount, Achievement__c achievement){
        // create uaa award instance here
        User_Achievement_Activity__c uaaObj = new User_Achievement_Activity__c();
        uaaObj.Activity__c = achievement.Activity__c;
        uaaObj.Achievement__c = achievement.Id;
        uaaObj.RecordTypeId = recordTypeId;
        uaaObj.Award_Date__c = System.now();
        uaaObj.User__c = userId;
        uaaObj.Activity_Count__c = achievement.Count_Needed__c;
        uaaObj.Points__c = achievement.Points__c;
        return uaaObj;
    }

}