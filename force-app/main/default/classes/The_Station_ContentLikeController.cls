public with sharing class The_Station_ContentLikeController {
        
        // @AuraEnabled
        // public static User getRunningUserInfo(){
        //     String userId = UserInfo.getUserId();
        //     User u = [SELECT Id, Name, Email, Title, Title__c, Department, Division, Business_Unit__c, BU__c, JobCode__c, JobFamily__c, JobProfile__c, Community__c, CSG_Role__c, Geo__c, LanguageLocaleKey FROM User WHERE Id = :userId];
        //     return u;
        // }

        @AuraEnabled
        public static boolean isContentLikedByRunningUser(String stationContentRecordId) {
        boolean isLike = false;
        String userId = UserInfo.getUserId();
        String userLikeRecordId = null;
        
        List<Station_Like_Action__c> userLikedContent = [SELECT Id
                FROM Station_Like_Action__c 
                WHERE User__c =: userID AND Station_Content__c =: stationContentRecordId];
        if ( userLikedContent != null && !userLikedContent.isEmpty()  )
        {
            isLike = true;
        }
        return isLike;
    }
    @AuraEnabled
    public static boolean LikeContent(String stationContentRecordId) {
        boolean isLike = false;
        String runningUserId = UserInfo.getUserId();
        List<Station_Like_Action__c> likedcontent = [SELECT Id FROM Station_Like_Action__c WHERE User__c =: runningUserId AND Station_Content__c =: stationContentRecordId];
        if (likedcontent.isEmpty()) {
            Station_Like_Action__c likecontent = new Station_Like_Action__c();
            likecontent.User__c = UserInfo.getUserId();
            likecontent.Station_Content__c = stationContentRecordId;
            try {
                insert likecontent;
                isLike = true;    
            } catch (Exception e) {
                System.debug('*** Content like failed ' + e.getmessage());
            }    
        } else {
            try {
                delete likedcontent;
                isLike = false;    
            } catch (Exception e) {
                System.debug('*** Content unlike failed ' + e.getmessage());
            }    
        }
        return isLike;
    }

    @AuraEnabled
    public static Integer getLikeCount(String stationContentRecordId) {
        List<Station_Like_Action__c> likeCount = [SELECT Id FROM Station_Like_Action__c WHERE Station_Content__c =: stationContentRecordId];
        Integer count = 0;
        if (likeCount != null & likeCount.isEmpty()) {
            count = 0;
        } else {
            count = likeCount.size();
        }
        return count;
    } 

    
}