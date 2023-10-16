public with sharing class PSCRASICMatrixCtrl {
    public static Boolean convertStringToBoolean(String input){
        return (input=='Yes'?true:false);
    }

    @AuraEnabled(Cacheable=true)
    public static List<RasicWrapper> getRasicData(String methodId) {
        Map<String,Map<String,Activity_Ownership__c>> mapOfRoleActivity   = new Map<String,Map<String,Activity_Ownership__c>>();
        Set<String> roleNameSet                                 = new Set<String>();
        Map<String,Activity__c> activityMap                     = new Map<String,Activity__c>();
        List<RasicWrapper> rasicWrapList                        = new List<RasicWrapper>();
        
        List<Activity__c> activityList= [SELECT Id,Name,Related_Method__c,Related_Method__r.Method_Number__c,
                                            (SELECT Id,Name,Accountable__c,Consulted__c,Informed__c,Responsible__c,Support__c,Role__r.Name
                                            FROM Activity_Ownerships__r
                                            )
                                        FROM Activity__c
                                        WHERE Id IN (SELECT Activity__c
                                                    FROM Method_By_Activity__c
                                                    WHERE Method__c=:methodId
                                                    AND Method__r.Status__c = 'Published'
                                                    AND Method__r.Method_Number__c != NULL
                                                    )
                                        ];
        for(Activity__c eachAct:activityList){
            for(Activity_Ownership__c each:eachAct.Activity_Ownerships__r){
                if(each.Role__r.Name != null){
                    roleNameSet.add(each.Role__r.Name);
                }
                if(eachAct.Name != null){
                    activityMap.put(eachAct.Name,eachAct);
                }
                if(mapOfRoleActivity.containsKey(each.Role__r.Name)){
                    if(mapOfRoleActivity.get(each.Role__r.Name).containsKey(eachAct.Name)){
                        mapOfRoleActivity.get(each.Role__r.Name).put(eachAct.Name,each);
                    }
                    else{
                        mapOfRoleActivity.get(each.Role__r.Name).put(eachAct.Name,each);
                    }
                }
                else{
                    mapOfRoleActivity.put(each.Role__r.Name,new Map<String,Activity_Ownership__c>{eachAct.Name=>each});
                }
            }
        } 
        
        for(String eachAct:activityMap.keySet()){
            RasicWrapper rasicWrapperObj = new RasicWrapper();
            List<RasicRoleWrapper> rasicActivityWrapList       = new List<RasicRoleWrapper>();
            for(String eachRole:roleNameSet ){
                RasicRoleWrapper rasicRoleWrapperObj = new RasicRoleWrapper();
                if(mapOfRoleActivity.containsKey(eachRole)){
                    if(mapOfRoleActivity.get(eachRole).containsKey(eachAct)){
                        rasicRoleWrapperObj.r = convertStringToBoolean(mapOfRoleActivity.get(eachRole).get(eachAct).Responsible__c);
                        rasicRoleWrapperObj.a = convertStringToBoolean(mapOfRoleActivity.get(eachRole).get(eachAct).Accountable__c);
                        rasicRoleWrapperObj.s = convertStringToBoolean(mapOfRoleActivity.get(eachRole).get(eachAct).Support__c);
                        rasicRoleWrapperObj.i = convertStringToBoolean(mapOfRoleActivity.get(eachRole).get(eachAct).Informed__c);
                        rasicRoleWrapperObj.c = convertStringToBoolean(mapOfRoleActivity.get(eachRole).get(eachAct).Consulted__c);
                    }
                    else{
                        rasicRoleWrapperObj.r = false;
                        rasicRoleWrapperObj.a = false;
                        rasicRoleWrapperObj.s = false;
                        rasicRoleWrapperObj.i = false;
                        rasicRoleWrapperObj.c = false;
                    }
                }
                else{
                    rasicRoleWrapperObj.r = false;
                    rasicRoleWrapperObj.a = false;
                    rasicRoleWrapperObj.s = false;
                    rasicRoleWrapperObj.i = false;
                    rasicRoleWrapperObj.c = false;
                }
                rasicRoleWrapperObj.roleName = eachRole;
                rasicActivityWrapList.add(rasicRoleWrapperObj);
            }
            rasicWrapperObj.activityName = eachAct;
            if(activityMap.get(eachAct).Related_Method__c != null  && activityMap.get(eachAct).Related_Method__r.Method_Number__c != null){
                rasicWrapperObj.activityURL = '/ServicesCentral/s/method?methodnumber='+String.valueOf(activityMap.get(eachAct).Related_Method__r.Method_Number__c);
            }
            rasicWrapperObj.roleNames = rasicActivityWrapList;
            rasicWrapList.add(rasicWrapperObj);
        }
        return rasicWrapList;
    }

    public class RasicWrapper{
        @auraEnabled
        public String activityName{get;set;}
        @auraEnabled
        public String activityURL{get;set;}
        @auraEnabled
        public List<RasicRoleWrapper> roleNames{get;set;}
    }

    public class RasicRoleWrapper{
        @auraEnabled
        public String roleName{get;set;}
        @auraEnabled
        public Boolean r{get;set;}
        @auraEnabled
        public Boolean a{get;set;}
        @auraEnabled
        public Boolean s{get;set;}
        @auraEnabled
        public Boolean i{get;set;}
        @auraEnabled
        public Boolean c{get;set;}
        
    }
}