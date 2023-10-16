public with sharing class The_Station_CollectionController {
    
    private static final String userFavCollectionName = 'My Favorites';
    private static final String userFavCollectionSubTitle = ' - The Station Content Favorites';
    private static final String userFavCollectionTabName = 'FAVORITES';
    
    public The_Station_CollectionController() {

    }

    @AuraEnabled
    public static List<Station_Pages__Share> updateCollectionSharing(String collectionRecordId, String userId, String AccessLevelReadEditRevoke) {
        List<Station_Pages__Share> collectionShares;
        Station_Pages__Share share = new Station_Pages__Share();
        boolean bSuccess = false;
        if(AccessLevelReadEditRevoke != NULL) {
            if (AccessLevelReadEditRevoke.equals('Revoke')) {
                share = [SELECT Id from Station_Pages__Share WHERE ParentId =: collectionRecordId AND UserOrGroupId =: userId];
                try {
                    delete share;
                    bSuccess = true;       
                } catch (Exception e) {
                    bSuccess = false;       
                }
            } else {
                try {
                    share.UserOrGroupId = userId;
                    share.ParentId = collectionRecordId;
                    share.AccessLevel = AccessLevelReadEditRevoke;
                    insert share;    
                    bSuccess = true;       
                } catch (Exception e) {
                    bSuccess = false;
                }    
            }    
        }
        collectionShares = getCollectionManualShareData(collectionRecordId);
        return collectionShares;
    }


    @AuraEnabled
    public static List<User> getCollectionsContributors(String collectionRecordId) {        
        List<User> contributors = [SELECT Id, MediumPhotoUrl, Name, FederationIdentifier FROM User where Id IN (SELECT UserOrGroupId FROM Station_Pages__Share WHERE ParentId =: collectionRecordId AND RowCause = 'Manual' AND AccessLevel = 'Edit') ORDER BY Name];
        return contributors;
    }

    // DAVID WANTED TO USE ORG62 PROFILE PHOTOS - TRIED THIS BUT ORG62 / CORS / CSP blocked photos...
    @AuraEnabled
    public static List<Org62_User__x> getCollectionsContributorsOrg62(String collectionRecordId) {
        List<User> conFedId = [SELECT FederationIdentifier FROM User where Id IN (SELECT UserOrGroupId FROM Station_Pages__Share WHERE ParentId =: collectionRecordId AND RowCause = 'Manual' AND AccessLevel = 'Edit') ORDER BY Name];
        Set<String> myIds = new Set<String>();                                                      
        for (User u : conFedId) {
            if(u.FederationIdentifier != NULL) {
                myIds.add(u.FederationIdentifier);        
            }
        } 
        List<Org62_User__x> org62UserData = [SELECT Id, SmallPhotoUrl__c, Name__c, FederationIdentifier__c, email__c FROM Org62_User__x WHERE FederationIdentifier__c IN :myIds];        
        return org62UserData;
    }

    @AuraEnabled
    public static List<Station_Pages__c> getUserOwnedCollections(String sortType) {
        List<Station_Pages__c> userCollections = null;
        String userId = UserInfo.getUserId();
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            if ((sortType == null) || (sortType == 'Last Updated')) {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and OwnerId =: userId AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY LastModifiedDate DESC];
            } else if (sortType == 'Created Date') {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and OwnerId =: userId AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY CreatedDate DESC];    
            } else if (sortType == 'Alphabetical') {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and OwnerId =: userId AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY Name];    
            } else {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and OwnerId =: userId AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY LastModifiedDate DESC];    
            }            
            if (userCollections != null & userCollections.isEmpty()) {
                // User does not have a collection
                userCollections = null;
            } 
        }
        return userCollections;
    }
    
    @AuraEnabled
    public static List<Station_Pages__c> getUserOwnedCollectionsIdNameOnlyLimitLastModified() {
        List<Station_Pages__c> userCollections = null;
        String userId = UserInfo.getUserId();
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            userCollections = [SELECT Id, Name FROM Station_Pages__c 
            WHERE RecordTypeId =: recType.Id and OwnerId =: userId AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName 
            ORDER BY lastmodifieddate DESC LIMIT 8];            
            if (userCollections != null & userCollections.isEmpty()) {
                // User does not have a collection
                userCollections = null;
            } 
        }
        return userCollections;
    }

    @AuraEnabled
    public static List<Station_Pages__c> getUserFollowedCollections(String sortType) {
        String userId = UserInfo.getUserId();
        List<Station_Pages__c> userFollowedCollections = null;
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            if ((sortType == null) || (sortType == 'Last Updated')) {
                userFollowedCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, OwnerId, Associated_Content_Count__c, CreatedBy.Name, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE OwnerId !=: userId AND RecordTypeId =: recType.Id AND Id IN (SELECT Station_Collection__c 
                                                            FROM Station_Collection_Follow__c 
                                                            WHERE user__c =: userId)
                ORDER BY LastModifiedDate];
        } else if (sortType == 'Created Date') {
            userFollowedCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, OwnerId, Associated_Content_Count__c, CreatedBy.Name, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                    FROM Station_Pages__c 
                    WHERE OwnerId !=: userId AND RecordTypeId =: recType.Id AND Id IN (SELECT Station_Collection__c 
                                                                FROM Station_Collection_Follow__c 
                                                                WHERE user__c =: userId)
                    ORDER BY CreatedDate DESC];    
        } else if (sortType == 'Alphabetical') {
            userFollowedCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, OwnerId, Associated_Content_Count__c, CreatedBy.Name, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE OwnerId !=: userId AND RecordTypeId =: recType.Id AND Id IN (SELECT Station_Collection__c 
                                                            FROM Station_Collection_Follow__c 
                                                            WHERE user__c =: userId)
                ORDER BY Name];    
        } else {
            userFollowedCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, OwnerId, Associated_Content_Count__c, CreatedBy.Name, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE OwnerId !=: userId AND RecordTypeId =: recType.Id AND Id IN (SELECT Station_Collection__c 
                                                            FROM Station_Collection_Follow__c 
                                                            WHERE user__c =: userId)
                ORDER BY LastModifiedDate DESC];
        } 

