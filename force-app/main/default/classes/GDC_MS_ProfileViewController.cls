/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This class is used for retrieving profile details and skills of a team member.
 ****************************/

public without sharing class GDC_MS_ProfileViewController {
    
    public class Profile{
        @AuraEnabled public GDC_MS_TeamBuilderController.TeamMember userDetails;
        @AuraEnabled public List<GDC_MS_TeamBuilderController.TeamMemberSkillSet> skillDetails;
    }
    
    /*
     * getProfileDetails - This method accepts an Id and returns all the details of a team member record associated with that ID
     * wrapped up inside the 'Profile' Wrapper.
     */
    @AuraEnabled(cacheable=true)
    public static Profile getProfileDetails(id recordId){
        List<gdc_ms_TeamMember__c> getGdcMember = [Select id,gdc_ms_Manager__c,gdc_ms_Manager__r.Name,Name,gdc_ms_ProfilePhoto__c,
                                                   gdc_ms_Designation__c FROM gdc_ms_TeamMember__c where id=:recordId];
        
        Profile prof = new Profile();
        prof.userDetails = GDC_MS_TeamBuilderController.convertToTeamMember(getGdcMember[0]);
        prof.skillDetails = GDC_MS_TeamBuilderController.getBioInfo((String)recordId);
        
        return prof;
    }
    
    /*
     * getSkillData - This method accepts an Id and a skill name and returns the skill data for the input skill of a team member record associated with the input ID
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getSkillData(id recordId,String skillName){
        List<String> skillData = new List<String>();
        List<GDC_MS_TeamBuilderController.TeamMemberSkillSet> skillDetails = GDC_MS_TeamBuilderController.getBioInfo((String)recordId);
        for(GDC_MS_TeamBuilderController.TeamMemberSkillSet skill:skillDetails){
            if(skill.skillKey.equals(skillName)){
                skillData = skill.skillDetails;
            }
        }
        return skillData;
    }
    
    
}