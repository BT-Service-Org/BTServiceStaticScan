global class CSG_EngagementFdbkSharingRecalcScheduler implements Schedulable {
    //class used to schedule the batch job which will recalcuate sharing of the feedback record based on curren management hierarchy for the users.
    
    global void execute(SchedulableContext sc)        
    {        
        CSG_EngagementFeedbackSharingRecalcBatch b = new CSG_EngagementFeedbackSharingRecalcBatch();        
        Database.executeBatch(b, 200); // setting batch size to 200 to minimize errors.
    }
}