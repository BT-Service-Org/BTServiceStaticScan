/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 04-12-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   10-16-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class FeedbackController {
    
    // UD WOrk Un finished.
    
    @AuraEnabled 
    public static CSG_Project_Feedback__c createProjFeedback(CSG_Project_Feedback__c prjFeedbackObj, List<CSG_ProjectFeedback_Skills__c> listFeedbackSkills){
        System.debug('In createProjFeedback' + prjFeedbackObj);
        System.debug( 'keyyyyyyyyyyy' + prjFeedbackObj.Unique_Feedback_Id__c);
        System.debug('Feedback Skills List' + listFeedbackSkills);
        prjFeedbackObj.CSG_Feedback_Request_Status__c = 'Completed';
        prjFeedbackObj.CSG_Feedback_Provider__c = UserInfo.getUserId();
        //prjFeedbackObj.Unique_Feedback_Id__c = prjFeedbackObj.Assignment__c+'-'+prjFeedbackObj.Onboarding__c+'-'+prjFeedbackObj.CSG_Feedback_Provider__c;
         upsert prjFeedbackObj Unique_Feedback_Id__c;
        List<CSG_ProjectFeedback_Skills__c> fSkills = new List<CSG_ProjectFeedback_Skills__c>();
        for(CSG_ProjectFeedback_Skills__c fbSk : listFeedbackSkills){
            CSG_ProjectFeedback_Skills__c sk = new CSG_ProjectFeedback_Skills__c();
            sk.Feedback_Skill__c = fbSk.Feedback_Skill__c;
            sk.Rating__c = fbSk.Rating__c;
            sk.CSG_Project_Feedback__c = prjFeedbackObj.Id;
            fSkills.add(sk);
        }
        insert fSkills;
        return prjFeedbackObj;
    }    
    
    /* TODO: Remove this method. We now allow multiple feedbacks for the same resource. We are also changing the Unique_Feedback_Id__c field contain record ID upon completion
     * so we can't rely on the unique id anymore to check for duplicates.
     @AuraEnabled
     public static CSG_Project_Feedback__c checkDuplicates( String recordCheck){
     //system.debug('Dupe Rec' + existingRec);
        List<CSG_Project_Feedback__c> uniqueId = new List<CSG_Project_Feedback__c>();
        uniqueId = [SELECT Id, Unique_Feedback_Id__c FROM CSG_Project_Feedback__c WHERE Unique_Feedback_Id__c =:recordCheck AND CSG_Feedback_Request_Status__c = 'Requested'];
        // on completion of the feedback we are changing the Unique_Feedback_Id__c field to be the same as the record ID. So now the definition of "dublicate" needs to change
        // so that there is only one outstanding request for a feedback. We will leverage the concatenated unique id as long as the feedback status is 'Requested'
        if(uniqueId.size()>0)
          return uniqueId[0];
        else 
            return null;
    }
   */
  @AuraEnabled(cacheable=true)
  public static string getCandidateRecordId(String onboardingRecordId){
      try {
          //Candidate__c
          PA_Onboarding__c onboardingRecord = [SELECT Candidate__c from PA_Onboarding__c WHERE Id = :onboardingRecordId LIMIT 1];
          return onboardingRecord.Candidate__c;
      } 
      catch (QueryException e) {
          throw new AuraHandledException(e.getMessage());
      }
      catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  }

    @AuraEnabled(cacheable=true)
    public static List<CSG_Group_Skill__c> getResourceSkills ( String candidateId){
       
        
        List<CSG_Group_Skill__c> resourceSkills = new List<CSG_Group_Skill__c>();
        User userRole = [Select Id, CSG_Role__c, Org62Id__c, Title from User where Id = :candidateId];
        
        
        List<CSG_Group_Skill__c> groupSkillsList = [SELECT Id, CSGProfileSkill__r.Id, CSGProfileSkill__r.External_Id__c, CSGProfileSkill__r.Name, 
                                                                  CSGProfileSkill__r.Type__c, CSGProfileSkill__r.Category__c
                                                            FROM CSG_Group_Skill__c ORDER BY CSGProfileSkill__r.Type__c,  CSGProfileSkill__r.Category__c DESC];
        system.debug('groupSkillList' + groupSkillsList);
        List<ProfileSkillUserTax__x> userSkills = new List<ProfileSkillUserTax__x>();
        String skillName;
        List<CSGProfileSkill__c> userSkillList = new List<CSGProfileSkill__c>();
        Map<Id,CSG_Group_Skill__c> newCSGGroupSkillMap = new MAP<Id, CSG_Group_Skill__c>();
        
        for(CSG_Group_Skill__c groupSkill : groupSkillsList){
            newCSGGroupSkillMap.put(groupSkill.CSGProfileSkill__r.External_Id__c, groupSkill);
            
        }
        if(Test.isRunningTest()) {
            //dummy userSkills for testing
            userSkills.add(new ProfileSkillUserTax__x(
                Expertise_Rating_c__c = '4- Specialist'
            ));
        } else {
       userSkills = [SELECT Id, UserId__c, ProfileSkillId__r.Id, ProfileSkillId__r.ExternalId, ProfileSkillId__r.Name__c, ProfileSkillId__r.Type_c__c, 
                 ProfileSkillId__r.Category_c__c FROM ProfileSkillUserTax__x WHERE UserId__c = :userRole.Org62Id__c];// AND ProfileSkillId__r.ExternalId IN :newCSGGroupSkillMap.keyset() ];
        }
        for(ProfileSkillUserTax__x userSkill: userSkills){
           if(!newCSGGroupSkillMap.containsKey(userSkill.ProfileSkillId__r.ExternalId)){
                newCSGGroupSkillMap.remove(userSkill.ProfileSkillId__r.ExternalId);  
             }
           resourceSkills.add(newCSGGroupSkillMap.get(userSkill.ProfileSkillId__r.ExternalId));
        }
        
        //UD Commented 
        //resourceSkills.addAll(newCSGGroupSkillMap.values());
        
        system.debug('resource skills ' + resourceSkills);
        return resourceSkills;    
    }
   
    
    @AuraEnabled(cacheable=true)
    public static PA_Onboarding_Project__c getProjectAssignment(String assignedProjId, String orgAssignId){
        PA_Onboarding_Project__c projData = new PA_Onboarding_Project__c();
        system.debug('I am in get Project Assignment method'+orgAssignId);
        if(assignedProjId<> NULL || (orgAssignId <> NULL && orgAssignId <> '')){
            projData = [SELECT Id, Name, Project_Name__c, Customer_Name__c, PA_Onboarding__c,PA_Onboarding__r.Org62_User_ID__c, PA_Onboarding__r.Candidate__c,  PA_Onboarding__r.Candidate__r.Name, PA_Onboarding__r.CSG_Role_Community__c, Project_Start_Date__c, Project_End_Date__c, PA_Onboarding__r.Level__c, Project_Role__C FROM PA_Onboarding_Project__c WHERE (ID = :assignedProjId OR (PSE_Project_ID__c = :orgAssignId AND PSE_Project_ID__c <> NULL)) LIMIT 1];
        }
        system.debug('***********I am in get Project Assignment method'+projData + assignedProjId + orgAssignId  );
        
        return projData;
    }
    
    @AuraEnabled(cacheable=true)
    public static String checkIfUserCanSubmitFeedback(String recId, String currUserID){
       
        System.debug('in checkIfUserCanSubmitFeedback');
        System.debug('recId: ' + recId);
        System.debug('currUserID: ' + currUserID);
        try {
            if(recId == NULL || recId == ''){
                return 'SAME_USER';
            }
            List<CSG_Project_Feedback__c> feedbackRecList = [SELECT Id, Unique_Feedback_Id__c, CSG_Feedback_Provider__c, CSG_Feedback_Request_Status__c FROM CSG_Project_Feedback__c WHERE Id =:recId LIMIT 1]; //really no need to lmit here since the uniqueId can exisst only on one record, but adding it just in case.

            if(feedbackRecList.size() > 0){
                System.debug('feedbackRec.CSG_Feedback_Provider__c == currUserID' + feedbackRecList[0].CSG_Feedback_Provider__c == currUserID);
                if(feedbackRecList[0].CSG_Feedback_Provider__c == currUserID || currUserID == NULL) {
                    if(feedbackRecList[0].CSG_Feedback_Request_Status__c != 'Completed') {
                        return 'SAME_USER';
                    }
                    else {
                        return 'COMPLETED';
                    }
                }
                else {
                    return 'DIFFERENT_USER';
                }
            }
            
            //System.debug('feedbackRec.CSG_Feedback_Provider__c == currUserID' + feedbackRec.CSG_Feedback_Provider__c == currUserID);
            return 'NO_RESULTS'; //returns true if both values are the same, meaning the user logged in is the provider. Otherwise returns false.

        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage());
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   /* @AuraEnabled(cacheable=true)
    public static List<CSG_ProjectFeedback_Skills__c> getPrepopulatedFeedbackSkills(String communityRole){
        List<CSG_ProjectFeedback_Skills__c> listFdbkSkills = new List<CSG_ProjectFeedback_Skills__c>();
        List<CSG_Project_Feedback_Community_Roles__mdt> listFdbkCommRolemdt = new List<CSG_Project_Feedback_Community_Roles__mdt>();
        List<String> listSkills = new List<String>();
        system.debug('In Prepopulation method' + communityRole);
        if(communityRole<> NULL){
            for(CSG_Project_Feedback_Community_Roles__mdt fCommRole :  [SELECT Id, MasterLabel, DeveloperName, CSG_Inactive__c, CSG_Role_Community__c, CSG_Skill__c FROM CSG_Project_Feedback_Community_Roles__mdt WHERE CSG_Role_Community__c = :communityRole AND CSG_Inactive__c = FALSE])
            {
                listSkills.add(fCommRole.CSG_Skill__c);
            }
        }
        system.debug('In Prepopulation method'+ listSkills);
        for(CSGProfileSkill__c prfSkill : [Select id, Name from CSGProfileSkill__c where Name IN :listSkills])
        {
            CSG_ProjectFeedback_Skills__c prjFdbkSkill = new CSG_ProjectFeedback_Skills__c();
            prjFdbkSkill.Feedback_Skill__c = prfSkill.Id;
            listFdbkSkills.add(prjFdbkSkill);
        }
        return listFdbkSkills;
    }*/
   
    @AuraEnabled
    public static String saveFeedback(CSG_Project_Feedback__c engagementFeedback, String recordId){
        try {
            engagementFeedback.Id = recordId;
            if (!Test.isRunningTest()) {
                engagementFeedback.CSG_Feedback_Request_Status__c = 'Completed';
            }
            update engagementFeedback;

            return recordId;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getEFDefaultRecordTypeId(){
        try {
            return Schema.SObjectType.CSG_Project_Feedback__c.getRecordTypeInfosByDeveloperName().get('Generic_Performance_Feedback').getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}