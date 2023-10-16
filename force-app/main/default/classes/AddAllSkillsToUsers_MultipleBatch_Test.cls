@isTest
public class AddAllSkillsToUsers_MultipleBatch_Test{
    public static testMethod void AddAllSkillsToUsers_MultipleBatch_Test() {
    // Create 200 test accounts - this simulates one execute.  
    // Important - the Salesforce.com test framework only allows you to 
    // test one execute.  
    
       Test.StartTest();
      
        //Build Contact Test object/data
        List <Contact> ListContacts = new List<Contact>();
          for(integer i = 0; i<10; i++){
             Contact c = new Contact(LastName='testContact'+i); 
             ListContacts.add(c);
          }
       Insert ListContacts;
       
        //Build Skills test objects/data       
       List <Skill__c> ListSkills = new List<Skill__c>();
       for(integer i = 0; i<10; i++){
             Skill__c s= new Skill__C(Skill__c='TestSkill_'+i, Skill_Category__c='SkillCategory', Skill_Type__c='SkillType'); 
             ListSkills.add(s);
       }
       Skill__c s= new Skill__C(Skill__c='TestSkill_Added', Skill_Category__c='SkillCategoryOverride', Skill_Type__c='SkillTypeOverride'); 
       ListSkills.add(s);
       system.debug('');
       insert ListSkills;

       
        
        
        AddAllSkillsToUsers_Multiplebatch basu = new AddAllSkillsToUsers_Multiplebatch();
        database.executeBatch(basu);
  
 
        Test.StopTest();
    
        System.AssertEquals(
               database.countquery('SELECT COUNT()'
                  +' FROM Consultant_Skill__c'),110); 
    }
}