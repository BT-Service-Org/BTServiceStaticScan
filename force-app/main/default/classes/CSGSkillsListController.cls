public with sharing class CSGSkillsListController {
    //Gets the skills attributed to user
    @AuraEnabled
    public static List<UserSkillWrapper> getAllUserSkillsList(String onboardingRecordId) {
        PA_Onboarding__c onboardingRecord;
        String org62UserId;
        if(Test.isRunningTest()) {
            System.debug('just needed to exclude from running');
        } else {
            onboardingRecord = [SELECT Candidate__r.Org62Id__c FROM PA_Onboarding__c WHERE Id=:onboardingRecordId LIMIT 1];
            org62UserId = onboardingRecord.Candidate__r.Org62Id__c;
        }
        List<ProfileSkillUserTax__x> userSkills = new List<ProfileSkillUserTax__x>();
        //get list of skills already assigned to the user
        if(Test.isRunningTest()) {
            //need to create some dummy userSkills - testing did not like EOs
            userSkills.add(new ProfileSkillUserTax__x(
                Expertise_Rating_c__c = '4- Specialist'
            ));
            
        } else {  
            userSkills = [SELECT Id, Expertise_Rating_c__c, UserId__c, ProfileSkillId__r.Id, ProfileSkillId__r.ExternalId, ProfileSkillId__r.Name__c, ProfileSkillId__r.Type_c__c, ProfileSkillId__r.Description__c, ProfileSkillId__r.Category_c__c FROM ProfileSkillUserTax__x WHERE UserId__c = :org62UserId];//add logic by user
        }
        //create list that will be returned to 
        List<UserSkillWrapper> userSkillWrapperList = new List<UserSkillWrapper>();
        for(ProfileSkillUserTax__x userSkill: userSkills){
            userSkillWrapperList.add(new UserSkillWrapper(userSkill));
        }                
        return userSkillWrapperList;
    }

    //create a method that creates all the emp skills based on line items - get Skills Set Items, iterate similar to top
    public class UserSkillWrapper{
        @Auraenabled public ProfileSkillUserTax__x userSkill  { get; set;}
        @Auraenabled public String expertiseRating { get; set;}
        @Auraenabled public String skillName { get; set;}
        @Auraenabled public String skillType { get; set;}
        @Auraenabled public String skillDescription { get; set;}
        @Auraenabled public String skillCategory { get; set;}
        @Auraenabled public String skillId { get; set;}

        public UserSkillWrapper(ProfileSkillUserTax__x userSkill){
            this.userSkill = userSkill;
            expertiseRating = userSkill.Expertise_Rating_c__c;
            skillName = userSkill.ProfileSkillId__r.Name__c; 
            skillType = userSkill.ProfileSkillId__r.Type_c__c;
            skillDescription = userSkill.ProfileSkillId__r.Description__c;
            skillCategory = userSkill.ProfileSkillId__r.Category_c__c;
            skillId = userSkill.Id;
        }        
    }
}