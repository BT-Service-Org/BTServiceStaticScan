public with sharing class PSCDisplayRelatedFilesCtrl {
    @AuraEnabled(cacheable=true)
    public static List<FileWrapper> getContentDocumentIDs(String parentId){
        List<FileWrapper> fileWrapObjList = new List<FileWrapper>();
        Map<String,String> mapFileTypeToIcon = new Map<String,String>{
            'xlsx'=>'excel',
            'xls'=>'excel',
            'jpeg'=>'image',
            'jpg'=>'image',
            'png'=>'image',
            'gif'=>'image',
            'docx'=>'word',
            'doc'=>'word',
            'pptx'=>'ppt'
        };
        String host = Url.getOrgDomainUrl().toExternalForm();
        host = URL.getSalesforceBaseUrl().toExternalForm();

        List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId,ContentDocument.Title,ContentDocument.FileExtension
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId = :parentId
                                            WITH SECURITY_ENFORCED];
        
        for(ContentDocumentLink each:cdlList){
            FileWrapper eachFileWrapper = new FileWrapper();
            eachFileWrapper.fileName = each.ContentDocument.Title;
            eachFileWrapper.fileExt = each.ContentDocument.FileExtension;
            eachFileWrapper.fileURL = '/ServicesCentral/sfc/servlet.shepherd/document/download/' + each.contentDocumentId;
            //eachFileWrapper.fileURL = host+'/sfc/servlet.shepherd/version/download/'+each.ContentDocumentId;
            //eachFileWrapper.fileURL = URL.getSalesforceBaseUrl().toExternalForm()  + '/sfc/servlet.shepherd/document/download/' + each.ContentDocumentId + '?operationContext=S1';
            //eachFileWrapper.fileURL = '/sfsites/c/sfc/servlet.shepherd/document/download/'+each.ContentDocumentId;
            eachFileWrapper.fileIconName = (mapFileTypeToIcon.containsKey(each.ContentDocument.FileExtension)?mapFileTypeToIcon.get(each.ContentDocument.FileExtension):each.ContentDocument.FileExtension);
            fileWrapObjList.add(eachFileWrapper);
        }
        return fileWrapObjList;
    }

    public class FileWrapper{
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String fileURL;
        @AuraEnabled
        public String fileExt;
        @AuraEnabled
        public String fileIconName;
    }
}