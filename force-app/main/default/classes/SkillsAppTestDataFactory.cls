@isTest
// This class is the test factory class that creates HierarchyModel and all associated objects
public class SkillsAppTestDataFactory{
    public static List<Contact> consultantList = new List<Contact>();
    public static List<Skill__C> skillsList = new List<Skill__C>();
    
    public static ConsultantSkillsExtension_VG2 createSkillsExtension() {
        // create the hierarchy model and related objects using the factory
    	ConsultantSkillsHierarchyModel_VG hierarchyModel = SkillsAppTestDataFactory.createHierarchy();
        Contact consultant=SkillsAppTestDataFactory.consultantList[0];
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(consultant);
        ConsultantSkillsExtension_VG2 TestExt = new ConsultantSkillsExtension_VG2(stdCtrl);
      
        //set the test page as the visual force page consultantskillsedit2
        PageReference TestPage = Page.consultantskillsedit2;
        Test.setCurrentPageReference(TestPage);
        
        ConsultantSkillsExtension_VG2 skillsExtension = new ConsultantSkillsExtension_VG2(stdCtrl);
        
        return skillsExtension;
    }
    
    public static ConsultantSkillsHierarchyModel_VG createHierarchy() {
        ConsultantSkillsHierarchyModel_VG hierarchyModel = new ConsultantSkillsHierarchyModel_VG();
        
        // Create a consultant
        consultantList.add(createConsultant('Test1', 'Test1', 'test@testorg.com'));
        System.debug('Test consultant created');
        
        // Create skills
        skillsList.add(createSkill('Core Platform', 'Application Design', 'Application Servers'));
        skillsList.add(createSkill('Enterprise Architecture', 'Integration', 'Informatica'));
        skillsList.add(createSkill('Interaction & Communication', 'Facilitation', 'Facilitation'));
        System.debug('Test skills created');
        
        // Create junction object
        createConsultantSkills(consultantList[0], skillsList[0]);
        createConsultantSkills(consultantList[0], skillsList[1]);
        createConsultantSkills(consultantList[0], skillsList[2]);
        System.debug('Test consultant skills junction object created');
        
        // initialize the hierarchy model with the consultant

        hierarchyModel.initializeHierarchy(consultantList[0]);
        	
        return hierarchyModel;
    }
    
    // Create consultant
    public static Contact createConsultant(String firstName, String lastName, String email) {
        Contact consultant = new Contact(FirstName = firstName, LastName=lastName, Email=email, Title__c='TestTitle', Role__c='Director, Technical Solution Architect', 
                         Organization__c ='Salesforce');
        insert consultant;
        
        return consultant;
    }
    
    // Create skills
    public static Skill__C createSkill(String category, String type, String skillDesc) {
        Skill__C skill = new Skill__c();
         
        // initialize the skills category and type 
       	skill.Skill_Category__c= category;   	
       	skill.Skill_Type__c = type;
       	skill.Skill__C = skillDesc;

        insert skill;
        
        return skill;  
    }
    
    // Create junction object
    public static void createConsultantSkills(Contact consultant, Skill__c skill) {
         Consultant_Skill__c conskills;
         conskills = new Consultant_Skill__c();
         //initialize the ratings
         conskills.Contact__c = consultant.Id;
         conskills.Skill__c = skill.Id;
         conskills.Rating__c = '2';
         conskills.Manager_Rating__c ='1';
         insert conskills;
    }
    
}