public with sharing class PSCArticlesContainerController {
    @AuraEnabled
    public static ResultWrapper getPSCArticles(String name,Integer maxNoOfResults){       
        List<Knowledge__kav> articleList    = new List<Knowledge__kav> ();
        List<String> favKnowIdList          = new List<String>();
        List<String> recTypeAllowedList     = new List<String>();
        FavWrapOuter desResBody             = new FavWrapOuter();
        ResultWrapper resultWrapperObj      = new ResultWrapper();
        List<TileDataWrapper> tileDataWrapperList = new List<TileDataWrapper>();
        String recTypes  = PSCSettingService.getValue('PSC_Knowledge_Record_Types'); 
        recTypeAllowedList.addAll(recTypes.split(','));
        Integer totalResultLimit = maxNoOfResults + 1;
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
                try{
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
                }   
                catch(Exception e){
                    System.debug(e);
                }

                
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
                    obj.bookmarkType = 'Knowledge Article';
                    obj.knowledgeArticleId = each.Knowledge__r.KnowledgeArticleId;
                    obj.recId = each.Knowledge__c;
                    obj.navigationURL = each.Knowledge__r.Community_URL__c;
                    tileDataWrapperList.add(obj);
                } 
                else if(each.Reusable_Asset__c != null){
                    obj.title = each.Reusable_Asset__r.Title__c;
                    obj.body = each.Reusable_Asset__r.Description__c;
                    obj.bookmarkType = 'Reusable Asset';
                    obj.recId = each.Reusable_Asset__c;
                    obj.navigationURL = '/ServicesCentral/s/reusable-asset?recordId='+each.Reusable_Asset__c;
                    tileDataWrapperList.add(obj);
                } 
            }
        }
        else if(name=='Recommendations'){
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
                    articleList= [SELECT Id,Summary,Title,UrlName,KnowledgeArticleId,Community_URL__c,
                                        (SELECT Id
                                        FROM Bookmarks__r
                                        WHERE Active__c = TRUE
                                        AND User__c =: UserInfo.getUserId()
                                        AND Parent_Record_Active__c = TRUE) 
                                    FROM Knowledge__kav  
                                    WHERE PublishStatus='Online'
                                    AND ID IN (SELECT Knowledge__c
                                                FROM Article_Product__c
                                                WHERE Product__c IN:userProjectProductSet)
                                    AND RecordType.DeveloperName IN: recTypeAllowedList
                                    AND Include_in_Slack_Journey__c != null
                                    WITH SECURITY_ENFORCED 
                                    LIMIT :totalResultLimit
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
                        obj.bookmarkType = 'Knowledge Article';
                        obj.knowledgeArticleId = each.KnowledgeArticleId;
                        obj.recId = each.Id;
                        obj.navigationURL = each.Community_URL__c;
                        tileDataWrapperList.add(obj);
                    }
                }
            }
        } 
        else if(name=='My Reusable Assets') {
            List<Reusable_Asset__c> raList = [SELECT Id,Title__c
                                              FROM Reusable_Asset__c 
                                              WHERE Status__c 
                                              IN ('Approved','Published') 
                                              AND OwnerId = :UserInfo.getUserId()
                                              ORDER BY LastModifiedDate DESC 
                                              LIMIT :totalResultLimit
                                            
                                            ];

            for(Reusable_Asset__c each:raList){
                TileDataWrapper obj = new TileDataWrapper();
                
                obj.title = each.Title__c;
                // obj.bookmarkType = 'Reusable Asset';
                obj.recId = each.Id;
                obj.navigationURL = '/ServicesCentral/s/reusable-asset?recordId='+each.Id;
                tileDataWrapperList.add(obj);
            }
        } 
        else{
            List<Reusable_Asset__c> raList = [SELECT Id,Description__c,Title__c, LastModifiedDate,Resource_Type__c,Owner.FirstName,Owner.LastName,
                                                (SELECT Id
                                                FROM Bookmarks__r
                                                WHERE Active__c = TRUE
                                                AND User__c =: UserInfo.getUserId()
                                                AND Parent_Record_Active__c = TRUE) 
                                            FROM Reusable_Asset__c 
                                            WHERE Status__c IN ('Approved','Published')
                                            ORDER BY LastModifiedDate DESC 
                                            LIMIT :totalResultLimit];

            for(Reusable_Asset__c each:raList){
                TileDataWrapper obj = new TileDataWrapper();
                if(each.Bookmarks__r.size()>0){
                    obj.fav = true;
                    obj.favId = each.Bookmarks__r[0].Id;
                }
                else{
                    obj.fav = false;
                    obj.favId = null;
                }
                obj.title = each.Title__c;
                obj.body = each.Description__c;
                obj.bookmarkType = 'Reusable Asset';
                obj.recId = each.Id;
                obj.navigationURL = '/ServicesCentral/s/reusable-asset?recordId='+each.Id;
                obj.recordLastUpdateDate = each.LastModifiedDate;
                tileDataWrapperList.add(obj);
            }

            articleList= [SELECT Id,Summary,Title,UrlName,KnowledgeArticleId,Community_URL__c,LastPublishedDate,
                            (SELECT Id
                            FROM Bookmarks__r
                            WHERE Active__c = TRUE
                            AND User__c =: UserInfo.getUserId()
                            AND Parent_Record_Active__c = TRUE) 
                        FROM Knowledge__kav  
                        WHERE PublishStatus='Online'
                        AND RecordType.DeveloperName IN: recTypeAllowedList
                        WITH SECURITY_ENFORCED 
                        ORDER BY LastPublishedDate DESC 
                        LIMIT :totalResultLimit];

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
                obj.bookmarkType = 'Knowledge Article';
                obj.knowledgeArticleId = each.KnowledgeArticleId;
                obj.recId = each.Id;
                obj.navigationURL = each.Community_URL__c;
                obj.recordLastUpdateDate = each.LastPublishedDate;
                tileDataWrapperList.add(obj);
            }
        }
        resultWrapperObj.tileData = tileDataWrapperList;
        return resultWrapperObj;
    }

    @AuraEnabled
    public static ResultWrapper getContainerData(String name,Integer maxNoOfResults, String key){ 
        List<Knowledge__kav> articleList            = new List<Knowledge__kav> ();
        ResultWrapper resultWrapperObj              = new ResultWrapper();
        List<TileDataWrapper> tileDataWrapperList   = new List<TileDataWrapper>();
        List<String> recTypeAllowedList             = new List<String>();
        String recTypes  = PSCSettingService.getValue('PSC_Knowledge_Record_Types'); 
        recTypeAllowedList.addAll(recTypes.split(','));
        Integer totalResultLimit = maxNoOfResults + 1;
        if(name=='My Knowledge Article') {
            articleList= [SELECT Id,Title,Body__c,Community_URL__c
                          FROM Knowledge__kav  
                          WHERE (PublishStatus='Online' AND OwnerId =: UserInfo.getUserId()
                          AND RecordType.DeveloperName IN: recTypeAllowedList)
                          WITH SECURITY_ENFORCED 
                          ORDER BY LastPublishedDate DESC 
                          LIMIT :totalResultLimit
            ];

            for(Knowledge__kav each:articleList){
                TileDataWrapper obj = new TileDataWrapper();
                
                obj.title = each.Title;
                // obj.bookmarkType = 'Knowledge Article';
                obj.recId = each.Id;
                obj.navigationURL = each.Community_URL__c;
                obj.body = each.Body__c;
                tileDataWrapperList.add(obj);
            }
        }
        else if(name=='My Answers') {
            List<Answer__c> ansList = new List<Answer__c>();
            if(key != null && key != ''){
                ansList = [SELECT Name, Response__c ,Response_By__c,Question__r.Title__c,Question__r.Body__c
                                       FROM Answer__c 
                                       WHERE  Question__r.Title__c !=null
                                       AND Response_By__c=: UserInfo.getUserId()
                                       AND Question__r.Community__r.URLName__c =: key
                                        LIMIT :maxNoOfResults];
            }
            else{
                ansList = [SELECT Name, Response__c ,Response_By__c,Question__r.Title__c,Question__r.Body__c
                                       FROM Answer__c 
                                       WHERE  Question__r.Title__c !=null
                                       AND Response_By__c=: UserInfo.getUserId()
                                        LIMIT :maxNoOfResults];
            }

            for(Answer__c each:ansList){
                TileDataWrapper obj = new TileDataWrapper();
                obj.title = each.Question__r.Title__c;
                obj.body = each.Question__r.Body__c;
                obj.recId = each.Id;
                tileDataWrapperList.add(obj);
            }
        }
        else if(name=='My Questions') {
            List<Question__c> quesList = new List<Question__c>();
            if(key != null && key != ''){
                quesList = [SELECT Name, Title__c, Body__c , Status__c,Slack_Link__c,Community__r.Page_Title__c,
                                            (SELECT Id, Response__c  FROM Answers__r LIMIT 1 )
                                          FROM Question__c
                                          WHERE Asked_By__c =: UserInfo.getUserId()
                                          AND Community__r.URLName__c =: key
                            			ORDER BY Createddate DESC
                                                    LIMIT :maxNoOfResults];
            }
            else{
                quesList = [SELECT Name, Title__c, Body__c , Status__c,Slack_Link__c,
                                            (SELECT Id, Response__c  FROM Answers__r LIMIT 1 )
                                          FROM Question__c
                                          WHERE Asked_By__c =: UserInfo.getUserId()
                            				ORDER BY Createddate DESC
                                          LIMIT :maxNoOfResults];
            }
            String userName = [SELECT Name FROM User WHERE Id=:UserInfo.getUserId()]?.Name;
            resultWrapperObj.additionaldata1 = PSCSettingService.getEnvSpecificValue('COP_Coveo_Source_Name');
            resultWrapperObj.additionaldata2 = userName;

            for(Question__c each:quesList){
                TileDataWrapper obj = new TileDataWrapper();
                obj.title = each.Title__c;
                obj.body = each.Body__c;
                obj.status = each.Status__c;
                obj.resourceType = each.Community__r.Page_Title__c;
                obj.navigationURL = each.Slack_Link__c;
                obj.recId = each.Id;
                tileDataWrapperList.add(obj);
            }
        } 
        else if(name=='Recent Questions') {
            List<Question__c> recentQuestions = new List<Question__c>();
            if(key != null && key != ''){
                recentQuestions = [SELECT Name, Title__c, Body__c, Slack_Link__c, Community__r.Page_Title__c
                                                FROM Question__c 
                                                WHERE Title__c != null
                                                AND Community__r.URLName__c =: key
                                                ORDER BY Ask_Date__c DESC
                                                LIMIT :maxNoOfResults];
            }
            else{ // not used currently
                recentQuestions = [SELECT Name, Title__c, Body__c , Community__r.Page_Title__c
                                                FROM Question__c 
                                                ORDER BY Ask_Date__c DESC
                                                LIMIT :maxNoOfResults];
            }
            resultWrapperObj.additionaldata1 = PSCSettingService.getEnvSpecificValue('COP_Coveo_Source_Name');
            for(Question__c each:recentQuestions){
                TileDataWrapper obj = new TileDataWrapper();
                obj.title = each.Title__c;
                obj.body = each.Body__c;
                obj.recId = each.Id;
                obj.navigationURL = each.Slack_Link__c;
                obj.resourceType = each.Community__r.Page_Title__c;
                tileDataWrapperList.add(obj);
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
        @AuraEnabled
        public String additionaldata1{get;set;}
        @AuraEnabled
        public String additionaldata2{get;set;}
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
        @AuraEnabled
        public String status{get;set;}
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
    }
}