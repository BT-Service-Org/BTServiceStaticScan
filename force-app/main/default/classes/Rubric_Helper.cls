public with sharing class Rubric_Helper
{
    /* Rebuild Objectives
        Fairly destructive process that will clear out all the objectives and rebuild from the template
    */

    // Prevents trigger recursion
    public static Boolean inTrigger = false;

    public static void RebuildObjectives(List <Id> rubricIds)
    {
        // get the list of rubrics
        List <Rubric__c> rubrics = [select Learning_Domain__c, Skill__c, Rebuild_Objectives__c from Rubric__c where Id in :rubricIds];

        // get the template objectives for the skill and create a map out of it
        Map<String, List<Rubric_Objective__c>> skillToObjTemplate = new Map<String, List<Rubric_Objective__c>>();
        PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('Template PA Onboarding Id');
        String recId = paTemplate.Value__c;
        List<Rubric__c> templateRubrics = [select Skill__c,
                                                  (select Domain_Rubric_Objective__c, Objective__c, Score_Definition_1__c,
                                                          Score_Definition_3__c, Score_Definition_5__c, Skill_Definition__c,
                                                          Special_Objective__c
                                                  from Rubrics_Objectives__r)
                                           from Rubric__c
                                           where Learning_Domain__r.PA_Onboarding__c = :recId];
        for (Rubric__c r : templateRubrics)
        {
            skillToObjTemplate.put(r.Skill__c, r.Rubrics_Objectives__r);
        }

        // delete all the rubrics first
        List <Rubric_Objective__c> objsToDel = [select id from Rubric_Objective__c where rubric__c in :rubricIds];
        delete objsToDel;

        // recreate the objectives
        List <Rubric_Objective__c> objsToAdd  = new List <Rubric_Objective__c>();

        for (Rubric__c r : rubrics)
        {
            r.Rebuild_Objectives__c = false;
            for (Rubric_Objective__c rot : skillToObjTemplate.get(r.Skill__c))
            {
                Rubric_Objective__c ro = new Rubric_Objective__c();
                ro.Rubric__c = r.Id;
                ro.Domain_Rubric_Objective__c = rot.Domain_Rubric_Objective__c;
                ro.Objective__c = rot.Objective__c;
                ro.Score_Definition_1__c = rot.Score_Definition_1__c;
                ro.Score_Definition_3__c = rot.Score_Definition_3__c;
                ro.Score_Definition_5__c = rot.Score_Definition_5__c;
                ro.Skill_Definition__c = rot.Skill_Definition__c;
                ro.Special_Objective__c = rot.Special_Objective__c;
                objsToAdd.add(ro);
            }
        }

        insert objsToAdd;
        // reset the rebuild flag
        update rubrics;
    }
}