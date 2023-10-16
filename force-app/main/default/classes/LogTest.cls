/*****************************
* Class : LogTest
* Created By : Mujjammil Khan
-----------------------------------------------------------------------------------
* Description : Test Class for Log class
-----------------------------------------------------------------------------------
* Version History:
* Version    Developer Name    Date          Detail Features
* 1.0        Mujjammil Khan    15/03/2021    Initial Development
*
****************************/
@isTest
private with sharing class LogTest {
    
    @TestSetup
    static void makeData(){
        Log_Settings__c logSetting = new Log_Settings__c();
        logSetting.Insert_Debug_Records__c = false;
        logSetting.Send_Error_Email__c = false;
        logSetting.SetupOwnerId = UserInfo.getUserId();
        insert logSetting;
    }

    // debug test methods

    @isTest
    static void testDebugWithLogRecord() {
        Log_Settings__c logSetting = Log_Settings__c.getInstance();
        logSetting.Insert_Debug_Records__c = true;
        update logSetting;

        String message = 'this is debug statement';

        Test.startTest();
            Log.debug(message);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Message__c FROM Log__c WHERE Type__c = 'DEBUG'];
        System.assertEquals(logs.size(), 1);
        System.assertEquals(logs[0].Message__c, message);
    }

    @isTest
    static void testDebugWithoutLogRecord() {
        String message = 'this is debug statement';

        Test.startTest();
            Log.debug(message);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Message__c FROM Log__c WHERE Type__c = 'DEBUG'];
        System.assertEquals(logs.size(), 0);
    }

    @isTest
    static void testDebugWithRecordList() {
        Log_Settings__c logSetting = Log_Settings__c.getInstance();
        logSetting.Insert_Debug_Records__c = true;
        update logSetting;

        String message = 'this is debug statement';
        List<Log_Settings__c> settingsToDebug = new List<Log_Settings__c> {
            new Log_Settings__c(Insert_Debug_Records__c = false),
            new Log_Settings__c(Insert_Debug_Records__c = true)
        };

        Test.startTest();
            Log.debug(message, settingsToDebug);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c WHERE Type__c = 'DEBUG'];
        System.assertEquals(logs.size(), 1);
    }

    @isTest
    static void testDebugWithAsyncJobId() {
        String message = 'this is debug statement';
        Log_Settings__c logSetting = Log_Settings__c.getInstance();
        logSetting.Insert_Debug_Records__c = true;
        update logSetting;

        Id jobId = logSetting.Id;

        Test.startTest();
            Log.debug(message, jobId);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c WHERE Async_Job_Id__c = :jobId AND Type__c = 'DEBUG'];
        System.assertEquals(logs.size(), 1);
    }

    @isTest
    static void testDebugWithException() {
        Log_Settings__c logSetting = Log_Settings__c.getInstance();
        logSetting.Insert_Debug_Records__c = true;
        update logSetting;

        Test.startTest();
            Log.debug(new DmlException());
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Stack_Trace__c FROM Log__c];
        System.assertEquals(logs.size(), 1);
        System.assert(String.isNotBlank(logs[0].Stack_Trace__c));
    }

    @isTest
    static void testDebugWithExceptionRecordList() {
        Log_Settings__c logSetting = Log_Settings__c.getInstance();
        logSetting.Insert_Debug_Records__c = true;
        update logSetting;

        Test.startTest();
            Log.debug(new DmlException(), new List<Log_Settings__c> {logSetting});
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Stack_Trace__c FROM Log__c WHERE Type__c = 'DEBUG'];
        System.assertEquals(logs.size(), 1);
        System.assert(String.isNotBlank(logs[0].Stack_Trace__c));
    }

    // error test methods

    @isTest
    static void testError() {
        String message = 'this is error statement';

        Test.startTest();
            Log.error(message);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Message__c FROM Log__c WHERE Type__c = 'ERROR'];
        System.assertEquals(logs.size(), 1);
        System.assertEquals(logs[0].Message__c, message);
    }

    @isTest
    static void testErrorWithRecordList() {
        String message = 'this is error statement';
        List<Log_Settings__c> settingsToDebug = new List<Log_Settings__c> {
            new Log_Settings__c(Insert_Debug_Records__c = false),
            new Log_Settings__c(Insert_Debug_Records__c = true)
        };

        Test.startTest();
            Log.error(message, settingsToDebug);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c WHERE Type__c = 'ERROR'];
        System.assertEquals(logs.size(), 1);
    }

    @isTest
    static void testErrorWithAsyncJobId() {
        String message = 'this is debug statement';
        Log_Settings__c logSetting = Log_Settings__c.getInstance();
        logSetting.Insert_Debug_Records__c = true;
        update logSetting;

        Id jobId = logSetting.Id;

        Test.startTest();
            Log.error(message, jobId);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c WHERE Async_Job_Id__c = :jobId AND Type__c = 'ERROR'];
        System.assertEquals(logs.size(), 1);
    }

    @isTest
    static void testErrorWithException() {
        Test.startTest();
            Log.error(new DmlException());
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Stack_Trace__c FROM Log__c WHERE Type__c = 'ERROR'];
        System.assertEquals(logs.size(), 1);
        System.assert(String.isNotBlank(logs[0].Stack_Trace__c));
    }

    @isTest
    static void testErrorWithExceptionRecordList() {
        Log_Settings__c logSetting = Log_Settings__c.getInstance();

        Test.startTest();
            Log.error(new DmlException(), new List<Log_Settings__c> {logSetting});
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Stack_Trace__c FROM Log__c WHERE Type__c = 'ERROR'];
        System.assertEquals(logs.size(), 1);
        System.assert(String.isNotBlank(logs[0].Stack_Trace__c));
    }
}