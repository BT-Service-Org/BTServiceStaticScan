public with sharing class PSCTemplateBestPracticeCtrl {
    @AuraEnabled(cacheable=true)
    public static List<TemplateWrapper> getTemplateData(String methodId){
        List<TemplateWrapper> templateWrapperList = new List<TemplateWrapper>();
        Map<String,String> mapFileTypeToIcon = new Map<String,String>{
            'xlsx'=>'excel',
            'xls'=>'excel',
            'jpeg'=>'image',
            'jpg'=>'image',
            'png'=>'image',
            'gif'=>'image',
            'docx'=>'word',
            'doc'=>'word',
            'Google Drive Link'=> 'gdoc',
            'PDF' => 'pdf',
            'Docx' => 'word',
            'Excel' => 'excel',
            'Other' => 'unknown'
        };

        List<Method__c> methodList = [SELECT Id,
                                        (SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension 
                                        FROM ContentDocumentLinks),
                                        (SELECT id, Link__c, Type__c, Name, Method_Version_Description__c, Resource_Name__c
                                        FROM Template__r 
                                        WHERE Link__c != NULL
                                        ORDER BY LastModifiedDate DESC),
                                        (SELECT Id, Knowledge__r.Title, Knowledge__r.Summary , Knowledge__r.Community_URL__c
                                        FROM Article_Methods__r 
                                        WHERE Knowledge__r.PublishStatus='Online')
                                    FROM Method__c 
                                    WHERE Id = :methodId
                                    AND Status__c = 'Published'
                                    ];

        for(Method__c each:methodList){
            
            for(ContentDocumentLink eachContent:each.ContentDocumentLinks){
                TemplateWrapper templateWrapper = new TemplateWrapper();
                templateWrapper.title = eachContent.ContentDocument.Title;
                templateWrapper.description = '';
                templateWrapper.linkName = eachContent.ContentDocument.FileExtension;
                templateWrapper.id = eachContent.Id;
                templateWrapper.linkURL = '/ServicesCentral/sfc/servlet.shepherd/document/download/' + eachContent.contentDocumentId;
                templateWrapper.linkLogo = (mapFileTypeToIcon.containsKey(eachContent.ContentDocument.FileExtension)?mapFileTypeToIcon.get(eachContent.ContentDocument.FileExtension):eachContent.ContentDocument.FileExtension);
                templateWrapperList.add(templateWrapper);
            }
            for(Templates__c eachTemp:each.Template__r){
                TemplateWrapper templateWrapper = new TemplateWrapper();
                templateWrapper.title = eachTemp.Resource_Name__c;
                templateWrapper.description = eachTemp.Method_Version_Description__c;
                templateWrapper.linkName = 'Template';
                templateWrapper.linkURL = eachTemp.Link__c;
                templateWrapper.id = eachTemp.Id;
                templateWrapper.linkLogo = (mapFileTypeToIcon.containsKey(eachTemp.Type__c)?mapFileTypeToIcon.get(eachTemp.Type__c):(eachTemp.Type__c!=null?eachTemp.Type__c:'unknown'));
                templateWrapperList.add(templateWrapper);
            }
            for(Article_Method__c eachArt:each.Article_Methods__r){
                TemplateWrapper templateWrapper = new TemplateWrapper();
                templateWrapper.title = eachArt.Knowledge__r.Title;
                templateWrapper.description = eachArt.Knowledge__r.Summary;
                templateWrapper.linkName = 'Knowledge Article';
                templateWrapper.linkURL = eachArt.Knowledge__r.Community_URL__c;
                templateWrapper.id = eachArt.Id;
                templateWrapper.linkLogo = 'article';
                templateWrapperList.add(templateWrapper);
            }
            
        }

        return templateWrapperList;
    }

    public class TemplateWrapper{
        @auraEnabled
        public String title{get;set;}
        @auraEnabled
        public String description{get;set;}
        @auraEnabled
        public String linkName{get;set;}
        @auraEnabled
        public String linkURL{get;set;}
        @auraEnabled
        public String linkLogo{get;set;}
        @auraEnabled
        public String id{get;set;}
    }
}