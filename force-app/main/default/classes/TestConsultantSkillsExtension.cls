@isTest
public class TestConsultantSkillsExtension {

    public static testMethod void testConsultantSkillsExtension() {
        // start the test
        Test.startTest();
        
        ConsultantSkillsExtension_VG2 skillsExtension = SkillsAppTestDataFactory.createSkillsExtension();
        
        //Test GetSkills
        skillsExtension.getSkills();
        //system.debug('GetSkills' +skillsExtension.getSkills());
        
        //Test GetAverageScoresMgr
        skillsExtension.getAverageScoresMgr();
        System.debug('GetAverageScoresMgr' + skillsExtension.getAverageScoresMgr().get('Core Platform').get('Application Design'));
        System.assertEquals(skillsExtension.getAverageScoresMgr().get('Core Platform').get('Application Design'), 1);
        system.debug('GetAverageScoresMgr Test Passed');
        
        //Test GetAverageScores
        skillsExtension.getAverageScores();
        System.debug('Get Average Scores' + skillsExtension.getAverageScores());
        System.assertEquals(skillsExtension.getAverageScores().get('Core Platform').get('Application Design'), 2);
        system.debug('GetAverageScores Test Passed');
        //Test GetBadgeImageMap
        
        skillsExtension.getBadgeImageMap();
        
        //GetCategories
		List<Skill__c> CategoriesTest = skillsExtension.getCategories();
        system.debug('CategoriesTest'+ CategoriesTest.size());
        System.debug('SkillsList'+SkillsAppTestDataFactory.skillsList.size());
        System.assertEquals(CategoriesTest.size(), SkillsAppTestDataFactory.skillsList.size());
        system.debug('GetCategories Test Passed');
        
        skillsExtension.getCategoryAverages();
        system.debug('Category Averages+' + skillsExtension.getCategoryAverages());
        System.assertEquals(skillsExtension.getCategoryAverages().get('Core Platform'), 2);
        system.debug('GetCategoryAverages Test Passed');
        
        skillsExtension.getConsultantALP();
        
        skillsExtension.getConsultantProjects();
        
        skillsExtension.getlowSkills();
        
        skillsExtension.getSkillManagerRating();
        
		skillsExtension.getSkillSelfRating();
        
        skillsExtension.getTopSkills();
        
        skillsExtension.goToEdit();
        
 		// Add parameters to page URL (Parameters for both UpdateManagerRating and update Self Rating)
		
        Skill__C skill = SkillsAppTestDataFactory.skillsList[0];
		Apexpages.currentPage().getParameters().put('theID', skill.Id);
        Apexpages.currentPage().getParameters().put('theRating', '1');
 		skillsExtension.updateManagerRating();
        Map <String, Integer> skillsMapManager = skillsExtension.getSkillManagerRating();
        Integer ratingManager = skillsMapManager.get(skill.Id);       
        System.assertEquals(ratingManager, 1);
        System.debug('update manager rating test successful');
        
        skillsExtension.saveEdits();
          
        skillsExtension.cancel();
        
        
        // Testing getSkillSelfRating: Note change theRating to ensure difference from self
		Map <String, Integer> skillsMapSelf = skillsExtension.getSkillSelfRating();
        Integer ratingSelf = skillsMapSelf.get(skill.Id);
        Apexpages.currentPage().getParameters().put('theRating', '2');
        skillsExtension.updateSelfRating();
        System.assertEquals(ratingSelf, 2);
        System.debug('update self rating test successful');
       
        Test.stopTest();
    }
        
}