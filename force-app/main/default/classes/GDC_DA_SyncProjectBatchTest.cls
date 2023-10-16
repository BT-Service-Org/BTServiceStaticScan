@istest
public class GDC_DA_SyncProjectBatchTest {
    
    @istest public static void APACRegionTest(){
        Test.startTest();
        GDC_DA_Configuration__c daConfig = DaConfigSetup('APAC India','APAC India');
        insert daConfig;
        pse_Assignment_c__x pseRecord = (pse_Assignment_c__x)json.deserializeStrict(mockJsonResponseDataPseAssignment('APAC India'), pse_Assignment_c__x.class);
        pse_Proj_c__x projx = (pse_Proj_c__x)json.deserializeStrict(mockJsonResponseData(), pse_Proj_c__x.class);
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        GDC_DA_SyncProjectBatch GDCBatch = new GDC_DA_SyncProjectBatch();
        ql = GDCBatch.start(bc);
        Database.QueryLocatorIterator QIT =  QL.iterator();
        do{
            GDC_DA_SyncProjectBatch.mockedRequestspseProject.add(projx);
            GDC_DA_SyncProjectBatch.mockedRequests.add(pseRecord);
        } while (QIT.hasNext());
        
        
        GDCBatch.execute(BC, GDC_DA_SyncProjectBatch.mockedRequests);
        GDCBatch.finish(BC);  
        Test.stopTest();

    }
    @istest public static void APACAsiaRegionTest(){
        
        Test.startTest();
        GDC_DA_Configuration__c daConfig = DaConfigSetup('APAC Asia','APAC Asia');
        insert daConfig;
        pse_Assignment_c__x pseRecord = (pse_Assignment_c__x)json.deserializeStrict(mockJsonResponseDataPseAssignment('APAC Asia'), pse_Assignment_c__x.class);
        pse_Proj_c__x projx = (pse_Proj_c__x)json.deserializeStrict(mockJsonResponseData(), pse_Proj_c__x.class);
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        GDC_DA_SyncProjectBatch GDCBatch = new GDC_DA_SyncProjectBatch();
        ql = GDCBatch.start(bc);
        Database.QueryLocatorIterator QIT =  QL.iterator();
        do{
            GDC_DA_SyncProjectBatch.mockedRequestspseProject.add(projx);
            GDC_DA_SyncProjectBatch.mockedRequests.add(pseRecord);
        } while (QIT.hasNext());
        
        
        GDCBatch.execute(BC, GDC_DA_SyncProjectBatch.mockedRequests);
        GDCBatch.finish(BC);  
        Test.stopTest();
        
    }  //LATAM 
    @istest public static void LATAMRegionTest(){
        
        Test.startTest();
        GDC_DA_Configuration__c daConfig = DaConfigSetup('LATAM','LATAM');
        insert daConfig;
        pse_Assignment_c__x pseRecord = (pse_Assignment_c__x)json.deserializeStrict(mockJsonResponseDataPseAssignment('LATAM'), pse_Assignment_c__x.class);
        pse_Proj_c__x projx = (pse_Proj_c__x)json.deserializeStrict(mockJsonResponseData(), pse_Proj_c__x.class);
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        GDC_DA_SyncProjectBatch GDCBatch = new GDC_DA_SyncProjectBatch();
        ql = GDCBatch.start(bc);
        Database.QueryLocatorIterator QIT =  QL.iterator();
        do{
            GDC_DA_SyncProjectBatch.mockedRequestspseProject.add(projx);
            GDC_DA_SyncProjectBatch.mockedRequests.add(pseRecord);
        } while (QIT.hasNext());
        
        
        GDCBatch.execute(BC, GDC_DA_SyncProjectBatch.mockedRequests);
        GDCBatch.finish(BC); 
        Test.stopTest();
        
    }
    
