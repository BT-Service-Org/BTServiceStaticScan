/**
    About
    -----
    Description: After Update/Insert Trigger on PA_Onboarding_Project__c
    Create date: April 2014
    
    Author
    ---------------
    Allan Hasgard Olesen Høybye
    
    
    Actions/Filters
    ---------------  
    When Project information is changed, update Consultant Milestones accordingly
    
*/
trigger lp_Project_AfterUpdate on PA_Onboarding_Project__c (after insert, after update) 
{
    
    List<Id> ContactIds = new List<Id>();
    
    for (PA_Onboarding_Project__c p : Trigger.new )
    {
        ContactIds.add(p.Consultant__c);        
    }
    
    //LP_ConsultantMilestone_SVC.recalculateMilestoneProgress(ContactIds);
    //lp_ConsultantMilestone_SVC.updateProjectProgress(ContactIds);
    // Moved to lp_UpdateConsutlantMilestones - SD - 06/25/2014
    lp_UpdateConsultantMilestones.updateProjectProgress(ContactIds);

}