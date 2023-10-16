/*
    About: Service Class for Consultant Milestone object management
    Purpose: 
            Manage and react to changes on milestones in a consultant's learning path timelne
            Static methods and generic classes only
    Outline: 
            ShiftedMilestone // Wrapper for Consultant milestones with X number of days the milestone will be moved in or out. Applies compare based on the start date.
            ShrinkTimeline // Takes a map of milestones that have been closed early and pulls in milestones that are yet to start by X number of days
    
    History:
            > Draft: April '14 / M.Evans
            > Added code: July 2014/ Parag Phanasgaonkar (PP) 
                    recalculateCompletionDatesBasedOnVariance
                    recalulateMiestoneByConsultant

    Todo:
            Temporarily commented out to allow refactoring
            ShrinkTimeline / not tested or prototyped
*/
public with sharing class lp_ConsultantMilestone_SVC {

    public static boolean doNotRefireDateCalculations = false; 
    
    /*PP: This method is used to recalculate completion dates on consultant milestones 
    that are not complete and impact timeline */
    public static void recalculateCompletionDatesBasedOnVariance(Map<Id, Integer> consultantIdVariance)
    {
        if (!doNotRefireDateCalculations)
        {
            doNotRefireDateCalculations = true;
            
            // List of Milestones that need to be update
            List<lp_Consultant_Milestone__c> milestonesToUpdate = new List<lp_Consultant_Milestone__c>();
            
            // Get All Open Consultant Milestones
            List<lp_Consultant_Milestone__c> listConsultantMilestones = [SELECT Id, Start_Date__c, PA_Onboarding__c, Expected_Completion_Date__c, 
                                                                         Revised_Expected_Completion_Date__c, PA_Onboarding__r.Contact__c
                                                                        FROM lp_Consultant_Milestone__c
                                                                        WHERE Milestone_Complete__c = false
                                                                        AND PA_Onboarding__c in :consultantIdVariance.keySet()];   
            
             // Update Expected Completion Date based on days variance
            if (!listConsultantMilestones.isEmpty())
            {
               
                for (lp_Consultant_Milestone__c cm : listConsultantMilestones)
                {
                    // Get Variance    
                    Integer daysVariance = consultantIdVariance.get(cm.PA_Onboarding__c);
                     
                    if (daysVariance == null)
                         daysVariance = 0;
                
                     // Adjust Revised Expected Completion Date
                     if (cm.Revised_Expected_Completion_Date__c != null)
                         cm.Revised_Expected_Completion_Date__c = cm.Revised_Expected_Completion_Date__c + daysVariance;
                     else
                         cm.Revised_Expected_Completion_Date__c = cm.Expected_Completion_Date__c + daysVariance;
                         
                     // Add to List to Update
                     milestonesToUpdate.add(cm); 
                }   
            }
            if (!milestonesToUpdate.isEmpty())
            {
                update milestonesToUpdate;
            }
        }
       
    }
    
    public static void adjustCompletionDatesBasedOnVariance(Map<Id, lp_Consultant_Milestone__c> consultantIdVariance)
    {
        if (!doNotRefireDateCalculations)
        {
            doNotRefireDateCalculations = true;
            
            // List of Milestones that need to be update
            List<lp_Consultant_Milestone__c> milestonesToUpdate = new List<lp_Consultant_Milestone__c>();
            
            System.Debug('ConsultantMilestoneMap: ' + consultantIdVariance);
            
            // Get open milestones
            List<lp_Consultant_Milestone__c> listConsultantMilestones = [SELECT Id, Start_Date__c, PA_Onboarding__c, Expected_Completion_Date__c, 
                                                                         Revised_Expected_Completion_Date__c, PA_Onboarding__r.Contact__c, Number__c
                                                                        FROM lp_Consultant_Milestone__c
                                                                        WHERE Milestone_Complete__c = false
                                                                        AND PA_Onboarding__c in :consultantIdVariance.keySet()];
            
            System.Debug('listConsultantMilestones: ' + listConsultantMilestones);
            
            // Update Expected Completion Date based on days variance
            if (!listConsultantMilestones.isEmpty())
            {
               
                for (lp_Consultant_Milestone__c cm : listConsultantMilestones)
                {
                
                     // Adjust Revised Expected Completion Date
                     if (cm.Revised_Expected_Completion_Date__c != null)
                     {    
                         Date actualCompletionDate = (Date)consultantIdVariance.get(cm.PA_Onboarding__c).Actual_Completion_Date__c;
                         Date revisedCompletionDate = (Date)consultantIdVariance.get(cm.PA_Onboarding__c).Revised_Expected_Completion_Date__c;
                         Date expectedCompletionDate = (Date)consultantIdVariance.get(cm.PA_Onboarding__c).Expected_Completion_Date__c;
                         
                         Integer daysToPush = 0;
                         
                         if (revisedCompletionDate != null)
                             daysToPush = actualCompletionDate.daysBetween(revisedCompletionDate);
                         else
                             daysToPush = actualCompletionDate.daysBetween(expectedCompletionDate);
                         
                         
                         cm.Revised_Expected_Completion_Date__c = cm.Revised_Expected_Completion_Date__c - daysToPush;
                     }
                     else
                     {
                        // Get Variance    
                        Integer daysMilestoneVariance = (Integer)consultantIdVariance.get(cm.PA_Onboarding__c).Variance__c;
                    
                        System.Debug('Variance: ' + daysMilestoneVariance);
                     
                        if (daysMilestoneVariance == null)
                         daysMilestoneVariance = 0;
                         
                        // Get Number of Days pushed back due to milestone missed
                        Integer daysMilestoneMissed = (Integer)consultantIdVariance.get(cm.PA_Onboarding__c).Number__c;
                    
                        if (daysMilestoneMissed == null)
                        daysMilestoneMissed = 0;
                         
                        cm.Revised_Expected_Completion_Date__c = cm.Expected_Completion_Date__c + daysMilestoneVariance - daysMilestoneMissed;
                     }   
                     // Add to List to Update
                     milestonesToUpdate.add(cm); 
                }   
            }
            
            // Update Open Milestones
            if (!milestonesToUpdate.isEmpty())
            {
                update milestonesToUpdate;
            }
        }
       
    }
    
    public static void reviseCompletionDates(List<Id> consultantIds, Integer daysToExtend)
    {
        
        Date currentDate = System.Date.today();
        
        List<lp_Consultant_Milestone__c> listConsultantMilestones = [SELECT Id, Start_Date__c, PA_Onboarding__c, Expected_Completion_Date__c, Revised_Expected_Completion_Date__c
                                                                        FROM lp_Consultant_Milestone__c
                                                                        WHERE Milestone_Complete__c = false
                                                                        AND Expected_Completion_Date__c < :currentDate 
                                                                        AND (Revised_Expected_Completion_Date__c = NULL 
                                                                             OR Revised_Expected_Completion_Date__c < :currentDate)
                                                                        AND PA_Onboarding__c in :consultantIds
                                                                        ORDER by Learning_Path_Milestone__r.Order__c];
        
        // List of Milestones that need to be update
        List<lp_Consultant_Milestone__c> milestonesToUpdate = new List<lp_Consultant_Milestone__c>();
        
        if(!listConsultantMilestones.isEmpty())
        {
            
            for (lp_Consultant_Milestone__c cm : listConsultantMilestones)
            {
                
                boolean processThisRecord = false;
                if(cm.Revised_Expected_Completion_Date__c != null)
                {
                    //Check if the revised date is in past. If yes only then process this record
                    if(cm.Revised_Expected_Completion_Date__c < currentDate)
                        processThisRecord = true;
                }
                else
                {
                    processThisRecord = true;
                }
                
                if (processThisRecord)
                {
                    // Adjust Revised Expected Completion Date
                     if (cm.Revised_Expected_Completion_Date__c != null)
                         cm.Revised_Expected_Completion_Date__c = cm.Revised_Expected_Completion_Date__c + daysToExtend;
                     else
                         cm.Revised_Expected_Completion_Date__c = cm.Expected_Completion_Date__c + daysToExtend;
                    cm.Expected_End_Date_Counter__c = cm.Expected_End_Date_Counter__c + 1;
                    cm.Number__c = cm.Number__c + daysToExtend;
                    
                    
                    milestonesToUpdate.add(cm);
                }
                    
            }            
        }
        
        if(!milestonesToUpdate.isEmpty())
            update milestonesToUpdate;
    }
    
    //PP: This function calculates the revised completion dates in case of missed milestones
    public static void recalulateMilestoneByConsultant(List<Id> consultantIds) 
    {
        Date currentDate = System.Date.today();
        //Get all the missed milestones for the consultant and also get the PA ready milestone as special case
        List<lp_Consultant_Milestone__c> listConsultantMilestones = [SELECT Id, Start_Date__c, PA_Onboarding__c, Expected_Completion_Date__c, Revised_Expected_Completion_Date__c,
                                                                            Learning_Path_Milestone__r.Name, Impacts_Timeline__c, Expected_End_Date_Counter__c, Number__c
                                                                        FROM lp_Consultant_Milestone__c
                                                                        WHERE Milestone_Complete__c = false
                                                                        AND ((Expected_Completion_Date__c < :currentDate 
                                                                              OR (Revised_Expected_Completion_Date__c = NULL 
                                                                                    OR Revised_Expected_Completion_Date__c < :currentDate)
                                                                              )
                                                                              OR (Learning_Path_Milestone__r.Name LIKE '%PA Ready%')
                                                                            )
                                                                        AND Impacts_Timeline__c = true
                                                                        AND PA_Onboarding__c = :consultantIds
                                                                        ORDER by Learning_Path_Milestone__r.Order__c];
        
        //Create a map of <PA_Onboarding__c,List<lp_Consultant_Milestone__c>> to organize milestones
        //by consultant.
        Map<Id,List<lp_Consultant_Milestone__c>> mapMilestonesByConsultant;
        
        if (!listConsultantMilestones.isEmpty())
        {
            mapMilestonesByConsultant = new Map<Id,List<lp_Consultant_Milestone__c>>();
            for(lp_Consultant_Milestone__c cmile: listConsultantMilestones)
            {
                List<lp_Consultant_Milestone__c>  innerList;
                innerList = mapMilestonesByConsultant.get(cmile.PA_Onboarding__c); 
                if(innerList == null)
                {
                    innerList = new List<lp_Consultant_Milestone__c>();
                }
                innerList.add(cmile);
                mapMilestonesByConsultant.put(cmile.PA_Onboarding__c, innerList);
            }
        }
        
        List<lp_Consultant_Milestone__c> milestonesToUpdate = new List<lp_Consultant_Milestone__c>();
        
        if(listConsultantMilestones.isEmpty()) 
            return;
        
        for(Id consultantId: mapMilestonesByConsultant.keySet())
        {
            milestonesToUpdate.addAll(getUpdatedMilestones(mapMilestonesByConsultant.get(consultantId)));    
        }
                
        if(!milestonesToUpdate.isEmpty())
            update milestonesToUpdate;
    }
    
    private static List<lp_Consultant_Milestone__c> getUpdatedMilestones(List<lp_Consultant_Milestone__c> listConsultantMilestones)
    {
        List<lp_Consultant_Milestone__c> milestonesToUpdate = new List<lp_Consultant_Milestone__c>();
        Integer daysToPush = 7;
        Integer daysToPushPAReady = 0;
        Date currentDate = System.Date.today();
        
        lp_Consultant_Milestone__c paReadyMilestone;
        
        for(lp_Consultant_Milestone__c cm: listConsultantMilestones)
        {
            boolean processThisRecord = false;
            daysToPush = 7;
            if(cm.Revised_Expected_Completion_Date__c != null)
            {
                //Check if the revised date is in past. If yes only then process this record
                if(cm.Revised_Expected_Completion_Date__c < currentDate)
                    processThisRecord = true;
            }
            else
            {
                if(cm.Expected_Completion_Date__c < currentDate)
                    processThisRecord = true;
            }
            
            if (cm.Learning_Path_Milestone__r.Name.toUpperCase().contains('PA READY'))
            {
                processThisRecord = true;
            }
            if (processThisRecord)
            {
                if (!cm.Learning_Path_Milestone__r.Name.toUpperCase().contains('PA READY'))
                {
                    // Adjust Revised Expected Completion Date
                    if (cm.Revised_Expected_Completion_Date__c != null)
                    {
                        daysToPush = Integer.valueOf(cm.Revised_Expected_Completion_Date__c.daysBetween(currentDate)) + daysToPush;
                        cm.Revised_Expected_Completion_Date__c = cm.Revised_Expected_Completion_Date__c + daysToPush;
                    }
                    else
                    {
                        daysToPush = Integer.valueOf(cm.Expected_Completion_Date__c.daysBetween(currentDate)) + daysToPush;
                        cm.Revised_Expected_Completion_Date__c = cm.Expected_Completion_Date__c + daysToPush;
                    }
                        
                    if (cm.Expected_End_Date_Counter__c != null) 
                        cm.Expected_End_Date_Counter__c = cm.Expected_End_Date_Counter__c + 1;
                    else
                        cm.Expected_End_Date_Counter__c = 1;
                    
                    if(cm.Number__c != null)
                        cm.Number__c = cm.Number__c + daysToPush;
                    else
                        cm.Number__c = daysToPush;
                    System.debug('cm.Learning_Path_Milestone__r.Name' + cm.Learning_Path_Milestone__r.Name);
                    
                    System.debug('daysToPush' + String.valueOf(daysToPush));
                        
                    System.debug('cm.Impacts_Timeline__c' + String.valueOf(cm.Impacts_Timeline__c));
                    if(cm.Impacts_Timeline__c) {
                        daysToPushPAReady = daysToPushPAReady + daysToPush;
                        System.debug('daysToPushPAReady' + String.valueOf(daysToPushPAReady));
                    }
                        
                    milestonesToUpdate.add(cm);
                }       
                else
                {
                    paReadyMilestone = cm;
                }
            }
        }
        
        if (paReadyMilestone != null)
        {
            if (daysToPushPAReady > 0)
            {
                //Process the PA Ready milestone
                if (paReadyMilestone.Revised_Expected_Completion_Date__c != null)
                    paReadyMilestone.Revised_Expected_Completion_Date__c = paReadyMilestone.Revised_Expected_Completion_Date__c + daysToPushPAReady;
                else
                    paReadyMilestone.Revised_Expected_Completion_Date__c = paReadyMilestone.Expected_Completion_Date__c + daysToPushPAReady;
                if(paReadyMilestone.Expected_End_Date_Counter__c  != null)
                    paReadyMilestone.Expected_End_Date_Counter__c = paReadyMilestone.Expected_End_Date_Counter__c + 1;
                else
                    paReadyMilestone.Expected_End_Date_Counter__c = 1;
                
                if(paReadyMilestone.Number__c != null)
                    paReadyMilestone.Number__c = paReadyMilestone.Number__c + daysToPushPAReady;
                else
                    paReadyMilestone.Number__c =daysToPushPAReady;
                
                System.debug('paReadyMilestone.Revised_Expected_Completion_Date__c ' + String.valueOf(paReadyMilestone.Revised_Expected_Completion_Date__c));
                milestonesToUpdate.add(paReadyMilestone);    
            }
                
        }
        return milestonesToUpdate;
    }
    
}