@isTest
public with sharing class The_Station_CollectionContentWrapTest {
    public The_Station_CollectionContentWrapTest() {

    }

    public static final String CONTENTTYPE_APP_EXCHANGE = 'App Exchange';
    public static final String CONTENTTYPE_CONTENT_VERSION = 'Content Version';
    public static final String CONTENTTYPE_SUCCESS_PROGRAM = 'Success Program';
    public static final String CONTENTTYPE_TRAILHEAD = 'Trailhead';
    public static final String CONTENTTYPE_URL = 'URL';

    public static final String DEV_CONTENTTYPE_APP_EXCHANGE = 'App_Exchange';
    public static final String DEV_CONTENTTYPE_CONTENT_VERSION = 'Standard_Content';
    public static final String DEV_CONTENTTYPE_SUCCESS_PROGRAM = 'Success_Program';
    // THERE IS NO TRAILHEAD RECORD TYPE
    //    public static final String DEV_CONTENTTYPE_TRAILHEAD = 'Trailhead';
    public static final String DEV_CONTENTTYPE_URL = 'URL';

    public static final String CONTENT_NAME = 'Test Content';

    public static Station_Content__c createContent(String Type, Integer randomNumber) {            
        Date thisDay = System.today() + 90;
        String recordTypeDevName = null;
        String contentName = CONTENT_NAME + ' ' + randomNumber;

        if(Type == CONTENTTYPE_APP_EXCHANGE) {
            recordTypeDevName = DEV_CONTENTTYPE_APP_EXCHANGE;
        } else if (Type == CONTENTTYPE_CONTENT_VERSION) {
            recordTypeDevName = DEV_CONTENTTYPE_CONTENT_VERSION;
        } else if (Type == CONTENTTYPE_SUCCESS_PROGRAM) {
            recordTypeDevName = DEV_CONTENTTYPE_SUCCESS_PROGRAM;
        } else if (Type == CONTENTTYPE_TRAILHEAD) {
            recordTypeDevName = DEV_CONTENTTYPE_URL; // THIS IS CORRECT PER DAVID URL FOR TRAILHEAD
        } else if (Type == CONTENTTYPE_URL) {
            recordTypeDevName = DEV_CONTENTTYPE_URL;
        }

        Id recordTypeIdContent = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();

//        RecordType recIds = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sobjecttype = 'Station_Content__c' and DeveloperName =: recordTypeDevName LIMIT 1];

        Station_Content__c content = new Station_Content__c(Name=contentName,
                                                            RecordTypeId = recordTypeIdContent,
                                                            Content_Type__c = Type,
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Next_Review_Date__c = thisDay,
                                                            Order__c = randomNumber,
                                                            Upload_Image__c = '<html><img src="https://c1.sfdcstatic.com/content/dam/sfdc-docs/www/logos/logo-salesforce.svg"/></html>');

        insert content;        
        return content;
    }

    @isTest static void test_APX_CollectionContentWrapper() {    
        System.debug('test_APX_CollectionContentWrapper');
        boolean bSuccess = false;
        Integer rnd = Integer.valueof((Math.random() * 100));
        String comp = CONTENT_NAME + ' ' + rnd;
        Station_Content__c c = createContent(CONTENTTYPE_APP_EXCHANGE, rnd);
        The_Station_CollectionContentWrapper ccw = new The_Station_CollectionContentWrapper(c);
        if(ccw != null) {
            System.assertEquals(ccw.contentTitle, comp);
        }        
    }
    @isTest static void test_CV_CollectionContentWrapper() {    
        System.debug('test_CV_CollectionContentWrapper');
        boolean bSuccess = false;
        Integer rnd = Integer.valueof((Math.random() * 100));
        String comp = CONTENT_NAME + ' ' + rnd;
        Station_Content__c c = createContent(CONTENTTYPE_CONTENT_VERSION, rnd);
        The_Station_CollectionContentWrapper ccw = new The_Station_CollectionContentWrapper(c);
        if(ccw != null) {
            System.assertEquals(ccw.contentTitle, comp);            
        }        
    }
    @isTest static void test_SP_CollectionContentWrapper() {    
        System.debug('test_SP_CollectionContentWrapper');
        boolean bSuccess = false;
        Integer rnd = Integer.valueof((Math.random() * 100));
        String comp = CONTENT_NAME + ' ' + rnd;
        Station_Content__c c = createContent(CONTENTTYPE_SUCCESS_PROGRAM, rnd);
        The_Station_CollectionContentWrapper ccw = new The_Station_CollectionContentWrapper(c);
        if(ccw != null) {
            System.assertEquals(ccw.contentTitle, comp);            
        }        
    }
// Skipping this since Trailhead is not used at the moment.
/*    
    @isTest static void test_TH_CollectionContentWrapper() {    
        System.debug('test_TH_CollectionContentWrapper');
        boolean bSuccess = false;
        Integer rnd = Integer.valueof((Math.random() * 100));
        String comp = CONTENT_NAME + ' ' + rnd;
        Station_Content__c c = createContent(CONTENTTYPE_TRAILHEAD, rnd);
        The_Station_CollectionContentWrapper ccw = new The_Station_CollectionContentWrapper(c);
        if(ccw != null) {
            System.assertEquals(ccw.contentTitle, comp);            
        }        
    }
*/    
    @isTest static void test_URL_CollectionContentWrapper() {    
        System.debug('test_URL_CollectionContentWrapper');
        boolean bSuccess = false;
        Integer rnd = Integer.valueof((Math.random() * 100));
        String comp = CONTENT_NAME + ' ' + rnd;
        Station_Content__c c = createContent(CONTENTTYPE_URL, rnd);
        The_Station_CollectionContentWrapper ccw = new The_Station_CollectionContentWrapper(c);
        if(ccw != null) {
            System.assertEquals(ccw.contentTitle, comp);            
        }        
    }
}