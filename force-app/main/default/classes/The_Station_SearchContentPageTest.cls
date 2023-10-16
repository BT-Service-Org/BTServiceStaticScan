@isTest
public with sharing class The_Station_SearchContentPageTest {

    public static String CSG_BASE_PROFILE = 'CSG Base Profile';

    public The_Station_SearchContentPageTest() {

    }

    public static List<Station_Pages__c> createContentGroups() {
        RecordType recordTypeContentGroup = [SELECT ID FROM RecordType WHERE SobjectType='Station_Pages__c' AND DeveloperName = 'Content_Group'];
/*
        Community/Team (Community_Team__c) : Station website, CSG Enablement website, etc.
        Product/Offering (Cloud_Product__c): This should only be used if the Community/Team= The Station Hub
        Page (Content_Sub_Group_Name__c): Used if Community/Team ≠The Station Hub
*/
        List<Station_Pages__c> groups = new List<Station_Pages__c>();

        Station_Pages__c group1 = new Station_Pages__c();
        Station_Pages__c group2 = new Station_Pages__c();
        Station_Pages__c group3 = new Station_Pages__c();

        group1.name = 'The Station Hub Sales Cloud';
        group1.Community_Team__c = 'The Station Hub';
        group1.Cloud_Product__c = 'Sales Cloud';
        group1.Content_Sub_Group_Name__c = '';
        group1.Tab_Name__c = 'Sales Cloud 1.0';
        group1.recordtypeid = recordTypeContentGroup.Id;

        group2.name = 'The Station Hub Sales Cloud';
        group2.Community_Team__c = 'The Station Hub';
        group2.Cloud_Product__c = 'Sales Cloud';
        group2.Content_Sub_Group_Name__c = '';
        group2.Tab_Name__c = 'Sales Cloud 2.0';
        group2.recordtypeid = recordTypeContentGroup.Id;

        group3.name = 'CSG Enablement Sales Cloud';
        group3.Community_Team__c = 'CSG Enablement';
        group3.Cloud_Product__c = 'Sales Cloud';
        group3.Content_Sub_Group_Name__c = 'Enablement';
        group3.Tab_Name__c = 'Sales Cloud Enablement';
        group3.recordtypeid = recordTypeContentGroup.Id;

        groups.add(group1);
        groups.add(group2);
        groups.add(group3);

        insert groups;

        return groups;
    }


    public static List<Station_Content__c> createContentAddToGroup(String groupID) {    
        Id recordTypeIdContentURL = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('URL').getRecordTypeId();
        Id recordTypeIdContentSP = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        Id recordTypeIdContentAppEx = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('App_Exchange').getRecordTypeId();
        Id recordTypeIdContentStandard = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Standard_Content').getRecordTypeId();
        
        List<String> nameVariables = new List<String>{'Red','Green','Blue','White','Black'};
        Integer listSize = nameVariables.size() - 1;
        Integer randomNumber = Integer.valueof((Math.random() * listSize));
        String randomString= nameVariables[randomNumber];

        String randomContentName = 'Sales Cloud' + ' - ' + randomString;
        
        Station_Content__c contentURL = new Station_Content__c(Name=randomContentName,
                                                            RecordTypeId = recordTypeIdContentURL,
                                                            Content_Type__c = 'URL',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 1);
        
        randomNumber = Integer.valueof((Math.random() * listSize));
        randomString= nameVariables[randomNumber];

        randomContentName = 'Marketing Cloud' + ' - ' + randomString;
                                                            
        Station_Content__c contentSP = new Station_Content__c(Name=randomContentName,
                                                            RecordTypeId = recordTypeIdContentSP,
                                                            Content_Type__c = 'Success Program',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 2);

        randomNumber = Integer.valueof((Math.random() * listSize));
        randomString= nameVariables[randomNumber];

        randomContentName = 'Service Cloud' + ' - ' + randomString;
                                                    
        Station_Content__c contentAppEx = new Station_Content__c(Name=randomContentName,
                                                            RecordTypeId = recordTypeIdContentAppEx,
                                                            Content_Type__c = 'App Exchange',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 3);

        randomNumber = Integer.valueof((Math.random() * listSize));
        randomString= nameVariables[randomNumber];

        randomContentName = 'Phsical Cloud' + ' - ' + randomString;

        Station_Content__c contentStandard = new Station_Content__c(Name=randomContentName,
                                                            RecordTypeId = recordTypeIdContentStandard,
                                                            Content_Type__c = 'Content Version',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 4);
                                                            
        List<Station_Content__c> content = new List<Station_Content__c>();
        content.add(contentURL);
        content.add(contentSP);
        content.add(contentAppEx);
        content.add(contentStandard);
                                                                                                                        
        insert content;

        List<StationGroupingAssociation__c> sga = new List<StationGroupingAssociation__c>();
        for (Station_Content__c c : content) {
            StationGroupingAssociation__c grpass = new StationGroupingAssociation__c();
            grpass.Station_Content__c = c.id;
            grpass.Station_Page__c = groupID;
            sga.add(grpass);            
        }
        
        insert sga;      
        
        return content;
    }

    @isTest static void test_Search() {    
        System.debug('The_Station_SearchContentPageTest.test_Search');        
        List<Station_Pages__c> grps = createContentGroups();
        List<Station_Content__c> content = null;
        String contentNameConstant = null;
        for (Station_Pages__c p : grps) {            
            content = createContentAddToGroup(p.id);
        }

        User u = The_Station_SearchContentPageController.getRunningUserInfo();

        String searchTerms = 'Cloud'; 
        String sortType = 'Alphabetical';
        String communityTeam = 'The Station Hub';
        String cloudProduct = 'Sales Cloud';
        String stationPage = '';
                
        List<StationContentWrapper> scw1 = The_Station_SearchContentPageController.searchContentInPage(searchTerms, sortType, communityTeam, cloudProduct, stationPage);

        if(scw1 != null) {
            System.debug('Search Term : ' + searchTerms);
            System.debug('Result Count : ' + scw1.size());
            for(StationContentWrapper c : scw1) {
                System.debug('Content Name : ' + c.content.Name);
            }
            System.assertEquals(8, scw1.size(), 'There should be 8 results');
        } else {
            System.debug('scw1 : ' + scw1);
        }
        
        searchTerms = 'Service'; 
        sortType = 'Created Date';
        communityTeam = 'CSG Enablement';
        cloudProduct = 'Sales Cloud';
        stationPage = 'Enablement';

        List<StationContentWrapper> scw2 = The_Station_SearchContentPageController.searchContentInPage(searchTerms, sortType, communityTeam, cloudProduct, stationPage);

        if(scw2 != null) {
            System.debug('Search Term : ' + searchTerms);
            System.debug('Result Count : ' + scw2.size());
            for(StationContentWrapper c : scw2) {
                System.debug('Content Name : ' + c.content.Name);
            }
            System.assertEquals(1, scw2.size(), 'There should be 1 result');
        } else {
            System.debug('scw2 : ' + scw2);
        }

        searchTerms = 'White'; 
        sortType = 'Last Updated';
        communityTeam = 'The Station Hub';
        cloudProduct = 'Sales Cloud';
        stationPage = '';

        List<StationContentWrapper> scw3 = The_Station_SearchContentPageController.searchContentInPage(searchTerms, sortType, communityTeam, cloudProduct, stationPage);

        if(scw3 != null) {
            System.debug('Search Term : ' + searchTerms);
            System.debug('Result Count : ' + scw3.size());
            for(StationContentWrapper c : scw3) {
                System.debug('Content Name : ' + c.content.Name);
            }
            System.assert(scw3 != null, 'No results returned');
        } else {
            System.debug('scw3 : ' + scw3);
        }

    }
}