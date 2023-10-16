/**
 * 
 * @author anurag.suman
 * @since Sep 2023
 * @group Services Central
 */
public with sharing class PSCSkillsRatingCtrl {
    public static Id org62UserId;

    /**
     * 
     * @param careerProfileId 
     * @return  `SkillDataWrapper`
     */
    @AuraEnabled(cacheable=true)
    public static SkillDataWrapper getUserSkillsData(String careerProfileId){
        SkillDataWrapper sdwObj                                 = new SkillDataWrapper();
        List<Career_profile__c> cpList                          = new List<Career_profile__c>();

        List<Talent_Management__c> tmList = [SELECT Id,User__c,User__r.Org62Id__c,Career_Profile__c,Career_Expected__c,Career_Readiness__c,
                                            Career_Match_pct__c,Career_Match__c, User__r.Name
                                            FROM Talent_Management__c 
                                            WHERE User__r.IsActive = True 
                                            AND User__c =: UserInfo.getUserId()
                                            LIMIT 1];

        if(tmList != null && !tmList.isEmpty()){
            Talent_Management__c curUser = tmList[0];
            org62UserId = curUser.User__r.Org62Id__c;
            Id profileId;
            if(careerProfileId != null && careerProfileId != ''){
                if(careerProfileId == UserInfo.getUserId()){
                    profileId = curUser.Career_Profile__c;
                }
                else{
                    profileId = careerProfileId;
                }
            }
            else{
                profileId = curUser.Career_Profile__c;
            }

            cpList = careerProfileDataById(profileId);
            
            // Add a null check on cpList
            if(cpList != null && !cpList.isEmpty()){
                sdwObj = getSkillData(cpList);
                sdwObj.userName = curUser.User__r.Name;
            }
        }
        else{
            List<User> userList = [SELECT Id, Name, JobProfile__c, JobGrade__c, JobFamily__c, Org62Id__c
                                    FROM User WHERE 
                                    Id = :UserInfo.getUserId()
                                    LIMIT 1];

            if(careerProfileId != null && careerProfileId != ''){
                if(careerProfileId == UserInfo.getUserId()){
                    cpList = careerProfileDataByUserData(userList[0]);
                }
                else{
                    cpList = careerProfileDataById(careerProfileId);
                }
            }
            else{
                cpList = careerProfileDataByUserData(userList[0]);
            }

            org62UserId = userList[0].Org62Id__c;
            

            // Add a null check on cpList
            if(cpList != null && !cpList.isEmpty()){
                sdwObj = getSkillData(cpList);
                sdwObj.userName = userList[0].Name;
            }
        }
        return sdwObj;
    }

    private static List<Career_profile__c> careerProfileDataByUserData(User u){
        return [SELECT Id, Name, Career_Path_Group__c, Profile_Description__c,Key_Experiences__c, Career_Path__c, Job_Grade__c,
                                                (SELECT Id,Expected_Rating__c,Skill_Name__c,Skill_Group__c ,skill__r.External_Id__c, Career_Profile__c,
                                                skill_Type__c,skill_category__c,skill__r.Description__c,Skill__c
                                                FROM Leveling_Guides__r
                                                ORDER BY Skill_Group__c DESC,Skill_Name__c DESC),
                                                (SELECT Id,Next_Career_Profile__r.Career_Path__c,Next_Career_Profile__r.Name,Movement_Direction__c
                                                FROM Career_Movements1__r
                                                ORDER BY Movement_Direction__c ASC) 
                                            FROM Career_profile__c 
                                            WHERE Job_Grade__c = :u.JobGrade__c
                                            AND Career_Path_Group__c = :u.JobFamily__c
                                            AND Career_Path__c = :u.JobProfile__c
                                            LIMIT 1];
    }

    private static List<Career_profile__c> careerProfileDataById(Id profileId){
        return [SELECT Id, Name, Career_Path_Group__c, Profile_Description__c,Key_Experiences__c, Career_Path__c, Job_Grade__c,
                                                (SELECT Id,Expected_Rating__c,Skill_Name__c,Skill_Group__c ,skill__r.External_Id__c, Career_Profile__c,
                                                skill_Type__c,skill_category__c,skill__r.Description__c,Skill__c
                                                FROM Leveling_Guides__r
                                                ORDER BY Skill_Group__c DESC,Skill_Name__c DESC),
                                                (SELECT Id,Next_Career_Profile__r.Career_Path__c,Next_Career_Profile__r.Name,Movement_Direction__c
                                                FROM Career_Movements1__r
                                                ORDER BY Movement_Direction__c ASC) 
                                            FROM Career_profile__c 
                                            WHERE Id =: profileId
                                            LIMIT 1];
    }

    private static SkillDataWrapper getSkillData(List<Career_profile__c> cpList){
        SkillDataWrapper sdwObj                                                         = new SkillDataWrapper();
        Map<String,Map<String,Leveling_Guide__c>> mapOfGroupToMapOfIdToLevel            = new Map<String,Map<String,Leveling_Guide__c>>();
        Map<String,ProfileSkillUserTax__x> mapOfIdToUserSkill                           = new Map<String,ProfileSkillUserTax__x>();
        Set<Id> setOfUserSkillId                                                        = new Set<Id>();
        List<LevelingMapDataWrapper> lmdwList                                           = new List<LevelingMapDataWrapper>();
        List<Career_Movement__c> roleMvmntList                                          = new List<Career_Movement__c>();

        Integer levelingGuideCount = 0;
        Integer managerValidatedCount = 0;
        integer tmpProfileMatch = 0;
        
        for(Career_profile__c each:cpList){
            sdwObj.cpDetail = each;
            for(Leveling_Guide__c eachLG:each.Leveling_Guides__r){
                if(eachLG.skill__r.External_Id__c != null){
                    setOfUserSkillId.add(eachLG.skill__r.External_Id__c);
                    if(mapOfGroupToMapOfIdToLevel.containsKey(eachLG.Skill_Group__c)){
                        mapOfGroupToMapOfIdToLevel.get(eachLG.Skill_Group__c).put(eachLG.skill__r.External_Id__c,eachLG);
                    }
                    else{
                        mapOfGroupToMapOfIdToLevel.put(eachLG.Skill_Group__c, new Map<String,Leveling_Guide__c>{eachLG.skill__r.External_Id__c=>eachLG});
                    }
                }                           
                levelingGuideCount++;
            }
            if(each.Career_Movements1__r != null && !each.Career_Movements1__r.isEmpty()){
                roleMvmntList.addAll(each.Career_Movements1__r);
            }
        }

        sdwObj.roleMovement = roleMvmntList;

        List<ProfileSkillUserTax__x> rateList = new List<ProfileSkillUserTax__x>();
        try{
            rateList = [SELECT ProfileSkillId__c,Expertise_Rating_c__c,Expertise_Certified__c
                                                    FROM ProfileSkillUserTax__x
                                                    WHERE UserId__c = :org62UserId
                                                    AND ProfileSkillId__c IN :setOfUserSkillId];
        }
        catch(exception e){
            System.debug(e);
        }
        
        for(ProfileSkillUserTax__x each:rateList){
            mapOfIdToUserSkill.put(each.ProfileSkillId__c,each);
        }

        for(String eachGroup:mapOfGroupToMapOfIdToLevel.keyset()){
            List<LevelingDataWrapper> ldwList                       = new List<LevelingDataWrapper>();
            LevelingMapDataWrapper lmdwObj = new LevelingMapDataWrapper();
            lmdwObj.skillGroup = eachGroup;
            for(String eachSkillId:mapOfGroupToMapOfIdToLevel.get(eachGroup).keyset()){
                LevelingDataWrapper ldw = new LevelingDataWrapper();
                ldw.tgtLevel = Integer.valueOf(mapOfGroupToMapOfIdToLevel.get(eachGroup).get(eachSkillId).Expected_Rating__c);
                ldw.label = mapOfGroupToMapOfIdToLevel.get(eachGroup).get(eachSkillId).Skill_Name__c;
                ldw.skillId = mapOfGroupToMapOfIdToLevel.get(eachGroup).get(eachSkillId).Skill__c;
                ldw.curLevel = 0;   //  Default Value
                ldw.validated = false; //  Default Value
                if(mapOfIdToUserSkill.containsKey(eachSkillId)){
                    String strRate = mapOfIdToUserSkill.get(eachSkillId).Expertise_Rating_c__c;
                    if( strRate == '' ) {
                        strRate = '0';
                    }
                    Integer rating = Integer.ValueOf( strRate.left( 1 ) );
                    ldw.curLevel = rating;
                    if(rating>=Integer.valueOf(mapOfGroupToMapOfIdToLevel.get(eachGroup).get(eachSkillId).Expected_Rating__c)){
                        tmpProfileMatch++;
                    }
                    ldw.validated = mapOfIdToUserSkill.get(eachSkillId).Expertise_Certified__c;
                    if(mapOfIdToUserSkill.get(eachSkillId).Expertise_Certified__c){
                        managerValidatedCount++;
                    }
                }
                ldwList.add(ldw);
            }
            lmdwObj.ldwList = ldwList;
            lmdwList.add(lmdwObj);
        }

        Double careerMatchPct = 0;
        String careerRediness = '';
        if( levelingGuideCount == 0 ) {
            careerMatchPct = 0;
            careerRediness = 'No leveling guide available'; 
        }
        else {
            careerMatchPct = 100 * (double) tmpProfileMatch / levelingGuideCount; 
            if(careerMatchPct >= 80 ){
                careerRediness = 'High Ready';
            }
            else{
                if(careerMatchPct < 50 ){
                    careerRediness = 'Low Ready';
                }  
                else{
                    careerRediness = 'Medium Ready';
                }   
            } 
        }

        sdwObj.displaySkillWarning = false;
        if(levelingGuideCount>0){
            if((rateList.size()/levelingGuideCount)*100 >= Integer.valueOf(pscSettings__mdt.getInstance('TM_Min_Skill_Percent').Value__c)){
                sdwObj.displaySkillWarning = false;
            }
            else{
                sdwObj.displaySkillWarning = true;
                sdwObj.displaySkillWarningHeader = pscSettings__mdt.getInstance('TM_Min_Skill_Toast_Text_Header').Value__c;
                sdwObj.displaySkillWarningBody = pscSettings__mdt.getInstance('TM_Min_Skill_Toast_Text_Body').Value__c;
            }
        }
        else{
            sdwObj.displaySkillWarning = false;
        }
        

        sdwObj.skillReadiness = careerRediness;
        sdwObj.totalSkillsMatchCount = tmpProfileMatch;
        sdwObj.totalSkillsCount = levelingGuideCount;
        sdwObj.careerMatchPct = careerMatchPct;
        sdwObj.lmdwList = lmdwList;
        sdwObj.managerValidatedCount = managerValidatedCount;
        sdwObj.skillInsightsLink = Url.getOrgDomainUrl().toExternalForm()+'/lightning/n/Talent_Management';

        return sdwObj;
    }

    /**
     * 
     * @param skillId 
     * @return  `List<Learning_Resource_Skill__c>`
     */
    @AuraEnabled(cacheable=true)
    public static List<CSGProfileSkill__c> getLearningResourceData(String skillId){
        List<CSGProfileSkill__c> csgSkillList = [SELECT Id, Name,
                                                    (SELECT Id,Learning_Resource__r.Link__c,Learning_Resource__r.Name,Learning_Resource__r.Duration__c,
                                                    Learning_Resource__r.Description__c
                                                    FROM Learning_Resources_Skills__r)
                                                FROM CSGProfileSkill__c
                                                WHERE Id =: skillId
                                                LIMIT 1];

        return csgSkillList;
    }


    public class SkillDataWrapper{
        @auraEnabled
        public Talent_Management__c talentMgmtDetail{get;set;}
        @auraEnabled
        public Career_profile__c cpDetail{get;set;}
        @auraEnabled
        public List<LevelingMapDataWrapper> lmdwList{get;set;}
        @auraEnabled
        public boolean displaySkillWarning{get;set;}
        @auraEnabled
        public String displaySkillWarningHeader{get;set;}
        @auraEnabled
        public String displaySkillWarningBody{get;set;}
        @auraEnabled
        public Integer totalSkillsMatchCount{get;set;}
        @auraEnabled
        public Integer totalSkillsCount{get;set;}
        @auraEnabled
        public String skillReadiness{get;set;}
        @auraEnabled
        public Double careerMatchPct{get;set;}
        @auraEnabled
        public List<Career_Movement__c> roleMovement{get;set;}
        @auraEnabled
        public Double managerValidatedCount{get;set;}
        @auraEnabled
        public String skillInsightsLink{get;set;}
        @auraEnabled
        public String userName{get;set;}

    }

    public class LevelingDataWrapper{
        @auraEnabled
        public Integer curLevel{get;set;}
        @auraEnabled
        public Integer tgtLevel{get;set;}
        @auraEnabled
        public String label{get;set;}
        @auraEnabled
        public Boolean validated{get;set;}
        @auraEnabled
        public String skillId{get;set;}
    }

    public class LevelingMapDataWrapper{
        @auraEnabled
        public String skillGroup{get;set;}
        @auraEnabled
        public List<LevelingDataWrapper> ldwList{get;set;}
    }
}