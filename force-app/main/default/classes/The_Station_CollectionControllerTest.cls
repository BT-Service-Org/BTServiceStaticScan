@isTest
public with sharing class The_Station_CollectionControllerTest {

    public static String CSG_BASE_PROFILE = 'CSG Base Profile';

    public The_Station_CollectionControllerTest() {

    }

    public static Station_Content__c createContent() {    
        Id recordTypeIdContent = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('URL').getRecordTypeId();
        Station_Content__c content = new Station_Content__c(Name='Test Content',
                                                            RecordTypeId = recordTypeIdContent,
                                                            Content_Type__c = 'URL',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 1);

        insert content;        
        return content;
    }

    public static Station_Pages__c createCollection(String collectionName, String collectionSubTitle, Boolean isPrivate) {
        Id recordTypeIdGroup = Schema.SObjectType.Station_Pages__c.getRecordTypeInfosByDeveloperName().get('Collection').getRecordTypeId();
        Station_Pages__c collection = new Station_Pages__c(Name=collectionName,
                                                            RecordTypeId = recordTypeIdGroup,
                                                            Collection_Header_Background_Color__c = 'rgb(125, 82, 194, 0.3)',
                                                            Group_Subtitle__c = collectionSubTitle, 
                                                            Private_Collection__c = isPrivate,                                                            
                                                            Tab_Name__c = 'COLLECTION');
        insert collection;
        return collection;
    }

    public static StationGroupingAssociation__c createCollectionContentAssociation(Station_Content__c con, Station_Pages__c pg) {
        StationGroupingAssociation__c associatedContent = new StationGroupingAssociation__c(
            Station_Content__c = con.id,
            Station_Page__c = pg.id
        );
        insert associatedContent;
        return associatedContent;
    }

    public static User createTestUser() {                

        String accountName = 'Salesforce.com - DO NOT TOUCH';
        String expectedValue = null;
        User usr = null;
        Account a = new Account(Name = accountName);
        insert a;

        List<String> firstNames = new List<String>{'Ally','Brandy','Casey','Debbie','Elisa'};
        Integer listSize1 = firstNames.size() - 1;
        Integer randomNumber1 = Integer.valueof((Math.random() * listSize1));
        String fName = firstNames[randomNumber1];
        List<String> lastNames = new List<String>{'Awesome','Bodacious','Cool','Dominant','Excellent'};
        Integer listSize2 = lastNames.size() - 1;
        Integer randomNumber2 = Integer.valueof((Math.random() * listSize2));
        String lName = lastNames[randomNumber2];
        Integer randomNumber3 = Integer.valueof((Math.random() * 100));
        String uName = fName+'.'+lName+'.'+randomNumber3+'@testorg.com';
        String n = fName + ' ' + lName;

        Profile p = [select id from Profile where name =: CSG_BASE_PROFILE];
        usr = new User();
        usr.Alias = 'TUser';
        usr.Email = 'newuser@testorg.com';
        usr.EmailEncodingKey = 'UTF-8';
        usr.FirstName = fName;
        usr.LastName = lName;
        usr.Username = uName;
        usr.ProfileId = p.Id;
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';        
        usr.TimeZoneSidKey = 'America/Los_Angeles';

        insert usr;
        
        return usr;
    }

    public static List<User> createTestUsers() {                
        System.debug('createTestUsers');
        String accountName = 'Salesforce.com - DO NOT TOUCH';
        String expectedValue = null;
        List<User> usrs = new List<User>();
        User usr = null;
        Account a = new Account(Name = accountName);
        insert a;

        List<String> firstNames = new List<String>{'Ally','Brandy','Casey','Debbie','Elisa'};
        List<String> lastNames = new List<String>{'Awesome','Bodacious','Cool','Dominant','Excellent'};
        Profile p = [select id from Profile where name =: CSG_BASE_PROFILE];

        for (Integer x = 0; x < 5; x++) {
            Integer listSize1 = firstNames.size() - 1;
            Integer randomNumber1 = Integer.valueof((Math.random() * listSize1));
            String fName = firstNames[randomNumber1];
            Integer listSize2 = lastNames.size() - 1;
            Integer randomNumber2 = Integer.valueof((Math.random() * listSize2));
            String lName = lastNames[randomNumber2];
            Integer randomNumber3 = Integer.valueof((Math.random() * 100));
            String uName = fName+'.'+lName+'.'+randomNumber3+'@testorg.com';
            String n = fName + ' ' + lName;

            usr = new User();
            usr.Alias = 'TUser';
            usr.Email = 'newuser@testorg.com';
            usr.EmailEncodingKey = 'UTF-8';
            usr.FirstName = fName;
            usr.LastName = lName;
            usr.Username = uName;
            usr.ProfileId = p.Id;
            usr.LanguageLocaleKey = 'en_US';
            usr.LocaleSidKey = 'en_US';        
            usr.TimeZoneSidKey = 'America/Los_Angeles';

            usrs.add(usr);
        }
        insert usrs;
        return usrs;
    }

    @isTest static void test_updateCollection() {    
        System.debug('test_updateCollection');
        boolean bSuccess = false;
        String ogName = 'OG Name';
        String ogSubTitle = 'OG Subtitle';
        String newName = 'Updated Collection Name';         
        String newDesc = 'Updated Collection Subtitle';
        String newColor = 'rgb(249, 225, 124, 0.3)';
        Boolean visibility = true;
        Boolean privateCollection = true;

        Station_Content__c c = createContent();
        Station_Pages__c p = createCollection(ogName, ogSubTitle, privateCollection);
        StationGroupingAssociation__c a = createCollectionContentAssociation(c, p);
        String collectionRecordId = p.id; 

        bSuccess = The_Station_CollectionController.updateCollection(collectionRecordId, newName, newDesc, newColor, visibility);

        Station_Pages__c updated = The_Station_CollectionController.getSpecificCollection(collectionRecordId);

        System.assertEquals(updated.Name, newName);        
    }

    @isTest static void test_followCollection() {    
        System.debug('test_followCollection');
        boolean bSuccess = false;
        String ogName = 'OG Name';
        String ogSubTitle = 'OG Subtitle';
        String sortType1 = 'Alphabetical';
        String sortType2 = 'Last Updated';
        String sortType3 = 'Created Date';
        String sortType4 = 'Default';
        Boolean privateCollection = true;

        Station_Content__c c = createContent();
        Station_Pages__c p = createCollection(ogName, ogSubTitle, privateCollection);
        StationGroupingAssociation__c a = createCollectionContentAssociation(c, p);
        String collectionRecordId = p.id; 
        
        bSuccess = The_Station_CollectionController.isUserFollowingCollections(collectionRecordId);
        
        System.assertEquals(bSuccess, false);
        
        bSuccess = The_Station_CollectionController.followCollection(collectionRecordId);
        
        System.assertEquals(bSuccess, true);

        bSuccess = The_Station_CollectionController.isUserFollowingCollections(collectionRecordId);

        System.assertEquals(bSuccess, true);

        List<Station_Pages__c> fp = null;
        fp = The_Station_CollectionController.getUserFollowedCollections(sortType1);
        fp = The_Station_CollectionController.getUserFollowedCollections(sortType2);
        fp = The_Station_CollectionController.getUserFollowedCollections(sortType3);
        fp = The_Station_CollectionController.getUserFollowedCollections(sortType4);

        Integer count = The_Station_CollectionController.getCollectionFollowerCount(collectionRecordId);

        System.assertEquals(count, 1);

        bSuccess = The_Station_CollectionController.followCollection(collectionRecordId);
        
        System.assertEquals(bSuccess, true);

        //User attributes : String pName, String fName, String lName, String uEmail, String uName
        User usr = createTestUser();

        System.runAs(usr) {
            fp = null;
            fp = The_Station_CollectionController.getUserFollowedCollections(sortType1);
            fp = The_Station_CollectionController.getUserFollowedCollections(sortType2);
            fp = The_Station_CollectionController.getUserFollowedCollections(sortType3);
            fp = The_Station_CollectionController.getUserFollowedCollections(sortType4);

        }        
    }

    @isTest static void test_getCollection() {   
        System.debug('test_getCollection'); 
        String ogName = 'OG Name';
        String ogSubTitle = 'OG Subtitle';
        boolean bSuccess = false;
        String sortType1 = 'Alphabetical';
        String sortType2 = 'Last Updated';
        String sortType3 = 'Created Date';
        String sortType4 = 'Default';
        Boolean privateCollection = true;

        Station_Content__c c = createContent();
        Station_Pages__c p = createCollection(ogName, ogSubTitle, privateCollection);
        StationGroupingAssociation__c a = createCollectionContentAssociation(c, p);
        String collectionRecordId = p.id;
        
        Integer cnt = The_Station_CollectionController.getCollectionContentCount(collectionRecordId);

        System.assertEquals(1, cnt);

        List<String> collcontent = The_Station_CollectionController.getUserCollectionWithContent(c.Id);

        if(collcontent != null && collcontent.isEmpty()) {
            System.assert(false);
        } else {
            System.assert(true);
        }

        bSuccess = The_Station_CollectionController.isCollectionEditableByRunningUser(collectionRecordId);

        bSuccess = The_Station_CollectionController.isPrivateCollectionShared(collectionRecordId);

        List<Station_Pages__c> owned = null;
        owned = The_Station_CollectionController.getUserOwnedCollections(sortType1);
        if(owned != null && owned.isEmpty()) {
            System.assert(false);
        } else {
            System.assert(true);
        }
        owned = The_Station_CollectionController.getUserOwnedCollections(sortType2);
        if(owned != null && owned.isEmpty()) {
            System.assert(false);
        } else {
            System.assert(true);
        }
        owned = The_Station_CollectionController.getUserOwnedCollections(sortType3);
        if(owned != null && owned.isEmpty()) {
            System.assert(false);
        } else {
            System.assert(true);
        }
        owned = The_Station_CollectionController.getUserOwnedCollections(sortType4);
        if(owned != null && owned.isEmpty()) {
            System.assert(false);
        } else {
            System.assert(true);
        }

        owned = The_Station_CollectionController.getUserOwnedCollectionsIdNameOnlyLimitLastModified();
        if(owned != null && owned.isEmpty()) {
            System.assert(false);
        } else {
            System.assert(true);
        }

        bSuccess = The_Station_CollectionController.addToRemoveFromCollection(collectionRecordId, c.Id, false);

        System.assertEquals(bSuccess, true);

        bSuccess = The_Station_CollectionController.addToRemoveFromCollection(collectionRecordId, c.Id, true);

        System.assertEquals(bSuccess, true);

        bSuccess = The_Station_CollectionController.deleteCollection(collectionRecordId);

        System.assertEquals(bSuccess, true);

    }

    @isTest static void test_sharingCollection() {    
        System.debug('test_sharingCollection'); 
        String ogName = 'OG Name';
        String ogSubTitle = 'OG Subtitle';
        boolean bSuccess = false;
        String sortType1 = 'Alphabetical';
        String sortType2 = 'Last Updated';
        String sortType3 = 'Created Date';
        String sortType4 = 'Default';
        String readAccess = 'Read';
        String editAccess = 'Read';
        String revokeAccess = 'Revoke';
        Boolean privateCollection = true;

        Station_Content__c c = createContent();
        Station_Pages__c p = createCollection(ogName, ogSubTitle, privateCollection);
        StationGroupingAssociation__c a = createCollectionContentAssociation(c, p);
        String collectionRecordId = p.id;

        List<User> usrs = createTestUsers();

        List<Station_Pages__Share> shared = null;
        
// ADD ASSERTS AS NEEDED

        shared = The_Station_CollectionController.updateCollectionSharing(collectionRecordId, usrs[0].id, readAccess);
        shared = The_Station_CollectionController.updateCollectionSharing(collectionRecordId, usrs[0].id, editAccess);
        shared = The_Station_CollectionController.updateCollectionSharing(collectionRecordId, usrs[0].id, revokeAccess);

        shared = The_Station_CollectionController.updateCollectionSharing(collectionRecordId, usrs[1].id, editAccess);
        shared = The_Station_CollectionController.updateCollectionSharing(collectionRecordId, usrs[2].id, editAccess);
        shared = The_Station_CollectionController.updateCollectionSharing(collectionRecordId, usrs[3].id, editAccess);                
        shared = The_Station_CollectionController.updateCollectionSharing(collectionRecordId, usrs[4].id, editAccess);                

        List<User> usrEdit = The_Station_CollectionController.getCollectionsContributors(collectionRecordId);

        List<Station_Pages__Share> manShare = The_Station_CollectionController.getCollectionManualShareData(collectionRecordId);

        System.runAs(usrs[1]) {
            List<Station_Pages__c> sp = null;
            sp = The_Station_CollectionController.getSharedWithUserCollections(sortType1);
            sp = The_Station_CollectionController.getSharedWithUserCollections(sortType2);
            sp = The_Station_CollectionController.getSharedWithUserCollections(sortType3);
            sp = The_Station_CollectionController.getSharedWithUserCollections(sortType4);
        }
    }
    
    @isTest static void test_getPublicCollections() {   
        System.debug('test_getPublicCollections'); 
        String cName1 = 'AAA Collection';
        String cName2 = 'BBB Collection';
        String cName3 = 'CCC Collection';
        String cName4 = 'DDD Collection';
        String cName5 = 'EEE Collection';
        String cSubTitle = 'Subtitle';
        boolean bSuccess = false;
        String sortType1 = 'Alphabetical';
        String sortType2 = 'Last Updated';
        String sortType3 = 'Created Date';
        String sortType4 = 'Most Popular';        
        String sortType5 = 'Default';
        Boolean privateCollection = false;

        Station_Content__c c1 = createContent();
        Station_Content__c c2 = createContent();
        Station_Content__c c3 = createContent();
        Station_Content__c c4 = createContent();
        Station_Content__c c5 = createContent();
        Station_Pages__c p1 = createCollection(cName1, cSubTitle, privateCollection);
        Station_Pages__c p2 = createCollection(cName2, cSubTitle, privateCollection);
        Station_Pages__c p3 = createCollection(cName3, cSubTitle, privateCollection);
        Station_Pages__c p4 = createCollection(cName4, cSubTitle, privateCollection);
        Station_Pages__c p5 = createCollection(cName5, cSubTitle, privateCollection);
        StationGroupingAssociation__c a1 = createCollectionContentAssociation(c1, p1);
        StationGroupingAssociation__c a2 = createCollectionContentAssociation(c2, p2);
        StationGroupingAssociation__c a3 = createCollectionContentAssociation(c3, p3);
        StationGroupingAssociation__c a4 = createCollectionContentAssociation(c4, p4);
        StationGroupingAssociation__c a5 = createCollectionContentAssociation(c5, p5);

        List<Station_Pages__c> pub1 = The_Station_CollectionController.getPublicCollections(sortType1);
        List<Station_Pages__c> pub2 = The_Station_CollectionController.getPublicCollections(sortType2);
        List<Station_Pages__c> pub3 = The_Station_CollectionController.getPublicCollections(sortType3);
        List<Station_Pages__c> pub4 = The_Station_CollectionController.getPublicCollections(sortType4);
        List<Station_Pages__c> pub5 = The_Station_CollectionController.getPublicCollections(sortType5);

        Station_Pages__c pg = pub1.get(0);
        System.assertEquals(cName1, pg.Name);        
    }

    @isTest static void test_searchPublicCollections() {   
        System.debug('test_searchPublicCollections'); 
        String cName1 = 'Red Ferrari Engine';
        String cName2 = 'Green Baby Mango';
        String cName3 = 'Blue Bottle';
        String cName4 = 'Sky Blue Baby';
        String cName5 = 'Fire Engine Red';
        String cSubTitle = 'Subtitle';
        boolean bSuccess = false;
        String sortType = 'Alphabetical';
        String searchTerms1 = 'Red';
        String searchTerms2 = 'Blue';
        String searchTerms3 = 'Baby';
        String searchTerms4 = 'Engine';
        String searchTerms5 = 'Green';

        Boolean privateCollection = false;

        Station_Content__c c1 = createContent();
        Station_Content__c c2 = createContent();
        Station_Content__c c3 = createContent();
        Station_Content__c c4 = createContent();
        Station_Content__c c5 = createContent();
        Station_Pages__c p1 = createCollection(cName1, cSubTitle, privateCollection);
        Station_Pages__c p2 = createCollection(cName2, cSubTitle, privateCollection);
        Station_Pages__c p3 = createCollection(cName3, cSubTitle, privateCollection);
        Station_Pages__c p4 = createCollection(cName4, cSubTitle, privateCollection);
        Station_Pages__c p5 = createCollection(cName5, cSubTitle, privateCollection);
        StationGroupingAssociation__c a1 = createCollectionContentAssociation(c1, p1);
        StationGroupingAssociation__c a2 = createCollectionContentAssociation(c2, p2);
        StationGroupingAssociation__c a3 = createCollectionContentAssociation(c3, p3);
        StationGroupingAssociation__c a4 = createCollectionContentAssociation(c4, p4);
        StationGroupingAssociation__c a5 = createCollectionContentAssociation(c5, p5);

        List<Station_Pages__c> pub1 = The_Station_CollectionController.searchPublicCollections(searchTerms1, sortType);
        List<Station_Pages__c> pub2 = The_Station_CollectionController.searchPublicCollections(searchTerms2, sortType);
        List<Station_Pages__c> pub3 = The_Station_CollectionController.searchPublicCollections(searchTerms3, sortType);
        List<Station_Pages__c> pub4 = The_Station_CollectionController.searchPublicCollections(searchTerms4, sortType);
        List<Station_Pages__c> pub5 = The_Station_CollectionController.searchPublicCollections(searchTerms5, sortType);
        
        System.debug('>>>>>>>>>> test_searchPublicCollections');
        System.debug('>>>>>>>>>> pub1 : ' + pub1);
        System.debug('>>>>>>>>>> pub2 : ' + pub2);
        System.debug('>>>>>>>>>> pub3 : ' + pub3);
        System.debug('>>>>>>>>>> pub4 : ' + pub4);
        System.debug('>>>>>>>>>> pub5 : ' + pub5);


        if (pub1 != null) {
            Station_Pages__c pg1 = pub1.get(0);
            System.assertEquals(cName5, pg1.Name);
        }
        if (pub2 != null) {
            Station_Pages__c pg2 = pub1.get(1);
            System.assertEquals(cName1, pg2.Name);
        }
        
    }    
}