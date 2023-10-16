trigger Rubric_Trigger on Rubric__c (after update)
{
    // Rebuild objectives
    if (trigger.isAfter && trigger.isUpdate && !Rubric_Helper.inTrigger)
    {
        List <Id> rubricsToRebuild = new List<Id>();

        for (Rubric__c r : trigger.new)
        {
            if (r.Rebuild_Objectives__c)
            {
                rubricsToRebuild.add(r.id);
            }
        }

        if (!rubricsToRebuild.isEmpty())
        {
            Rubric_Helper.inTrigger = true;
            Rubric_Helper.RebuildObjectives(rubricsToRebuild);
        }
    }
}