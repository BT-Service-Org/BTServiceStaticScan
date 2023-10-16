/**
 * Created by Rahul Mehta for PROJ-12 user story for Project 180 Feedback
 * For scheduling reminder notification batch PRJ180_ReminderNotificationsBatch .
*/ 
global with sharing class PRJ180_ReminderNotificationsScheduler implements Schedulable { 
    private Integer ReminderNumber;
    global PRJ180_ReminderNotificationsScheduler(Integer reminder) {
        this.ReminderNumber = reminder;
    }
    global void execute(SchedulableContext sc) {        
        PRJ180_ReminderNotificationsBatch batch = new PRJ180_ReminderNotificationsBatch(ReminderNumber);
        ID batchprocessid = Database.executeBatch(batch);
    }
}