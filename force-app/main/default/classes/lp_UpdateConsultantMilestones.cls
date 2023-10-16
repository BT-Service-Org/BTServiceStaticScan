public class lp_UpdateConsultantMilestones
{
    public static void updateCertificateData(List<Certification_Data__c> certificationData)
    {
        List<lp_Consultant_Milestone_Certification__c> cmcToUpdate = new List<lp_Consultant_Milestone_Certification__c>();
        
        // Change code to add to Map
        // Map<Id, Id> mapCerts = new Map<Id, Id>();
        Set<Id> contactIds = new Set<Id>();
        for (Certification_Data__c cd : certificationData)
        {
            if (cd.contact__c != null)
                contactIds.add(cd.contact__c);
        }
        
        System.Debug('***************Certification Data *****************: ' + certificationData);       
        List<lp_Consultant_Milestone_Certification__c> listCMCNew = [SELECT Id, Completed__c, Completed_Date__c, lp_Certificate__c, Consultant__c
                                                                          FROM lp_Consultant_Milestone_Certification__c
                                                                          WHERE Consultant_Milestone__r.Consultant__c in :ContactIds];
        if (!listCMCNew.isEmpty())
        {
            for (Certification_Data__c cd : certificationData)
            {
                for (lp_Consultant_Milestone_Certification__c cmc : listCMCNew)
                {
                    if (cd.Contact__c == cmc.Consultant__c && cd.Certification__c == cmc.lp_Certificate__c)
                    {
                        lp_Consultant_Milestone_Certification__c newCMC = new lp_Consultant_Milestone_Certification__c();
                        newCMC.Id = cmc.Id;
                        newCMC.lp_Certificate__c = cd.Certification__c;
                        newCMC.Completed__c = cd.Passed__c;
                        newCMC.Completed_Date__c = cd.Acquired_Date__c;
                        cmcToUpdate.add(newCMC);
                    }
                }
            }
        
        
        }
        
        // Commented out by SD - 07/02
        /*for (Certification_Data__c cd : certificationData)
        {
            // TODO: Change this to a map - Map<Id,Id> - where Ids are consultant certificate
            List<lp_Consultant_Milestone_Certification__c> listCMC = [SELECT Id, Completed__c, Completed_Date__c
                                                                          FROM lp_Consultant_Milestone_Certification__c
                                                                          WHERE Consultant_Milestone__r.Consultant__c = :cd.Contact__c
                                                                          AND lp_Certificate__c = :cd.Certification__c];
            
            System.Debug('***************Consultant*****************: ' + cd.Contact__c);
            System.Debug('***************Certificate *****************: ' + cd.Certification__c);
            System.Debug('***************listCMC *****************: ' + listCMC);
          
            // For each certicate, they could be multiple consultant milestone certificats
            // Create entry in consultant milestone certificate for each instance
            for (lp_Consultant_Milestone_Certification__c l : listCMC)
            {
                lp_Consultant_Milestone_Certification__c newCMC = new lp_Consultant_Milestone_Certification__c();
                newCMC.Id = l.Id;
                newCMC.lp_Certificate__c = cd.Certification__c;
                newCMC.Completed__c = cd.Passed__c;
                newCMC.Completed_Date__c = cd.Acquired_Date__c;
                cmcToUpdate.add(newCMC);
            }
            
        }
        */
        
        // Update Consultant Milestones Certificate Object
        if (!cmcToUpdate.isEmpty())
        {
            update cmcToUpdate;
        }
        
    }
    
    
    public static void updateBadgeData(List<Badge_Data__c> badgeData)
    {
    
        List<lp_Consultant_Milestone_Badge__c> cmbToUpdate = new List<lp_Consultant_Milestone_Badge__c>();
       
        // Change code to add to Map
        //Map<Id, Id> mapBadges = new Map<Id, Id>();
        Set<Id> contactIds = new Set<Id>();
        for (Badge_Data__c bd : badgeData)
        {
            if (bd.contact__c != null)
                contactIds.add(bd.contact__c);
        }
        
        List<lp_Consultant_Milestone_Badge__c> listCMB = [SELECT Id, Completed__c, Completed_Date__c, lp_Badge__c, Consultant__c
                                                                          FROM lp_Consultant_Milestone_Badge__c
                                                                          WHERE Consultant_Milestone__r.Consultant__c in :contactIds];
                                                                          
        if (!listCMB.isEmpty())
        {
            for (Badge_Data__c bd : badgeData)
            {
                for (lp_Consultant_Milestone_Badge__c cmb : listCMB)
                {
                    if (bd.Contact__c == cmb.Consultant__c && bd.Badge__c == cmb.lp_Badge__c)
                    {
                        lp_Consultant_Milestone_Badge__c newCMB = new lp_Consultant_Milestone_Badge__c();
                        newCMB.Id = cmb.Id;
                        newCMB.lp_Badge__c = bd.Badge__c;
                        newCMB.Completed__c = bd.Passed__c;
                        newCMB.Completed_Date__c = bd.Acquired_Date__c.date();
                        cmbToUpdate.add(newCMB);
                    }
                
                }
            
            }
        
        
        }
        
        
        // Commented out by SD - 07/02
        /*
        for (Badge_Data__c bd : badgeData)
        {
            // TODO: Change this to a map - Map<Id,Id> - where Ids are consultant certificate
            List<lp_Consultant_Milestone_Badge__c> listCMB = [SELECT Id, Completed__c, Completed_Date__c
                                                                          FROM lp_Consultant_Milestone_Badge__c
                                                                          WHERE Consultant_Milestone__r.Consultant__c = :bd.Contact__c
                                                                          AND lp_Badge__c = :bd.Badge__c];
                                                                          
            System.Debug('***************Consultant*****************: ' + bd.Contact__c);
            System.Debug('***************badge*****************: ' + bd.Badge__c);
            System.Debug('***************listCMB*****************: ' + listCMB);
            
            // For each certicate, they could be multiple consultant milestone certificats
            // Create entry in consultant milestone certificate for each instance
            for (lp_Consultant_Milestone_Badge__c l : listCMB)
            {
                lp_Consultant_Milestone_Badge__c newCMB = new lp_Consultant_Milestone_Badge__c();
                newCMB.Id = l.Id;
                newCMB.lp_Badge__c = bd.Badge__c;
                newCMB.Completed__c = bd.Passed__c;
                newCMB.Completed_Date__c = bd.Acquired_Date__c.date();
                cmbToUpdate.add(newCMB);
            }
            
        }
        */
        
        // Update Consultant Milestones Badge Object
        if (!cmbToUpdate.isEmpty())
        {
            update cmbToUpdate;
        }
    
    }
    
    
    public static void updateProjectProgress(List<Id> consultantIds)
    {
        // List of consultant Milestones to Update
        List<lp_Consultant_Milestone__c> cmToUpdate = new List<lp_Consultant_Milestone__c>();
        
        // Get Consultant milestones for affected contacts
        List<lp_Consultant_Milestone__c> ConsultantMilestoneList = [SELECT Id, Consultant__c, Learning_Path_Milestone__c, 
                                         Learning_Path_Milestone__r.Project_Hours_Required__c, Learning_Path_Milestone__r.Foundation_Hours_Required__c,
                                         PA_Onboarding__c, Milestone_Complete__c, Actual_Completion_Date__c, IsFoundation__c, IsBillableProject__c,
                                         Progress__c, Actual_Billable_Hours__c, Actual_Non_Billable_Hours__c, Required_Hours__c 
        FROM lp_Consultant_Milestone__c
        WHERE Required_Hours__c > 0
        AND PA_Onboarding__c IN (SELECT Id FROM PA_Onboarding__c WHERE Contact__c IN :consultantIds)];
                                    
        // Get Project Hours
        AggregateResult[] groupedResults = [SELECT Consultant__c, sum(Non_Billable_Hours__c) non_billable_hours, sum(Billable_Hours__c) billable_hours, sum(Foundation_Hours__c) foundation_hours
                               from PA_Onboarding_Project__c
                               where Consultant__c in :consultantIds
                               group by Consultant__c];
        
        // Put Project Hours in a map                       
        Map<String, Decimal> mapNonBillableHours = new Map<String, Decimal>();
        Map<Id, Decimal> mapBillableHours = new Map<Id, Decimal>();
        Map<Id, Decimal> mapFoundationHours = new Map<Id, Decimal>();
        
        for (AggregateResult ar : groupedResults)
        {
            mapNonBillableHours.put((Id)ar.get('Consultant__c'), (Decimal)ar.get('non_billable_hours'));
            mapBillableHours.put((Id)ar.get('Consultant__c'), (Decimal)ar.get('billable_hours'));
            mapFoundationHours.put((Id)ar.get('Consultant__c'), (Decimal)ar.get('foundation_hours'));
        }
     
        
        System.debug(LoggingLevel.INFO, '$$  LP_ConsultantMilestone_SVC:Loop through the consultant milestones');
        // Loop through the consultant milestones
        for (lp_Consultant_Milestone__c consultantMilestone : ConsultantMilestoneList) 
        {
            System.debug(LoggingLevel.INFO, '$$  LP_ConsultantMilestone_SVC: Milestone ' + consultantMilestone);  
            
            //Decimal reqHoursCnt= learningPathMilestone.Project_Hours_Required__c + learningPathMilestone.Foundation_Hours_Required__c;
            
            Decimal nonbillableHoursCnt = 0.0;
            Decimal billableHoursCnt = 0.0;
            Decimal foundationHoursCnt = 0.0;
            
            if (consultantMilestone.IsFoundation__c || consultantMilestone.IsBillableProject__c)
            {
                lp_Consultant_Milestone__c cm = new lp_Consultant_Milestone__c();
                
                cm.Id = consultantMilestone.Id;
                cm.Actual_Billable_Hours__c = mapBillableHours.get(consultantMilestone.Consultant__c);
                cm.Actual_Non_Billable_Hours__c = mapNonBillableHours.get(consultantMilestone.Consultant__c);
                cm.Foundation_Hours__c = mapFoundationHours.get(consultantMilestone.Consultant__c);
                Decimal reqHoursCnt = consultantMilestone.Learning_Path_Milestone__r.Project_Hours_Required__c + consultantMilestone.Learning_Path_Milestone__r.Foundation_Hours_Required__c;
                if (consultantMilestone.Required_Hours__c == null)
                    cm.Required_Hours__c = reqHoursCnt;
                cm.Update_Progress__c = true;
                cmToUpdate.add(cm);
            }
        }
        
        //update ConsultantMilestoneList;
        if (!cmToUpdate.isEmpty())
            update cmToUpdate;
        
    }    


}