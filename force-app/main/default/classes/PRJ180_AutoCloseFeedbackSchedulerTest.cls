/**
 * Created by Rahul Mehta for PROJ-12 user story for Project 180 Feedback
 * For Testing of PRJ180_AutoCloseFeedbackBatchScheduler.
*/ 
@isTest
public class PRJ180_AutoCloseFeedbackSchedulerTest {
    @isTest public static void testScheudlingOfBatch() {
        String cronExp = returnCronExpr();
        Test.startTest();
        String jobId = System.schedule('Test PRJ180 Auto Close Feedback Schedule', cronExp, new PRJ180_AutoCloseFeedbackBatchScheduler());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        // nextDay returns YYYY-MM-DD, no time, so adding midnight to the string value of date to check next fire time  
        System.assertEquals(String.valueOf(system.today().addDays(1)) + ' 00:00:00', String.valueOf(ct.NextFireTime));
    }
	
    private static string returnCronExpr() {
        Date nextDay = System.today().addDays(1);
        Integer year = nextDay.year();
        Integer month = nextDay.month();
        Integer day = nextDay.day();   
        String cronExp = '0 0 0 ' + day + ' ' +  month + ' ? ' + year; // schedule for midnight next day.
        return cronExp;
    }
}