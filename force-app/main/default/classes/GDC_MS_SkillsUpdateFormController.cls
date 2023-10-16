/****************************
* Created By - Kushagra, Sehrab and Vibhor
* Purpose - This class is used for retrieving skill details for individual team member.
****************************/

public class GDC_MS_SkillsUpdateFormController {
    
    public class SkillSet{
        @AuraEnabled public List<GDC_MS_TeamBuilderController.TeamMemberSkillSet> skillDetails;
        @AuraEnabled public String teamMemberId; 
        @AuraEnabled public String teamMemberName;        
    }
    
    /*
     * getTeamMemberSkillSet - This method accepts a User ID and returns all the skills data associated with the User's team member record.
     */
    @AuraEnabled(cacheable=true)
    public static SkillSet getTeamMemberSkillSet(String userId){
        User userRec;
        SkillSet skills;
        try{
            userRec = [Select Id,(Select Id, Name ,gdc_ms_Designation__c,gdc_ms_SalesforceCertifications__c, gdc_ms_SkillHighlights__c,
                                  gdc_ms_Summary__c, gdc_ms_VerticalExpertise__c, gdc_ms_Customer_Credentials__c from gdc_Team_Members__r) 
                       From User Where Id =: userId LIMIT 1];
            Id teamMemberId = userRec.gdc_Team_Members__r[0].Id;
            String teamMemberName = userRec.gdc_Team_Members__r[0].Name;
            skills = new SkillSet(); 
            skills.teamMemberName = teamMemberName;
            skills.teamMemberId = (String)teamMemberId;
            skills.skillDetails = GDC_MS_TeamBuilderController.getBioInfo((String)teamMemberId);
            
        }
        catch(Exception e){
            Log.error(e);
            throw new AuraHandledException('Team Member for this user not found');
        } 
        return skills;
    }
    
    
    
    
}