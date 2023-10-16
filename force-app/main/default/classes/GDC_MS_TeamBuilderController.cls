/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This class is used as the server side controller for the org chart .
 ****************************/
public with sharing class GDC_MS_TeamBuilderController {
    
    private static Map<String,String> keyField;
     
    public class TeamMember{
        @AuraEnabled public Id id;
        @AuraEnabled public Id parentId;
        @AuraEnabled public String name;
        @AuraEnabled public String positionName;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String managerName;
    }

    public class TeamMemberSkillSet{
        @AuraEnabled public List<String> skillDetails;
        @AuraEnabled public String skillKey;
    }
    
    
    /*
     * getOrgMembers - This method returns a list of all team member records along with some basic info about them.
     */
    @AuraEnabled(cacheable=true)
    public static List<TeamMember> getOrgMembers(){
        List<gdc_ms_TeamMember__c> allGDCMembers = [Select id,gdc_ms_Manager__c,gdc_ms_Manager__r.Name,Name,gdc_ms_ProfilePhoto__c,
                                                    gdc_ms_Designation__c from gdc_ms_TeamMember__c where gdc_ms_isActive__c = true];
        List<TeamMember> allTeamMembers = new List<TeamMember>();
        for(gdc_ms_TeamMember__c gdcMember : allGDCMembers){
            allTeamMembers.add(convertToTeamMember(gdcMember));
        }
        return allTeamMembers;
    }
    
    /*
     * convertToTeamMember - This method accepts a team member record, wraps it up in the TeamMember Wrapper and returns it.
     */
    public static TeamMember convertToTeamMember(gdc_ms_TeamMember__c gdcMember){
        TeamMember member = new TeamMember();
        member.id = gdcMember.id;
        member.parentId = gdcMember.gdc_ms_Manager__c;
        member.name = gdcMember.Name;
        //member.imageUrl = gdcMember.gdc_ms_ProfilePhoto__c !=null ? gdcMember.gdc_ms_ProfilePhoto__c :'https://lh3.googleusercontent.com/CNBZrkXNGQ_xajQHG_a8Hc9jUB7nhtu4kPQEmlJN8mB5o5yWcMQe9XGStA8jNKg-u5ehFObVok5FPxVeJz4LXNbfHLFbT2ezErbRgvt4J5wHibvGbxHHmEE3-BNRHsVAZmsQGIaqq34=s0';
        member.imageUrl = gdcMember.gdc_ms_ProfilePhoto__c;
        member.positionName = gdcMember.gdc_ms_Designation__c;
        member.managerName = gdcMember.gdc_ms_Manager__r.Name;
        return member;
    }

    /*
     * getBioInfo - This method accepts a team member record's ID, retrieves all skill data associated to that record,
     * wraps it up in the TeamMemberSkillSet Wrapper in the form of a list and returns it.
     */
    @AuraEnabled(cacheable=true)
    public static List<TeamMemberSkillSet> getBioInfo(string bioId) {
        Id bId = (Id)bioId;
        List<String> skillApiNames = GDC_MS_TeamMemberSkillHandler.retrieveSkillsApiNames();
        String soql = 'SELECT '+ String.join( skillApiNames, ', ' );
        soql = soql + ' FROM gdc_ms_TeamMember__c Where Id = :bId limit 1';
        System.debug(soql);           
        List<gdc_ms_TeamMember__c> bioInfo = Database.query(soql);
        System.debug(bioInfo);
        List<TeamMemberSkillSet> listOfTMSkills = new List<TeamMemberSkillSet>();
        if(keyField == null ){
            keyField = GDC_MS_TeamMemberSkillHandler.retrieveSkillsMap();
        }
        for(String key : keyField.keySet()){
            listOfTMSkills.add(convertToTeamMemberSkillSet(bioInfo[0],key));
        }
        return listOfTMSkills;
    }
    
    
    /*
     * getBioInfo - This method formats one skill's data at a time and returns it wrapped inside TeamMemberSkillSet wrapper.
     */
    private static TeamMemberSkillSet convertToTeamMemberSkillSet(gdc_ms_TeamMember__c gdcMember, String key){
        TeamMemberSkillSet teamMemberSkills = new TeamMemberSkillSet();
        String skills = ((String)gdcMember.get(keyField.get(key)))?.replace('\r','');
        if(String.isNotBlank(skills) && skills.contains(';')){
            teamMemberSkills.skillDetails = skills.split(';');
        }else if(String.isNotBlank(skills) && skills.contains('\n')){
             teamMemberSkills.skillDetails = skills.split('\n');
        }
        else{
            teamMemberSkills.skillDetails = new List<String>{skills};
        }
        //teamMemberSkills.skillDetails = skills?.contains(';') ? skills?.split(';') : skills?.split('\n');
        teamMemberSkills.skillKey = key;
        return teamMemberSkills;
    }
}