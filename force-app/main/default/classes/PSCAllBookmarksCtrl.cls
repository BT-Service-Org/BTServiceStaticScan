public with sharing class PSCAllBookmarksCtrl {
    @AuraEnabled
    public static ResultWrapper getPSCBookmarkedArticles(String name){       
        List<Knowledge__kav> articleList    = new List<Knowledge__kav> ();
        List<String> favKnowIdList          = new List<String>();
        
        FavWrapOuter desResBody             = new FavWrapOuter();
        ResultWrapper resultWrapperObj      = new ResultWrapper();
        List<TileDataWrapper> tileDataWrapperList = new List<TileDataWrapper>();
        String recTypes  = PSCSettingService.getValue('PSC_Knowledge_Record_Types'); 
        List<String> recTypeAllowedList     = new List<String>();
        recTypeAllowedList.addAll(recTypes.split(','));
        
        if(name=='My Bookmarks'){
            List<UserCompetencies__c> existingUserCmpList = [Select Id,User_Bookmark_Migrated__c
                                                                FROM UserCompetencies__c
                                                                WHERE User__c =: UserInfo.getUserId()
                                                                LIMIT 1];

            if(existingUserCmpList != null && !existingUserCmpList.isEmpty() && existingUserCmpList[0].User_Bookmark_Migrated__c){
                // all the logic is shifted to outside if else block
            }
            else{
                List<Bookmarks__c> bookmarksList = new List<Bookmarks__c>();
                String resBody = PSCFavoriteService.getFavourites();
                desResBody = (FavWrapOuter) JSON.deserialize(resBody,FavWrapOuter.class);
                for(FavWrapInner each:desResBody.favorites){
                    if(each.objectType == 'Knowledge__kav'){
                        favKnowIdList.add(each.target);
                        Bookmarks__c book = new Bookmarks__c();
                        book.Knowledge__c = each.target;
                        book.User__c = userinfo.getUserId();
                        book.Active__c = true;
                        book.Bookmark_Identifier__c = userinfo.getUserId() + '-' + book.Knowledge__c;
                        bookmarksList.add(book);
                    }
                }
                upsert bookmarksList Bookmark_Identifier__c;

                
                //check if User competency records exist, then update else create.
                if(existingUserCmpList != null && !existingUserCmpList.isEmpty() && !existingUserCmpList[0].User_Bookmark_Migrated__c){
                    existingUserCmpList[0].User_Bookmark_Migrated__c = true;
                    update existingUserCmpList;
                }
                else{
                    UserCompetencies__c uc = new UserCompetencies__c();
                    uc.User_Bookmark_Migrated__c = true;
                    uc.User__c = userinfo.getUserId();
                    insert uc;
                }
            }

            List<Bookmarks__c> bookmarksList = getBookmarksData();

            for(Bookmarks__c each:bookmarksList){
                TileDataWrapper obj = new TileDataWrapper();
                obj.fav = true;
                obj.favId = each.Id;
                if(each.Knowledge__c != null){
                    obj.title = each.Knowledge__r.Title;
                    obj.body = each.Knowledge__r.Summary;
                    obj.resourceType = each.Knowledge__r.Resource_Type__c;
                    obj.recordLastUpdateDate = each.Knowledge__r.lastPublishedDate;
                    obj.author = each.Knowledge__r.Owner.firstName +' '+ each.Knowledge__r.Owner.lastname;
                    obj.bookmarkType = 'Knowledge Article';
                    obj.knowledgeArticleId = each.Knowledge__r.KnowledgeArticleId;
                    obj.recId = each.Knowledge__c;
                    obj.navigationURL = each.Knowledge__r.Community_URL__c;
                    tileDataWrapperList.add(obj);
                } 
                else if(each.Reusable_Asset__c != null){
                    obj.title = each.Reusable_Asset__r.Title__c;
                    obj.body = each.Reusable_Asset__r.Description__c;
                    obj.resourceType = each.Reusable_Asset__r.Resource_Type__c;
                    obj.recordLastUpdateDate = each.Reusable_Asset__r.LastModifiedDate;
                    obj.author = each.Reusable_Asset__r.Owner.firstName +' '+ each.Reusable_Asset__r.Owner.lastname;
                    obj.bookmarkType = 'Reusable Asset';
                    obj.recId = each.Reusable_Asset__c;
                    obj.navigationURL = '/ServicesCentral/s/reusable-asset?recordId='+each.Reusable_Asset__c;
                    tileDataWrapperList.add(obj);
                } 
            }
        }
        else if(name=='All Recommendations'){
            Set<Id> userProjectProductSet = new Set<Id>();
            List<Contact> contactList = [SELECT Id
                                        FROM Contact
                                        WHERE User_Record__c =: UserInfo.getUserId()
                                        LIMIT 1];

            if(contactList != null && !contactList.isEmpty()){
                List<Project_by_Product_Offerings__c> projectProductList = [SELECT Id,Product__c
                                                                            FROM Project_by_Product_Offerings__c
                                                                            WHERE Project__c IN (SELECT PSA_Project__c
                                                                                                FROM Project_Assignment__c
                                                                                                WHERE Resource__c=:contactList[0].Id
                                                                                                AND End_Date__c >= TODAY)
                                                                            //WITH SECURITY_ENFORCED
                                                                            ];
                if(projectProductList != null && !projectProductList.isEmpty()){
                    for(Project_by_Product_Offerings__c each:projectProductList){
                        userProjectProductSet.add(each.Product__c);
                    }
                    articleList= [SELECT Id,Summary,Title,UrlName,Resource_Type__c,Owner.firstName,Owner.lastname,lastPublishedDate,KnowledgeArticleId,Community_URL__c,
                                        (SELECT Id
                                        FROM Bookmarks__r
                                        WHERE Active__c = TRUE
                                        AND Parent_Record_Active__c = TRUE
                                        AND User__c =: UserInfo.getUserId()) 
                                    FROM Knowledge__kav  
                                    WHERE PublishStatus='Online'
                                    AND ID IN (SELECT Knowledge__c
                                                FROM Article_Product__c
                                                WHERE Product__c IN:userProjectProductSet)
                                    AND RecordType.DeveloperName IN: recTypeAllowedList
                                    AND Include_in_Slack_Journey__c != null
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 50000
                                    ];

                    for(Knowledge__kav each:articleList){
                        TileDataWrapper obj = new TileDataWrapper();
                        if(each.Bookmarks__r.size()>0){
                            obj.fav = true;
                            obj.favId = each.Bookmarks__r[0].Id;
                        }
                        else{
                            obj.fav = false;
                            obj.favId = null;
                        }
                        obj.title = each.Title;
                        obj.body = each.Summary;
                        obj.resourceType = each.Resource_Type__c;
                        obj.recordLastUpdateDate = each.lastPublishedDate;
                        obj.author = each.Owner.firstName +' '+ each.Owner.lastname;
                        obj.bookmarkType = 'Knowledge Article';
                        obj.knowledgeArticleId = each.KnowledgeArticleId;
                        obj.recId = each.Id;
                        obj.navigationURL = each.Community_URL__c;
                        tileDataWrapperList.add(obj);
                    }
                }
            }
        }
        resultWrapperObj.tileData = tileDataWrapperList;
        return resultWrapperObj;
    }

    private static List<Bookmarks__c> getBookmarksData(){
        
        List<Bookmarks__c> bookmarksList = [SELECT Id,Knowledge__c,Knowledge__r.Summary,Knowledge__r.Title,Knowledge__r.Resource_Type__c,
                                            Knowledge__r.Owner.firstName,Knowledge__r.Owner.lastname,Knowledge__r.lastPublishedDate,
                                            Knowledge__r.KnowledgeArticleId,Reusable_Asset__c,Reusable_Asset__r.Description__c,
                                            Reusable_Asset__r.Title__c, Reusable_Asset__r.LastModifiedDate,Reusable_Asset__r.Resource_Type__c,
                                            Reusable_Asset__r.Owner.FirstName, Reusable_Asset__r.Owner.LastName, Knowledge__r.PublishStatus,
                                            Knowledge__r.RecordType.DeveloperName, Knowledge__r.Community_URL__c, Reusable_Asset__r.Status__c
                                            FROM Bookmarks__c
                                            WHERE Active__c = TRUE
                                            AND Parent_Record_Active__c = TRUE
                                            AND User__c = :UserInfo.getUserId()
                                            ORDER BY LastModifiedDate DESC];
        return bookmarksList;
    }

    public class ResultWrapper{
        @AuraEnabled
        public List<TileDataWrapper> tileData{get;set;}
    }

    public class TileDataWrapper{
        @AuraEnabled
        public String title{get;set;}
        @AuraEnabled
        public String body{get;set;}
        @AuraEnabled
        public String resourceType{get;set;}
        @AuraEnabled
        public String author{get;set;}
        @AuraEnabled
        public Datetime recordLastUpdateDate{get;set;}
        @AuraEnabled
        public String bookmarkType{get;set;}
        @AuraEnabled
        public String recId{get;set;}
        @AuraEnabled
        public String favId{get;set;}
        @AuraEnabled
        public Boolean fav{get;set;}
        @AuraEnabled
        public String knowledgeArticleId{get;set;}
        @AuraEnabled
        public String navigationURL{get;set;}
    }

    public class FavWrapOuter{
        @AuraEnabled
        public List<FavWrapInner> favorites{get;set;}
    }

    public class FavWrapInner{
        @AuraEnabled
        public String objectType{get;set;}
        @AuraEnabled
        public String target{get;set;}
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public Integer sortOrder{get;set;}
    }
}