    @istest public static void AMERegionTest(){
        
        Test.startTest();
        GDC_DA_Configuration__c daConfig = DaConfigSetup('AMER','AMER');
        insert daConfig;
        pse_Assignment_c__x pseRecord = (pse_Assignment_c__x)json.deserializeStrict(mockJsonResponseDataPseAssignment('AMER'), pse_Assignment_c__x.class);
        pse_Proj_c__x projx = (pse_Proj_c__x)json.deserializeStrict(mockJsonResponseData(), pse_Proj_c__x.class);
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        GDC_DA_SyncProjectBatch GDCBatch = new GDC_DA_SyncProjectBatch();
        ql = GDCBatch.start(bc);
        Database.QueryLocatorIterator QIT =  QL.iterator();
        do{
            GDC_DA_SyncProjectBatch.mockedRequestspseProject.add(projx);
            GDC_DA_SyncProjectBatch.mockedRequests.add(pseRecord);
        } while (QIT.hasNext());
        
        
        GDCBatch.execute(BC, GDC_DA_SyncProjectBatch.mockedRequests);
        GDCBatch.finish(BC);
        Test.stopTest();
        
    }
    
    @istest public static void otherRegionTest(){
        test.startTest();
        GDC_DA_Configuration__c daConfig = DaConfigSetup('EMEA','EMEA');
        daConfig.Active__c=true;
        insert daConfig;
        pse_Assignment_c__x pseRecord = (pse_Assignment_c__x)json.deserializeStrict(mockJsonResponseDataPseAssignment('EMEA'), pse_Assignment_c__x.class);
        pse_Proj_c__x projx = (pse_Proj_c__x)json.deserializeStrict(mockJsonResponseData(), pse_Proj_c__x.class);
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        GDC_DA_SyncProjectBatch GDCBatch = new GDC_DA_SyncProjectBatch();
        ql = GDCBatch.start(bc);
        Database.QueryLocatorIterator QIT =  QL.iterator();
        do{
            GDC_DA_SyncProjectBatch.mockedRequestspseProject.add(projx);
            GDC_DA_SyncProjectBatch.mockedRequests.add(pseRecord);
        } while (QIT.hasNext());
        
        
        GDCBatch.execute(BC, GDC_DA_SyncProjectBatch.mockedRequests);
        GDCBatch.finish(BC);
        test.stopTest();
        
        
        
    }
    public static GDC_DA_Configuration__c DaConfigSetup(string Name,string Region){
        GDC_DA_Configuration__c daConfig = new GDC_DA_Configuration__c();
        daConfig.Region__c=Region;
        daConfig.Name=Name;
        daConfig.Owner__c=userinfo.getUserId();
        return daConfig;
    }
    
    public static string mockJsonResponseData(){
        Date dToday = Date.today();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        String dateStr1 = dt.format('yyyy-MM-dd');
        System.debug('>>>>' + dateStr1);
        string mockresponse = '{"attributes":{"type":"pse_Proj_c__x","url":"/services/data/v54.0/sobjects/pse_Proj_c__x/0037x0000012rioAAA"},"Id":"x037x00000005m5AAA","ExternalId":"0037x0000012rioAAA","Name__c":"Demo Project","pse_Start_Date_c__c":"'+dateStr1+'","pse_End_Date_c__c":"'+dateStr1+'"}';
        return mockresponse;
    }
    
    public static string mockJsonResponseDataPseAssignment(string region){
        Date dToday = Date.today();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        String dateStr1 = dt.format('yyyy-MM-dd');
        System.debug('>>>>' + dateStr1);
        string mockresponse = '{"attributes":{"type":"pse_Assignment_c__x","url":"/services/data/v54.0/sobjects/pse_Assignment_c__x/a8a7x000005cGDlAAM"},"Id":"x097x000005cGDlAAM","pse_Resource_c__c":"0037x0000012rioAAA" , "ExternalId":"a8a7x000005cGDlAAM","Name__c":"Demo Project","Project_Region_c__c":"'+region+'","pse_Project_c__c":"0037x0000012rioAAA","pse_Start_Date_c__c":"'+dateStr1+'","pse_End_Date_c__c":"'+dateStr1+'"}';
        return mockresponse;
    }
}