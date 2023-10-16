trigger lp_Certification_DefaultCertificationId on Certification_Data__c (before insert, before update) 
{
    Set<String> certs = new Set<String>();
    //List<Certification_Data> certsToUpdate = new List<Certification_Data>();
    for (Certification_Data__c cd : Trigger.New)
    {
        if (cd.Certification__c == null)
        {
            certs.add(cd.Certification_Type_Name__c);  
            //certsToUpdate.add(cd); 
        }
    }
    
    Map<String, Id> certMap = new Map<String, Id>();
    for (lp_Certificate__c c : [SELECT Name, Id FROM lp_Certificate__c WHERE Name in :certs])
    {
        certMap.put(c.Name, c.Id);
    }
    
    for (Certification_Data__c cd : Trigger.New)
    {
        if (cd.Certification__c == null)
            cd.Certification__c = certMap.get(cd.Certification_Type_Name__c);
    }
}