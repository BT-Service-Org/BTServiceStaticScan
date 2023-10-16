/**
Class Name      : SkillsEntryController
@description    : This is the controller class for the skills lwc component
*/
public with sharing class SkillsEntryController {
    public static Integer size = 10;
    public static final string ARCHIVE_EXCLUDED_SKILL = Label.Skill_Archived_String+'%';
    public static User userRecord = [Select id,name,profileId,AboutMe,Title,Manager.Name,JobFamily__c from user where id=:userinfo.getUserId()];
    public static final string SKILL_NONE_RATING = Label.CSG_None_Skill_Rating;
    public static String onboardingRecordId ;
    private static Map<String, TreeStructure> result;
    private static Map<Id, Id> childIdMap;
   
    /**
    @description : This checks for the Permission set assignment for logged in user
    @return      : Map<object,object>
    */
    @AuraEnabled(cacheable=true)  
    public static Map<object,object> loadDefaults()    { 
        Map<Object,Object> defaultConfigsMap = new Map<Object,Object>();
        List<CSG_Group__c> csgGrps = getAvailableGroups();
        defaultConfigsMap.put('csgGrps',csgGrps);
        defaultConfigsMap.put('batchButtonEnabled',checkBatchTriggerPermission());
        defaultConfigsMap.put('picklistWrapperList',getpicklistValues());
        defaultConfigsMap.put('userinfo',userRecord);
	defaultConfigsMap.put('picklistWrapperListNone',getpicklistValuesNone());
        return defaultConfigsMap;
        
    }
    /**
    @description : This checks for the Permission set assignment for logged in user
    @return      : Map<object,object>
    */
    @AuraEnabled
    public static Map<object,object> loadParentDefaults()    { 
        Map<Object,Object> defaultConfigsMap = new Map<Object,Object>();
        
        defaultConfigsMap.put('batchButtonEnabled',isSuperAdmin());
        
        defaultConfigsMap.put('userinfo',userRecord);
        defaultConfigsMap.put('focusareaStr',getFocusAreas());
        defaultConfigsMap.put('onboardingRecordId',onboardingRecordId);
        defaultConfigsMap.put('isManagerOrAdmin',(isManager() || isSuperAdmin() || isDelegate()));
        defaultConfigsMap.put('isManager',isManager());
        defaultConfigsMap.put('isDelegate',isDelegate());
        
        return defaultConfigsMap;
        
    }
    /**
     @description : This method invokes batch job for Skills Taxonomy update in Services Org
     
     */
    @AuraEnabled 
    public static void invokeSkillsBatchJob()
    {
        Database.executebatch(new CSG_SkillsTaxonomySyncBatch(),200);
        
    } 
    /**
      @description : This checks for the Permission set assignment for logged in user
      @return      : Boolean
     */
    @AuraEnabled(cacheable=true)  
    public static Boolean checkBatchTriggerPermission(){ 
        
        //if(FeatureToggleService.getFeatureState('SkillsTaxonomyBatchEnabled')){
        
            //Check for profile in hierarchy custom setting       
        Update_Skills_Taxonomy_Permission__c updatePermission = Update_Skills_Taxonomy_Permission__c.getInstance(userRecord.ProfileId);
        if(updatePermission !=null && updatePermission.id != null)
        { 
            return true; 
        }   
        //Check for Current user in hierarchy custom setting
        updatePermission = Update_Skills_Taxonomy_Permission__c.getInstance(userRecord.Id);
        if(updatePermission !=null && updatePermission.id != null)
        { 
            return true; 
        }   
        //}
        return false;
    } 
    /**
      @description : This method returns the currect user
      @return : <User>
     */
    public static User getUser(){
        if(Test.isRunningTest()) {
            String hostname = '@sfservices.com.qa';//swap out for prod
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User user = new User(
                Alias = uid,
                Email= uid + hostname, 
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/New_York',
                UserName= uid + hostname
            );
            return user;
        }
        User user = [select Id, Org62Id__c, Profile.Name, Profile.PermissionsModifyAllData from User where id = :Userinfo.getUserId()];
        return user;
    }
    /**
     @description : This method to return a list of available groups for group drop down
     @return : List<CSG_Group__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<CSG_Group__c> getAvailableGroups(){
        List<CSG_Group__c> groupList = [ SELECT Id, Name FROM CSG_Group__c WITH SECURITY_ENFORCED ORDER BY Name ASC ];
        return groupList;
    }
    /**
     @description : Gets the skills attributed to user by group
     @return : List<UserSkillWrapper>
     @param userId - String
     @param groupName - String
     */
    @AuraEnabled
    public static List<UserSkillWrapper> getUserGroupSkillsList(String userId, String groupName) {
        String orgUserId = getUser().Org62Id__c;
        //get list of skills associated to a group, uses the local junction object
        List<CSG_Group_Skill__c> groupSkillsList = [SELECT Id, CSGProfileSkill__r.Id, CSGProfileSkill__r.External_Id__c, CSGProfileSkill__r.Name, CSGProfileSkill__r.Description__c, CSGProfileSkill__r.Type__c, CSGProfileSkill__r.Category__c FROM CSG_Group_Skill__c WHERE 
	(CSG_Group__r.Name = :groupName 
        OR CSG_Group__r.Level_1__c =:groupName  OR    CSG_Group__r.Level_2__c =:groupName OR    CSG_Group__r.Level_3__c =:groupName)
        AND   (NOT CSGProfileSkill__r.Name like :ARCHIVE_EXCLUDED_SKILL) WITH SECURITY_ENFORCED ORDER BY CSGProfileSkill__r.Type__c, CSGProfileSkill__r.Category__c ASC];
        //get list of skills already assigned to the user, if 
        List<ProfileSkillUserTax__x> userSkills = new List<ProfileSkillUserTax__x>();
        //create list that will be returned to 
        List<UserSkillWrapper> userSkillWrapperList = new List<UserSkillWrapper>();
        //create map to filter out skills user has, needed external id in key - wy I didnt load directly using SOQL
        Map<Id,CSG_Group_Skill__c> newCSGGroupSkillMap = new MAP<Id, CSG_Group_Skill__c>();
        for(CSG_Group_Skill__c groupSkill : groupSkillsList){
            newCSGGroupSkillMap.put(groupSkill.CSGProfileSkill__r.External_Id__c, groupSkill);
        }
        if(Test.isRunningTest()) {
            //need to create some dummy userSkills - testing did not like EOs
            userSkills.add(new ProfileSkillUserTax__x(
                Expertise_Rating_c__c = '4- Specialist'
            ));
            
        } else {
		   if(String.isnotblank(orgUserId)){ 
			userSkills = [SELECT Id, Aspirational_Skill__c,Expertise_Rating_c__c,Expertise_Certified__c, UserId__c, ProfileSkillId__r.Id, ProfileSkillId__r.ExternalId, ProfileSkillId__r.Name__c, ProfileSkillId__r.Type_c__c, ProfileSkillId__r.Description__c, ProfileSkillId__r.Category_c__c, ProfileSkillId__r.Last_Modified_Date__c,Skill_Rating_Last_Update__c FROM ProfileSkillUserTax__x WHERE UserId__c = :orgUserId 
				   WITH SECURITY_ENFORCED];
		   }
        }
        String csgSkillId;
        //get user skills based on group skill list, remove skills from group skill list so we dont show twice if you already have the skill
        for(ProfileSkillUserTax__x userSkill: userSkills){
           if(newCSGGroupSkillMap.containsKey(userSkill.ProfileSkillId__r.ExternalId)
              && (!userSkill.ProfileSkillId__r.Name__c.contains(Label.Skill_Archived_String))
             ){
            if(newCSGGroupSkillMap.containsKey(userSkill.ProfileSkillId__r.ExternalId)){
                csgSkillId = newCSGGroupSkillMap.get(userSkill.ProfileSkillId__r.ExternalId).CSGProfileSkill__r.Id;
                newCSGGroupSkillMap.remove(userSkill.ProfileSkillId__r.ExternalId);
            }
            UserSkillWrapper userwpr = new UserSkillWrapper(userSkill);
            userwpr.skillViewId = csgSkillId;
            
            userSkillWrapperList.add(userwpr);
        }
               
        }
        //now that we've reduced groupSkillList we need to add any skills users may not have to the final list
        for (Id key : newCSGGroupSkillMap.keySet()) {
            // The "key" variable is also available inside the loop
            userSkillWrapperList.add(new UserSkillWrapper(newCSGGroupSkillMap.get(key)));
        }
        
        return userSkillWrapperList;
    }

     /**
     @description : Gets the skills attributed to user by group
     @return : List<UserSkillWrapper>
     @param userId - String
     */
    @AuraEnabled
    public static List<UserSkillWrapper> getAllUserSkillsList(String userId) {
        String orgUserId = getUser().Org62Id__c;
        List<ProfileSkillUserTax__x> userSkills = new List<ProfileSkillUserTax__x>();
		PA_Onboarding__c onboardingRecord = new PA_Onboarding__c();
        Set<String> skillExIds = new Set<String>();
        Map<String,CSGProfileSkill__c> csgSkillMap = new Map<String,CSGProfileSkill__c>();
        try{
            onboardingRecord = [SELECT Id,Industry_Focus__c,Product_Focus__c,Discipline__c, Last_Profile_Skills_Update__c FROM PA_Onboarding__c WHERE Candidate__c =:Userinfo.getUserId()  LIMIT 1];
        }Catch(Exception ex){
            Logger.error(ex.getMessage());
            Logger.saveLog(); 
        }
        //get list of skills already assigned to the user
        if(Test.isRunningTest()) {
            //need to create some dummy userSkills - testing did not like EOs
            userSkills.add(new ProfileSkillUserTax__x(
                Expertise_Rating_c__c = '4- Specialist'
            ));
            
        } else {
		if(String.isnotblank(orgUserId)){ 
                
                userSkills = [SELECT Id,Aspirational_Skill__c,Expertise_Certified__c, Expertise_Rating_c__c, UserId__c, ProfileSkillId__r.Id, ProfileSkillId__r.ExternalId, ProfileSkillId__r.Name__c, ProfileSkillId__r.Type_c__c, ProfileSkillId__r.Description__c, ProfileSkillId__r.Category_c__c,Skill_Rating_Last_Update__c 
                              FROM ProfileSkillUserTax__x 
                              WHERE UserId__c = :orgUserId AND  (NOT ProfileSkillId__r.Name__c like :ARCHIVE_EXCLUDED_SKILL)];//add logic by user
		}
	}
        for(ProfileSkillUserTax__x userSkill1: userSkills){
            skillExIds.add(userSkill1.ProfileSkillId__r.ExternalId);
        }
        for(CSGProfileSkill__c csg1:[SELECT Id,External_Id__c, Name FROM CSGProfileSkill__c WHERE External_Id__c IN :skillExIds WITH SECURITY_ENFORCED]){
            csgSkillMap.put(csg1.External_Id__c, csg1);
        }
        //create list that will be returned to 
        List<UserSkillWrapper> userSkillWrapperList = new List<UserSkillWrapper>();
        Set<String> industrySet = New Set<String>();
        Set<String> productSet = New Set<String>();
         for(ProfileSkillUserTax__x userSkill: userSkills){
            UserSkillWrapper userwpr = new UserSkillWrapper(userSkill);
         
            IF(!string.isBlank(onboardingRecord.Industry_Focus__c)){
            
            	industrySet.addAll(onboardingRecord.Industry_Focus__c.split(';'));  
            }
            IF(!string.isBlank(onboardingRecord.Product_Focus__c)){
                
            	productSet.addAll(onboardingRecord.Product_Focus__c.split(';'));  
            }
            
            if(userSkill.ProfileSkillId__r.Category_c__c != null
               && 
               (onboardingRecord.Industry_Focus__c != null  && industrySet.contains(userSkill.ProfileSkillId__r.Category_c__c)
                ||
                onboardingRecord.Product_Focus__c != null && productSet.contains(userSkill.ProfileSkillId__r.Category_c__c)
               
               )
              ){
                userwpr.focusSkill = TRUE;
              }
            if(csgSkillMap.get(userSkill.ProfileSkillId__r.ExternalId) != null){
            	userwpr.skillViewId = csgSkillMap.get(userSkill.ProfileSkillId__r.ExternalId).Id;
        }            
            userSkillWrapperList.add(userwpr);
        }  
         
        return userSkillWrapperList;
    }
     /**
     @description : Gets a list of all skills the user can choose from
     @return : List<UserSkillWrapper>
     */
    @AuraEnabled
    public static List<UserSkillWrapper> getAllSkillsList() {
        String orgUserId = getUser().Org62Id__c;
        List<ProfileSkillUserTax__x> userSkills = new List<ProfileSkillUserTax__x>();
        List<UserSkillWrapper> userSkillWrapperList = new List<UserSkillWrapper>();
        Map<Id,CSGProfileSkill__c> skillslMap = new MAP<Id, CSGProfileSkill__c>();
        Map<Id,ProfileSkillUserTax__x> userSkillslMap = new MAP<Id, ProfileSkillUserTax__x>();
        //get list of all skills in skills database
        List<CSGProfileSkill__c> skills = [SELECT Id, External_Id__c, Name, Type__c, Description__c, Category__c FROM CSGProfileSkill__c where (NOT Name like :ARCHIVE_EXCLUDED_SKILL) WITH SECURITY_ENFORCED];//
        if(Test.isRunningTest()) {
            //need to create some dummy userSkills - testing did not like EOs
            userSkills.add(new ProfileSkillUserTax__x(
                Expertise_Rating_c__c = '4- Specialist'
            ));
            
        } else {
		if(String.isnotblank(orgUserId)){ 
		    userSkills = [SELECT Id,Aspirational_Skill__c, Expertise_Rating_c__c,Expertise_Certified__c, UserId__c, ProfileSkillId__r.Id, ProfileSkillId__r.ExternalId, ProfileSkillId__r.Name__c, ProfileSkillId__r.Type_c__c, ProfileSkillId__r.Description__c, ProfileSkillId__r.Category_c__c ,Skill_Rating_Last_Update__c
				  FROM ProfileSkillUserTax__x WHERE UserId__c = :orgUserId AND (NOT ProfileSkillId__r.Name__c like :ARCHIVE_EXCLUDED_SKILL) WITH SECURITY_ENFORCED ];
		}
	}
        //create list that will be returned to 
        for(CSGProfileSkill__c skill : skills){
            skillslMap.put(skill.External_Id__c, skill);
        }

        for(ProfileSkillUserTax__x userSkill : userSkills){
            userSkillslMap.put(userSkill.ProfileSkillId__r.ExternalId, userSkill);
        }
        String csgSkillId;
        for (Id key : skillslMap.keySet()) {
            if(userSkillslMap.containsKey(key)){
                csgSkillId = skillslMap.get(key).Id;
                skillslMap.remove(key);
                UserSkillWrapper uswpr = new UserSkillWrapper(userSkillslMap.get(key));
                uswpr.skillViewId = csgSkillId;
                userSkillWrapperList.add(uswpr);
                
            } else {
                userSkillWrapperList.add(new UserSkillWrapper(skillslMap.get(key)));
            }
        }                   
        return userSkillWrapperList;
    }

     /**
     @description : Gets the list of subordinates skills
     @return : List<UserSkillWrapper>
     */
    @AuraEnabled
    public static List<UserSkillWrapper> getMyTeamSkillsList() {
        List<UserSkillWrapper> userSkillWrapperList = new List<UserSkillWrapper>();
        List<ProfileSkillUserTax__x> userSkills = new List<ProfileSkillUserTax__x>();
        set<string> org62ids = new set<string>();
        Set<String> skillExIds = new Set<String>();
        Map<String,CSGProfileSkill__c> csgSkillMap = new Map<String,CSGProfileSkill__c>();
        Map<String,PA_Onboarding__c> onboardingMap = new Map<String,PA_Onboarding__c>();
        List<User> directSubordinates = [select id,Name,Org62Id__c from user where managerid=:Userinfo.getUserId() AND isactive = TRUE];
        Map<string,User> org62IdvsUser = new Map<string,User>(); 
        for(User u : directSubordinates){
            if(String.isNotblank(u.Org62Id__c)){
                org62ids.add(u.Org62Id__c);
                if(!org62IdvsUser.containsKey(u.Org62Id__c)){
                    org62IdvsUser.put(u.Org62Id__c,u);
                } 
            }
            
        }
	if(!org62ids.isEmpty()){ 
        	userSkills = [SELECT Id, Aspirational_Skill__c,Expertise_Rating_c__c,Expertise_Certified__c, UserId__c, ProfileSkillId__r.Id, ProfileSkillId__r.ExternalId, ProfileSkillId__r.Name__c, ProfileSkillId__r.Type_c__c, ProfileSkillId__r.Description__c, ProfileSkillId__r.Category_c__c,Skill_Rating_Last_Update__c FROM ProfileSkillUserTax__x WHERE UserId__c = :org62ids AND (NOT ProfileSkillId__r.Name__c like :ARCHIVE_EXCLUDED_SKILL) WITH SECURITY_ENFORCED];
	}
		if(Test.isRunningTest()) {
            //need to create some dummy userSkills - testing did not like EOs
            userSkills.add(new ProfileSkillUserTax__x(
                Expertise_Rating_c__c = '4- Specialist', UserId__c= Userinfo.getUserId()));
            
        }        
        List<PA_Onboarding__c> onboardingRecList = [SELECT Candidate__c,Industry_Focus__c,Product_Focus__c,Discipline__c, Last_Profile_Skills_Update__c FROM PA_Onboarding__c WHERE Candidate__c IN:directSubordinates];
        for(PA_Onboarding__c paRec: onboardingRecList){
            onboardingMap.put(paRec.Candidate__c, paRec);
        }
        for(ProfileSkillUserTax__x userSkill1: userSkills){
            skillExIds.add(userSkill1.ProfileSkillId__r.ExternalId);
        }
        for(CSGProfileSkill__c csg1:[SELECT Id,External_Id__c, Name FROM CSGProfileSkill__c WHERE External_Id__c IN :skillExIds WITH SECURITY_ENFORCED]){
            csgSkillMap.put(csg1.External_Id__c, csg1);
        }
        Set<String> industrySet = New Set<String>();
	Set<String> productSet = New Set<String>();
         for(ProfileSkillUserTax__x profile : userSkills){
             UserSkillWrapper uswpr = new UserSkillWrapper(profile,org62IdvsUser);
             if(csgSkillMap.get(profile.ProfileSkillId__r.ExternalId) != null){
            	uswpr.skillViewId = csgSkillMap.get(profile.ProfileSkillId__r.ExternalId).Id;
        }
            PA_Onboarding__c paRec = new PA_Onboarding__c();
            if(Test.isRunningTest()){
                paRec = new PA_Onboarding__c(Industry_Focus__c = 'Financial Services',Product_Focus__c = 'Industry Clouds',Operating_Unit_Focus__c = 'ANZ Australia, New Zealand');
            }else{
            String userid = org62IdvsUser.get(profile.UserId__c).Id;
                paRec = onboardingMap.get(userid);
            }
            if(!string.isBlank(paRec.Industry_Focus__c)){
            
                industrySet.addAll(paRec.Industry_Focus__c.split(';'));  
            }
            if(!string.isBlank(paRec.Product_Focus__c)){
                
                productSet.addAll(paRec.Product_Focus__c.split(';'));  
            }
          
             if(paRec != null && profile.ProfileSkillId__r.Category_c__c != null
               && 
               (paRec.Industry_Focus__c != null  && industrySet.contains(profile.ProfileSkillId__r.Category_c__c)
                ||
                paRec.Product_Focus__c != null && productSet.contains(profile.ProfileSkillId__r.Category_c__c)
               
               )
              ){
                uswpr.focusSkill = TRUE;
              }
            
             userSkillWrapperList.add(uswpr);
           
        }
       
        return userSkillWrapperList;
    }    
     /**
     @description : Gets the list of subordinates skills
     @return : List<UserSkillWrapper>
     */
    @AuraEnabled
    public static List<UserSkillWrapper> getMyDelegatedTeamSkills() {
        List<UserSkillWrapper> userSkillWrapperList = new List<UserSkillWrapper>();
        try{
        List<ProfileSkillUserTax__x> userSkills = new List<ProfileSkillUserTax__x>();
        set<string> org62ids = new set<string>();
            Map<string,User> org62IdvsUser = new Map<string,User>();
        	Set<String> skillExIds = new Set<String>();
        	Map<String,CSGProfileSkill__c> csgSkillMap = new Map<String,CSGProfileSkill__c>();
            Map<String,PA_Onboarding__c> onboardingMap = new Map<String,PA_Onboarding__c>();
            List<User> managerRecs = [SELECT Managerid FROM user WHERE Skills360_Delegated_Approver__c=:Userinfo.getUserId() AND isactive = TRUE];
            List<User> directSubordinates = [SELECT Name,Org62Id__c FROM user WHERE managerid=: managerRecs AND isactive = TRUE];
 
        for(User u : directSubordinates){
            if(String.isNotblank(u.Org62Id__c)){
                org62ids.add(u.Org62Id__c);
                if(!org62IdvsUser.containsKey(u.Org62Id__c)){
                    org62IdvsUser.put(u.Org62Id__c,u);
                }
            }
        }
	if(!org62ids.isEmpty()){ 
        	userSkills = [SELECT Id, Aspirational_Skill__c,Expertise_Rating_c__c,Expertise_Certified__c, UserId__c, ProfileSkillId__r.Id, ProfileSkillId__r.ExternalId, ProfileSkillId__r.Name__c, ProfileSkillId__r.Type_c__c, ProfileSkillId__r.Description__c, ProfileSkillId__r.Category_c__c,Skill_Rating_Last_Update__c FROM ProfileSkillUserTax__x WHERE UserId__c = :org62ids AND (NOT ProfileSkillId__r.Name__c like :ARCHIVE_EXCLUDED_SKILL) WITH SECURITY_ENFORCED];   
	}
            if(Test.isRunningTest()) {
                //need to create some dummy userSkills - testing did not like EOs
                userSkills.add(new ProfileSkillUserTax__x(
                    Expertise_Rating_c__c = '4- Specialist'
                ));
            
        	}
            List<PA_Onboarding__c> onboardingRecList = [SELECT Candidate__c,Industry_Focus__c,Product_Focus__c,Discipline__c, Last_Profile_Skills_Update__c FROM PA_Onboarding__c WHERE Candidate__c IN:directSubordinates];
            for(PA_Onboarding__c paRec: onboardingRecList){
                onboardingMap.put(paRec.Candidate__c, paRec);
            }
            for(ProfileSkillUserTax__x userSkill1: userSkills){
            	skillExIds.add(userSkill1.ProfileSkillId__r.ExternalId);
            }
            for(CSGProfileSkill__c csg1:[SELECT Id,External_Id__c, Name FROM CSGProfileSkill__c WHERE External_Id__c IN :skillExIds WITH SECURITY_ENFORCED]){
                csgSkillMap.put(csg1.External_Id__c, csg1);
            }
            Set<String> industrySet = New Set<String>();
			Set<String> productSet = New Set<String>();
        for(ProfileSkillUserTax__x profile : userSkills){
                 UserSkillWrapper uswpr = new UserSkillWrapper(profile,org62IdvsUser);
                 if(csgSkillMap.get(profile.ProfileSkillId__r.ExternalId) != null){
                    uswpr.skillViewId = csgSkillMap.get(profile.ProfileSkillId__r.ExternalId).Id;
                 }
                PA_Onboarding__c paRec = new PA_Onboarding__c();
                if(Test.isRunningTest()){
                	paRec = new PA_Onboarding__c(Industry_Focus__c = 'Financial Services',Product_Focus__c = 'Industry Clouds',Operating_Unit_Focus__c = 'ANZ Australia, New Zealand');
                }else{
                String userid = org62IdvsUser.get(profile.UserId__c).Id;
                	paRec = onboardingMap.get(userid);
                }
                
                IF(!string.isBlank(paRec.Industry_Focus__c)){
                    
                    industrySet.addAll(paRec.Industry_Focus__c.split(';'));  
                }
                IF(!string.isBlank(paRec.Product_Focus__c)){
                    
                    productSet.addAll(paRec.Product_Focus__c.split(';'));  
                }
               
             if(paRec != null && profile.ProfileSkillId__r.Category_c__c != null
               && 
                   (paRec.Industry_Focus__c != null  && industrySet.contains(profile.ProfileSkillId__r.Category_c__c)
                ||
                    paRec.Product_Focus__c != null && productSet.contains(profile.ProfileSkillId__r.Category_c__c)
                    )
               )
              {
                uswpr.focusSkill = TRUE;
              }
                 userSkillWrapperList.add(uswpr);
                 
        }
        }Catch(Exception ex){
            Logger.error(ex.getMessage());
            Logger.saveLog(); 
           
        }
        
        return userSkillWrapperList;
    } 
    /**
    Class Name      : SaveCallback
    @description    : This is a callback class
    */
    public class SaveCallback extends DataSource.AsyncSaveCallback{
        
        override public void processSave(Database.SaveResult sr) {
            Skills_Entry_Event__e skillEntryEvent = new Skills_Entry_Event__e();
            String errorMessage = '';
            
            if (sr.isSuccess()){
                skillEntryEvent.Save_Response_Id__c = sr.getId();
                EventBus.publish(skillEntryEvent);
            } else {
                //look to add event with a status code and show error toaster
                for(Database.Error err : sr.getErrors()) {
                    
                    Logger.error(err.getMessage());
                    errorMessage = err.getMessage();
                    skillEntryEvent.Save_Response_Id__c = 'fail';
                    skillEntryEvent.Response_Message__c = errorMessage;
                    EventBus.publish(skillEntryEvent);
                }
                Logger.saveLog(); 
            }
        }
    }
     /**
    @description : Enhancement request - Add method to update PA Onboarding record with timestamp when skills are added/udpated.     
    @param userSet - List<String>
    */
    @AuraEnabled
    public static void updatePAOnboardingRecord(List<String> userSet) {
        PA_Onboarding__c onboardingRecord = new PA_Onboarding__c();
        List<PA_Onboarding__c> updateList = new List<PA_Onboarding__c>();
        try {
            if(userSet == null || userSet.isEmpty()){
                onboardingRecord = [SELECT Id, Last_Profile_Skills_Update__c FROM PA_Onboarding__c WHERE Candidate__c = :Userinfo.getUserId() LIMIT 1];
                onboardingRecord.Last_Profile_Skills_Update__c = DateTime.now();
                
                updateList.add(onboardingRecord);
            }
            else{
                for(PA_Onboarding__c pao:[SELECT Candidate__c,Last_Profile_Skills_Update__c FROM PA_Onboarding__c WHERE Candidate__c IN :userSet]){               
                    pao.Last_Profile_Skills_Validated__c = DateTime.now();
                    updateList.add(pao);
                }
            }
            if(!updateList.isEmpty()){
                update updateList;
            }
            
        }
        catch (DmlException e) {
            Logger.error('Sorry, we had an issue updating the Onboarding record' + e.getMessage());
            Logger.saveLog(); 
            
        }
    }

    /**
     @description : Enhancement request - Add method to support Mass Skills Delete functionality.     
     @return : String
     @param skillRecsToDelete - List<String>
     * UserStory :  W-10673605  
    */
    @AuraEnabled
    public static String deleteRecords(List<String> skillRecsToDelete) {
        Map<String,String> resultMap = new Map<String,String>();
        Integer noOfRecsProcessed = 0;
        try{
            
            List<Sobject> skillsListToDelete = [Select id from ProfileSkillUserTax__x where id in:skillRecsToDelete WITH SECURITY_ENFORCED];
            if(skillsListToDelete!=null && !skillsListToDelete.isEmpty()) {
                List<Database.DeleteResult >  dsList =  Database.deleteImmediate(skillsListToDelete);
                for(Database.DeleteResult dr :  dsList){
                    if(dr.isSuccess()){ 
                        noOfRecsProcessed ++;
                    }
                } 
            }
            resultMap.put('Success',String.valueOf(noOfRecsProcessed));         
        }
        catch(Exception e){
            resultMap.put('Error',Label.Skill_Delete_Error);
        }
        return JSON.serialize(resultMap);
    }

    /**
     @description : Enhancement request - Add method to support Mass Skills Validate functionality.     
      @return : String
      @param recordsMap - Map<String,Boolean>
      @param isRemoveValidate - Boolean
     * UserStory :   W-10747538   
    */
    @AuraEnabled
    public static String validateExpertiseRecords(Map<String,Boolean> recordsMap, Boolean isRemoveValidate) {
        Map<String,String> resultMap = new Map<String,String>();
        Integer noOfRecsProcessed = 0;
        List<ProfileSkillUserTax__x> results = new List<ProfileSkillUserTax__x>();
        try{          
            for(string userskill : recordsMap.keySet()){
                if(isRemoveValidate){
                    results.add(new ProfileSkillUserTax__x(id=userskill,Expertise_Certified__c=false));
                }else{
                 results.add(new ProfileSkillUserTax__x(id=userskill,Expertise_Certified__c=true));        
            }
            }
            if(!results.isEmpty()) {
                List<Database.SaveResult>  dsList =  Database.updateImmediate(results);
                for(Database.SaveResult dr :  dsList){
                    if(dr.isSuccess()){ 
                        noOfRecsProcessed ++;
                    }
                } 
                resultMap.put('Success',String.valueOf(noOfRecsProcessed));
            }        
        }
        catch(Exception e){
            resultMap.put('Error',Label.Skills360_Validate_Error);       
        }
        return JSON.serialize(resultMap);
    }
    /**
     @description : Save the skills to database
     @param records - List<List<Map<String,String>>>
     */
    @AuraEnabled
    public static void submitRecords(List<List<Map<String,String>>> records) {
        String org62UserId = getUser().Org62Id__c;
        Map<Id,String> recordsToUpdate = new Map<Id,String>();
        Map<Id,String> aspRecsToUpdate = new Map<Id,String>();
        List<ProfileSkillUserTax__x> profileUserSkills = new List<ProfileSkillUserTax__x>();
        List<ProfileSkillUserTax__x> profileUserSkillsToUpdate = new List<ProfileSkillUserTax__x>();
        List<ProfileSkillUserTax__x> profileUserSkillsToInsert = new List<ProfileSkillUserTax__x>();
        
       
        for(List<Map<String,String>> record: records){
            for(Map<String,String> row : record){
                //get if id is valid SFDC id, if it is we update else we insert
                if(!row.get('id').contains('-')){
                    //gets list of records we need udpate
                   
                    recordsToUpdate.put(row.get('id'),row.get('Expertise_Rating__c'));
                    aspRecsToUpdate.put(row.get('id'),row.get('aspirationSkill'));
                } else {
                    //creates list of records we want to insert rating > 0
                    //if(row.get('Expertise_Rating__c') != 'Not yet selected'){
                        ProfileSkillUserTax__x newUserSkill = new ProfileSkillUserTax__x();
                        newUserSkill.UserId__c = org62UserId;
                        newUserSkill.Expertise_Rating_c__c = row.get('Expertise_Rating__c');
                        newUserSkill.ProfileSkillId__c = row.get('ProfileSkill_c__c');
                        if(newUserSkill.Expertise_Rating_c__c != null && newUserSkill.Expertise_Rating_c__c != ''){
                            newUserSkill.Skill_Rating_Last_Update__c = System.now();
                        }
                        profileUserSkillsToInsert.add(newUserSkill);
                    //}
                }
            }
        }
        //Get skills to update
        if(Test.isRunningTest()) {
            //need to create some dummy userSkills - testing did not like EOs
            profileUserSkills.add(new ProfileSkillUserTax__x(
                Expertise_Rating_c__c = '4- Specialist'
            ));
            
        } else {
            profileUserSkills = [SELECT Id,Expertise_Certified__c, Expertise_Rating_c__c, ProfileSkillId__r.Name__c, ProfileSkillId__r.Type_c__c, ProfileSkillId__r.Description__c, ProfileSkillId__r.Category_c__c,Skill_Rating_Last_Update__c FROM ProfileSkillUserTax__x WHERE Id IN :recordsToUpdate.keySet() WITH SECURITY_ENFORCED];
        }
        for( ProfileSkillUserTax__x profileUserSkill : profileUserSkills){
            //if there is change of skill rating, reset Expertise Certified
            string selectedRating = recordsToUpdate.get(profileUserSkill.Id);
            if(selectedRating != null){
            if(profileUserSkill.Expertise_Rating_c__c != selectedRating){
                profileUserSkill.Expertise_Certified__c = false;
                if(selectedRating  != null && selectedRating != ''){
                profileUserSkill.Skill_Rating_Last_Update__c = System.now();
                } 
            } 
                profileUserSkill.Expertise_Rating_c__c = recordsToUpdate.get(profileUserSkill.Id);
            }
            if(aspRecsToUpdate.get(profileUserSkill.Id) != null){
                
            	profileUserSkill.Aspirational_Skill__c = Boolean.valueOf(aspRecsToUpdate.get(profileUserSkill.Id));
            }
            if(profileUserSkill.Expertise_Rating_c__c == '4- Specialist' || profileUserSkill.Expertise_Rating_c__c == '5- Expert'){
                profileUserSkill.Aspirational_Skill__c = false;
            }
            profileUserSkillsToUpdate.add(profileUserSkill);
        }
        
        SaveCallback callback = new SaveCallback();
        //Update External Object Records
        if(profileUserSkillsToUpdate!=null && !profileUserSkillsToUpdate.isEmpty()) {
            Database.updateAsync(profileUserSkillsToUpdate, callback);
        }
        //Insert exteral 
        if(profileUserSkillsToInsert!=null && !profileUserSkillsToInsert.isEmpty()) {
            Database.insertAsync(profileUserSkillsToInsert, callback);
        }                
    }
    /**
     * @description : create a method that creates all the emp skills based on line items - get Skills Set Items, iterate similar to top
     */
    public class UserSkillWrapper {
        /**
         * @description variable to hold info of CSG_Group_Skill__c
        */
        @Auraenabled public CSG_Group_Skill__c groupSkill  { get; set;}
        /**
         * @description variable to hold info of ProfileSkillUserTax__x
        */
        @Auraenabled public ProfileSkillUserTax__x userSkill  { get; set;}
           /**
         * @description variable to hold info of CSGProfileSkill__c
        */
        @Auraenabled public CSGProfileSkill__c skill  { get; set;}
           /**
         * @description variable to hold info of ProfileSkillUserTax__x id
        */
        @Auraenabled public String id {get; set;}
           /**
         * @description variable to hold info of expertiseRating
        */
        @Auraenabled public String expertiseRating { get; set;}
           /**
         * @description variable to hold info of relevantExperienceDescription
        */
        @Auraenabled public String relevantExperienceDescription { get; set;}
             /**
         * @description variable to hold info of skillName
        */
        @Auraenabled public String skillName { get; set;}
             /**
         * @description variable to hold info of skillType
        */
        @Auraenabled public String skillType { get; set;}
        /**
         * @description variable to hold info of skillDescription
        */
        @Auraenabled public String skillDescription { get; set;}
         /**
         * @description variable to hold info of skillCategory
        */
        @Auraenabled public String skillCategory { get; set;}
         /**
         * @description variable to hold info of skillId
        */
        @Auraenabled public String skillId { get; set;}
         /**
         * @description variable to hold info of skillExternalId
        */
        @Auraenabled public String skillExternalId { get; set;}
         /**
         * @description variable to hold info of expertiseCertified
        */
        @Auraenabled public Boolean expertiseCertified { get; set;}
         /**
         * @description variable to hold info of Name of user
        */
        @Auraenabled public String userName { get; set;}
         /**
         * @description variable to hold info of org62 id of user
        */
        @Auraenabled public String userId { get; set;}
         /**
         * @description variable to hold info of skillViewId
        */
		@Auraenabled public String skillViewId  { get; set;}
         /**
         * @description variable to hold info of skilllastupdate
        */
        @Auraenabled public String skilllastupdate  { get; set;} 
       /**
        * @description variable to hold info of aspirationSkill value
        */ 
        @Auraenabled public Boolean aspirationSkill { get; set;}
        /**
         * @description variable to hold info of focusSkill value
        */ 
        @Auraenabled public Boolean focusSkill { get; set;}
        /**
        * @description variable to hold info of aspirationSkill value
        */ 
        @Auraenabled public Boolean disableAspToggle { get; set;}
         /**
        * @description variable to hold info of aspirationSkill value
        */ 
        @Auraenabled public Boolean displayATag { get; set;}
        /**
         @description : Constructor
         @param groupSkill - CSG_Group_Skill__c rec
         */
        public UserSkillWrapper(CSG_Group_Skill__c groupSkill){
            this.groupSkill = groupSkill;
            
            relevantExperienceDescription = ''; 
            skillName = groupSkill.CSGProfileSkill__r.Name; 
            skillType = groupSkill.CSGProfileSkill__r.Type__c;
            skillDescription = groupSkill.CSGProfileSkill__r.Description__c;
            skillCategory = groupSkill.CSGProfileSkill__r.Category__c;
            skillId = '';
            skillExternalId = groupSkill.CSGProfileSkill__r.External_Id__c;
            skillViewId = groupSkill.CSGProfileSkill__r.Id;
			focusSkill = false;
	    expertiseRating =  SKILL_NONE_RATING;
            disableAspToggle = aspirationSkill;
        }
        /**
         @description : Constructor
         @param userSkill - ProfileSkillUserTax__x rec
         */
        public UserSkillWrapper(ProfileSkillUserTax__x userSkill){
            this.userSkill = userSkill;
            expertiseRating = userSkill.Expertise_Rating_c__c;
            skillName = userSkill.ProfileSkillId__r.Name__c; 
            skillType = userSkill.ProfileSkillId__r.Type_c__c;
            skillDescription = userSkill.ProfileSkillId__r.Description__c;
            skillCategory = userSkill.ProfileSkillId__r.Category_c__c;
            skillId = userSkill.Id;
			expertiseCertified = userSkill.Expertise_Certified__c;
            if(userSkill.Skill_Rating_Last_Update__c != null){
                skilllastupdate = '' + userSkill.Skill_Rating_Last_Update__c.format('yyyy-MM-dd h:mm a');
            }
            aspirationSkill = userSkill.Aspirational_Skill__c;
            focusSkill = false;
            if(expertiseRating == '4- Specialist' || expertiseRating == '5- Expert'){
                disableAspToggle = TRUE;
            }
            displayATag = false;
            if(userSkill.Aspirational_Skill__c){
            	displayATag = true;
            }
            
            
        }

        /**
         @description : Constructor
          @param userSkill - ProfileSkillUserTax__x rec
          @param org62IdvsUser - Map<string,User>
         */
        public UserSkillWrapper(ProfileSkillUserTax__x userSkill, Map<string,User> org62IdvsUser){
            this.userSkill = userSkill;
            expertiseRating = userSkill.Expertise_Rating_c__c;
            skillName = userSkill.ProfileSkillId__r.Name__c; 
            skillType = userSkill.ProfileSkillId__r.Type_c__c;
            skillDescription = userSkill.ProfileSkillId__r.Description__c;
            skillCategory = userSkill.ProfileSkillId__r.Category_c__c;
            skillId = userSkill.Id;
            expertiseCertified = userSkill.Expertise_Certified__c;
            if(org62IdvsUser.get(userSkill.UserId__c) != null){
            userName = org62IdvsUser.get(userSkill.UserId__c).Name;
            userId = org62IdvsUser.get(userSkill.UserId__c).id;
            }
            if(userSkill.Skill_Rating_Last_Update__c != null){
                skilllastupdate = '' + userSkill.Skill_Rating_Last_Update__c.format('yyyy-MM-dd h:mm a');
            }
            aspirationSkill = userSkill.Aspirational_Skill__c;
            focusSkill = false;
            if(expertiseRating == '4- Specialist' || expertiseRating == '5- Expert'){
                disableAspToggle = TRUE;
            }
            displayATag = false;
            if(userSkill.Aspirational_Skill__c){
            	displayATag = true;
            }
        }
        /**
         @description : Constructor
          @param skill - CSGProfileSkill__c rec
         */
        public UserSkillWrapper(CSGProfileSkill__c skill){
            this.skill = skill;
           
            relevantExperienceDescription = '';
            skillName = skill.Name;
            skillType = skill.Type__c;
            skillDescription = skill.Description__c;
            skillCategory = skill.Category__c;
            skillId = '';
            skillExternalId = skill.External_Id__c;
            skillViewId = skill.Id;
			focusSkill = false;
	    expertiseRating = SKILL_NONE_RATING;
            disableAspToggle = false;
            displayATag = false;
            
        }

    }


    /**
    @description : Gets the Expertise_Rating_c__c Global picklist options
    @return      :  List<labelWrapper> 
    */
    @AuraEnabled
    public static List<labelWrapper>  getpicklistValues(){
        List<labelWrapper> wrapperLst = new List<labelWrapper>();
        Schema.DescribeFieldResult fieldResult = ProfileSkillUserTax__x.Expertise_Rating_c__c.getDescribe();
        List<Schema.PicklistEntry> plv = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : plv)	
        {	
            wrapperLst.add(new labelWrapper(f.getLabel(),f.getValue()));	
        }	
        return wrapperLst;	
    }	
		
    /**	
    @description : Gets the Expertise_Rating_c__c Global picklist options
    @return -  List<labelWrapper> 
    */	
    @AuraEnabled	
    public static List<labelWrapper>  getpicklistValuesNone(){	
        List<labelWrapper> wrapperLst = new List<labelWrapper>();	
        Schema.DescribeFieldResult fieldResult = ProfileSkillUserTax__x.Expertise_Rating_c__c.getDescribe();	
        List<Schema.PicklistEntry> plv = fieldResult.getPicklistValues();	
        wrapperLst.add(new labelWrapper(SKILL_NONE_RATING,SKILL_NONE_RATING));for( Schema.PicklistEntry f : plv)
        {
           wrapperLst.add(new labelWrapper(f.getLabel(),f.getValue()));
        }
        return wrapperLst;
    }

    /**
    Class Name      : LabelWrapper
    @description    : This is the wrapper class 
    */
    public with sharing class labelWrapper{
        
        /**
        * @description variable to hold info of label
        */
        @AuraEnabled public  string label{get;set;}
        /**
        * @description variable to hold info of value
        */
        @AuraEnabled public  string value{get;set;}
        
        /**
        @description : labelWrapper.
        @param label - String label 
		@param value - String value 
        */
        public labelWrapper(string label, string value){
            this.label = label;
            this.value = value;
        }
    }

    /**
    @description : Method to get the focus areas.
    @return      : String
    */
    @AuraEnabled
    public static String getFocusAreas(){
        String focusStr ='';
        PA_Onboarding__c onboardingRecord = new PA_Onboarding__c();
        try{
            onboardingRecord = [SELECT Id,Industry_Focus__c,Product_Focus__c,Operating_Unit_Focus__c, Last_Profile_Skills_Update__c,Discipline__c FROM PA_Onboarding__c WHERE Candidate__c =:Userinfo.getUserId()  LIMIT 1];
            onboardingRecordId = onboardingRecord.Id;
            if(String.isNotBlank(onboardingRecord.Industry_Focus__c)){
                focusStr = onboardingRecord.Industry_Focus__c;
            }
            if(String.isNotBlank(onboardingRecord.Product_Focus__c)){
                if(String.isNotBlank(focusStr)){
                focusStr = focusStr+','+onboardingRecord.Product_Focus__c;
                }else{
                    focusStr = onboardingRecord.Product_Focus__c;
                }
            }
            if(String.isNotBlank(onboardingRecord.Operating_Unit_Focus__c)){
                if(String.isNotBlank(focusStr)){
                focusStr = focusStr+','+onboardingRecord.Operating_Unit_Focus__c;
                }else{
                    focusStr = onboardingRecord.Operating_Unit_Focus__c;
                }
            }
          
            focusStr = focusStr.replace(';', ', ');
        }Catch(Exception ex){
            Logger.error('Sorry, we had an issue updating the Onboarding record' + ex.getMessage());
            Logger.saveLog(); 
            
        }
        return focusStr;
    }
    
    /**
    @description : Method to identify the manager.
    @return      : Boolean
    */
    @AuraEnabled
    public static Boolean isManager(){
        Boolean isManager = false;
        List<User> directSubordinates = [select id,Name,Org62Id__c from user where managerid=:Userinfo.getUserId() and isactive = true];
        if(directSubordinates != null  &&  directSubordinates.size() > 0){
            isManager = true;
        }
        
        return isManager;
        
    }
    /**
    @description : Method to identify the Delegate approver.
    @return      : Boolean
    */
    @AuraEnabled
    public static Boolean isDelegate(){
        Boolean isDelegate = false;
            List<User> managerRecs = [SELECT Managerid FROM user WHERE Skills360_Delegated_Approver__c=:Userinfo.getUserId() and isactive = true];
            List<User> directSubordinates1 = [SELECT Name,Org62Id__c FROM user WHERE managerid=: managerRecs  and isactive = true];
            if(directSubordinates1 != null  &&  directSubordinates1.size() > 0){
            isDelegate = true;
        }
        
        
        return isDelegate;
        
    }
    
     /**
    @description : Method to identify the isSuperAdmin.
    @return      : Boolean
    */
    @AuraEnabled
    public static Boolean isSuperAdmin(){
        Boolean isSuperAdmin = false;
        List<PermissionSetAssignment> currentUserAsgnmentList = [SELECT Id,Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CSG_Skills_App_Super' AND Assignee.Id =: UserInfo.getUserId()];
        if(currentUserAsgnmentList != null && currentUserAsgnmentList.size() > 0){
            isSuperAdmin = TRUE;
        }else{
            isSuperAdmin = FALSE;
        }
        
        return isSuperAdmin;
        
    }
    
    
    /**
    @description : Method to fetch CSG groups.
    @return      : List<TreeStructure>
    */   
    @AuraEnabled(cacheable=true)
    public static List<TreeStructure> getCSGGrps(){
        result = new Map<String, TreeStructure>();
        childIdMap = new Map<Id, Id>();
        Map<String, CSG_Group__c> accMap = new Map<String, CSG_Group__c>([SELECT Id, Name,Level_1__c,Level_2__c,Level_3__c FROM CSG_Group__c ORDER BY Name ASC]);
        if(!accMap.isEmpty()){
            result = fetchingGrpDetails(accMap);
        }

	TreeStructure topStr = new TreeStructure('Browse All Skills', 'All Skills', false, null);
        
        for(TreeStructure child : result.values()){
            topStr.items.add(child);
        }
       
        return new List<TreeStructure>{topStr};
     }
    /**
    @description : Method to fetch CSG groups.
    @return      : Map<String, TreeStructure>
	@param accMap - Map<String, CSG_Group__c> 
    */ 
    private static Map<String, TreeStructure> fetchingGrpDetails(Map<String, CSG_Group__c> accMap){
        
        Map<String, TreeStructure> parentStructure = new Map<String, TreeStructure>();
        Map<String,List<CSG_Group__c>> level1Map  = new Map<String,List<CSG_Group__c>>();
        Map<String,List<CSG_Group__c>> level2Map  = new Map<String,List<CSG_Group__c>>();
        Map<String,List<CSG_Group__c>> level3Map  = new Map<String,List<CSG_Group__c>>();
        Set<String> finalSet = new Set<STring>();
        Map<String, CSG_Group__c> fLevelMap = new Map<String, CSG_Group__c>();
        Map<String,Set<String>> parentChildMap = new Map<String,Set<String>>();
        Map<String, CSG_Group__c> parentMap = new Map<String, CSG_Group__c>();
        Map<String,Set<String>> secondparentChildMap = new Map<String,Set<String>>();
        Map<String, List<TreeStructure>> child2Structure = new Map<String, List<TreeStructure>>();
        
        for(String accountId : accMap.keySet()){
            CSG_Group__c csg = accMap.get(accountId);
            if(csg.Level_1__c != null){
                
                if(!level1Map.containsKey(csg.Level_1__c)){
                    level1Map.put(csg.Level_1__c, new List<CSG_Group__c>());
                }
                if(csg.Level_2__c == null){
                    level1Map.get(csg.Level_1__c).add(csg);
                }
                
            }
            if(csg.Level_2__c != null){
                if(!level2Map.containsKey(csg.Level_2__c)){
                    level2Map.put(csg.Level_2__c, new List<CSG_Group__c>());
                }
                if(csg.Level_3__c == null){
                    level2Map.get(csg.Level_2__c).add(csg);
                }
                
                if(level1Map.containsKey(csg.Level_1__c)){
                    if(!parentChildMap.containsKey(csg.Level_1__c)){
                        parentChildMap.put(csg.Level_1__c, new Set<String>());
                    }
                    
                    parentChildMap.get(csg.Level_1__c).add(csg.Level_2__c);
                    
                    
                }
                if(csg.Level_3__c != null){
                    if(!level3Map.containsKey(csg.Level_3__c)){
                        level3Map.put(csg.Level_3__c, new List<CSG_Group__c>());
                    }
                    level3Map.get(csg.Level_3__c).add(csg);
                    if(level2Map.containsKey(csg.Level_2__c)){
                        if(!secondparentChildMap.containsKey(csg.Level_2__c)){
                            secondparentChildMap.put(csg.Level_2__c, new Set<String>());
                        }
                        
                        secondparentChildMap.get(csg.Level_2__c).add(csg.Level_3__c);
                        
                        
                    }
                    
                }
                
            }
            if(csg.Level_2__c == null && csg.Level_1__c == null){
                parentMap.put(csg.Id,csg);
            }
        }
        finalSet.addAll(level1Map.keySet());
        for(String accountId : parentMap.keySet()){
            CSG_Group__c cg = parentMap.get(accountId);
            fLevelMap.put(cg.Name,cg);
            finalSet.add(cg.Name);
        }
        List<String> sList = new List<String>(finalSet);
        sList.sort();
        finalSet = new Set<String>();
        finalSet.addAll(sList);
        
        for(String parentStr: secondparentChildMap.keyset()){
            for(String childLevel: secondparentChildMap.get(parentStr)){
                
                TreeStructure csgStr = new TreeStructure(childLevel, childLevel, false, null);
                
                for(CSG_Group__c cg : level3Map.get(childLevel)){
                    
                    TreeStructure csgStr1 = new TreeStructure(cg.name, cg.name, false, null);
                   
                    csgStr.items.add(csgStr1);
                    
                }
               
                if(!child2Structure.containsKey(parentStr)){
                    child2Structure.put(parentStr, new List<TreeStructure>());
                }
                
                child2Structure.get(parentStr).add(csgStr);
                
            }
}
        
        
        for(String accountId : finalSet){
            if(fLevelMap.get(accountId) != null){
                CSG_Group__c acc = fLevelMap.get(accountId);
                TreeStructure accStructure = new TreeStructure(acc.name, accountId, false, null);
                
                parentStructure.put(accountId, accStructure);
            }else{
                TreeStructure accStructure = new TreeStructure(accountId, accountId, false, null);
                parentStructure.put(accountId, accStructure);
                for(CSG_Group__c cg : level1Map.get(accountId)){
                    
                    TreeStructure csgStr = new TreeStructure(cg.name, cg.name, false, null);
                    TreeStructure parent = parentStructure.get(accountId);
                    parent.items.add(csgStr);
                    
                }
                if(parentChildMap.get(accountId) != null){
                    
                    for(String childLevel: parentChildMap.get(accountId)){
                       
                        TreeStructure csgStr = new TreeStructure(childLevel, childLevel, false, null);
                        if(child2Structure.get(childLevel) != null){
                            csgStr.items.addAll(child2Structure.get(childLevel));
                        }
                        for(CSG_Group__c cg : level2Map.get(childLevel)){
                           
                            TreeStructure csgStr1 = new TreeStructure(cg.name, cg.name, false, null);
                           
                            csgStr.items.add(csgStr1);
                            
                        }
                        TreeStructure parent1 = parentStructure.get(accountId);
                        parent1.items.add(csgStr);
                    }
                }
                
                
            }
        }
        return parentStructure;
    }
    
    /**
    Class Name      : TreeStructure
    @description    : This is the wrapper class to build tree structure
    */
    public class TreeStructure{
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public List<TreeStructure> items;

         /**
        @description : TreeStructure.     
        @param label - String
        @param name - String
        @param expanded - Boolean
        @param items - List<TreeStructure>
        */
        public TreeStructure(String label, String name, Boolean expanded, List<TreeStructure> items){
            this.label = label;
            this.name = name;
            this.expanded = expanded;
            if(items != null && items.size() > 0){
                this.items = items;
            }else{
                this.items = new List<TreeStructure>();
            }
        }
    }
    
}