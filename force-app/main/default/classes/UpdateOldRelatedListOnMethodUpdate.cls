public with sharing class UpdateOldRelatedListOnMethodUpdate {
    public UpdateOldRelatedListOnMethodUpdate() {}
    @InvocableMethod(label='Update Related Lists' description='Create or Delete(Deliverable, Artefacts, Files) of a method during Update Method based on Status')
    public static void executeUpdate(List<RelatedListsRequest> request) {
        String methodRecordId = request.get(0).methodRecordId;
        String deleteDeliverables = request.get(0).deleteDeliverables;
        String defaultDeliverables = request.get(0).defaultDeliverables;
        String deleteFiles = request.get(0).deleteFiles;
        String defaultFiles = request.get(0).defaultFiles;
        String deleteTemplates = request.get(0).deleteTemplates;
        String defaultTemplates = request.get(0).defaultTemplates;
        String currentStatus = request.get(0).currentStatus;
    
        system.debug('create files: '+defaultFiles);
        system.debug('create templates: '+defaultTemplates);
        system.debug('delete files: '+deleteFiles);
        system.debug('delete templates: '+deleteTemplates);
        /**Deliverable - Create or Delete */
        /*
         * Status = Published : only create remaining deliverables those user did not delete from published version
         * Status != Published : create remaining deliverables those user did not delete from published version & Delete deleteDeliverables
         */
        if (currentStatus == 'Published') {
            createDeliverable(defaultDeliverables, methodRecordId);
            createFiles(defaultFiles, methodRecordId);
            createTemplates(defaultTemplates, methodRecordId);
            createActivityOwnershipRecords(methodRecordId);
        }else if (currentStatus != 'Published') {
            deleteDeliverable(deleteDeliverables, methodRecordId);
            deleteFiles(deleteFiles, methodRecordId);
            deleteTemplates(deleteTemplates, methodRecordId);
        }
    }

    public class RelatedListsRequest {
        @InvocableVariable
        public String methodRecordId;
        @InvocableVariable
        public String deleteDeliverables;
        @InvocableVariable
        public String defaultDeliverables;
        @InvocableVariable
        public String deleteFiles;
        @InvocableVariable
        public String defaultFiles;
        @InvocableVariable
        public String deleteTemplates;
        @InvocableVariable
        public String defaultTemplates;
        @InvocableVariable
        public String currentStatus;

    }

    public static void createDeliverable(String defaultDeliverables, String methodRecordId) {
        try{
            List<String> oIds = defaultDeliverables?.split(',');
            List<Method_by_Deliverables__c> newRecs = new List<Method_by_Deliverables__c>();
            List<Method_by_Deliverables__c> deliverables = [Select id, Deliverable__c, Role__c, Method__c from Method_by_Deliverables__c where id IN :oIds];
            if (!deliverables.isEmpty()) {
                for(Method_by_Deliverables__c deliverable: deliverables) {
                    Method_by_Deliverables__c rec = new Method_by_Deliverables__c();
                    rec.Deliverable__c = deliverable.Deliverable__c;
                    rec.Role__c = deliverable.Role__c;
                    rec.Method__c = methodRecordId;
                    newRecs.add(rec);
                }
                if( !newRecs.isEmpty() ) Database.insert(newRecs);
            }
        }catch(Exception ex) {System.debug('*createDeliverable*'+String.valueOf(ex));}
          
    }

    public static void deleteDeliverable(String deleteDeliverables, String methodRecordId) {
        List<String> ids = deleteDeliverables?.split(',');
        List<Method_by_Deliverables__c> deliverables = [Select id, Deliverable__c, Role__c, Method__c from Method_by_Deliverables__c where id IN :ids];
        if( !deliverables.isEmpty() ) Database.delete(deliverables);
    }

    public static void createFiles(String defaultFiles, String methodRecordId) {
        try{
            List<String> oIds = defaultFiles?.split(',');
            List<ContentDocumentLink> newRecs = new List<ContentDocumentLink>();
            List<ContentDocumentLink> files = [Select id, ContentDocumentId, LinkedEntityId, ShareType, Visibility from ContentDocumentLink where id IN :oIds];
            if (!files.isEmpty()) {
                for(ContentDocumentLink file: files) {
                    ContentDocumentLink rec = new ContentDocumentLink();
                    rec.ContentDocumentId = file.ContentDocumentId;
                    rec.ShareType = 'V';
                    rec.Visibility = 'InternalUsers';
                    rec.LinkedEntityId = methodRecordId;
                    newRecs.add(rec);
                }
                if( !newRecs.isEmpty() ) Database.insert(newRecs);
            }
        }catch(Exception ex) {System.debug('*createFiles*'+String.valueOf(ex));}  
    }

    public static void deleteFiles(String deleteFiles, String methodRecordId) {
        List<String> ids = deleteFiles?.split(',');
        List<ContentDocumentLink> files = [Select id from ContentDocumentLink where id IN :ids];
        if( !files.isEmpty() ) Database.delete(files);
    }

    public static void createTemplates(String defaultTemplates, String methodRecordId) {
        try{
            List<String> oIds = defaultTemplates?.split(',');
            List<Templates__c> newRecs = new List<Templates__c>();
            List<Templates__c> templates = [Select id, Link__c, Method_Version_Description__c, Method__c, Status__c,Type__c from Templates__c where id IN :oIds];
            if (!templates.isEmpty()) {
                for(Templates__c template: templates) {
                    Templates__c rec = new Templates__c();
                    rec.Link__c = template.Link__c;
                    rec.Method_Version_Description__c = template.Method_Version_Description__c;
                    rec.Status__c = template.Status__c;
                    rec.Type__c = template.Type__c;
                    rec.Method__c = methodRecordId;
                    newRecs.add(rec);
                }
                if( !newRecs.isEmpty() ) Database.insert(newRecs);
            }
        }catch(Exception ex) {System.debug('*createTemplates*'+String.valueOf(ex));}  
         
    }

    public static void deleteTemplates(String deleteTemplates, String methodRecordId) {
        List<String> ids = deleteTemplates?.split(',');
        List<Templates__c> templates = [Select id from Templates__c where Id IN :ids];
        if( !templates.isEmpty() ) Database.delete(templates);
    }

    public static void createActivityOwnershipRecords(String methodRecordId){

        try{
            String ParentMethodId = [Select Id, Parent_Method__c from Method__c where id=:methodRecordId]?.Parent_Method__c;
            List<Activity_Ownership__c> activityOwnershipRecords = [Select Id, Method__c, Activity__c, Role__c, Responsible__c, Accountable__c, Support__c, Informed__c, Consulted__c from Activity_Ownership__c where Method__c =:ParentMethodId];
            List<Activity_Ownership__c> activityOwnershipToInsert = new List<Activity_Ownership__c>();
            for(Activity_Ownership__c rec : activityOwnershipRecords){
                Activity_Ownership__c newRec = new Activity_Ownership__c();
                newRec.Method__c = methodRecordId;
                newRec.Activity__c = rec.Activity__c;
                newRec.Role__c     = rec.Role__c;
                newRec.Responsible__c = rec.Responsible__c;
                newRec.Accountable__c = rec.Accountable__c;
                newRec.Support__c     = rec.Support__c;
                newRec.Informed__c    = rec.Informed__c;
                newRec.Consulted__c   = rec.Consulted__c;
                activityOwnershipToInsert.add(newRec);
            }
            if(!activityOwnershipToInsert.isEmpty())
                Database.insert(activityOwnershipToInsert);                      
        }catch(Exception ex) { System.debug('*createActivityOwnershipRecords*'+String.valueOf(ex));}

    }
}