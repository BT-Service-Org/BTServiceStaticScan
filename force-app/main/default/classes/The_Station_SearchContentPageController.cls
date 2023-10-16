/*            
            Query 1 : select * from Station_Pages__c where Cloud_Product__c = 'CSG Career & Enablement' AND Content_Sub_Group_Name__c = 'Industries'

            Query 2 : select * from Station_Pages__c where Cloud_Product__c = 'CSG Career & Enablement'
            
            Community/Team (Community_Team__c) : Station website, CSG Enablement website, etc.
            Product/Offering (Cloud_Product__c): This should only be used if the Community/Team= The Station Hub
            Page (Content_Sub_Group_Name__c): Used if Community/Team ≠The Station Hub
            
            Query Type 1 : select Associated_Content_Count__c, Cloud_Product__c, Community_Team__c, Content_Sub_Group_Name__c, CreatedBy.Name, CreatedDate, Id, LastModifiedBy.Name, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, Owner.Name, Page_Section__c, Running_User_is_Record_Owner__c, Tab_Name__c 
            from Station_Pages__c 
            where Community_Team__c = 'The Station Hub' and Cloud_Product__c = 'Compass'

            Query Type 2 : select Associated_Content_Count__c, Cloud_Product__c, Community_Team__c, Content_Sub_Group_Name__c, CreatedBy.Name, CreatedDate, Id, LastModifiedBy.Name, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, Owner.Name, Page_Section__c, Running_User_is_Record_Owner__c, Tab_Name__c 
            from Station_Pages__c 
            where Community_Team__c = 'Success Managers' and Content_Sub_Group_Name__c = 'Home'

            select ID from Station_Pages__c where Community_Team__c = 'Success Managers' and Content_Sub_Group_Name__c = 'Home'

            select Station_Content__c from StationGroupingAssociation__c 
            where Station_Page__c in 
            (select ID from Station_Pages__c where Community_Team__c = 'Success Managers' and Content_Sub_Group_Name__c = 'Home') 
            AND Station_Content__r.Name like '%SM%'

            // EXAMPLE            
            select station_Content__r.name, station_page__r.name, station_page__r.Community_Team__c, station_page__r.Cloud_Product__c, station_page__r.Content_Sub_Group_Name__c from stationgroupingassociation__c where station_Content__c in (SELECT Id FROM Station_Content__c where name like '%cloud%')            
*/ 
public with sharing class The_Station_SearchContentPageController {
    static final String strTheStationHub = 'The Station Hub';
    
    public The_Station_SearchContentPageController() {

    }

    @AuraEnabled
    public static String getLexOriginUrl() {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    }

    @AuraEnabled
    public static User getRunningUserInfo(){
        String userId = UserInfo.getUserId();
        User u = [SELECT Id, Name, Email, Title, Title__c, Department, Division, Business_Unit__c, BU__c, JobCode__c, JobFamily__c, JobProfile__c, Community__c, CSG_Role__c, Geo__c, LanguageLocaleKey FROM User WHERE Id = :userId];
        return u;
    }

    public static StationContentWrapper getContentPieces(StationContentWrapper wrapped) {
        String url = null;
        if (wrapped != null) {
            if (wrapped.content != null) {
                url = wrapped.content.Content_URL__c;
                if (url != null) {
                    url = url.replace('/view', '');
                }
                if (wrapped.content.Content_Type__c == 'Content Version') {
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
                        contentVersion.OwnerId__c = StationSPController.getLocalUserIDForOrg62UserID(contentVersion.OwnerId__c);
                    } catch (Exception e) {
                        System.debug('Content Version Get Org62 User Exception caught: ' + e.getMessage());
                    }
                    if (contentVersion != null) {
                        wrapped.contentPiece = contentVersion;
                        wrapped.previewIcon = StationSPController.imageForContentType(contentVersion.FileType__c);
                        if(StationSPController.fileTypeMap.get(contentVersion.FileType__c)!= null){
                            wrapped.fileType = StationSPController.fileTypeMap.get(contentVersion.FileType__c);
                        }
                    }
                } else if (wrapped.content.Content_Type__c == 'Success Program') {
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
                        sp.OwnerId__c = StationSPController.getLocalUserIDForOrg62UserID(sp.OwnerId__c);                    
                    } catch (Exception e) {
                        System.debug('Success program Get Org62 User Exception caught: ' + e.getMessage());
                    }
                    if (sp != null) {
                        wrapped.contentPiece = sp;                       
                    }
                } else if (wrapped.content.Content_Type__c == 'URL') {
                    System.debug(wrapped.content.Description__c);
                } else if (wrapped.content.Content_Type__c == 'App Exchange') {
                    System.debug(wrapped.content.Description__c);
                }
            }
        }
        return wrapped;        
    }

    @AuraEnabled
    public static List<StationContentWrapper> searchContentInPage(String searchTerms, String sortType, String communityTeam, String cloudProduct, String stationPage) {
        List<StationContentWrapper> wrappedList = null;
        List<Station_Content__c> searchResults = null;
        List<StationGroupingAssociation__c> sgaContentIDs = null;
        String userId = UserInfo.getUserId();
        String query1 = null;
        String query2 = null;
        System.debug('>>>>>>>>>> searchContentInPage : ' + searchTerms + '|' + sortType + '|' + communityTeam + '|' + cloudProduct + '|' + stationPage );
        if ((searchTerms == null) || (searchTerms == '')) {
            System.debug('>>>>>>>>>> searchContentInPage : no term');            
            searchResults = null;
        } else {
                       
            searchTerms='\'%' + String.escapeSingleQuotes(searchTerms.trim()) + '%\'';

            System.debug('>>>>>>>>>> searchContentInPage : Search Terms : ' + searchTerms);

            if (communityTeam != null) {                

                query1 = 'SELECT Station_Content__c, Station_Page__c from StationGroupingAssociation__c ' +
                'WHERE Station_Page__c in ' +
                '(SELECT Id from Station_Pages__c where Community_Team__c = \'' + communityTeam + '\'';
    
                if (communityTeam.equalsIgnoreCase(strTheStationHub)) {
                    query1 = query1 + ' and Cloud_Product__c = \'' + cloudProduct + '\') AND Station_Content__r.Name like ' + searchTerms;
                } else {
                    query1 = query1 + ' and Content_Sub_Group_Name__c = \'' + stationPage + '\') AND Station_Content__r.Name like ' + searchTerms;
                }
            }            
            System.debug('>>>>>>>>>> searchContentInPage : query1 : ' + query1);

            sgaContentIDs = Database.query(query1);
            System.debug('>>>>>>>>>> QUERY 1 RUN');

            System.debug('>>>>>>>>>> searchContentInPage : sgaContentIDs : ' + sgaContentIDs);
            
            Set<String> contentRecords = new Set<String>();														
            for (StationGroupingAssociation__c sga : sgaContentIDs) {
                System.debug('>>>>>>>>>> searchContentInPage : sga : ' + sga.Station_Content__c);
                contentRecords.add(sga.Station_Content__c); 
            }            

            if (contentRecords != null & contentRecords.isEmpty()) {
                System.debug('>>>>>>>>>> searchContentInPage : contentRecords [empty]: ' + contentRecords);
            } else {
                System.debug('>>>>>>>>>> searchContentInPage : contentRecords : ' + contentRecords);

                query2 = 'SELECT Id, Name, Description__c, CreatedDate, LastModifiedDate, Subtitle__c, Next_Review_Date__c, Content_Type__c, Content_URL__c, Display_Image_URL__c FROM Station_Content__c WHERE Id in (';

                System.debug('>>>>>>>>>> searchContentInPage : query2 w/o ids : ' + query2);

                for (String contentId : contentRecords) {
                    query2 = query2 + '\''+contentId+'\',';                    
                }
                query2 = query2.left(query2.length()-1);
                query2 = query2 + ')'; 

                System.debug('>>>>>>>>>> searchContentInPage : query2 : ' + query2);
    
                if ((sortType == null) || (sortType == 'Alphabetical')) {
                    query2 = query2 + ' ORDER BY Name';
                } else if (sortType == 'Created Date') {
                    query2 = query2 + ' ORDER BY CreatedDate DESC';
                } else if (sortType == 'Last Updated') {
                    query2 = query2 + ' ORDER BY LastModifiedDate DESC';
                } else {
                    query2 = query2 + ' ORDER BY Name';
                }
                System.debug('>>>>>>>>>> searchContentInPage : query2 w/ sort : ' + query2);
    
                searchResults = Database.query(query2);
                System.debug('>>>>>>>>>> QUERY 2 RUN');
            }        
            System.debug('>>>>>>>>>> searchContentInPage : searchResults : ' + searchResults);

            // Wrap Results                                    
            if (searchResults != null) {
                wrappedList = new List<StationContentWrapper>();
                for(Station_Content__c content : searchResults) {
                    StationContentWrapper wrapped = new StationContentWrapper(content);

                    wrapped = getContentPieces(wrapped);

                    wrappedList.add(wrapped);
                }
                            
                if (wrappedList != null & wrappedList.isEmpty()) {                    
                    wrappedList = null;
                }                     
            }            
        }
        System.debug('>>>>>>>>>> searchContentInPage : wrappedList RETURN : ' + wrappedList);                    
        return wrappedList;
    }
}