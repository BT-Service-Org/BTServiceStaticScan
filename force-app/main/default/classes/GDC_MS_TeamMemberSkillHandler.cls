/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This class is used for retrieving skill keys from cutom metadata(gdc_ms_TeamMemberSkillKey).
 ****************************/

public class GDC_MS_TeamMemberSkillHandler {
    
    //private static List<gdc_ms_TeamMemberSkillKey__mdt> skillsList = [Select gdc_ms_SkillAPIName__c ,gdc_ms_SkillLabel__c from gdc_ms_TeamMemberSkillKey__mdt];
    
    /*
     * retrieveSkillsMap - This method returns a map of all the Team member skill field's API names and Labels.
     */
    public static Map<String,String> retrieveSkillsMap(){
        Map<String,String> temp = new Map<String,String>();
        List<gdc_ms_TeamMemberSkillKey__mdt> skillsList = [Select gdc_ms_SkillAPIName__c ,gdc_ms_SkillLabel__c from gdc_ms_TeamMemberSkillKey__mdt where gdc_ms_isActive__c=true];
        for(gdc_ms_TeamMemberSkillKey__mdt skill:skillsList){
            temp.put(skill.gdc_ms_SkillLabel__c,skill.gdc_ms_SkillAPIName__c);
        }
        return temp;
    }
    
    /*
     * retrieveSkillsList - This method returns a list of all the Team member skill field's Labels.
     */
    public static List<String> retrieveSkillsList(){
        Map<String,String> temp = retrieveSkillsMap();        
        return new List<String>(temp.keySet());
    }

	/*
     * retrieveSkillsApiNames - This method returns a list of all the Team member skill field's API names.
     */
    public static List<String> retrieveSkillsApiNames(){
        Map<String,String> temp = retrieveSkillsMap(); 
        return new List<String>(new Set<String>(temp.values()));//to remove duplicate values
    }
}