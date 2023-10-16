public class lp_CreateConsultantMilestoneTasks
{
    public static void CreateTasks(List<lp_Consultant_Milestone__c> consultantMilestones)
    {
        // Variables
        // Learning Path Ids
        Set<Id> lpIds = new Set<Id>();
        
        // List of Certifications to add
        List<lp_Consultant_Milestone_Certification__c> cmCertsToAdd = new List<lp_Consultant_Milestone_Certification__c>();
        
        // List of Badages to add
        List<lp_Consultant_Milestone_Badge__c> cmBadgesToAdd = new List<lp_Consultant_Milestone_Badge__c>();
    
        // For each consultant milestone, create instaniation of badges, certs, and learning domain
        // Note, tasks won't be created for projects, these will need to be created when the project is updated
        // 1. Get list of Learning Path Milestone for Consultant Milestones
        for (lp_Consultant_Milestone__c cm : consultantMilestones)
        {
            lpIds.add(cm.Learning_Path_Milestone__c);
        }
        
        // 2. Get list of certifications for each learning path and add to map
        // For each consultant milestone, get the certification data
        List<lp_CertificationGroup__c> cmCertifications = [SELECT Id, Learning_Path_Milestone__c, Certificate__c 
                                                              from lp_CertificationGroup__c
                                                              where Learning_Path_Milestone__c in :lpIds];
        
        // Create Map of Certifications
        Map<Id, List<lp_CertificationGroup__c>> mapCertification = new Map<Id, List<lp_CertificationGroup__c>>();
        // Populate Map of Certifications
        for (lp_CertificationGroup__c c : cmCertifications)
        {
            if (mapCertification.containsKey(c.Learning_Path_Milestone__c))
            {
                // Add Cert to existing key
                List<lp_CertificationGroup__c> listCert = mapCertification.get(c.Learning_Path_Milestone__c);
                lp_CertificationGroup__c addCert = new lp_CertificationGroup__c(Id=c.Id, Certificate__c=c.Certificate__c);
                listCert.add(addCert);
                mapCertification.put(c.Learning_Path_Milestone__c, listCert);
            }
            else
            {
                // Add Certification to New Key
                List<lp_CertificationGroup__c> listCert = new List<lp_CertificationGroup__c>();
                lp_CertificationGroup__c addCert = new lp_CertificationGroup__c(Id=c.Id, Certificate__c=c.Certificate__c);
                listCert.add(addCert);
                mapCertification.put(c.Learning_Path_Milestone__c, listCert);
            }
            
        }
              
        
        // 3. Get list of badges for each learning path and add to map
        // For each consultant milestone, get the badge data
        List<lp_BadgeGroup__c> cmBadges = [SELECT Id, Learning_Path_Milestone__c, Badge__c 
                                                              from lp_BadgeGroup__c
                                                              where Learning_Path_Milestone__c in :lpIds];
                                                              
        // Create Map of Badges
        Map<Id, List<lp_BadgeGroup__c>> mapBadges = new Map<Id, List<lp_BadgeGroup__c>>();
        // Populate Map of Badges
        for (lp_BadgeGroup__c c : cmBadges)
        {
            if (mapBadges.containsKey(c.Learning_Path_Milestone__c))
            {
                // Add Badge to existing key
                List<lp_BadgeGroup__c> listBadge = mapBadges.get(c.Learning_Path_Milestone__c);
                lp_BadgeGroup__c addBadge = new lp_BadgeGroup__c(Id=c.Id, Badge__c=c.Badge__c);
                listBadge.add(addBadge);
                mapBadges.put(c.Learning_Path_Milestone__c, listBadge);
            }
            else
            {
                // Add Badge to New Key
                List<lp_BadgeGroup__c> listBadge = new List<lp_BadgeGroup__c>();
                lp_BadgeGroup__c addBadge = new lp_BadgeGroup__c(Id=c.Id, Badge__c=c.Badge__c);
                listBadge.add(addBadge);
                mapBadges.put(c.Learning_Path_Milestone__c, listBadge);
            }
            
        }

        // For each consultant milestone, get the learning domain data
        // Question: How do I tell the difference between a learning domain and badage?
        /*
        List<lp_BadgeGroup__c> cmLearningDomain = [SELECT Id, Learning_Path_Milestone__c, Badge__c 
                                                              from lp_BadgeGroup__c
                                                              where Learning_Path_Milestone__c = :Trigger.New];
        */
        
        for (lp_Consultant_Milestone__c cm : consultantMilestones)
        {
            // Add Certification Group
            List<lp_CertificationGroup__c> listCert = new List<lp_CertificationGroup__c>();
            listCert = mapCertification.get(cm.Learning_Path_Milestone__c);
            if (listCert != null)
            {
                for (lp_CertificationGroup__c cg : listCert)
                {
                    lp_Consultant_Milestone_Certification__c cmc = new lp_Consultant_Milestone_Certification__c();
                    cmc.Consultant_Milestone__c = cm.Id;
                    cmc.lp_Certificate__c = cg.Certificate__c;
                    cmc.Certification_Group__c = cg.Id;
                    cmCertsToAdd.add(cmc);
                }
            }
            
            // Add Badge/Learning Badge Data
            List<lp_BadgeGroup__c> listBadge = new List<lp_BadgeGroup__c>();
            listBadge = mapBadges.get(cm.Learning_Path_Milestone__c);
            if (listBadge != null)
            {
                for (lp_BadgeGroup__c bg : listBadge)
                {
                    lp_Consultant_Milestone_Badge__c cmb = new lp_Consultant_Milestone_Badge__c();
                    cmb.Consultant_Milestone__c = cm.Id;
                    cmb.lp_Badge__c = bg.Badge__c;
                    cmb.Badge_Group__c = bg.Id;
                    cmBadgesToAdd.add(cmb);
                }
            }
        
        
        }
        
        // Add Consultant Milestone Certificates
        if (!cmCertsToAdd.isEmpty())
        {
            insert cmCertsToAdd;        
        }
        
        // Add Consultant Milestone Badges
        if (!cmBadgesToAdd.isEmpty())
        {
            insert cmbadgesToAdd;        
        }
        
    }
}