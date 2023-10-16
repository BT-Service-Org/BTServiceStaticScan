@isTest
public class Station_Team_Member_Page_Controller_Test{
    @isTest static void TestgetDetails() {
        Id recordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Team_Member').getRecordTypeId();
        
        Station_Pages__c grouping = new Station_Pages__c(Name='Team test group',
                                                       Cloud_Product__c='Advisory Services',
                                                       Tab_Name__c='test tab');
        insert grouping;
        String groupingId = grouping.Id;
        
        Station_Content__c content1 = new Station_Content__c(Name='Leader',
                                                            RecordTypeId = recordTypeId,
                                                            Content_Type__c = 'Team Member',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 1);
        insert content1;
        
        StationGroupingAssociation__c association1 = new StationGroupingAssociation__c(Station_Content__c=content1.Id,
                                                                                      Station_Page__c=grouping.Id,
                                                                                      Order__c = 1);
        insert association1;
        
        Station_Content__c content2 = new Station_Content__c(Name='Member',
                                                            RecordTypeId = recordTypeId,
                                                            Content_Type__c = 'Team Member',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 2);
        insert content2;
        
        StationGroupingAssociation__c association2 = new StationGroupingAssociation__c(Station_Content__c=content2.Id,
                                                                                      Station_Page__c=grouping.Id,
                                                                                      Order__c = 2);
        insert association2;
        
        
        Test.startTest();
        List<Station_Team_Member_Page_Controller.StationTeamMember> leaderList = Station_Team_Member_Page_Controller.getLeaderDetails(groupingId,1);
        List<Station_Team_Member_Page_Controller.StationTeamMember> memberList = Station_Team_Member_Page_Controller.getMemberDetails(groupingId,1);
        Test.stopTest();
        
        System.assert(leaderList.isEmpty() == FALSE, 'Leader query returned zero results');
        System.assert(memberList.isEmpty() == FALSE, 'Member query returned zero results');
   }
}