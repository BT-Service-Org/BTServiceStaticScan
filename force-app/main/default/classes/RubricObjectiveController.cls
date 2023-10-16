public class RubricObjectiveController {
    private final Rubric_Objective__c rubricObj;
    
    public RubricObjectiveController() {
        rubricObj = [SELECT Id, Objective__c,Score__c, Score_Comments__c, Score_Definition_1__c, Score_Definition_3__c,
                      Score_Definition_5__c, Skill__c, Skill_Definition__c 
                FROM Rubric_Objective__c
                WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
    }
    
    public Rubric_Objective__c getRubricObj() {
        return rubricObj;
    }

    public PageReference saveScores() {
        update rubricObj;
        return null;
    } 
}