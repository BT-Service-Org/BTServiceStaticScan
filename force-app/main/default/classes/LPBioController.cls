public with sharing class LPBioController {
    
    public String flashVars {get;set;}
    public String downloadurl {get;set;}
    public String name {get;set;}
    public String fileName {get;set;}
    public boolean isError {get;set;}
    public Integer size {get;set;}
    
    public String recid {get;set;}
    
    public PA_Onboarding__c record;
    
    public PageReference getFile(String id) {

        try {   
            //FeedItem[] f = [select Id,ContentFileName,RelatedRecordId,ContentType,ContentSize from FeedItem where Type='ContentPost' and ParentId=:id order by createddate desc];
            ContentDocumentLink link = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId=:Id order by SystemModStamp desc limit 1];
            System.debug('link ' + link.ContentDocumentId);
            ContentVersion f = [Select Id,Title, SystemModstamp, IsLatest, ContentUrl, ContentSize, ContentDocumentId From ContentVersion 
                        where ContentDocumentId=:link.ContentDocumentId and IsLatest=true limit 1];
            System.debug('f ver ' + f.Title);
            String docId = '';
            if (id == null || f == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Bio slide for '+ record.Candidate__r.Name + ' does not exist.'));
                isError = true;
                return null;            
            } else if (f.Title.contains('Bio')) {
                recid = f.Id;
                fileName = f.Title;
                size = f.ContentSize/1000;
                System.debug('recid ' + fileName + recid);
                flashVars = 'shepherd_prefix=/sfc/servlet.shepherd&v=' + recid  + '&mode=details';
                downloadurl = '/sfc/servlet.shepherd/version/download/'+ recid + '?asPdf=false&operationContext=CHATTER';
            } 
        } catch (Exception e) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error finding the Bio slide.'+e));
        }
        return null;
    }
        
    public LPBioController(ApexPages.StandardController controller) {
        record = [select Candidate__r.Name from PA_onboarding__c where Id=:controller.getId()]; 
        String id = ApexPages.currentPage().getParameters().get('id');
        getFile(id);
    }

}