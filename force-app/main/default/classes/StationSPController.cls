public with sharing class StationSPController {



    @AuraEnabled(cacheable=true)
    public static List<StationContentWrapper> getGroups(String groupingList) {
        if (groupingList != null || !String.isEmpty(groupingList)) {
            List<String> idList = groupingList.split(',');
            // Fetch all contents for group
            List<StationGroupingAssociation__c> associations = [SELECT Station_Content__c, Station_Content__r.Id, Station_Content__r.Order__c, Order__c FROM StationGroupingAssociation__c WHERE Station_Page__r.Id IN :idList ORDER BY Order__c ASC NULLS FIRST];
            List<Id> associationIds = new List<Id>();
            for(StationGroupingAssociation__c a : associations) {
                associationIds.add(a.Station_Content__r.Id);
            }
            List<Station_Content__c> contentList = new List<Station_Content__c>(
                [SELECT Id, Name, CreatedDate, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, Sales_Region__c, Visibility__c, Partner_Type__c, Type_of_Application__c, LastModifiedDate, Upload_Image__c, OwnerId,Language__c,File_Type__c,Asset_Type_L1__c,Next_Review_Date__c, Additional_URL_Button_Title__c, Additional_URL_Link__c, Audience__c, Region__c, Market_Segment__c  FROM Station_Content__c WHERE Id IN :associationIds]);
            List<Station_Content__c> sorted = new List<Station_Content__c>();
            // ugly sorting by relationships Order__c
            for(Id a : associationIds) {
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
            
            return wrappedList;
            
        } else {
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<StationContentWrapper> getContentPieces(String contentJSON) {
        // unwrap and fetch content object
        List<StationContentWrapper> fromContent = (List<StationContentWrapper>)JSON.deserialize(contentJSON, List<StationContentWrapper>.class);
        for (StationContentWrapper w : fromContent) {
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
    public static Station_Pages__c getGroupName(String groupId) {
        Station_Pages__c grouping = [SELECT Id, Name, Group_Subtitle__c, Cloud_Product__c FROM Station_Pages__c WHERE Id = :groupId LIMIT 1];
        return grouping;
    }

    @AuraEnabled(cacheable=true)
    public static Station_Content__c getStationContentFields(String stcontentId) {
        Station_Content__c stcontent = [SELECT Id, Description__c, notif_Title__c,Page_Owner_1_Name__c,Page_Owner_1_Job_Title__c,Page_Owner_1_Page_Title__c,Page_Owner_2_Name__c,Page_Owner_2_Job_Title__c,Page_Owner_2_Page_Title__c,Page_Owner_3_Name__c,Page_Owner_3_Job_Title__c,Page_Owner_3_Page_Title__c,Page_Owner_4_Name__c,Page_Owner_4_Job_Title__c,Page_Owner_4_Page_Title__c,Org62_User__c,Org62_User2__c,Org62_User3__c,Org62_User4__c FROM Station_Content__c WHERE Id = :stcontentId LIMIT 1];
        return stcontent;
    }

    @AuraEnabled(cacheable=true)
    public static List<Station_Pages__c> getSCGroupNames(String ContentId) {
        List<StationGroupingAssociation__c> associationList = [SELECT Station_Page__r.Name,Station_Page__r.Id, Id FROM StationGroupingAssociation__c WHERE Station_Content__r.Id = :ContentId];
        if (associationList!=null) {
            List<Id> associationIds = new List<Id>();
            for(StationGroupingAssociation__c a : associationList) {
                associationIds.add(a.Station_Page__r.Id);
            }
            List<Station_Pages__c> groupList = new List<Station_Pages__c>([SELECT Id, Name, Cloud_Product__c  FROM Station_Pages__c WHERE Id IN :associationIds]);
        
            return groupList;
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static Case submitFeedbackCase(String reason, String descr) {
        //'Subject':'','Description':'','Origin':'Web','Status':'In Process'
// COMMENT OUT DUE TO NO LONGER IN USE - ASSESSMENT ON 06/23/2020 - ALSO REMOVING TEST CODE 
    /*
        Case newCase = new Case(Subject = reason, Description = descr, Origin = 'Web', Status = 'In Process');
        upsert newCase;
        return newCase;
    */        
    return null;
    }
    
    @AuraEnabled
    public static String imageForContentType(String type) {
        
        switch on type {
            when 'a' {
                return '/Icons/AstroAnswer@2x.png';
            }
            /*when 'EXCEL_X' {
            return '/TheStation_Icons/icons/excel.png';
            }
            when 'GOOGLE_DOCUMENT' {
            return '/TheStation_Icons/icons/googledocument.png';
            }
            when 'GOOGLE_PRESENTATION' {
            return '/TheStation_Icons/icons/googlepresentation.png';
            }
            when 'GOOGLE_SPREADSHEET' {
            return '/TheStation_Icons/icons/googlespreadsheet.png';
            }
            when 'JPG' {
            return '/TheStation_Icons/icons/jpgimage.png';
            }
            when 'JPEG' {
            return '/TheStation_Icons/icons/jpgimage.png';
            }*/
            when 'b' {
                return '/Icons/KnowledgeArticle@2x.png';
            }
            when 'LINK' {
                return '/Icons/LINK@2x.png';
            }
            when 'MOV' {
                return '/Icons/MOV@2x.png';
            }
            when 'MP3' {
                return '/Icons/MP3@2x.png';
            }
            when 'MP4' {
                return '/Icons/MP4@2x.png';
            }
            when 'PACK' {
                return '/Icons/PACK@2x.png';
            }
            /*when 'PDF' {
            return '/TheStation_Icons/icons/pdf.png';
            }
            when 'PNG' {
            return '/TheStation_Icons/icons/pngimage.png';
            }*/
                        /*when 'POWER_POINT_X' {
            return '/TheStation_Icons/icons/powerpoint.png';
            }*/
            when 'QUIPSHEET' {
                return '/Icons/QUIPSHEET@2x.png';
            }
            when 'QUIPDOC' {
                return '/Icons/QUIPDOC@2x.png';
            }
            /*when 'WORD_X' {
            return '/TheStation_Icons/icons/word.png';
            }*/
            when 'ZIP' {
                return '/Icons/ZIP@2x.png';
            }
            when else {
                return '';
            }
        }        
    }

    /* THIS METHOD CAN NOT BE TESTED AND WILL NOT HAVE CODE COVERAGE */
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
    
    public static Map<String, String> fileTypeMap = new Map<String, String> { 
            'a'=>'Astro', 
            'EXCEL_X' => 'Excel',
            'GOOGLE_DOCUMENT' => 'Google Document',
            'GOOGLE_PRESENTATION' => 'Google Presentation',
            'GOOGLE_SPREADSHEET' => 'Google Spreadsheet',
            'JPG' => 'JPG',
            'JPEG' => 'JPEG',
            'b' => 'Knowledge Article',
            'LINK' => 'Link',
            'MOV' => 'MOV',
            'MP3' => 'MP3',
            'MP4' => 'MP4',
            'PACK' => 'PACK',
            'PNG' => 'PNG',
            'POWER_POINT_X' => 'Power Point',
            'QUIPSHEET' => 'Quip Sheet',
            'QUIPDOC' => 'Quip Document',
            'ZIP' => 'Zip',
            'WORD_X' => 'Word'
            };
    
    @AuraEnabled
    public static String getLexOriginUrl() {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    }

    @AuraEnabled(cacheable=true)
    public static String getBaseUrl() {
        return URL.getSalesforceBaseURL().toExternalForm();
    }
    
    @AuraEnabled
    public static String getDomainOriginUrl() {
        String prefix = Url.getOrgDomainUrl().toExternalForm().replace('https://', '').split('\\.')[0];
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    }

    @AuraEnabled(cacheable=true)
    public static String getParamsValuesfromURl(String Url, String Param) {
        System.PageReference pageReference = new System.PageReference(Url);
        Map<String,String> parameters = pageReference.getParameters();
        return parameters.get(Param);
    }

    @AuraEnabled
    public static User getRunningUserInfo(){
        String userId = UserInfo.getUserId();
        User u = [SELECT Id, Name, Email, Title, Title__c, Department, Division, Business_Unit__c, BU__c, JobCode__c, JobFamily__c, JobProfile__c, Community__c, CSG_Role__c, Geo__c, LanguageLocaleKey FROM User WHERE Id = :userId];
        return u;
    }

    @AuraEnabled(cacheable=true)
    public static String getUserName(String userId){
        User u = [SELECT Id, Name, Email, Title FROM User WHERE Id = :userId];
        String IdName= u.Name;
        return IdName;
    }

    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody){
        User u = [SELECT Email, Name FROM User WHERE Id=:UserInfo.getUserId()];

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(mMail);

        mail.setToAddresses(sendTo);
        mail.setReplyTo(u.Email); 
        mail.setSenderDisplayName(u.Name); 
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
        
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
    
    @AuraEnabled public static String getAnalyticsTrackingId(){
          return 'UA-132432336-1';
      }

    @AuraEnabled(cacheable=true)
    public static List<Station_Content__c> getContentRecords(String OwnerRecordID) {
        if (OwnerRecordID != null || !String.isEmpty(OwnerRecordID)) {

            List<Station_Content__c> contentList = new List<Station_Content__c>(                
                [SELECT Id, Name, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, Owner.Name, Visibility__c, Next_Review_Date__c, Review_Status__c, LastModifiedDate, Upload_Image__c, Exclude_from_Sharing_Rule__c, OwnerId  FROM Station_Content__c WHERE OwnerId = :OwnerRecordID AND (RecordType.Name='URL' OR 
                RecordType.Name ='App Exchange' OR RecordType.Name='Standard Content' OR RecordType.Name='Success Program') ]);

            return contentList;            
        } else {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<StationContentWrapper> getContentBits(List<StationContentWrapper> scwInput) {
        for (StationContentWrapper w : scwInput) {
            String url = w.content.Content_URL__c;
            if (url != NULL) {
                url = url.replace('/view', '');
            }
            if (w.content.Content_Type__c == 'Content Version') {
                //https://org62.lightning.force.com/lightning/r/ContentDocument/0690M000006PS52QAG/view
                url = url.replace('https://org62.lightning.force.com/lightning/r/', '');
                url = url.replace('ContentDocument/', '');
                Org62_ContentVersion__x contentVersion;
                try {
                    contentVersion = [SELECT Id,ContentUrl__c,ContentDocumentId__c,Description__c,FileType__c,Title__c,Language_c__c,Next_Review_Date_c__c,ExternalId,Asset_Type_c__c,Visibility_c__c,ExternalDocumentInfo1__c,ExternalDocumentInfo2__c,OwnerId__c,OwnerId__r.Name__c    
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
                if (contentVersion != null) {
                    w.contentPiece = contentVersion;
                    w.previewIcon = StationSPController.imageForContentType(contentVersion.FileType__c);
                    if(StationSPController.fileTypeMap.get(contentVersion.FileType__c)!= null){
                        w.fileType = StationSPController.fileTypeMap.get(contentVersion.FileType__c);
                    }
                }
            } else if (w.content.Content_Type__c == 'Success Program') {
                ////https://org62.lightning.force.com/lightning/r/Success_Program__c/aCe0M0000008OShSAM/view
                url = url.replace('https://org62.lightning.force.com/lightning/r/', '');
                url = url.replace('Success_Program__c/', '');
                Success_Program_c__x sp;
                try {
                    // UPDATED QUERY TO ALSO FETCH EMAIL !                    
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
                if (sp != null) {
                    w.contentPiece = sp;                       
                }
            } else if (w.content.Content_Type__c == 'URL') {
                //System.debug(w.content.Description__c);
            } else if (w.content.Content_Type__c == 'App Exchange') {
                //System.debug(w.content.Description__c);
            }
        }
        return scwInput;          
    }
}