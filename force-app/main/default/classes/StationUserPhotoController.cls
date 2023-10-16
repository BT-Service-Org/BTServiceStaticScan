public class StationUserPhotoController {

    @AuraEnabled(cacheable=false)
    public static user fetchUserDetail(){
        return [Select id,Name,SmallPhotoUrl, FullPhotoUrl
                From User
                Where Id =: Userinfo.getUserId()];
    }

    @AuraEnabled()
    public static void updateUserPhoto(String docId){ if(!Test.isRunningTest())  ConnectApi.UserProfiles.setPhoto(null, Userinfo.getUserId(),docId, null) ;}
    
    @AuraEnabled()
    public static void deleteUserPhoto(){
        ConnectApi.UserProfiles.deletePhoto(null, Userinfo.getUserId());
    }
    @AuraEnabled()
    public static String getDocumentVersionId(String documentId){
        return [SELECT LatestPublishedVersionId
                    FROM ContentDocument
                    WHERE Id=:documentId].LatestPublishedVersionId;
    }
}