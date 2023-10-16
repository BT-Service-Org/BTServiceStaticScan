public with sharing class The_Station_ContentFavoriteController {

    private static final String userFavCollectionName = 'My Favorites';
    private static final String userFavCollectionSubTitle = ' - The Station Content Favorites';
    private static final String userFavCollectionTabName = 'FAVORITES';

    // NO LONGER NEEDED - BUT The_Station_UserProfileFavorites.cmp uses this to get Running User to pass into StationContentPiece component...
    @AuraEnabled
    public static User getRunningUserInfo(){
        String userId = UserInfo.getUserId();
        User u = [SELECT Id, Name, Email, Title, Title__c, Department, Division, Business_Unit__c, BU__c, JobCode__c, JobFamily__c, JobProfile__c, Community__c, CSG_Role__c, Geo__c, LanguageLocaleKey FROM User WHERE Id = :userId];
        return u;
    }

    @AuraEnabled
    public static boolean isContentFavoriteByRunningUser(String stationContentRecordId) {
        boolean isFavorite = false;
        String userId = UserInfo.getUserId();
        String userFavCollectionRecordId = null;
        
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            List<Station_Pages__c> userFavCollection = [SELECT Id, Name FROM Station_Pages__c WHERE RecordTypeId =: recType.Id 
                                                        AND OwnerId =: userId AND Name =: userFavCollectionName 
                                                        AND Tab_Name__c =: userFavCollectionTabName];
            if(userFavCollection != null & userFavCollection.isEmpty()) {
                // NO FAVORITE COLLECTION SO NO FAVORITE
            } else {
                userFavCollectionRecordId = userFavCollection[0].Id;
                List <StationGroupingAssociation__c> userFavs = [SELECT Id FROM StationGroupingAssociation__c 
                WHERE Station_Page__c =: userFavCollectionRecordId AND Station_Content__c =: stationContentRecordId];
                if (userFavs != null & userFavs.isEmpty()) {
                    // CONTENT NOT IN FAVORITE COLLECTION
                } else {
                    // CONTENT FOUND IN FAVORITE COLLECTION
                    isFavorite = true;
                }
            }
        }
        return isFavorite;        
    }

    @AuraEnabled
    public static boolean createStationCollectionFavorite(String stationContentRecordId){
        boolean fav = false;
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getName();
        String userFavCollectionRecordId = null;

        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            // Create My Favorites Collection or Get Existing My Favorite Collection
            List<Station_Pages__c> userFavCollection = [SELECT Id, Name FROM Station_Pages__c 
            WHERE RecordTypeId =: recType.Id and OwnerId =: userId and Name =: userFavCollectionName and Tab_Name__c =: userFavCollectionTabName];            
            if (userFavCollection != null & userFavCollection.isEmpty()) {
                Station_Pages__c myFavCollection = new Station_Pages__c();
                myFavCollection.Name = userFavCollectionName;
                myFavCollection.RecordTypeId = recType.Id;
                myFavCollection.Group_Subtitle__c = userName + userFavCollectionSubTitle;
                myFavCollection.Tab_Name__c = userFavCollectionTabName;
                insert myFavCollection;
                userFavCollectionRecordId = myFavCollection.Id;
            } else {                
                userFavCollectionRecordId = userFavCollection[0].Id;
            }
            // Add New Content to My Favorites Collection or Delete Existing Content from My Favorites Collection
            List <StationGroupingAssociation__c> userFavs = [SELECT Id FROM StationGroupingAssociation__c 
            WHERE Station_Page__c =: userFavCollectionRecordId AND Station_Content__c =: stationContentRecordId];
            if (userFavs != null & userFavs.isEmpty()) {
                StationGroupingAssociation__c collectionContentAssociation = new StationGroupingAssociation__c();
                collectionContentAssociation.Station_Page__c = userFavCollectionRecordId;
                collectionContentAssociation.Station_Content__c	= stationContentRecordId;
                insert collectionContentAssociation;
                fav = true;
            } else {
                delete userFavs;
                fav = false;
            }
        }
        return fav;
    }
        
    @AuraEnabled(cacheable=true)
    public static List<StationContentWrapper> getUserFavorites() {
        List<StationContentWrapper> scwWithContent = null;
        String userFavCollectionRecordId = null;  
        String userId = UserInfo.getUserId();
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            List<Station_Pages__c> userFavCollection = [SELECT Id, Name FROM Station_Pages__c 
            WHERE RecordTypeId =: recType.Id and OwnerId =: userId AND Name =: userFavCollectionName AND Tab_Name__c =: userFavCollectionTabName];            
            if (userFavCollection != null & userFavCollection.isEmpty()) {
                // User does not have a favorite collection
            } else {                
                userFavCollectionRecordId = userFavCollection[0].Id;
                List <StationGroupingAssociation__c> userFavs = [SELECT Station_Content__c FROM StationGroupingAssociation__c 
                WHERE Station_Page__c =: userFavCollectionRecordId];
                if (userFavs != null & userFavs.isEmpty()) {
                    // User had not favorited this content
                } else {
                    List<Id> favoriteContentIds = new List<Id>();
                    for(StationGroupingAssociation__c a : userFavs) {
                        favoriteContentIds.add(a.Station_Content__c);
                    } 
                    List<Station_Content__c> contentList = new List<Station_Content__c>(
                        [SELECT Id, Name, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, Sales_Region__c, Visibility__c, Partner_Type__c, Type_of_Application__c, LastModifiedDate, Upload_Image__c, OwnerId 
                        FROM Station_Content__c WHERE Id IN :favoriteContentIds]);
                
                    List<Station_Content__c> sorted = new List<Station_Content__c>();
                    for(Id a : favoriteContentIds) {
                        for(Station_Content__c c : contentList) {
                            if (c.Id == a) {
                                sorted.add(c);
                            }
                        }
                    }              
                    // wrap
                    List<StationContentWrapper> wrappedList = new List<StationContentWrapper>();
                    for(Station_Content__c content : sorted) {
                        StationContentWrapper wrapped = new StationContentWrapper(content);
                        wrappedList.add(wrapped);
                    }  
                    // Call GetContentBits to load in Success Program and Content Version additional data attributes.
                    scwWithContent = StationSPController.getContentBits(wrappedList);                                  
                }                
            }
        }
        return scwWithContent;         
    }
}