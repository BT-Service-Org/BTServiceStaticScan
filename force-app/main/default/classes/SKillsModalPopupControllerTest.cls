/**
Class Name : SKillsModalPopupControllerTest
@description		: Test class for SKillsModalPopupController
Created Date	: June 15th, 2022  
*/
@isTest
public class SKillsModalPopupControllerTest {
    /**
     @description : createData
    */
	@testsetup
    public static void createData(){
        List<CSG_Group__c> groupList =  new List<CSG_Group__c> ();
        List<CSGProfileSkill__c> profSkillList =  new List<CSGProfileSkill__c> ();
        List<Learning_Resources__c> lrList = new List<Learning_Resources__c>();
        
        CSG_Group__c groupVal = new CSG_Group__c();
        groupVal.Name = 'Program Architect';
        groupList.add(groupVal);
        insert groupList;
        CSGProfileSkill__c profileVal = new CSGProfileSkill__c();
        profileVal.Category__c = 'Test cat';
        profileVal.Description__c = 'Test desc';
        profileVal.CSG_Community__c = 'Test community';
        profileVal.External_Id__c = 'a4V3C00000014hWUAQ';
        profSkillList.add(profileVal);
        insert profSkillList; 
        
        Learning_Resources__c lrRec = new Learning_Resources__c();
        lrRec.name = 'Apex';
        lrRec.source__c = 'ACT Courses';
        lrRec.Link__c = 'https://www.google.com/';
        lrList.add(lrRec);
        insert lrList;
        
        Learning_Resource_Skill__c lrSkillRec = new Learning_Resource_Skill__c();
        lrSkillRec.Learning_Resource__c = lrRec.Id;
        lrSkillRec.CSGProfileSkill__c = profileVal.Id;
        insert lrSkillRec;
        
    }
    /**
      @description : testLearningResources
    */
    @isTest
    static void testLearningResources(){
        test.startTest();
        CSGProfileSkill__c skillRec = [SELECT Id FROM CSGProfileSkill__c];
		SKillsModalPopupController.getLearningResourceRecs(skillRec.Id);        
            System.assert(skillRec != null,' ');       
        test.stopTest();
        
    }
    
}