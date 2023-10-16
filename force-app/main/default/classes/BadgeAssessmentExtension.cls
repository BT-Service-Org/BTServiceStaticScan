public with sharing class BadgeAssessmentExtension {
    private Learning_Domain__c myLd {get;set;}
    public String assignedJudge {get;set;}
    
    
    private BadgeAssessmentController myController;
    
    public BadgeAssessmentExtension(ApexPages.StandardController controller) {
        myLD = (Learning_Domain__c) controller.getRecord();
        
        myController = new BadgeAssessmentController(myLD.id);
    }
    
    public List<SelectOption> getJudgeItems() {
        myController.allowOtherRegionJudges = true;
        return myController.getJudgeItems();
    }
    
    public Learning_Domain__c getLearningDomain() {
        return myController.learningDomain;
    }
    
    public PageReference createBadgeAssessment() {
        myController.assignedJudge = this.assignedJudge;
        PageReference myRef =  myController.createCaseWithSelectedJudge();
        return Page.Badge_Assessment_Request_Confirmation;
    } 
    
    public Judge__c getJudge() {
        return myController.judge;
    }
    
    public Case getCreatedCase() {
        return myController.createdCase;
    }
    
    public PageReference checkPreConditions() {
        return myController.checkPreConditions();
    }
    
    public boolean getValidLearningDomain() {
        return myController.validLearningDomain;
    }
    

}