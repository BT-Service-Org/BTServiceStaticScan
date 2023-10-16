public class resource_scheduler {

    public List <Resource_Schedule_Week__c> ScheduleWeeks {public get; private set;}

    public List <Resource_Schedule_Week__c> getScheduleWeeks( String resourceAssignmentId ) {
    
        return new List <Resource_Schedule_Week__c> ();
    
    }


}