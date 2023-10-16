@istest(seealldata=false)
public class GDC_DA_FirstSyncTeamMemberBatchTest {
       @istest public static void APACRegionTest(){
        Test.startTest();
        GDC_DA_Configuration__c daConfig = DaConfigSetup('APAC India','APAC India');
        insert daConfig;
        pse_Assignment_c__x pseRecord = (pse_Assignment_c__x)json.deserializeStrict(mockJsonResponseDataPseAssignment('APAC India'), pse_Assignment_c__x.class);
        pse_Proj_c__x projx = (pse_Proj_c__x)json.deserializeStrict(mockJsonResponseData(), pse_Proj_c__x.class);
        Contact__x contX = (Contact__x)json.deserializeStrict(mockJsonResponseDataContact(), Contact__x.class);
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        GDC_DA_FirstSyncProjectBatch GDCBatch = new GDC_DA_FirstSyncProjectBatch();
        ql = GDCBatch.start(bc);
        Database.QueryLocatorIterator QIT =  QL.iterator();
        do{
            GDC_DA_FirstSyncProjectBatch.mockedRequestspseProject.add(projx);
            GDC_DA_FirstSyncProjectBatch.mockedRequests.add(pseRecord);
        } while (QIT.hasNext());
        
        
        GDCBatch.execute(BC, GDC_DA_FirstSyncProjectBatch.mockedRequests);
        GDCBatch.finish(BC);  
            
        Database.QueryLocator QL1;
        Database.BatchableContext BC1;
        GDC_DA_FirstSyncTeamMemberBatch GDCSyncBatch = new GDC_DA_FirstSyncTeamMemberBatch();
        ql1 = GDCSyncBatch.start(bc);
        Database.QueryLocatorIterator QIT1 =  QL1.iterator();
        do{
            GDC_DA_FirstSyncTeamMemberBatch.mockedconX.add(contX);
            GDC_DA_FirstSyncTeamMemberBatch.mockedRequests.add(pseRecord);
        } while (QIT1.hasNext());
        
        
        GDCSyncBatch.execute(BC, GDC_DA_FirstSyncTeamMemberBatch.mockedRequests);
        GDCSyncBatch.finish(BC);  
        Test.stopTest();
        
    }
    
    public static GDC_DA_Configuration__c DaConfigSetup(string Name,string Region){
        GDC_DA_Configuration__c daConfig = new GDC_DA_Configuration__c();
        daConfig.Region__c=Region;
        daConfig.Name=Name;
        daConfig.Owner__c=userinfo.getUserId();
        return daConfig;
    }
   
    
      public static string mockJsonResponseDataPseAssignment(string region){
        Date dToday = Date.today();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        String dateStr1 = dt.format('yyyy-MM-dd');
        System.debug('>>>>' + dateStr1);
        string mockresponse = '{"attributes":{"type":"pse_Assignment_c__x","url":"/services/data/v54.0/sobjects/pse_Assignment_c__x/a8a7x000005cGDlAAM"},"Id":"x097x000005cGDlAAM","pse_Resource_c__c":"0037x0000012rioAAA" , "ExternalId":"a8a7x000005cGDlAAM","Name__c":"Demo Project","Project_Region_c__c":"'+region+'","pse_Project_c__c":"0037x0000012rioAAA","pse_Start_Date_c__c":"'+dateStr1+'","pse_End_Date_c__c":"'+dateStr1+'"}';
        return mockresponse;
    }
    
     public static string mockJsonResponseDataContact(){
            string emailData = userinfo.getUserEmail();
        string mockresponse = '{"attributes":{"type":"Contact__x","url":"/services/data/v54.0/sobjects/Contact__x/0037x0000012rioAAA"},"Id":"x0a7x0000012rioAAA" , "ExternalId":"0037x0000012rioAAA","Email__c":"'+emailData+'"}';
        return mockresponse;
    }
    
        public static string mockJsonResponseData(){
        Date dToday = Date.today();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        String dateStr1 = dt.format('yyyy-MM-dd');
        System.debug('>>>>' + dateStr1);
        string mockresponse = '{"attributes":{"type":"pse_Proj_c__x","url":"/services/data/v54.0/sobjects/pse_Proj_c__x/0037x0000012rioAAA"},"Id":"x037x00000005m5AAA","ExternalId":"0037x0000012rioAAA","Name__c":"Demo Project","pse_Start_Date_c__c":"'+dateStr1+'","pse_End_Date_c__c":"'+dateStr1+'"}';
        return mockresponse;
    }
}