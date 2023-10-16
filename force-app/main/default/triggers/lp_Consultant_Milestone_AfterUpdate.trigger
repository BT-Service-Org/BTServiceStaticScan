/* 
    About:  After update trigger on Consultant Milestone object
    Filters: 
            1) Where the expected completion date has been brought forward (ex. due to early completion) bring the other milestones onthe timeline forward by the same amount 
    History:
            > Draft: April '14 / M.Evans
    Todo:
            LP_ConsultantMilestone_SVC service class / not tested or prototyped 
*/

trigger lp_Consultant_Milestone_AfterUpdate on lp_Consultant_Milestone__c (after update) 
{
    //map<Id, LP_ConsultantMilestone_SVC.ShiftedMilestone[]> shiftedMilestonesByConsultantId = new map<Id, LP_ConsultantMilestone_SVC.ShiftedMilestone[]>();
    // New Code added by SD
    if (trigger.IsUpdate)
    {
        // Stores milestone and number of days (variance)
        Map<Id, Integer> milestoneVariance = new Map<Id, Integer>();
        Map<Id, lp_Consultant_Milestone__c> milestoneVarianceNew = new Map<Id, lp_Consultant_Milestone__c>();
        
        // Loop thru all updated consultant milestones
        for (lp_Consultant_Milestone__c m : Trigger.New)
        {
            // Filter 1 - Brought forward and completed
            if (m.Milestone_Complete__c && m.Milestone_Complete__c != Trigger.oldMap.get(m.Id).Milestone_Complete__c && m.Impacts_Timeline__c)
            {
                Integer daysVariance =  (Integer)m.Variance__c;
                
                // Add milestone and variance to map
                milestoneVariance.put((Id)m.PA_Onboarding__c, daysVariance);
                
                // Add milestone to map
                milestoneVarianceNew.put((Id)m.PA_Onboarding__c, m);
            }
        }
        
        System.debug('milestoneVariance = ' + milestoneVariance);
        //PP: called a service class method to recalculate completion dates based on variance
        /*if (!milestoneVariance.isEmpty())
            lp_ConsultantMilestone_SVC.recalculateCompletionDatesBasedOnVariance(milestoneVariance);*/

        if (!milestoneVarianceNew.isEmpty())
            lp_ConsultantMilestone_SVC.adjustCompletionDatesBasedOnVariance(milestoneVarianceNew);
    }
}