/**
    About
    -----
    Description: LaunchPad Service Class
    Create date: April 2014
    
    Author
    ---------------
    Allan Hasgard Olesen Høybye
    Sandip Dhara
    Parag Phanasgaonkar
    
    Modification History
    --------------_____-  
    2014-04-22: AH Added functionality to handle selection/update of the learningpath from the launchpad object - called by trigger
    2014-06-11: SD - This functionality has been moved to lp_PAOnboarding_SVC
    
    
*/
public with sharing class lp_PAOnboarding_SVC {
    
    /**
     * Check Learning Paths
     */
        
    public static void checkForChangedLearningPath(List<PA_Onboarding__c> updatedLPADS) {
        
        System.debug(LoggingLevel.INFO, '$$  START checkLearningPath');
        
        // Loop through the LaunchPads that are modified
        if (updatedLPADS != null && updatedLPADS.size() > 0) {
            
            List<Id> LearningPathIds = new List<Id>();
            List<Id> lpadIds = new List<Id>();
            
            List<lp_Consultant_Milestone__c> newMilestones = new List<lp_Consultant_Milestone__c>();
            List<lp_Consultant_Milestone__c> deactivatedMilestones = new List<lp_Consultant_Milestone__c>();
            
            for (PA_Onboarding__c lpad : updatedLPADS) {
                lpadIds.add(lpad.id);
                // pickup all learningpaths used in this update
                LearningPathIds.add(lpad.Learning_Path__c);
            }
        
            // Get the relevant learningpath milestones (template milestones)
            List<lp_Learning_Path__c> learningPaths = 
                [SELECT Name, Id, (SELECT Id,Name,Description__c,MandatoryMilestone__c, Forecast_Category_Number__c, lp_Forecast_Category__r.Id  FROM lp_Milestone__r Order By Order__c) FROM lp_Learning_Path__c
                WHERE Id in :LearningPathIds];
            
            // Re-write above statement
            List<PA_Onboarding__c> dbLPADS = 
                [SELECT Id, Name, Learning_Path__c, Program_Start_Date__c,
                (SELECT Id, Name, Learning_Path_Milestone__c,PA_Onboarding__c,Active__c, Mandatory_Milestone__c, Forecast_Category__c FROM Consultant_Milestones__r) 
                FROM PA_Onboarding__c
                WHERE Id in :lpadIds];
            
            List<PA_Onboarding__c> changedLPADS= new List<PA_Onboarding__c>();
            
            for (PA_Onboarding__c updatedLPAD : updatedLPADS) // Loop through all updated LaunchPads
            {
                for (PA_Onboarding__c dbLPAD : dbLPADS)  // Loop through all updated LaunchPads
                {
                    // Match the LaunchPads
                    if (dbLPAD.Id == updatedLPAD.Id)
                    {
                        // STEP 1 - De-activate all existing consultant milestones 
                        System.debug(LoggingLevel.INFO, '$$  De-activate all milestones for '+dbLPAD+' '+dbLPAD.Consultant_Milestones__r);
                        for (lp_Consultant_Milestone__c milestone : dbLPAD.Consultant_Milestones__r) 
                        {
                                System.debug(LoggingLevel.INFO, '$$  De-activate milestone: '+milestone);
                                milestone.Active__c = False;
                                deactivatedMilestones.add(milestone);
                        }
                                
                        System.debug(LoggingLevel.INFO, '$$  Find new learningpath '+updatedLPAD.Learning_Path__c+' in '+learningPaths);
                        // STEP 2 - Find the new learning path for the updated launchpad
                        for (lp_Learning_Path__c LPATH : learningPaths) 
                        {
                            if (LPATH.Id==updatedLPAD.Learning_Path__c)
                            {
                                System.debug(LoggingLevel.INFO, '$$  new learningpath found '+LPATH);
                                // Learning path found!
                                for (lp_Learning_Path_Milestone__c lp_milestone : LPATH.lp_Milestone__r) 
                                {
                                    // Loop through all learning path milestones
                                    // to activate existing or create new
                                    Boolean milestone_exists=false;
                                    
                                    System.debug(LoggingLevel.INFO, '$$  Look for existing milestones to re-activate '+dbLPAD.Consultant_Milestones__r);
                                    for (lp_Consultant_Milestone__c milestone : dbLPAD.Consultant_Milestones__r) 
                                    {
                                        if (milestone.Learning_Path_Milestone__c == lp_milestone.Id)
                                        {
                                            // Activate milestone since it is in the new learning path
                                            
                                            //Considerations:
                                            // What if learningpath milestone have changed 
                                            // which information should be copied over from the learningpath milestone
                                            milestone.Active__c = True;
                                            milestone.Mandatory_Milestone__c=lp_milestone.MandatoryMilestone__c;
                                            milestone.Forecast_Category__c = lp_milestone.Forecast_Category_Number__c;                                      
                                            
                                            milestone.Recalculate_dates__c=True;                                            
                                            
                                            milestone_exists=true;
                                            newMilestones.add(milestone);
                                            System.debug(LoggingLevel.INFO, '$$ Re-activate milestone '+milestone+' on '+dbLPAD);
                                            break;
                                        }
                                    }
                                    
                                    // if milestone does not exist - create a new milestone
                                    if (!milestone_exists)
                                    {
                                        lp_Consultant_Milestone__c m = new lp_Consultant_Milestone__c();
                                        m.Active__c = true;
                                        //m.LaunchPad__c = dbLPAD.Id;
                                        m.PA_Onboarding__c = dbLPAD.Id;
                                        m.Learning_Path_Milestone__c = lp_milestone.Id;
                                        //m.Start_Date__c = dbLPAD.Learning_Path_Start_Date__c;
                                        m.Start_Date__c = dbLPAD.Program_Start_Date__c;
                                        //m.Expected_Completion_Date__c = Date.today();
                                        m.Progress__c=0;
                                        //m.Success_Group_Progress__c=0;                                        
                                        m.Mandatory_Milestone__c=lp_milestone.MandatoryMilestone__c;
                                        m.Forecast_Category__c = lp_milestone.Forecast_Category_Number__c;
                                        m.lp_Forecast_Category_New__c = lp_milestone.lp_Forecast_Category__r.Id;
                                        m.Recalculate_dates__c=True;                                        
                                        newMilestones.add(m);
                                        System.debug(LoggingLevel.INFO, '$$ Add new milestone '+m+' to '+dbLPAD);
                                    }
                                    
                                }
                                break;
                            }
                        }           
                    }
                }
            }
            
            update deactivatedMilestones;
            upsert newMilestones;
                        
        }
    }
}