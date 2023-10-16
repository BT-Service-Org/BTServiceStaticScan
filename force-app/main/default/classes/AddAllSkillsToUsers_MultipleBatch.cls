global class AddAllSkillsToUsers_MultipleBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global list<Consultant_Skill__c> cs = new list<Consultant_Skill__c>{};
  
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT contact__c, skill__c from Consultant_Skill__c';
        return Database.getQueryLocator(query);
        
    }
   
    global void execute(Database.BatchableContext BC, list<Consultant_Skill__c> cs1)
    {
    // Add all skills to all users who don't already have a value
    // for that skill 
    cs.addAll(CS1);
    System.debug('Size=' + cs.size());
    }
    
    
  global void finish(Database.BatchableContext BC)
    {

  List<Consultant_Skill__c> consultantSkillsList = new List<Consultant_Skill__c>();
    Consultant_Skill__c conskills;
  
    //Initialize the Skills List
    System.debug('InProcess');
    List<Skill__c> sk = [select id, Name, skill__c from Skill__c];        
    List<Contact> co = [SELECT Id, Name FROM Contact];        
    system.debug('sk.size=' + sk.size() + 'co.size=' + co.size() + 'cs.size=' + cs.size());
    set<string> cs_set = new set<string>{};       
    //system.debug('Testing123' + CS.size());
    for (Integer i=0;i<CS.size();i++) {
      cs_set.add(cs.get(i).contact__c + '_' + cs.get(i).skill__c);
        //System.debug('===' + CS.get(i).contact__c + '_' + cs.get(i).skill__c);
  }
    
    for (Skill__c s : sk) //artificial limit to 5, remove after testing
    {
        //Add the skill to each Contact with a default value of 0
        for(Contact c: co)
        {//For Each contact - artificial limit to 5, remove after testing
            //check if the skill has been added to that contact
          //System.debug('Checking... c.id=' + c.Id + ' c.Name' + c.Name + ' s.id=' + s.Id + ' s.name=' + s.Name + ' s.skill=' + s.Skill__c);
              //system.debug('cs_set contains' + cs_set.contains(c.id + '_' + s.id));                   
              if (!cs_set.contains(c.id + '_' + s.id)) 
                { //If the existing skill/consultant record is no in the junction table
                   ConSkills = new Consultant_Skill__c();
                   ConSkills.Contact__c = c.Id;
                   ConSkills.Skill__c = s.Id;
                   ConSkills.Rating__c = '0';
                   ConSkills.Manager_Rating__c ='0';
                   System.debug('Adding c.id=' + c.Id + ' ' + c.Name + ' s.id=' + s.Id + ' s.name=' + s.Name + ' s.skill=' + s.Skill__c + ' Size=' + consultantSkillsList.size());
                   consultantSkillsList.add(ConSkills);
                } else {
                  System.debug('Already Contains... c.id=' + c.Id + ' c.Name' + c.Name + ' s.id=' + s.Id + ' s.name=' + s.Name + ' s.skill=' + s.Skill__c + ' Size=' + consultantSkillsList.size());
                
                } //EndIf
        //cs_set.remove(c.id + '_' + s.id);
        } //Next Contact
    }//Next Skill
  System.debug('Rowcount to add=' + consultantSkillsList.size());
  if(!consultantSkillsList.isEmpty()) {    
  system.debug('In Update');
    insert consultantSkillsList;//insert junction records
  } 
        //endif
  }// end finish
}//end class