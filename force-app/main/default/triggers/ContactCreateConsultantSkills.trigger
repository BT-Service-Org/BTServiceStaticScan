trigger ContactCreateConsultantSkills on Contact (after insert) {
List<Consultant_Skill__c> consultantSkillsList = new List<Consultant_Skill__c>();
    Consultant_Skill__c conskills;
    for(Contact c: Trigger.new) {//for all the newly created contact
        
        for(Skill__c s: [SELECT Id FROM Skill__c]) {//here skills are recorded
            conskills = new Consultant_Skill__c();
            //set values
            conskills.Contact__c = c.Id;
            conskills.Skill__c = s.Id;
            conskills.Rating__c = '0';
            conskills.Manager_Rating__c ='0';
            consultantSkillsList.add(conskills);
        }
    }
    if(!consultantSkillsList.isEmpty()) {
        
        insert consultantSkillsList;//insert junction records
    }
}