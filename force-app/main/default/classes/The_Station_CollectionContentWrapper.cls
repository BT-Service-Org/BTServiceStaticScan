public with sharing class The_Station_CollectionContentWrapper {

    static final String CONTENTTYPE_APP_EXCHANGE = 'App Exchange';
    static final String CONTENTTYPE_CONTENT_VERSION = 'Content Version';
    static final String CONTENTTYPE_SUCCESS_PROGRAM = 'Success Program';
    static final String CONTENTTYPE_TRAILHEAD = 'Trailhead';
    static final String CONTENTTYPE_URL = 'URL';
    
    static final String PREVIEW_APP_EXCHANGE = '/sfsites/c/resource/The_Station_Icons/Icons/Appexchange@2x.png';
    static final String PREVIEW_TRAILHEAD = '/sfsites/c/resource/1561350737000/StationTrailheadImage?';
    static final String PREVIEW_UNKNOWN = '/sfsites/c/resource/The_Station_Icons/Icons/UNKNOWN@2x.png';
    static final String PREVIEW_ORG62_CV_PART1 = 'https://org62.my.salesforce.com/contenthub/renditiondownload?rendition_page_number=0&rendition_id=';
    static final String PREVIEW_ORG62_CV_PART2 = '%40THUMBNAIL_BIG&xds_id=0XC30000000KzGh';
    static final String PREVIEW_ORG62_CV_PREFIX = 'https://org62.my.salesforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=SVGZ&versionId=';
    
    @AuraEnabled public String contentTitle;
    @AuraEnabled public String contentDescription;
    @AuraEnabled public String contentType;
    @AuraEnabled public String contentURL;    
    @AuraEnabled public String contentImageURL;    
    @AuraEnabled public String contentImageURLRichText;
    @AuraEnabled public String contentDocumentId;
    @AuraEnabled public String previewIcon;
    @AuraEnabled public String fileType;

    @AuraEnabled public sObject contentPiece;
    
    // I question if the content record itself is even needed.
    @AuraEnabled public Station_Content__c content;

    public The_Station_CollectionContentWrapper(Station_Content__c c) {
        content = c;        
        contentTitle = c.Name;
        contentDescription = c.Description__c;
        contentType = c.Content_Type__c;
        contentURL = c.Content_URL__c;
        contentImageURLRichText = c.Upload_Image__c;
        contentDocumentId = null;

//        System.debug('The_Station_CollectionContentWrapper contentType : ' + contentType);        
//        System.debug('The_Station_CollectionContentWrapper contentURL : ' + contentURL);
//        System.debug('The_Station_CollectionContentWrapper contentDocumentId : ' + contentDocumentId);
        if (contentURL != NULL) {
            contentDocumentId = contentURL;
            contentDocumentId = contentDocumentId.replace('/view', '');
            contentDocumentId = contentDocumentId.replace('https://org62.lightning.force.com/lightning/r/', '');
            contentDocumentId = contentDocumentId.replace('ContentDocument/', '');
        }
//        System.debug('The_Station_CollectionContentWrapper contentDocumentId : ' + contentDocumentId);

        if (contentType.equals(CONTENTTYPE_APP_EXCHANGE)) {
            // IF CONTENT TYPE = APP EXCHANGE
//            System.debug('The_Station_CollectionContentWrapper APP EXCHANGE');
            contentImageURL = PREVIEW_APP_EXCHANGE;
        } else if (contentType.equals(CONTENTTYPE_CONTENT_VERSION)) {
            // IF CONTENT TYPE = CONTENT VERSION
//            System.debug('The_Station_CollectionContentWrapper CONTENT VERSION');            
            Org62_ContentVersion__x cv = getOrg62ContentVersion(contentURL);
            
            if(Test.isRunningTest()){
                cv = new Org62_ContentVersion__x();
            }

            if (cv != null) {

                String icon = StationSPController.imageForContentType(cv.FileType__c);
                String extId = cv.ExternalDocumentInfo2__c;
                String cvId = cv.ExternalId;

                if(Test.isRunningTest()){
                    // Test Examples
                    String fileType = 'POWER_POINT_X';
                    String extDoc2 = 'presentation:1GjeKRENv2xaXeTwBXwvry_02T2mUm-H4KMXHNJpAdvU';
                    String externId = '0680M000004K4VDQA0';

                    icon = StationSPController.imageForContentType(fileType);
                    cvId = externId;
                }

                if (extId != null) {
//                    System.debug('The_Station_CollectionContentWrapper CONTENT VERSION - extId ' + extId);                                
                    extId = extId.replace(':','%3A');
                    contentImageURL = PREVIEW_ORG62_CV_PART1 + extId + PREVIEW_ORG62_CV_PART2;
                } else if (cvId != null) {
//                    System.debug('The_Station_CollectionContentWrapper CONTENT VERSION - cvId ' + cvId);                                                    
                    contentImageURL = PREVIEW_ORG62_CV_PREFIX + cvId;        
                } else if (icon != null) {
//                    System.debug('The_Station_CollectionContentWrapper CONTENT VERSION - icon ' + icon);                                                    
                    contentImageURL = icon;
                } else {
//                    System.debug('The_Station_CollectionContentWrapper CONTENT VERSION - else ');
                    contentImageURL = PREVIEW_UNKNOWN;
                }
            }
        } else if (contentType.equals(CONTENTTYPE_SUCCESS_PROGRAM)) {
            // IF CONTENT TYPE = SUCCESS PROGRAM            
//            System.debug('The_Station_CollectionContentWrapper SUCCESS PROGRAM');            
            contentImageURL = PREVIEW_UNKNOWN;
        } else if (contentType.equals(CONTENTTYPE_TRAILHEAD)) {
            // IF CONTENT TYPE = TRAILHEAD
//            System.debug('The_Station_CollectionContentWrapper TRAILHEAD');            
            contentImageURL = PREVIEW_TRAILHEAD;
        } else if (contentType.equals(CONTENTTYPE_URL)) {
            // IF CONTENT TYPE = URL
//            System.debug('The_Station_CollectionContentWrapper URL');            
            contentImageURL = getIMGTagSRC(c.Upload_Image__c);
        }
//        System.debug('The_Station_CollectionContentWrapper contentImageURL : ' + contentImageURL);                
    }

    public static String getIMGTagSRC(String contentRichTextFieldSource) {
        String URL = null;
        String imgtag = '<img';
        String srctag = 'src=';
        String quote = '"';
        String amp = '&amp;';
        String tmp = null;

        Integer imgindx = 0;
        Integer srcindx = 0;
        Integer srcendindx = 0;
        if (contentRichTextFieldSource != null) {
            imgindx = contentRichTextFieldSource.indexOf(imgtag);
            srcindx = contentRichTextFieldSource.indexOf(srctag, imgindx);
            srcendindx = contentRichTextFieldSource.indexOf(quote, srcindx+5);
            tmp = contentRichTextFieldSource.substring(srcindx+5,srcendindx);
            URL = tmp.replace(amp, '&'); 
        }
        return URL;
    }

    private static Org62_ContentVersion__x getOrg62ContentVersion(String contentURL) {
        Org62_ContentVersion__x contentVersion;
        if (contentURL != NULL) {
            contentURL = contentURL.replace('/view', '');
            contentURL = contentURL.replace('https://org62.lightning.force.com/lightning/r/', '');
            contentURL = contentURL.replace('ContentDocument/', '');

            try {
                contentVersion = [SELECT Id,ContentUrl__c,ContentDocumentId__c,Description__c,FileType__c,Title__c,Language_c__c,Next_Review_Date_c__c,ExternalId,Asset_Type_c__c,LastModifiedDate__c,Visibility_c__c,ExternalDocumentInfo1__c,ExternalDocumentInfo2__c,OwnerId__c,OwnerId__r.Name__c    
                                    FROM 
                                    Org62_ContentVersion__x 
                                    WHERE 
                                    ContentDocumentId__c = :contentURL AND IsLatest__c = true LIMIT 1];
            } catch (Exception e) {
                System.debug('Content Version query exception: ' + e.getMessage());
            }            
        }
        return contentVersion;
    }   
}