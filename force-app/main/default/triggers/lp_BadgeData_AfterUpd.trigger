/**
    About
    -----
    Description: After Update/Insert Trigger on lp_BadgeData__c
    Create date: April 2014
    
    Author
    ---------------
    Allan Hasgard Olesen Høybye
    Sandip Dhara
    
    Actions/Filters
    ---------------  
    // TODO: Unfinished trigger. Purpose was to update consultant milestone progress based on completion of certs and badges etc.
    
*/
trigger lp_BadgeData_AfterUpd on Badge_Data__c (after insert, after update) 
{
    // Commented out by SD - 06/10
    /*
    List<Id> ContactIds = new List<Id>();
    
    for (lp_BadgeData__c bd : Trigger.new )
    {
        ContactIds.add(bd.Contact__c);        
    }
    
    LP_ConsultantMilestone_SVC.recalculateMilestoneProgress(ContactIds);
    */
    
    // New Code added by SD - 6/10
    List<Badge_Data__c> acquiredBadges = new List<Badge_Data__c>();
    for (Badge_Data__c b : Trigger.New)
    {
        if (b.State__c == 'Acquired' && b.Acquired_Date__c != null)
        acquiredBadges.add(b);
    }
    
    if (!acquiredBadges.isEmpty())
        lp_UpdateConsultantMilestones.updateBadgeData(acquiredBadges);
    
}