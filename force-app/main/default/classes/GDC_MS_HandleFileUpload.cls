public without sharing class GDC_MS_HandleFileUpload {
    @AuraEnabled                            
    public static void saveDocument(Id parentId, String fileName, String base64Data, String contentType){
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            
            // Creating a new document
            Document d= new Document();
            d.Body= EncodingUtil.base64Decode(base64Data);
            d.name= parentId + ' - ' + fileName;
            d.folderId= [SELECT Id, Name FROM Folder where Type = 'Document' and Name= 'GDC Microsite'].Id;
            d.IsPublic= true;
            insert d;
            
            // getting the key prefix for Team Member and Success Stories to compare with the parentId
            Schema.DescribeSObjectResult r = gdc_ms_Engagement__c.sObjectType.getDescribe();
            String keyPrefixForEngagement = r.getKeyPrefix();
            Schema.DescribeSObjectResult s = gdc_ms_TeamMember__c.sObjectType.getDescribe();
            String keyPrefixForTeamMember = s.getKeyPrefix();
            
            // generating the URL for the document uploaded
        // String URL= label.GDC_MS_BaseURL;
            String URL= URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost()+'/servlet/servlet.ImageServer?id=';
            URL += d.Id;
            URL += '&oid=' + UserInfo.getOrganizationId();
            
            // updating the URL in respective field of that object
            if(String.valueOf(parentId).startsWith(keyPrefixForTeamMember)){            
                update (new gdc_ms_TeamMember__c(gdc_ms_ProfilePhoto__c = URL, ID= parentId));   
            }else if(String.valueOf(parentId).startsWith(keyPrefixForEngagement)){
                update (new gdc_ms_Engagement__c(gdc_ms_CompanyLogo__c= URL, ID= parentId));
            }
        }
        catch(Exception e){
            Log.error('Error thrown from Apex Class: GDC_MS_HandleFileUpload.\nException Type: '+e.getTypeName()+'\nLine Number: '+e.getLineNumber()+'\nError Message: '+e.getMessage());
            throw new AuraHandledException('Oops! something went wrong. Kindly contact your Administrator.');
        }
    }
}