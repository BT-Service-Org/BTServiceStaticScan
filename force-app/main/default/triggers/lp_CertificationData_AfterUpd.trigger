/**
    About
    -----
    Description: After Update/Insert Trigger on lp_Certficate_Data__c
    Create date: April 2014
    
    Author
    ---------------
    Allan Hasgard Olesen Høybye
    
    
    Actions/Filters
    ---------------  
    // TODO: Unfinished trigger. Purpose was to update consultant milestone progress based on completion of certs and badges etc.
    
*/

trigger lp_CertificationData_AfterUpd on Certification_Data__c (after insert, after update) 
{
    /*
    List<Id> ContactIds = new List<Id>();
    
    for (lp_CertificationData__c cd : Trigger.new )
    {
        ContactIds.add(cd.Contact__c);        
    }
    
    LP_ConsultantMilestone_SVC.recalculateMilestoneProgress(ContactIds);
    */
    
    // New Code added by SD - 06/10 (Add check to make sure it is completed)
    List<Certification_Data__c> certData = new List<Certification_Data__c>();
    
    for (Certification_Data__c cd : Trigger.new )
    {
        if ( cd.Original_Certification_Date__c != null)
            certData.add(cd);        
    }
    
    lp_UpdateConsultantMilestones.updateCertificateData(certData);
}