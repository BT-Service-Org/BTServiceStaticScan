@isTest
public class The_Station_ContentFavoriteTest {
    @isTest static void testFavorite() {

        String userFavCollectionName = 'My Favorites';
        String userFavCollectionSubTitle = ' - The Station Content Favorites';
        String userFavCollectionTabName = 'FAVORITES';

        Id recordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('URL').getRecordTypeId();
        Station_Content__c content = new Station_Content__c(Name='Test Content',
                                                    RecordTypeId = recordTypeId,
                                                    Content_Type__c = 'URL',
                                                    Content_URL__c = 'http://contenttesturl.com/testurl',
                                                    Order__c = 1);

        insert content;

        System.debug('Current UserName: ' + UserInfo.getUserName());        
        String runningUserId = UserInfo.getUserId();
        System.debug('Current UserId: ' + runningUserId);
        

        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {     
            System.debug('Record Type : ' + recType.Name);   
            List<Station_Pages__c> userFavCollection = [SELECT Id, Name FROM Station_Pages__c 
                                                        WHERE RecordTypeId =: recType.Id and OwnerId =: runningUserId 
                                                        AND Name =: userFavCollectionName and Tab_Name__c =: userFavCollectionTabName];

            System.debug('userFavCollection : ' + userFavCollection);                                                           
            if (userFavCollection != null & userFavCollection.isEmpty()) {
                System.debug('EMPTY COLLECTION - EXPECTED');
                System.assert(TRUE);
            } else {
                System.debug('NON-EMPTY COLLECTION - NOT EXPECTED');                
                System.assert(FALSE);
            }                                                            
        }
        
        List<StationContentWrapper> userFavs = The_Station_ContentFavoriteController.getUserFavorites();
        System.debug('userFavs : ' + userFavs);                                                           

        if (userFavs == null) {
            System.debug('EMPTY COLLECTION - EXPECTED');        
            System.assert(TRUE);
        } else {
            System.debug('NON-EMPTY COLLECTION - NOT EXPECTED');                            
            System.assert(FALSE);
        }                                                            

        userFavs = null;
        boolean favSuccess = false;
        System.debug('Create Favorite Collection');                
        favSuccess = The_Station_ContentFavoriteController.createStationCollectionFavorite(content.Id);
        System.debug('favSuccess : ' + favSuccess);                                                           

        userFavs = The_Station_ContentFavoriteController.getUserFavorites();
        if(userFavs == null) {
            System.debug('EMPTY COLLECTION - NOT EXPECTED');        
        }
        if (userFavs != null & userFavs.isEmpty()) {
            System.assert(FALSE);
        } else {
            System.assert(TRUE);
        }                             
    }
}