global class AddSkillsToUsers_Batch_MS2 implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select id, Name, skill__c from Skill__c';
        return Database.getQueryLocator(query);
       
    }
   
    global void execute(Database.BatchableContext BC, list<Skill__c> s1)
    {
    // Add all skills to all users who don't already have a value
    // for that skill 
    
    //Initialize Consultant_Skill__c
    List<Consultant_Skill__c> consultantSkillsList = new List<Consultant_Skill__c>();
    Consultant_Skill__c conskills;
    
    //Initialize Contact
    List<Contact> co = [SELECT Id, Name FROM Contact];
        
    //Initialize the Skills List
    for (Skill__c s : s1) //artificial limit to 5, remove after testing
    {
        Consultant_Skill__c[] CSL = [SELECT Id FROM Consultant_Skill__c where Consultant_Skill__c.Skill__c = :s.id];
        try{
            delete CSL;
            System.debug('Successfully Deleted:'+s.name);
            }  catch (DmlException e)  {
            System.debug('ERROR' + e.getMessage());
            }//end try catch
        
        //Add the skill to each Contact with a default value of 0
        for(Contact c: co)
        {//For Each contact - artificial limit to 5, remove after testing                  
                   ConSkills = new Consultant_Skill__c();
                   ConSkills.Contact__c = c.Id;
                   ConSkills.Skill__c = s.Id;
                   ConSkills.Rating__c = '0';
                   ConSkills.Manager_Rating__c ='0';
                   System.debug('Adding c.id=' + c.Id + ' ' + c.Name + ' s.id=' + s.Id + ' s.name=' + s.Name + ' s.skill=' + s.Skill__c);
                   consultantSkillsList.add(ConSkills);
        } //Next Contact
        System.debug('Rowcount to add=' + consultantSkillsList.size() + ' s.name=' + s.Name);
        if(!consultantSkillsList.isEmpty()) {    
            system.debug('In Update');
            try{
            insert consultantSkillsList;//insert junction records
            system.debug('Insert Successful:'+s.name);
            }  catch (DmlException e)  {
            System.debug('ERROR' + e.getMessage());
            }//end try catch
            consultantSkillsList.clear();
        } //endif
    }//Next Skill
    }//execute
    
    
    global void finish(Database.BatchableContext BC)
    {


  }// end finish
}//end class