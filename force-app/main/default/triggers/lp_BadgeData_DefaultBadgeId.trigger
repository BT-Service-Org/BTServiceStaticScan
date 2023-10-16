trigger lp_BadgeData_DefaultBadgeId on Badge_Data__c (before insert, before update) 
{
    Set<String> badges = new Set<String>();
    
    for (Badge_Data__c bd : Trigger.New)
    {
        if (bd.Badge__c == null)
            badges.add(bd.Name);   
    }
    
    Map<String, Id> badgeMap = new Map<String, Id>();
    //for (Badge__c b : [SELECT Name, Id FROM Badge__c WHERE Name in :badges])
    for (Badge__c b : [SELECT Name, Id FROM Badge__c WHERE Name in :badges])
    {
        badgeMap.put(b.Name, b.Id);
    }
    
    for (Badge_Data__c bd : Trigger.New)
    {
        if (bd.Badge__c == null)
            bd.Badge__c = badgeMap.get(bd.Name);
    }
    
}