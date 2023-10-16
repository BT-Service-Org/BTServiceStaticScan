trigger SkillCreateNewSkill on Skill__c (after insert) {

// On create of new skill, add the skill to all users in the 
// junction table with a default value of 0
    
    List<Consultant_Skill__c> consultantSkillsList = new List<Consultant_Skill__c>();
    Consultant_Skill__c conskills;
    //For each skill that's newly added
    for(Skill__c s: Trigger.new){ 
        //Add the skill to each Contact with a default value of 0
        system.debug('SkillCategory =' + s.Skill_Category__c + 'Match=' + s.Skill_Category__c != 'SkillCategory');
        If (s.Skill_Category__c != 'SkillCategory')
        {
        for(Contact c: [SELECT Id FROM Contact]) {//For Each contact
           ConSkills = new Consultant_Skill__c();
           ConSkills.Contact__c = c.Id;
           system.debug('c.id=' + c.Id);
           ConSkills.Skill__c = s.Id;
           system.debug('s.id=' + s.Id);
           ConSkills.Rating__c = '0';
           ConSkills.Manager_Rating__c ='0';
           //ConSkills.Consultant_Skill_Key__c = s.Id.valueOf(String str); + '_' + s.id;  
           consultantSkillsList.add(ConSkills);
           }//For Each Contact
        } //SkillCategory Check
    }
    if(!consultantSkillsList.isEmpty()) {    
        insert consultantSkillsList;//insert junction records
    }       
}