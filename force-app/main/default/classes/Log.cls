/*****************************
* Class : Log
* Test Class : LogTest
* Created By : Mujjammil Khan
-----------------------------------------------------------------------------------
* Description : Class to log debug or error
-----------------------------------------------------------------------------------
* Version History:
* Version    Developer Name    Date          Detail Features
* 1.0        Mujjammil Khan    15/03/2021    Initial Development
*
****************************/
public with sharing class Log {

    private static final String ORG_NAMESPACE = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
    private static final String CLASSNAME = Log.class.getName();
    private static final String NEW_LINE = '\n';
    private static final Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');
    public enum LogType {
        DEBUG,
        ERROR,
        API_LOG
    }

    // Note: Required to allow testing
    @TestVisible
    private static Log_Event__e currentEvent = null;
    private static Log_Settings__c logSetting = getLogSetting();

    // PUBLIC

    /**
     * Method to debug the passed message
     */
    public static void debug(String message) {
        debug(message, null, new List<Object>(), null);
    }

    /**
     * Method to debug the passed message along with list of record values
     */
    public static void debug(String message, List<Object> values) {
        debug(message, null, values, null);
    }

    /**
     * Method to debug the passed message along with async job Id
     */
    public static void debug(String message, Id asyncJobId) {
        debug(message, null, new List<Object>(), asyncJobId);
    }

    /**
     * Method to debug the exception
     */
    public static void debug(Exception ex) {
        debug(ex.getMessage(), ex.getStackTraceString(), new List<Object>(), null);
    }

    /**
     * Method to debug the exception along with list of records
     */
    public static void debug(Exception ex, List<Object> values) {
        debug(ex.getMessage(), ex.getStackTraceString(), values, null);
    }

    public static void debug(String message, String stackTrace, List<Object> values, Id asyncJobId) {
        Boolean publishEvent = logSetting != null && logSetting.Insert_Debug_Records__c;
        emit(message, stackTrace, values, asyncJobId, LogType.DEBUG, publishEvent);
    }

    /**
     * Method to add Log record with error message
     */
    public static void error(String message) {
        error(message, null, new List<Object>(), null);
    }

    /**
     * Method to add Log record with error message and list of records
     */
    public static void error(String message, List<Object> values) {
        error(message, null, values, null);
    }

    /**
     * Method to add Log record with error message and Async job Id
     */
    public static void error(String message, Id asyncJobId) {
        error(message, null, new List<Object>(), asyncJobId);
    }

    /**
     * Method to add Log record with exception error message & stack trace
     */
    public static void error(Exception ex) {
        error(ex.getMessage(), ex.getStackTraceString(), new List<Object>(), null);
    }

    /**
     * Method to add Log record with exception error message & stack trace with list of records
     */
    public static void error(Exception ex, List<Object> values) {
        error(ex.getMessage(), ex.getStackTraceString(), values, null);
    }

    public static void error(String message, String stackTrace, List<Object> values, Id asyncJobId) {
        emit(message, stackTrace, values, asyncJobId, LogType.ERROR, true);
    }


    // PRIVATE

    /**
     * Method to publish Log Event record based on publishEvent parameters
     */
    private static void emit(
        String message,
        String stackTrace,
        List<Object> values,
        Id asyncJobId,
        LogType logType,
        Boolean publishEvent
    ) {

        message = values != null ? message + ' ' + String.join(cast(values), NEW_LINE) : message;
        stackTrace = String.isNotBlank(stackTrace) ? stackTrace : '';

        if(publishEvent) {
            currentEvent = new Log_Event__e();
            currentEvent.User__c = UserInfo.getUserId();
            currentEvent.Type__c = logType.name();
            currentEvent.Message__c = message;
            currentEvent.Stack_Trace__c = stackTrace;
            currentEvent.Send_Email__c = logSetting != null && logSetting.Send_Error_Email__c;
            currentEvent.Asyc_Job_Id__c = asyncJobId;

            populateLocation(currentEvent);
            EventBus.publish(currentEvent);
        }
        else {
            System.debug(NEW_LINE + message + NEW_LINE + stackTrace);
        }
    }

    /**
     * Method to cast the List of Object to List of String
     */
    private static List<String> cast(List<Object> values) {
        List<String> result = new List<String>();

        for(Object value : values) {
            result.add('' + value);
        }

        return result;
    }

    /**
     * Method to populate platform event object with Class and Method name
     */
    private static void populateLocation(Log_Event__e logEvent) {
        // Note: Idea taken from https://salesforce.stackexchange.com/questions/153835
        String stackTrace = new DmlException().getStackTraceString();
        List<String> stacktraces = stackTrace.split(NEW_LINE);
        List<String> callingClassStackTrace = new List<String>();
        Boolean isTopLevelClassFound = false;

        for(String line : stacktraces) {
            Matcher matcher = STACK_LINE.matcher(line);

            if(matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
                
                Boolean hasNamespace = String.isNotBlank(matcher.group(3));

                if(hasNamespace) {
                    logEvent.Class__c = (matcher.group(1).equals(ORG_NAMESPACE)) ? matcher.group(2) : matcher.group(1) + '.' + matcher.group(2);
                    logEvent.Method__c = prettyMethod(matcher.group(3));
                }
                else {
                    logEvent.Class__c = matcher.group(1);
                    logEvent.Method__c = prettyMethod(matcher.group(2));
                }

                logEvent.Line_Number__c = Integer.valueOf(matcher.group(4));
            }
        }

    }

    /**
     * Method to ignore the null 
     */
    private static String prettyMethod(String method) {
        String result = (method == null) ? 'anonymous' : method;
        return (result.contains('init')) ? 'ctor' : result;
    }

    private static Log_Settings__c getLogSetting() {
        Log_Settings__c logSetting = Log_Settings__c.getInstance();
        return logSetting != null && logSetting.Id != null ? logSetting : null;
    }
}