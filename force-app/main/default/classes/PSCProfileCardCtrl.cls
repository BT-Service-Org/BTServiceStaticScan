public with sharing class PSCProfileCardCtrl {
    
    @AuraEnabled(cacheable = true)
    public static ProfileCardWrapperOuter getProfileData(){
        rankWrapper levelWrapper = new rankWrapper();
        Map<String,Integer> articlesMap = new Map<String,Integer>();
        Id currentUserId = UserInfo.getUserId();
        String knowledgeArticleStatus = 'Online';
        
        Integer onlineArticlesCount = [SELECT count() 
                                        FROM Knowledge__kav 
                                        WHERE OwnerId =:currentUserId 
                                        AND PublishStatus = :knowledgeArticleStatus];        

        Integer reviewedArticlesCount = [SELECT count() 
                                        FROM Knowledge__kav 
                                        WHERE Reviewer__c =:currentUserId 
                                        AND PublishStatus = :knowledgeArticleStatus];

        Integer feedbacksGivenCount = [SELECT count() 
                                        FROM Article_Feedback__c 
                                        WHERE CreatedById =:currentUserId
                                        AND RecordType.DeveloperName = 'Feedback'];
        
        User user = [SELECT Id, Total_Points__c 
                    FROM User 
                    WHERE Id =:currentUserId]; 

        List<UserCompetencies__c> ucList = [SELECT Id,Level__r.Name,Total_Points__c,Badge_Count__c,Level__c,Level__r.Count_Needed__c,Current_Level_Completion_Percent__c
                                            ,Level__r.Min_Level_Points__c
                                            FROM UserCompetencies__c 
                                            WHERE User__c =: userinfo.getUserId()
                                            LIMIT 1];

        if(ucList != null && !ucList.isEmpty()){
            articlesMap.put('Points',Integer.valueOf(ucList[0].Total_Points__c!=null?ucList[0].Total_Points__c:0));
            levelWrapper.label = 'My Level';
            levelWrapper.value = String.ValueOf(ucList[0].Level__r?.Name); 
            levelWrapper.nextLevelPercent = ucList[0].Current_Level_Completion_Percent__c;
            levelWrapper.userPoints = ucList[0].Total_Points__c;
            
            List<Achievement__c> nextAchivementList = [SELECT Id,Min_Level_Points__c, Count_Needed__c, Max_Level_Points__c, Name 
                                                        FROM Achievement__c 
                                                        WHERE RecordType.DeveloperName = 'Level' 
                                                        AND Count_Needed__c > :ucList[0].Level__r.Count_Needed__c 
                                                        AND Min_Level_Points__c > :ucList[0].Level__r.Min_Level_Points__c 
                                                        ORDER BY Count_Needed__c ASC 
                                                        LIMIT 1];

            if(nextAchivementList != null && !nextAchivementList.isEmpty()){
                levelWrapper.nextLevelName = nextAchivementList[0].Name;
                
                levelWrapper.nextLevelBadgesRequired = (nextAchivementList[0].Count_Needed__c - ucList[0].Badge_Count__c > 0? nextAchivementList[0].Count_Needed__c - ucList[0].Badge_Count__c :0 );
                levelWrapper.nextLevelPointsRequired =(nextAchivementList[0].Min_Level_Points__c - ucList[0].Total_Points__c > 0? nextAchivementList[0].Min_Level_Points__c - ucList[0].Total_Points__c :0 ) ;
            }
        }
        
        articlesMap.put('Articles Published',onlineArticlesCount);
        articlesMap.put('Articles Reviewed',reviewedArticlesCount);
        articlesMap.put('Feedback Given',feedbacksGivenCount);
        
        List<articlesWrapper> artWrapperList = new List<articlesWrapper>();
        for(String s:articlesMap.keyset()){
            articlesWrapper artWrapper = new articlesWrapper();
            artWrapper.label = s;
            artWrapper.value = articlesmap.get(s);
            artWrapperList.add(artWrapper);
        }
        
        List<User_Achievement_Activity__c > uaaList = [SELECT Id,Achievement__r.Name
                                                       FROM User_Achievement_Activity__c
                                                       WHERE RecordType.DeveloperName = 'Award' 
                                                       AND User__c  =: currentUserId
                                                       AND Achievement__r.Active__c = true
                                                       AND Achievement__r.Points_Only_Award__c = false
                                                       ORDER BY Award_Date__c 
                                                       DESC, Activity_Count__c DESC LIMIT 3];
        
        List<badgeWrapper> badgeList = new List<badgeWrapper>();
        for(User_Achievement_Activity__c uaa:uaaList){
            badgeWrapper badges = new badgeWrapper();
            badges.label = uaa.Achievement__r.Name;
            badgeList.add(badges);
        }
        
        ProfileCardWrapperOuter outerWrapperList = new ProfileCardWrapperOuter();
        outerWrapperList.articlesData = artWrapperList;
        
        outerWrapperList.levelData = levelWrapper;
        outerWrapperList.badgeData = badgeList;
        outerWrapperList.imagePathData = PSCSettingService.getValue('psc_badge_images'); 
        return outerWrapperList;
        
    }
    
    public class articlesWrapper{
        @auraEnabled
        public String label{get;set;}
        @auraEnabled
        public Integer value{get;set;}
    }
    
    public class rankWrapper{
        @auraEnabled
        public String label{get;set;}
        @auraEnabled
        public String value{get;set;}
        @auraEnabled
        public String nextLevelName{get;set;}
        @auraEnabled
        public Decimal nextLevelPercent{get;set;}
        @auraEnabled
        public Decimal nextLevelPointsRequired{get;set;}
        @auraEnabled
        public Decimal nextLevelBadgesRequired{get;set;}
        @auraEnabled
        public Decimal userPoints{get;set;}
    }
    
    
    public class badgeWrapper{
        @auraEnabled
        public String label{get;set;}
        
    }
    
    public class ProfileCardWrapperOuter{
        @auraEnabled
        public List<articlesWrapper> articlesData{get;set;}
        @auraEnabled
        public rankWrapper levelData{get;set;}
        @auraEnabled
        public List<badgeWrapper> badgeData{get;set;}
        @AuraEnabled
        public String imagePathData{get;set;}
    }    
}