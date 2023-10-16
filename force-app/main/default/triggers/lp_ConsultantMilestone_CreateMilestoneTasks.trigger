trigger lp_ConsultantMilestone_CreateMilestoneTasks on lp_Consultant_Milestone__c (after insert) 
{
    List<lp_Consultant_Milestone__c> listConsultantMilestones = new List<lp_Consultant_Milestone__c>();
    
    for (lp_Consultant_Milestone__c cm : Trigger.New)
    {
        listConsultantMilestones.add(cm);
    }
    
    lp_CreateConsultantMilestoneTasks.CreateTasks(listConsultantMilestones);

}