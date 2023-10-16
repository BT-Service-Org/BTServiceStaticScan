global class StationContentWrapper implements Comparable {
	@AuraEnabled public Station_Content__c content;
    @AuraEnabled public sObject contentPiece;
    @AuraEnabled public String previewIcon;
    @AuraEnabled public String fileType;
// RETIRE THIS ONCE FAV BUTTON IS SELF AWARE    
	@AuraEnabled public Boolean isFavoriteByRunningUser = false;
    
//    private static final String userFavCollectionName = 'My Favorites';
//    private static final String userFavCollectionTabName = 'FAVORITES';

    public StationContentWrapper(Station_Content__c c) {
        content = c;
//        String userFavCollectionRecordId = null;        
//        String userId = UserInfo.getUserId();
// MOVED FAVORITE LOGIC INTO BUTTON
/*        
        RecordType recType = [SELECT Id, Name from RecordType where sObjectType = 'Station_Pages__c' and Name = 'Collection' LIMIT 1];
        if (recType != null) {
            List<Station_Pages__c> userFavCollection = [SELECT Id, Name FROM Station_Pages__c 
            WHERE RecordTypeId =: recType.Id and OwnerId =: userId AND Name =: userFavCollectionName AND Tab_Name__c =: userFavCollectionTabName];            
            if (userFavCollection != null & userFavCollection.isEmpty()) {
                // User does not have a favorite collection
            } else {                
                userFavCollectionRecordId = userFavCollection[0].Id;
                List <StationGroupingAssociation__c> userFavs = [SELECT Id FROM StationGroupingAssociation__c 
                WHERE Station_Page__c =: userFavCollectionRecordId AND Station_Content__c =: c.id];
                if (userFavs != null & userFavs.isEmpty()) {
                    // User had not favorited this content
                    isFavoriteByRunningUser = false;
                } else {
                    isFavoriteByRunningUser = true;
                }                
            }
        }
*/
    }
    
    global Integer compareTo(Object compareTo) {
		StationContentWrapper compareToWrapper = (StationContentWrapper)compareTo;
        
        Integer retVal = 0;
        if (content.Order__c > compareToWrapper.content.Order__c) {
            retVal = 1;
        } else if (content.Order__c < compareToWrapper.content.Order__c) {
            retVal = -1;
        }
        return retVal;
    }
}