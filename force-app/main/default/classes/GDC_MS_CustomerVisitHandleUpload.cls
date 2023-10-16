public without sharing class GDC_MS_CustomerVisitHandleUpload {

    @AuraEnabled                            
    public static void saveDocument(Id parentId, String fileName, String base64Data, String fieldName){
        try{

            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8'); // multiple
            
            // Creating a new document
            Document d= new Document();
            d.Body= EncodingUtil.base64Decode(base64Data);
            d.name= parentId + ' - ' + fileName;
            d.folderId= [SELECT Id, Name FROM Folder where Type = 'Document' and Name= 'GDC Microsite'].Id;
            d.IsPublic= true;
            insert d;
                        
            // generating the URL for the document uploaded
            // String URL= label.GDC_MS_BaseURL;
            String URL= URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost()+'/servlet/servlet.ImageServer?id=';
            URL += d.Id;
            URL += '&oid=' + UserInfo.getOrganizationId();
            
            if(fieldName == 'Customer Logo'){
                update (new gdc_ms_Customer_Visit__c(gdc_ms_Customer_Logo__c = URL, ID= parentId));  
            }
            else if(fieldName == 'Photo of Visitor'){
                update (new gdc_ms_Customer_Visit__c(gdc_ms_Photos_of_visitor__c = URL, ID= parentId));  
            }
            else {
                update (new gdc_ms_Customer_Visit__c(gdc_ms_SF_Partner_Photo__c = URL, ID= parentId));  
            }
        }
        catch(Exception e){
            Log.error('Error thrown from Apex Class: GDC_MS_HandleFileUpload.\nException Type: '+e.getTypeName()+'\nLine Number: '+e.getLineNumber()+'\nError Message: '+e.getMessage());
            throw new AuraHandledException('Oops! something went wrong. Kindly contact your Administrator.');
        }
    }

}