/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This class is used for enabling admins to add or remove Skill keys on experience cloud using the GdcmsTeamMemberSkillDisplay component.
 ****************************/
global class GDC_MS_SkillsPicklist extends VisualEditor.DynamicPickList{
    
    global List<String> skillsList = GDC_MS_TeamMemberSkillHandler.retrieveSkillsList();
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(skillsList[0], skillsList[0]);
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();        
        for(String skill: skillsList){
            VisualEditor.DataRow value = new VisualEditor.DataRow(skill, skill);
            myValues.addRow(value);
        }
        return myValues;
    }
}