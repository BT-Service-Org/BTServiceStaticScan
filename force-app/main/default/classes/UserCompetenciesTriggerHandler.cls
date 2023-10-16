public class UserCompetenciesTriggerHandler {
    public static void userLevelUpdate(List<UserCompetencies__c> newUserCompetenciesList,Map<Id,UserCompetencies__c> oldUserCompetenciesMap){
        List<UserCompetencies__c> ucRecordsToUpdate = new List<UserCompetencies__c>();

        for(UserCompetencies__c each:newUserCompetenciesList){
            if((oldUserCompetenciesMap != null && !oldUserCompetenciesMap.isEmpty() 
            && (each.Total_Points__c != oldUserCompetenciesMap.get(each.Id).Total_Points__c || each.Badge_Count__c != oldUserCompetenciesMap.get(each.Id).Badge_Count__c)) 
            || oldUserCompetenciesMap == null){
                ucRecordsToUpdate.add(each);
            }
        }    
        
        if(ucRecordsToUpdate != null && !ucRecordsToUpdate.isEmpty()){
            List<Achievement__c> achievementList = [SELECT Id,Count_Needed__c,Max_Level_Points__c,Min_Level_Points__c
                                                    FROM Achievement__c
                                                    WHERE Active__c = true
                                                    AND RecordType.DeveloperName='Level'
                                                    ORDER BY Min_Level_Points__c ASC NULLS LAST,Count_Needed__c ASC NULLS LAST];
                                                    
            Integer achievementListSize = achievementList.size();

            for(UserCompetencies__c uc:ucRecordsToUpdate){
                uc.Total_Points__c = (uc.Total_Points__c==null?0:uc.Total_Points__c);
                uc.Badge_Count__c = (uc.Badge_Count__c==null?0:uc.Badge_Count__c);
                Integer tempPointActCount;
                Integer tempBadgeActCount;
                for(Integer i=0;i<achievementListSize;i++){
                    if(uc.Total_Points__c >= achievementList[i].Min_Level_Points__c ){
                        tempPointActCount = i;
                    }
                    else{
                        break;
                    }
                    if(uc.Badge_Count__c >= achievementList[i].Count_Needed__c){
                        tempBadgeActCount = i;
                    }
                    else{
                        break;
                    }
                }
                if(tempBadgeActCount != null && achievementListSize>=tempPointActCount && (tempPointActCount == tempBadgeActCount || tempPointActCount < tempBadgeActCount)){
                    uc.Level__c = achievementList[tempPointActCount].Id;
                }
                else if(tempBadgeActCount != null && achievementListSize>=tempBadgeActCount && tempPointActCount > tempBadgeActCount) {
                    uc.Level__c =  achievementList[tempBadgeActCount].Id;
                }
                if(tempBadgeActCount == null){
                    uc.Level__c = null;
                }
            }
        }
    }
}