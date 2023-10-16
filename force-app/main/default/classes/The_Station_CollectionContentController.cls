public with sharing class The_Station_CollectionContentController {

    @AuraEnabled(cacheable=true)
    public static List<The_Station_CollectionContentWrapper> getCollectionContentRecordsWithSearch(String searchTerms, String recordId, String sortType, Integer ofst) {
        String query = null;
        if (recordId != null || !String.isEmpty(recordId)) {
            List<StationGroupingAssociation__c> associationList = [SELECT Station_Content__c, Station_Content__r.Id, Station_Content__r.Order__c, Order__c FROM StationGroupingAssociation__c WHERE Station_Page__r.Id = :recordId];
            
            if (associationList!=null) {
                String strIDs = '';
                for(StationGroupingAssociation__c a : associationList) {
                    strIDs = strIDs + '\'' + a.Station_Content__r.Id + '\',';
                }
                searchTerms='\'%' + String.escapeSingleQuotes(searchTerms.trim()) + '%\'';                
                strIDs = strIDs.left(strIDs.length()-1);
                
                List<Station_Content__c> groupList = new List<Station_Content__c>();

                query = 'SELECT Id, Name, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, Sales_Region__c, Visibility__c, Partner_Type__c, Type_of_Application__c, LastModifiedDate, Upload_Image__c, OwnerId, Owner.Name, CreatedDate, Next_Review_Date__c, File_Type__c, Audience__c, Region__c, Market_Segment__c,Language__c,Unapproved_Content__c ' +
                'FROM Station_Content__c WHERE Id IN (' + strIDs +
                ') AND (( Name LIKE '+searchTerms+' ) OR (Primary_Contact__r.Name LIKE '+searchTerms+') OR (Owner.Name LIKE ' + searchTerms + '))';
                
                if (sortType == 'Created Date') {
                    query = query + ' ORDER BY CreatedDate DESC';
                } else if (sortType == 'Alphabetical') {
                    query = query + ' ORDER BY Name';
                } else if (sortType == 'Last Updated') {
                    query = query + ' ORDER BY LastModifiedDate DESC';
                } else {
                    query = query + ' ORDER BY Name';
                }
                query = query + ' LIMIT 12 OFFSET '+ofst;
                             
                groupList = Database.query(query);
                
                List<The_Station_CollectionContentWrapper> wrappedList = new List<The_Station_CollectionContentWrapper>();

                           
                if (groupList != null & groupList.isEmpty()) {                    
                    groupList = null;
                    wrappedList = null;
                } else {                    
                    for(Station_Content__c content : groupList) {
                        The_Station_CollectionContentWrapper wrapped = new The_Station_CollectionContentWrapper(content);
                        wrappedList.add(wrapped);
                    }
                }
                return wrappedList;
            } else {
                return null;
            }
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<The_Station_CollectionContentWrapper> getCollectionContentRecords(String recordId, String sortType, Integer ofst) {
        if (recordId != null || !String.isEmpty(recordId)) {
            // Fetch all contents for group
            
            List<StationGroupingAssociation__c> associationList = [SELECT Station_Content__c, Station_Content__r.Id, Station_Content__r.Order__c, Order__c FROM StationGroupingAssociation__c WHERE Station_Page__r.Id = :recordId];
            if (associationList!=null) {
                List<Id> associationIds = new List<Id>();
                for(StationGroupingAssociation__c a : associationList) {
                    associationIds.add(a.Station_Content__r.Id);
                }
    
                List<Station_Content__c> groupList = new List<Station_Content__c>();
                if (sortType.equals('Last Updated')){

                    groupList = [SELECT Id, Name, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, Sales_Region__c, Visibility__c, Partner_Type__c, Type_of_Application__c, LastModifiedDate, Upload_Image__c, OwnerId, CreatedDate, Next_Review_Date__c, File_Type__c, Audience__c, Region__c, Market_Segment__c,Language__c, Unapproved_Content__c FROM Station_Content__c WHERE Id IN :associationIds ORDER BY LastModifiedDate DESC LIMIT 12 OFFSET :ofst];
                }
                else if (sortType.equals('Created Date')){
                     groupList = [SELECT Id, Name, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, Sales_Region__c, Visibility__c, Partner_Type__c, Type_of_Application__c, LastModifiedDate, Upload_Image__c, OwnerId, CreatedDate, Next_Review_Date__c, File_Type__c, Audience__c, Region__c, Market_Segment__c,Language__c, Unapproved_Content__c FROM Station_Content__c WHERE Id IN :associationIds ORDER BY CreatedDate DESC LIMIT 12 OFFSET :ofst];
                }
                else if(sortType.equals('Alphabetical')){
                    groupList = [SELECT Id, Name, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, Sales_Region__c, Visibility__c, Partner_Type__c, Type_of_Application__c, LastModifiedDate, Upload_Image__c, OwnerId, CreatedDate, Next_Review_Date__c, File_Type__c, Audience__c, Region__c, Market_Segment__c,Language__c, Unapproved_Content__c FROM Station_Content__c WHERE Id IN :associationIds ORDER BY Name ASC LIMIT 12 OFFSET :ofst];
                }
                List<The_Station_CollectionContentWrapper> wrappedList = new List<The_Station_CollectionContentWrapper>();
                for(Station_Content__c content : groupList) {
                    The_Station_CollectionContentWrapper wrapped = new The_Station_CollectionContentWrapper(content);
                    wrappedList.add(wrapped);
                }
               
                return wrappedList;
                
            }
            else {
                return null;
            }
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalItems(String recordId){	
        String query = null;
        Integer total = 0;
        if (recordId != null || !String.isEmpty(recordId)) {
            
            List<StationGroupingAssociation__c> associationList = [SELECT Station_Content__c, Station_Content__r.Id FROM StationGroupingAssociation__c WHERE Station_Page__r.Id = :recordId];
            
            if (associationList!=null) {
                String strIDs = '';
                for(StationGroupingAssociation__c a : associationList) {
                    strIDs = strIDs + '\'' + a.Station_Content__r.Id + '\',';
                }             
                strIDs = strIDs.left(strIDs.length()-1);
                
                List<Station_Content__c> groupList = new List<Station_Content__c>();

                query = 'SELECT Id ' +
                'FROM Station_Content__c WHERE Id IN (' + strIDs +
                ')';
              
                groupList = Database.query(query);
               
                total = groupList.size();
                
                return total;

            }
            return null;
        }
        return null;
    }


    @AuraEnabled(cacheable=true)
    public static List<The_Station_CollectionContentWrapper> getContentPieces(String contentJSON) {
        // unwrap and fetch content object
        List<The_Station_CollectionContentWrapper> fromContent = (List<The_Station_CollectionContentWrapper>)JSON.deserialize(contentJSON, List<The_Station_CollectionContentWrapper>.class);

        

        for (The_Station_CollectionContentWrapper w : fromContent) {
                     
            String url = w.content.Content_URL__c;
            if (url != NULL) {
                url = url.replace('/view', '');
            }
                                              
            if (w.content.Content_Type__c == 'Content Version') {
                url = url.replace('https://org62.lightning.force.com/lightning/r/', '');
                url = url.replace('ContentDocument/', '');
                Org62_ContentVersion__x contentVersion;
               

                try {
                    contentVersion = [SELECT Id,ContentUrl__c,ContentDocumentId__c,Description__c,FileType__c,Title__c,Language_c__c,Next_Review_Date_c__c,ExternalId,Asset_Type_c__c,LastModifiedDate__c,Visibility_c__c,ExternalDocumentInfo1__c,ExternalDocumentInfo2__c,OwnerId__c,OwnerId__r.Name__c,OwnerId__r.Email__c    
                                                              FROM 
                                                              Org62_ContentVersion__x 
                                                              WHERE 
                                                              ContentDocumentId__c = :url AND IsLatest__c = true LIMIT 1];
                } catch (Exception e) {
                    System.debug('Content Version query exception: ' + e.getMessage());
                }
                try {
                    contentVersion.OwnerId__c = getLocalUserIDForOrg62UserID(contentVersion.OwnerId__c);
                } catch (Exception e) {
                    System.debug('Content Version Get Org62 User Exception caught: ' + e.getMessage());
                }
                System.debug('contentVersion : ' + contentVersion);
                if (contentVersion != null) {
                    w.contentPiece = contentVersion;
                    w.previewIcon = StationSPController.imageForContentType(contentVersion.FileType__c);
                    if(StationSPController.fileTypeMap.get(contentVersion.FileType__c)!= null){
                        w.fileType = StationSPController.fileTypeMap.get(contentVersion.FileType__c);
                    }
                }
            } else if (w.content.Content_Type__c == 'Success Program') {
                url = url.replace('https://org62.lightning.force.com/lightning/r/', '');
                url = url.replace('Success_Program__c/', '');
                Success_Program_c__x sp;
             
                try {                 
                    sp = [SELECT Id,Content_Location_c__c,CreatedById__c,Delivery_Method_c__c,Description_c__c,Estimated_Delivery_Hours_c__c,Estimated_Internal_Hours_c__c,ExternalId,Long_Description_c__c,Name__c,Certification_Activity_Instructions_c__c,Validation_Date_c__c,Website_Datasheet_URL_c__c,OwnerId__c,OwnerId__r.Name__c,OwnerId__r.Email__c
                          FROM 
                          Success_Program_c__x 
                          WHERE 
                          ExternalId = :url LIMIT 1];
                } catch (Exception e) {
                    System.debug('Success Program exception: ' + e.getMessage());
                }
                try {
                    sp.OwnerId__c = getLocalUserIDForOrg62UserID(sp.OwnerId__c);                    
                } catch (Exception e) {
                    System.debug('Success program Get Org62 User Exception caught: ' + e.getMessage());
                }
                System.debug('sp : ' + sp);
                if (sp != null) {
                    w.contentPiece = sp;                       
                }
            } 
            //else if (w.content.Content_Type__c == 'Trailhead') {
            //System.debug('Trailhead record');
            //    url = url.replace('https://sfservices--bedrockuat.lightning.force.com/lightning/r/', '');
            //    url = url.replace('Station_Trailhead__c/', '');
            //System.debug(url);
            //    try {
            //        Station_Trailhead__c th = [SELECT Id,Module_Time__c,Name,Trailhead_Description__c,Trailhead_Type__c,Trailhead_URL__C
            //                                   FROM 
            //                                   Station_Trailhead__c 
            //                                   WHERE 
            //                                   Id = :url LIMIT 1];
            //        if (th != null) {
            //            w.contentPiece = th;
            //        }
            //    } catch (Exception e) {
            //        System.debug('Exception caught: ' + e.getMessage());
            //    }
            //} 
            else if (w.content.Content_Type__c == 'URL') {
                //System.debug(w.content.Description__c);
            } else if (w.content.Content_Type__c == 'App Exchange') {
                //System.debug(w.content.Description__c);
            }
        }

        return fromContent;
        
    }

    @AuraEnabled(cacheable=true)
    public static Integer getCollectionNumber(String recordId) {
        if (recordId != null || !String.isEmpty(recordId)) {
            // Fetch all contents for group
            List<StationGroupingAssociation__c> associationList = [SELECT Id, Station_Page__c, Station_Page__r.Id  FROM StationGroupingAssociation__c WHERE Station_Content__r.Id = :recordId];
            if (associationList!=null) {
                List<Id> associationIds = new List<Id>();
                for(StationGroupingAssociation__c a : associationList) {
                    associationIds.add(a.Station_Page__r.Id);
                }
                List<Station_Pages__c> groupList = new List<Station_Pages__c>([SELECT Id, Name  FROM Station_Pages__c WHERE Id IN :associationIds AND RecordType.Name='Collection']);
             
                return groupList.size();
            }
            return null; 
        }
            return null;  
        }

    @AuraEnabled(cacheable=true)
    public static String getUserName(String userId){
        User u = [SELECT Id, Name, Email, Title FROM User WHERE Id = :userId];
        String IdName= u.Name;
        return IdName;
    }

    @AuraEnabled
    public static User getRunningUserInfo(){
        String userId = UserInfo.getUserId();
        User u = [SELECT Id, Name, Email, Title, Title__c, Department, Division, Business_Unit__c, BU__c, JobCode__c, JobFamily__c, JobProfile__c, Community__c, CSG_Role__c, Geo__c, LanguageLocaleKey FROM User WHERE Id = :userId];
        return u;
    }

    @AuraEnabled
    public static String getLexOriginUrl() {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    }

    @AuraEnabled(cacheable=true)
    public static The_Station_CollectionContentWrapper getContentRecord(String recordId) {
        if (recordId != null || !String.isEmpty(recordId)) {
            // Fetch all contents for group

                List<Station_Content__c> groupList = new List<Station_Content__c>();

                    groupList = [SELECT Id, Name, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, Sales_Region__c, Visibility__c, Partner_Type__c, Type_of_Application__c, LastModifiedDate, Upload_Image__c, OwnerId, CreatedDate, Next_Review_Date__c, File_Type__c, Audience__c, Region__c, Market_Segment__c,Language__c,Unapproved_Content__c FROM Station_Content__c WHERE Id =: recordId];
                
                List<The_Station_CollectionContentWrapper> wrappedList = new List<The_Station_CollectionContentWrapper>();
                for(Station_Content__c content : groupList) {
                    The_Station_CollectionContentWrapper wrapped = new The_Station_CollectionContentWrapper(content);
                    wrappedList.add(wrapped);
                }
                return wrappedList[0];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static String getLocalUserIDForOrg62UserID(String Org62UserID) {
        String localUserID = null;
        try { 
            List<Org62_User__x> org62User = [SELECT FederationIdentifier__c FROM Org62_User__x WHERE ExternalId =: Org62UserID LIMIT 1];
            if(org62User != null & !(org62User.isEmpty())) {
                List<User> localUser = [SELECT Id from User WHERE isActive = TRUE AND FederationIdentifier =: org62User[0].FederationIdentifier__c LIMIT 1];
                if(localUser != null & !(localUser.isEmpty())) {
                    localUserID = localUser[0].Id;
                } else {
                    System.debug('*** LOCAL USER NOT FOUND FOR FederationIdentifier : ' + org62User[0].FederationIdentifier__c);
                }
            } else {
                System.debug('*** ORG62 USER NOT FOUND FOR Org62UserID : ' + Org62UserID);
                User u = [SELECT Id FROM User WHERE name = 'David Mierke' AND alias = 'DMier' LIMIT 1];
                if (u == null) {
                    System.debug('*** MAJOR ISSUE - COULD NOT EVEN FIND DAVID MIERKE');
                } else {
                    localUserID = u.Id;
                }
            }
        } catch (Exception e) {
            System.debug('*** getLocalUserIDForOrg62UserID - ERROR : ' + e.getMessage());
        }
        return localUserID;
    }


}