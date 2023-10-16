public with sharing class PSCFavoriteCtrl {
    @AuraEnabled
    public static List<Bookmarks__c> getUserFavorite(String key){
        String userId = userinfo.getUserId();
        String query = 'SELECT Id,Knowledge__c FROM Bookmarks__c WHERE User__c =:userId  AND Parent_Record_Active__c = TRUE AND Active__c = true';
        if(Key != null){
            String objectApiName = getObjectApiName(Key);
            if(objectApiName == 'Knowledge__kav'){
                query += ' AND Knowledge__c=: key';
            }
            else if (objectApiName == 'Reusable_Asset__c') {
                query += ' AND Reusable_Asset__c=: key';
            }
        }
        query += ' ORDER BY LastModifiedDate DESC';
        List<Bookmarks__c> userBookmarks = Database.query(query);
        return userBookmarks;
    }

    @AuraEnabled
    public static Bookmarks__c createFavorite(String recId,String name){
        Bookmarks__c book = new Bookmarks__c();
        if(recId != null){
            String objectApiName = getObjectApiName(recId);
            if(objectApiName == 'Knowledge__kav'){
                book.Knowledge__c = recId;
            }
            else if (objectApiName == 'Reusable_Asset__c') {
                book.Reusable_Asset__c = recId;
            }
            book.Bookmark_Identifier__c = userinfo.getUserId() + '-' + recId;
        }
        book.User__c = userinfo.getUserId();
        book.Active__c = true;
        upsert book Bookmark_Identifier__c;
        return book;
    }

    @AuraEnabled
    public static Bookmarks__c deleteUserFavorite(String recId){
        Bookmarks__c book = new Bookmarks__c();
        book.Active__c = false;
        book.Bookmark_Identifier__c = userinfo.getUserId() + '-' + recId;
        upsert book Bookmark_Identifier__c;
        return book;
    }

    public static String getObjectApiName(String recId){
        Id keyId = (Id)recId;
        String objectApiName = keyId.getSObjectType().getDescribe().getName();
        return objectApiName;
    }
}