/*
            userFollowedCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, OwnerId, CreatedBy.Name, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                    FROM Station_Pages__c 
                    WHERE OwnerId !=: userId AND RecordTypeId =: recType.Id AND Id IN (SELECT Station_Collection__c 
                                                                FROM Station_Collection_Follow__c 
                                                                WHERE user__c =: userId)
                    ORDER BY LastModifiedDate];
*/                    
        }
        return userFollowedCollections;
    }
    
    @AuraEnabled
    public static boolean isPrivateCollectionShared(String collectionRecordId) {
        boolean bReturn = false;
        List <Station_Pages__Share> shared = [SELECT id FROM Station_Pages__Share WHERE rowcause = 'Manual' AND parentid =: collectionRecordId];
        if (shared != null & shared.isEmpty()) {
            // NOT SHARED
            bReturn = false;
        } else {
            bReturn = true;
        }
        return bReturn;        
    }

    @AuraEnabled
    public static List<Station_Pages__c> getSharedWithUserCollections(String sortType) {
        String userId = UserInfo.getUserId();
        List<Station_Pages__c> sharedWithUserCollections = new List<Station_Pages__c>();
        List<Station_Pages__c> shared = null;
        List<Station_Pages__c> followed = null;
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
/*            
            sharedWithUserCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, CreatedBy.Name, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Tab_Name__c 
                    FROM Station_Pages__c 
                    WHERE RecordTypeId =: recType.Id AND Id IN (SELECT ParentId 
                                                                FROM Station_Pages__Share 
                                                                WHERE UserOrGroupId =: userId and RowCause = 'Manual')];
*/

            if ((sortType == null) || (sortType == 'Last Updated')) {
                shared = [SELECT Id, Name, Collection_Header_Background_Color__c, CreatedBy.Name, CreatedDate, Associated_Content_Count__c, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId in (select id from recordtype where name = 'Collection') AND Id IN (SELECT ParentId 
                FROM Station_Pages__Share 
                WHERE UserOrGroupId =: userId and RowCause = 'Manual')
                ORDER BY LastModifiedDate DESC];
            } else if (sortType == 'Created Date') {
                shared = [SELECT Id, Name, Collection_Header_Background_Color__c, CreatedBy.Name, CreatedDate, Associated_Content_Count__c, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId in (select id from recordtype where name = 'Collection') AND Id IN (SELECT ParentId 
                FROM Station_Pages__Share 
                WHERE UserOrGroupId =: userId and RowCause = 'Manual')
                ORDER BY CreatedDate DESC];    
            } else if (sortType == 'Alphabetical') {
                shared = [SELECT Id, Name, Collection_Header_Background_Color__c, CreatedBy.Name, CreatedDate, Associated_Content_Count__c, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId in (select id from recordtype where name = 'Collection') AND Id IN (SELECT ParentId 
                FROM Station_Pages__Share 
                WHERE UserOrGroupId =: userId and RowCause = 'Manual')
                ORDER BY Name];    
            } else {
                shared = [SELECT Id, Name, Collection_Header_Background_Color__c, CreatedBy.Name, CreatedDate, Associated_Content_Count__c, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId in (select id from recordtype where name = 'Collection') AND Id IN (SELECT ParentId 
                FROM Station_Pages__Share 
                WHERE UserOrGroupId =: userId and RowCause = 'Manual')
                ORDER BY LastModifiedDate DESC];
            } 
            // LIST OF COLLECTIONS SHARED WITH THE USER
/*            
            shared = [SELECT Id, Name, Collection_Header_Background_Color__c, CreatedBy.Name, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                                        FROM Station_Pages__c 
                                        WHERE RecordTypeId in (select id from recordtype where name = 'Collection') AND Id IN (SELECT ParentId 
                                        FROM Station_Pages__Share 
                                        WHERE UserOrGroupId =: userId and RowCause = 'Manual')];
*/
            // LIST OF COLLECTIONS FOLLOWED BY THE USER                                        
            followed = [SELECT Id, Name, Collection_Header_Background_Color__c, CreatedBy.Name, CreatedDate, Associated_Content_Count__c, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
            FROM Station_Pages__c where Id in (SELECT Station_Collection__c FROM Station_Collection_Follow__c WHERE user__c =: userId)];

            // REMOVE Y FROM X
            for (Station_Pages__c sharedFollowed : shared) {
                if(followed.contains(sharedFollowed)) {                    
                    Integer i = followed.indexOf(sharedFollowed);
                    // DONT DO THIS - CAUSES LIST INDEX OUT OF BOUNDS ERROR BUT DOES WORK.
//                    shared.remove(i);
                    
                } else {
                    sharedWithUserCollections.add(sharedFollowed);
                }
            }    

        }
        return sharedWithUserCollections;
