/**
 * @author Jonathan Cohen - Salesforce.com
 * @date   September 2016
 * @group  Services Org
 */
public class Judge_TriggerHelper
{
	/**
     *  @name     	 - assignPermissionSetAssignmentToUser()
     *  @param    	 - Map<Id, Judge__c> judgesTriggered_NewMap: Judge Sign Up Request triggered new values map.
     *  @param    	 - Map<Id, Judge__c> judgesTriggered_OldMap: Judge Sign Up Request triggered old values map.
     *  @return   	 - N.A.
     *  @description - The method will assign the "PA_Onboarding_Mentor_Badge_Approver" permission set to the user that have been approved as judges.
     *  @Ticket      - W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service.
     */
	public static void assignJudgeDomainsAndUsersPermissionSet(Map<Id, Judge__c> judgesTriggered_NewMap)
	{
		List<Judge__c> judgeRequiringPermissionSetAssignment_List 	= new List<Judge__c>();

		if(judgesTriggered_NewMap.Size() > 0){
			for(Judge__C judge : judgesTriggered_NewMap.Values()){
				if(judge.Request_Approved__c == true && judge.Is_Active__c == false){
					updateJudge9DomainsBadgesAmdJudgingSkills(judge);
					judgeRequiringPermissionSetAssignment_List.add(judge);
				}
				else if(judge.Request_Approved__c == true){
					updateJudge9DomainsBadgesAmdJudgingSkills(judge);
				}
				else if(judge.Request_Rejected__c == true){
					judge.Request_Rejected__c   = false;
					judge.Nine_Domain_Badges__c = Null; 
				}
			}
		}
		if(judgeRequiringPermissionSetAssignment_List.Size() > 0){
			assignPermissionSetToUsers(judgeRequiringPermissionSetAssignment_List);
		}
	}

	/**
     *  @name        - updateJudge9DomainsBadgesAmdJudgingSkills()
     *  @param       - Judge__c judgeToUpdate.
     *  @return      - N.A
     *  @description - The method updates the judge record fields when approved.
     *  @Ticket      - W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service.
     */
	private static void updateJudge9DomainsBadgesAmdJudgingSkills(Judge__c judgeToUpdate)
	{
		judgeToUpdate.Request_Approved__c 	= false;
		judgeToUpdate.Is_Active__c 			= true;
		judgeToUpdate.Judging_Skills__c 	= removeDuplicatesFromStrings(judgeToUpdate.Judging_Skills__c, judgeToUpdate.Nine_Domain_Badges__c);
		judgeToUpdate.Nine_Domain_Badges__c = Null;                
	}

