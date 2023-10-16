/**
 * 
 * @author anurag.suman
 * @since March 2023
 * @description Controller class for PSCBadges component
 * @group Services Central
 */
public class PSCBadgesCtrl {
    /**
     * 
     * @param key  `String`
     * @return  `outerWrapper`
     */
    @AuraEnabled(cacheable=true)
    public static outerWrapper getbadges(String key){
        String imageData = PSCSettingService.getValue('psc_badge_images');
        Id currentLevel;
        if(key=='level'){
            List<UserCompetencies__c> ucList = [SELECT Id,Level__c
                                                FROM UserCompetencies__c
                                                WHERE User__c=:userinfo.getUserId()
                                                ];

            currentLevel = (ucList != null && !ucList.isEmpty())?ucList[0].Level__c:null;
        }

        List<Achievement__c> achievementsList = [SELECT Id,Name,Description__c,Activity__c,Group__c,Min_Level_Points__c,Max_Level_Points__c,Points__c,
                                                Count_Needed__c, RecordType.DeveloperName,
                                                 (SELECT Id,name,User__c 
                                                  FROM User_Achievement_Activities__r 
                                                  WHERE User__c=:userinfo.getUserId())
                                                 FROM Achievement__c 
                                                 WHERE Active__c = TRUE
                                                 AND Points_Only_Award__c = false
                                                 ORDER BY Activity__c,Count_Needed__c ASC NULLS LAST];
        
        List<innerWrapper> wrapperList = new List<innerWrapper>();
        Map<String,List<badgeData>> badgeMap = new map<String,List<badgeData>>();
        
        boolean userLevelFound = false;
        Boolean badgeAchievedFlag = false;
        for(Achievement__c obj:achievementsList){
            if(key=='level'){
                System.debug('currentLevel->'+currentLevel);
                System.debug('userLevelFound->'+userLevelFound);
                System.debug('obj.Id ->'+obj.Id);
                if(currentLevel != null && !userLevelFound){
                    badgeAchievedFlag = true;
                    userLevelFound = (obj.Id == currentLevel?true:false);
                }
                else{
                    badgeAchievedFlag = false;
                }
            }
            else{
                badgeAchievedFlag = !obj.User_Achievement_Activities__r.isEmpty()?true:false;
            }

            // Key is used as a input from controller to get the relevant data
            if((key=='myBadges' && badgeAchievedFlag && obj.RecordType.DeveloperName == 'Badge')        // Shows the users badges that user has already achieved
            || (key=='targetBadges' && !badgeAchievedFlag && obj.RecordType.DeveloperName == 'Badge')   // Shows the badges which are 
            || (key=='level' && obj.RecordType.DeveloperName == 'Level')) {                             // Gets the levels data
                badgeData badgeIns = new badgeData();
                badgeIns.badgeName = obj.Name;
                badgeIns.badgeDescription = obj.Description__c;
                badgeIns.countNeeded = obj.Count_Needed__c;
                badgeIns.minLevelPoints = obj.Min_Level_Points__c;
                badgeIns.maxLevelPoints = obj.Max_Level_Points__c;
                badgeIns.points = obj.Points__c;
                badgeIns.badgeAchieved = badgeAchievedFlag;
                if(badgeMap.containsKey(obj.Group__c)){
                    badgeMap.get(obj.Group__c).add(badgeIns);
                }
                else{
                    badgeMap.put(obj.Group__c,new List<badgeData>{badgeIns});
                }
            }  
        }
        
        for(String s:badgeMap.Keyset()){
            innerWrapper ins = new innerWrapper();
            ins.activityName = s;
            ins.badgeList = badgeMap.get(s);
            wrapperList.add(ins);
        }
        
        outerWrapper mainWrapper = new outerWrapper();
        mainWrapper.imgData = imageData;
        mainWrapper.data = wrapperList;
        return mainWrapper;
    }
    
    public class badgeData{
        @AuraEnabled
        public string badgeName{get;set;}
        @AuraEnabled
        public string badgeDescription{get;set;}
        @AuraEnabled
        public boolean badgeAchieved{get;set;}
        @AuraEnabled
        public Decimal points{get;set;}
        @AuraEnabled
        public Decimal minLevelPoints{get;set;}
        @AuraEnabled
        public Decimal maxLevelPoints{get;set;}
        @AuraEnabled
        public Decimal countNeeded{get; set;}
    }
    
    public class innerWrapper{
        @AuraEnabled
        public string activityName{get;set;}
        @AuraEnabled
        public List<badgeData> badgeList{get;set;}
    }
    
    public class outerWrapper{
        @AuraEnabled
        public string imgData{get;set;}
        @AuraEnabled
        public List<innerWrapper> data{get;set;}
    }
}