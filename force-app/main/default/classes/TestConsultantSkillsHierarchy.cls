@isTest
private class TestConsultantSkillsHierarchy{
    static testmethod void testGetHierarchy() {
    	// start the test
        Test.startTest();
        
        // create the hierarchy model and related objects using the factory
    	ConsultantSkillsHierarchyModel_VG hierarchyModel = SkillsAppTestDataFactory.createHierarchy();
        Contact consultant=SkillsAppTestDataFactory.consultantList[0];
        
        // test get hierarchy
        hierarchyModel.getHierarchy();
        
        // test get skill ids   
        hierarchyModel.getSkillIds();
        
        // test categories
        List<Skill__c> categories = hierarchyModel.getCategories();
        String categoryInput, categoryOutput;
        categoryOutput = categories[0].Skill_Category__c;
        categoryInput = 'Core Platform';
        // compare the value initialized in factory class with the stored value in hierarchy
        System.assertEquals(categoryInput, categoryOutput);
        System.debug('get categories test passed');
        
        // test get badge map
        hierarchyModel.getBadgeImageMap();
        
        // test get type ids
        hierarchyModel.getTypeIds();
        
        // test get type map
        hierarchyModel.getTypeMap();
        
        // test that the initial ratings have been set to 2
        Map<String, Integer> selfRating = hierarchyModel.getSkillSelfRating(consultant);
        List<Skill__C> skillsList = SkillsAppTestDataFactory.skillsList;
        String skillId = skillsList[0].Id;
        Integer rating = selfRating.get(skillId);
        System.assertEquals(rating, 2);
        System.debug('get skill self rating test passed');
        
        // test manager rating
        Map<String, Integer> managerRating = hierarchyModel.getSkillManagerRating(consultant);
        rating = managerRating.get(skillId);
        System.assertEquals(rating, 1);
        System.debug('get manager rating test passed');
        
        // test manager rating update
        hierarchyModel.updateManagerRating(consultant, skillId, 3);
        managerRating = hierarchyModel.getSkillManagerRating(consultant);
        rating = managerRating.get(skillId);
        System.assertEquals(rating, 3);
        System.debug('update manager rating test passed');
        
        // test self rating update
        hierarchyModel.updateSelfRating(consultant, skillId, 4);
        selfRating = hierarchyModel.getSkillSelfRating(consultant);
        rating = selfRating.get(skillId);
        System.assertEquals(rating, 4);
        System.debug('update skill self rating test passed');
        
        Test.stopTest();
    }
}