public with sharing class Learning_Domain_Skill_Extension {
    
    private final Learning_Domain_Skill__c skill;
    List<EmailTemplate> templatesList = [select Id,Name from EmailTemplate 
                        where FolderId in (Select  id From Folder f where Type='Email' and Name='PA Onboarding')];
    public Learning_Domain_Skill_Extension(ApexPages.StandardController stdController) {
        this.skill = (Learning_Domain_Skill__c)stdController.getRecord();
    }

 
    public List<SelectOption> getTemplateOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (EmailTemplate t : templatesList) {
            options.add(new SelectOption(t.Id,t.Name));
        }
        return options;
    }   
}