    /**
     *  @name     	 - assignPermissionSetAssignmentToUser()
     *  @param    	 - Map<Id, Judge__c> judgesTriggered_NewMap: Judge Sign Up Request triggered new values map.
     *  @param    	 - Map<Id, Judge__c> judgesTriggered_OldMap: Judge Sign Up Request triggered old values map.
     *  @return   	 - N.A.
     *  @description - The method will assign the "PA_Onboarding_Mentor_Badge_Approver" permission set to the user that have been approved as judges.
     *  @Ticket      - W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service.
     */
	private static void assignPermissionSetToUsers(List<Judge__c> judgeRequiringPermissionSetAssignment_List)
	{
		try{
			List<Id> usersRelatedToJudgesId_List 						= new List<Id>();
			List<Id> userRequiringPermissionSetIds_List					= new List<Id>();
			Set<Id> usersRelatedToJudgesHavingPermissionSet_Set 		= new Set<Id>();
			List<PermissionSetAssignment> permissionSetsToAssign_List 	= new List<PermissionSetAssignment>();

			for(Judge__c insertedJudge : judgeRequiringPermissionSetAssignment_List){
				usersRelatedToJudgesId_List.add(insertedJudge.User__c);
			}

			Id  paOnboardingMentorAndBadgeApproverPermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'PA_Onboarding_Mentor_Badge_Approver'].Id;
			Map<Id, PermissionSetAssignment> permssionSetAssignmentById_Map = new Map<Id, PermissionSetAssignment>([SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :paOnboardingMentorAndBadgeApproverPermissionSetId AND AssigneeId IN :usersRelatedToJudgesId_List]);

			for(PermissionSetAssignment permssionSetAssignment : permssionSetAssignmentById_Map.Values()){
				usersRelatedToJudgesHavingPermissionSet_Set.add(permssionSetAssignment.AssigneeId);
			}

			for(Judge__c insertedJudge : judgeRequiringPermissionSetAssignment_List){
				if(!usersRelatedToJudgesHavingPermissionSet_Set.contains(insertedJudge.User__c)){
					userRequiringPermissionSetIds_List.add(insertedJudge.User__c);
				}
			}
			
			if(userRequiringPermissionSetIds_List.Size() > 0){
				AssignJudgePermissionSetToUser_future(userRequiringPermissionSetIds_List, usersRelatedToJudgesHavingPermissionSet_Set);
			}
		}
        catch(Exception ex){
			system.debug('SFDC JudgeSignUpRequest_TriggerHelper createAndRelateJudgeToSignUpRequest Exception Catched ' + ex.getMessage());
		}
	}
    
    /**
     *  @name     	 - AssignJudgePermissionSetToUser_future()
     *  @param    	 - List<Id> userRequiringPermissionSetIds_List: List of the usersIds that need to be assigned the "PA_Onboarding_Mentor_Badge_Approver" permission set.
     *  @return   	 - N.A.
     *  @description - The method will assign the "PA_Onboarding_Mentor_Badge_Approver" permission set to the necessary users.
     *  @Ticket      - W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service.
     */
	@future
	@TestVisible private static void assignJudgePermissionSetToUser_future(List<Id> userRequiringPermissionSetIds_List, Set<Id> userWithPermissionSet)
	{
		Id  paOnboardingMentorAndBadgeApproverPermissionSetId 		= [SELECT Id FROM PermissionSet WHERE Name = 'PA_Onboarding_Mentor_Badge_Approver'].Id;
		List<PermissionSetAssignment> permissionSetsToAssign_List 	= new List<PermissionSetAssignment>();

		for(Id userRequiringPermissionSetId : userRequiringPermissionSetIds_List){
			if(!userWithPermissionSet.contains(userRequiringPermissionSetId)){
				PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(PermissionSetId = paOnboardingMentorAndBadgeApproverPermissionSetId, AssigneeId = userRequiringPermissionSetId);
				permissionSetsToAssign_List.add(permissionSetAssignment);
			}
		}

		if(permissionSetsToAssign_List.Size() > 0){
            insert permissionSetsToAssign_List;
        }
	}
    
    /**
     *  @name        - removeDuplicatesFromStrings()
     *  @param       - String nineDomainsValues.
     *  @param       - String judgingSkillsValues.
     *  @return      - String without duplicates values.
     *  @description - The method receives 2 strings and remove the duplicates values in those (Used for the multi picklist values assignemnt).
     *                      - For example if the method receives EMEA;APAC and EMEA;Japan, the result will be EMEA;APAC;Japan
     *  @Ticket      - W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service.
     */
    private static String removeDuplicatesFromStrings(String judgingSkillsValues, String nineDomainsValues)
    {
        String result = nineDomainsValues;

        if(judgingSkillsValues != Null)
        {
            List<String> values_List = new List<String>();
            values_List.addAll(judgingSkillsValues.split(';'));

            List<String> previousNineDomainsValues_List = new List<String>();
            previousNineDomainsValues_List.addAll(nineDomainsValues.split(';'));

            Set<String> judgingSkillsValuesCleanedOfNineDomains_Set = new Set<String>(values_List);
            judgingSkillsValuesCleanedOfNineDomains_Set.removeAll(previousNineDomainsValues_List);

            if(nineDomainsValues != Null){
                judgingSkillsValuesCleanedOfNineDomains_Set.addAll(nineDomainsValues.split(';'));
            }
            result = string.join(New List<String>(new Set<String>(judgingSkillsValuesCleanedOfNineDomains_Set)),';');
        }

        return result;
    }
}