//        return shared;        
    }

    @AuraEnabled
    public static Station_Pages__c getSpecificCollection(String collectionRecordId) {         
        Station_Pages__c userCollection = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedBy.Name, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, OwnerId, Private_Collection__c, Tab_Name__c 
                                FROM Station_Pages__c 
                                WHERE Id =: collectionRecordId];             
        return userCollection;
    }  

    @AuraEnabled(cacheable=true)
    public static Integer getCollectionContentCount(String collectionRecordId) {
        List<StationGroupingAssociation__c> collectionContentCount = [SELECT Station_Content__c FROM StationGroupingAssociation__c WHERE Station_Page__c =: collectionRecordId];
        Integer count = 0;
        if (collectionContentCount != null & collectionContentCount.isEmpty()) {
            count = 0;
        } else {
            count = collectionContentCount.size();
        }
        return count;
    }    


    @AuraEnabled
    public static Integer getCollectionFollowerCount(String collectionRecordId) {
        List<Station_Collection_Follow__c> collectionCount = [SELECT Id FROM Station_Collection_Follow__c WHERE Station_Collection__c =: collectionRecordId];
        Integer count = 0;
        if (collectionCount != null & collectionCount.isEmpty()) {
            count = 0;
        } else {
            count = collectionCount.size();
        }
        return count;
    }    

    @AuraEnabled
    public static boolean isUserFollowingCollections(String collectionRecordId) {
        String userId = UserInfo.getUserId();
        boolean followed = false;
        List<Station_Collection_Follow__c> userFollowedCollection = [SELECT Id FROM Station_Collection_Follow__c WHERE Station_Collection__c =: collectionRecordId AND user__c =: userId];
        if (userFollowedCollection != null & userFollowedCollection.isEmpty()) {
            followed = false;
        } else {
            followed = true;
        }
        return followed;
    }       

    //////////////////////
    // WORKING HERE NOW //
    //////////////////////
    private static List<Station_Pages__c> getUserCollections() {
        List<Station_Pages__c> userCollections = null;
        String userId = UserInfo.getUserId();
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            userCollections = [SELECT Id, Name FROM Station_Pages__c 
            WHERE RecordTypeId =: recType.Id and OwnerId =: userId AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName];            
        }
        return userCollections;
    }

    @AuraEnabled
    public static List<String> getUserCollectionWithContent(String contentID) {
        List<Station_Pages__c> userCollectionsWithContent = new List<Station_Pages__c>();
        List<StationGroupingAssociation__c> sga = null;
        String userId = UserInfo.getUserId();
        Set<Id> allCollectionIds = new Set<Id>();
        Set<Id> collectionWithContentIds = new Set<Id>();
        List<String> delimtedListNameIdChecked = null;

        List<Station_Pages__c> userAllCollections = getUserCollections();
        
        if (userAllCollections != null) {
            for (Station_Pages__c sp : userAllCollections) {
                allCollectionIds.add(sp.id);
            }
    
            sga = [SELECT Station_Page__c FROM StationGroupingAssociation__c WHERE Station_Page__c in :allCollectionIds AND Station_Content__c =: contentID];
    
            for (StationGroupingAssociation__c s : sga) {
                collectionWithContentIds.add(s.Station_Page__c);
            }
    
            delimtedListNameIdChecked = new List<String>();

            for (Station_Pages__c collection : userAllCollections) {
                if (collectionWithContentIds.contains(collection.Id)) {
                    delimtedListNameIdChecked.add(collection.Name + '|' + collection.Id + '|' + 'true');                    
                }  else {
                    delimtedListNameIdChecked.add(collection.Name + '|' + collection.Id + '|' + 'false');                    
                }
            }
        } else {
            delimtedListNameIdChecked = null;
        }       

        return delimtedListNameIdChecked;
    }
    
    @AuraEnabled
    public static boolean updateCollection(String collectionRecordId, String newName, String newDesc, String newColor, Boolean visibility) {
        boolean bSuccess = false;
        Station_Pages__c userCollection = [SELECT Id, Name, Group_Subtitle__c, Tab_Name__c, Collection_Header_Background_Color__c, Private_Collection__c
                                FROM Station_Pages__c 
                                WHERE Id =: collectionRecordId];
        if (userCollection != null) {
            try {
                userCollection.Name = newName;
                userCollection.Group_Subtitle__c = newDesc;
                userCollection.Collection_Header_Background_Color__c = newColor;
                userCollection.Private_Collection__c = visibility;
                update userCollection;
                bSuccess = true;    
            } catch (Exception e) {
                System.debug('*** Collection update failed ' + e.getmessage());
            }
        }
        return bSuccess;
    }

    @AuraEnabled
    public static boolean deleteCollection(String collectionRecordId) {
        boolean bSuccess = false;
        Station_Pages__c userCollection = [SELECT Id FROM Station_Pages__c WHERE Id =: collectionRecordId];
        if (userCollection != null) {
            try {
                List<StationGroupingAssociation__c> collectionItems = [SELECT Id FROM StationGroupingAssociation__c WHERE Station_Page__c =: collectionRecordId];
                if (collectionItems != null & collectionItems.isEmpty()) {
                    // No items in the collections
                } else {
                    delete collectionItems;
                }
                delete userCollection;
                bSuccess = true;    
            } catch (Exception e) {
                System.debug('*** Collection delete failed ' + e.getmessage());
            }
        }
        return bSuccess;
    }

    @AuraEnabled
    public static boolean addToRemoveFromCollection(String collectionRecordId, String contentId, Boolean addToCollection) {
        boolean bSuccess = false;
        try {
            List<StationGroupingAssociation__c> collectionItems = [SELECT Id, Station_Page__c, Station_Page__r.Name, Station_Content__c, Station_Content__r.Name 
            FROM StationGroupingAssociation__c 
            WHERE Station_Page__c =: collectionRecordId AND Station_Content__c =: contentId];
            if (collectionItems != null & collectionItems.isEmpty()) {
                // Add to Collection
                if (addToCollection) {
                    StationGroupingAssociation__c addContent = new StationGroupingAssociation__c();
                    addContent.Station_Page__c = collectionRecordId;
                    addContent.Station_Content__c = contentId;
                    insert addContent;    
                }
            } else {
                delete collectionItems;
            }
            bSuccess = true;    
        } catch (Exception e) {
            System.debug('*** Collection Add / Remove failed ' + e.getmessage());
        }
        return bSuccess;
    }

    @AuraEnabled
    public static boolean followCollection(String collectionRecordId) {
        boolean bSuccess = false;
        String runningUserId = UserInfo.getUserId();
        List<Station_Collection_Follow__c> followed = [SELECT Id from Station_Collection_Follow__c WHERE User__c =: runningUserId AND Station_Collection__c =: collectionRecordId];
        if (followed != null & followed.isEmpty()) {
            Station_Collection_Follow__c follow = new Station_Collection_Follow__c();
            follow.User__c = UserInfo.getUserId();
            follow.Station_Collection__c = collectionRecordId;
            try {
                insert follow;
                bSuccess = true;    
            } catch (Exception e) {
                System.debug('*** Collection follow failed ' + e.getmessage());
            }    
        } else {
            try {
                delete followed;
                bSuccess = true;    
            } catch (Exception e) {
                System.debug('*** Collection (UN)follow failed ' + e.getmessage());
            }    
        }
        return bSuccess;
    }
    
    @AuraEnabled
    public static List<Station_Pages__Share> getCollectionManualShareData(String collectionRecordId) {
        List<Station_Pages__Share> collectionShares = [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId, UserOrGroup.Name FROM Station_Pages__Share WHERE ParentId =: collectionRecordId AND RowCause = 'Manual' ORDER BY AccessLevel DESC];
        return collectionShares;
    }

    @AuraEnabled(cacheable=true)
    public static boolean isCollectionEditableByRunningUser(String collectionRecordId) {
        String userId = UserInfo.getUserId();
        boolean editable = false;
        List<Station_Pages__Share> collectionAccessLevel = [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId, UserOrGroup.Name 
        FROM Station_Pages__Share 
        WHERE ParentId =: collectionRecordId 
        AND ( AccessLevel = 'Edit' OR AccessLevel = 'All' )
        AND UserOrGroupId =: userId];
        if (collectionAccessLevel != null & collectionAccessLevel.isEmpty()) {
            editable = false;
        } else {
            editable = true;
        }
        return editable;
    }
    
    @AuraEnabled
    public static List<Station_Pages__c> getPublicCollections(String sortType) {
        List<Station_Pages__c> userCollections = null;
        String userId = UserInfo.getUserId();
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            if ((sortType == null) || (sortType == 'Last Updated')) {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and Private_Collection__c = false AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY LastModifiedDate DESC];
            } else if (sortType == 'Created Date') {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and Private_Collection__c = false AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY CreatedDate DESC];    
            } else if (sortType == 'Alphabetical') {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and Private_Collection__c = false AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY Name];    
            } else if (sortType == 'Most Popular') {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and Private_Collection__c = false AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY Followers__c DESC];    
            } else {
                userCollections = [SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c 
                FROM Station_Pages__c 
                WHERE RecordTypeId =: recType.Id and Private_Collection__c = false AND Name !=: userFavCollectionName AND Tab_Name__c !=: userFavCollectionTabName
                ORDER BY Followers__c DESC];    
            }            
            if (userCollections != null & userCollections.isEmpty()) {
                // User does not have a collection
                userCollections = null;
            } 
        }
        return userCollections;
    }

    @AuraEnabled
    public static List<Station_Pages__c> searchPublicCollections(String searchTerms, String sortType) {
        List<Station_Pages__c> userCollections = null;
        String userId = UserInfo.getUserId();
        String query = null;
        System.debug('>>>>>>>>>> searchPublicCollections : ' + searchTerms + '|' + sortType);
        if ((searchTerms == null) || (searchTerms == '')) {
            System.debug('>>>>>>>>>> searchPublicCollections : no term -> getPublicCollections');            
            userCollections = getPublicCollections(sortType);
        } else {
            searchTerms='\'%' + String.escapeSingleQuotes(searchTerms.trim()) + '%\'';

            System.debug('>>>>>>>>>> searchPublicCollections : Search Terms : ' + searchTerms);
    
            RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];

            if (recType != null) {
                query = 'SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c ' +
                'FROM Station_Pages__c ' +
                'WHERE RecordTypeId = \'' + recType.Id + '\' AND Private_Collection__c = false AND Tab_Name__c !=  \'' + userFavCollectionTabName +
                '\' AND (( Name LIKE ' + searchTerms + ' ) OR ( Owner.Name LIKE ' + searchTerms + '))';

                // JUST NAME
                /*
                '\' AND Name LIKE ' + searchTerms;
                */
            
                if ((sortType == null) || (sortType == 'Most Popular')) {
                    query = query + ' ORDER BY Followers__c DESC';
                } else if (sortType == 'Created Date') {
                    query = query + ' ORDER BY CreatedDate DESC';
                } else if (sortType == 'Alphabetical') {
                    query = query + ' ORDER BY Name';
                } else if (sortType == 'Last Updated') {
                    query = query + ' ORDER BY LastModifiedDate DESC';
                } else {
                    query = query + ' ORDER BY Followers__c DESC';
                }

                userCollections = Database.query(query);
                
                System.debug('>>>>>>>>>> searchPublicCollections : userCollections : ' + userCollections);            
                if (userCollections != null & userCollections.isEmpty()) {                    
                    userCollections = null;
                } 

                // THIS IS JUST TESTING
                /*                
                String query2 = 'SELECT Id, Name, Collection_Header_Background_Color__c, Associated_Content_Count__c, CreatedDate, Group_Subtitle__c, LastModifiedDate, LastViewedDate, Private_Collection__c, Tab_Name__c ' +
                'FROM Station_Pages__c ' +
                'WHERE RecordTypeId = \'' + recType.Id + '\' AND Private_Collection__c = false AND Tab_Name__c !=  \'' + userFavCollectionTabName + '\' AND (( Name LIKE ' + searchTerms + ' ) OR ( Owner.Name LIKE ' + searchTerms + '))' +
                ' ORDER BY Followers__c DESC';

                List<sObject> sobjList = Database.query(query2);
                System.debug('>>>>>>>>>> searchPublicCollections : sobjList : ' + sobjList);            
                System.debug('>>>>>>>>>> searchPublicCollections : query2 : ' + query2);            
                */
            }
        }
        System.debug('>>>>>>>>>> searchPublicCollections : userCollections RETURN : ' + userCollections);                    
        return userCollections;
    }
}