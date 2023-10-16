@isTest
public class PSCUserAnalyticsDataCtrlTest { 
    @testSetup
    static void createData() {
        
        String analyticsEmails = PSCSettingService.getValue('Analytics_Emails');
        List<String> analyticsEmailsList = analyticsEmails.split(',');
        List<User> user = [Select Id,isactive,Is_GKC_User__c,Mgmt_Chain_Hierarchy_Level_03__r.FederationIdentifier
                           from User Where isactive=false and Is_GKC_User__c=false Limit 1];        
        if(user != null && !user.isEmpty()){
            user[0].IsActive = true;
            user[0].Is_GKC_User__c = true;
            user[0].Mgmt_Chain_Hierarchy_Level_03__r.FederationIdentifier = analyticsEmailsList[0];
            update user[0];
        }
        
    }
    @isTest
    public static void getUserAnalyticsDataTest(){
        
        List<User> userList = [select Id,isactive,Is_GKC_User__c From User Where isactive=true and Is_GKC_User__c=true and
                               Mgmt_Chain_Hierarchy_Level_03__r.FederationIdentifier = 'bmillham@salesforce.com'];
        
        List<Knowledge__kav> knowledgeObjList = New List<Knowledge__kav>();
        Knowledge__kav knowledgeObj = PSCTestDataFactory.createKnowledge();
        knowledgeObjList.add(knowledgeObj);
        insert knowledgeObj;
        
        test.startTest();
        PSCUserAnalyticsDataCtrl.getUserAnalyticsData();
        PSCUserAnalyticsDataCtrl.getKnowledgeData();
        test.stopTest();
        System.assertEquals(1, userList.size());
        System.assertEquals(1, knowledgeObjList.size());
        
        
    }
    
    
}