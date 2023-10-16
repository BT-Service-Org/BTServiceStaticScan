@isTest
public class CSG_FdbkSharingRecalcSchedulerTest {
    
    @isTest public static void testScheudlingOfBatch() {
        
        String jobId = '';        
        Date nextDay = System.today().addDays(1);
        Integer year = nextDay.year();
        Integer month = nextDay.month();
        Integer day = nextDay.day();   
        String cronExp = '0 0 0 ' + day + ' ' +  month + ' ? ' + year; // schedule for midnight next day.
        
        Test.startTest();
        jobId = System.schedule('Test Sharing Recalc Batch Schedule', cronExp, new CSG_EngagementFdbkSharingRecalcScheduler());
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

         // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        // nextDay returns YYYY-MM-DD, no time, so adding midnight to the string value of date to check next fire time  
        System.assertEquals(String.valueOf(nextDay) + ' 00:00:00', String.valueOf(ct.NextFireTime));

    }
}