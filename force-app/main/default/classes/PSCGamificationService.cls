public with sharing class PSCGamificationService {
    public static Id recordTypeId = Schema.SObjectType.User_Achievement_Activity__c.getRecordTypeInfosByDeveloperName().get('Tracking').getRecordTypeId();

    public static List<User_Achievement_Activity__c> createKnowledgeRelatedUAA(List<Knowledge__kav> knowledgeInContextList){
        Map<String,User_Achievement_Activity__c> mapOfNewUAA        = new Map<String,User_Achievement_Activity__c>();
        Set<String> setOfExistingUAA                                = new Set<String>();

        List<User_Achievement_Activity__c> uaaList = [SELECT Id,User__c,Activity__c,Knowledge__c
                                                        FROM User_Achievement_Activity__c
                                                        WHERE Knowledge__c IN :knowledgeInContextList
                                                        AND RecordTypeId =: recordTypeId];

        for(User_Achievement_Activity__c uaa:uaaList){
            setOfExistingUAA.add(uaa.Activity__c+uaa.User__c+uaa.Knowledge__c);
        }
        
        for(Knowledge__kav each:knowledgeInContextList){
            if(each.Reviewer__c != null){
                mapOfNewUAA.put('Review'+each.Reviewer__c+each.Id,createUAAInstance('Review',each.Reviewer__c,each.Id,1));
                if(each.Curation_Level__c == 'Verified'){
                    mapOfNewUAA.put('Review Verified'+each.Reviewer__c+each.Id,createUAAInstance('Review Verified',each.Reviewer__c,each.Id,1));
                }
            }

            if(each.Resource_Type__c == 'Sample Deliverables'){
                mapOfNewUAA.put('Contribute Sample Deliverable'+each.OwnerId+each.Id,createUAAInstance('Contribute Sample Deliverable',each.OwnerId,each.Id,1));
            }
            else if(each.Resource_Type__c == 'Best Practices'){
                mapOfNewUAA.put('Contribute Best Practice'+each.OwnerId+each.Id,createUAAInstance('Contribute Best Practice',each.OwnerId,each.Id,1));
            }
            else if(each.Resource_Type__c == 'Standards'){
                mapOfNewUAA.put('Contribute Standard'+each.OwnerId+each.Id,createUAAInstance('Contribute Standard',each.OwnerId,each.Id,1));
            }
            else if(each.Resource_Type__c == 'Product & Industry Knowledge'){
                mapOfNewUAA.put('Contribute Product & Industry'+each.OwnerId+each.Id,createUAAInstance('Contribute Product & Industry',each.OwnerId,each.Id,1));
            }
            else if(each.Resource_Type__c == 'Reusable Assets'){
                mapOfNewUAA.put('Contribute Reusable Assets'+each.OwnerId+each.Id,createUAAInstance('Contribute Reusable Assets',each.OwnerId,each.Id,1));
            }

            if(each.Curation_Level__c == 'Crowd Sourced'){
                mapOfNewUAA.put('Contribute Crowdsourced'+each.OwnerId+each.Id,createUAAInstance('Contribute Crowdsourced',each.OwnerId,each.Id,1));
            }
            else if(each.Curation_Level__c == 'Verified'){
                mapOfNewUAA.put('Contribute Verified'+each.OwnerId+each.Id,createUAAInstance('Contribute Verified',each.OwnerId,each.Id,1));
            }
            mapOfNewUAA.put('Contribute'+each.OwnerId+each.Id,createUAAInstance('Contribute',each.OwnerId,each.Id,1));
        }

        for(String removeEach:setOfExistingUAA){
            mapOfNewUAA.remove(removeEach);
        }

        insert mapOfNewUAA.values();
        return mapOfNewUAA.values();
    }

    public static List<User_Achievement_Activity__c> createReusableAssetRelatedUAA(List<Reusable_Asset__c> raInContextList){
        Map<String,User_Achievement_Activity__c> mapOfNewUAA        = new Map<String,User_Achievement_Activity__c>();
        Set<String> setOfExistingUAA                                = new Set<String>();

        List<User_Achievement_Activity__c> uaaList = [SELECT Id,User__c,Activity__c,Reusable_Asset__c
                                                        FROM User_Achievement_Activity__c
                                                        WHERE Reusable_Asset__c IN :raInContextList
                                                        AND RecordTypeId =: recordTypeId];

        for(User_Achievement_Activity__c uaa:uaaList){
            setOfExistingUAA.add(uaa.Activity__c+uaa.User__c+uaa.Reusable_Asset__c);
        }
        
        for(Reusable_Asset__c each:raInContextList){
            for(Contribution_Team__c eachCT:each.Contribution_Teams__r){
                if(eachCT.psc_Role__c == 'Primary Author' || eachCT.psc_Role__c == 'Additional Author'){
                    if(each.Resource_Type__c == 'Reusable Assets'){
                        mapOfNewUAA.put('Contribute Reusable Assets'+eachCT.psc_Team_Member__c+each.Id,createUAARAInstance('Contribute Reusable Assets',eachCT.psc_Team_Member__c,each.Id,1));
                    }
                    if(each.Curation_Level__c == 'Crowd Sourced'){
                        mapOfNewUAA.put('Contribute Crowdsourced'+eachCT.psc_Team_Member__c+each.Id,createUAARAInstance('Contribute Crowdsourced',eachCT.psc_Team_Member__c,each.Id,1));
                    }
                    else if(each.Curation_Level__c == 'Verified'){
                        mapOfNewUAA.put('Contribute Verified'+eachCT.psc_Team_Member__c+each.Id,createUAARAInstance('Contribute Verified',eachCT.psc_Team_Member__c,each.Id,1));
                    }
                    mapOfNewUAA.put('Contribute'+eachCT.psc_Team_Member__c+each.Id,createUAARAInstance('Contribute',eachCT.psc_Team_Member__c,each.Id,1));
                }
                else if(eachCT.psc_Role__c == 'Reviewer'){
                    mapOfNewUAA.put('Review'+eachCT.psc_Team_Member__c+each.Id,createUAARAInstance('Review',eachCT.psc_Team_Member__c,each.Id,1));
                    if(each.Curation_Level__c == 'Verified'){
                        mapOfNewUAA.put('Review Verified'+eachCT.psc_Team_Member__c+each.Id,createUAARAInstance('Review Verified',eachCT.psc_Team_Member__c,each.Id,1));
                    }
                }
            }
        }

        for(String removeEach:setOfExistingUAA){
            mapOfNewUAA.remove(removeEach);
        }

        insert mapOfNewUAA.values();
        return mapOfNewUAA.values();
    }

    private static User_Achievement_Activity__c createUAAInstance(String activity,Id userId,Id knowledgeId,Integer actCount){
        // create uaa award instance here
        User_Achievement_Activity__c uaaObj = new User_Achievement_Activity__c();
        uaaObj.Activity__c = activity;
        uaaObj.Knowledge__c = knowledgeId;
        uaaObj.RecordTypeId = recordTypeId;
        uaaObj.Award_Date__c = System.now();
        uaaObj.User__c = userId;
        uaaObj.Activity_Count__c = actCount;
        return uaaObj;
    }

    private static User_Achievement_Activity__c createUAARAInstance(String activity,Id userId,Id raId,Integer actCount){
        // create uaa award instance here
        User_Achievement_Activity__c uaaObj = new User_Achievement_Activity__c();
        uaaObj.Activity__c = activity;
        uaaObj.Reusable_Asset__c = raId;
        uaaObj.RecordTypeId = recordTypeId;
        uaaObj.Award_Date__c = System.now();
        uaaObj.User__c = userId;
        uaaObj.Activity_Count__c = actCount;
        return uaaObj;
    }
}