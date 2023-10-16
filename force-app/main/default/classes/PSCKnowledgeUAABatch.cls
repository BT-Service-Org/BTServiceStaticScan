global class PSCKnowledgeUAABatch implements Database.batchable<sObject>{ 
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        String query = 'SELECT Id,Reviewer__c,OwnerId,VersionNumber,Resource_Type__c,Curation_Level__c from Knowledge__kav where PublishStatus =\'Online\' AND owner.type = \'User\' ';
        if(pscSettings__mdt.getInstance('Gamification_Knowledge_Today').Value__c=='True'){
            query += 'AND FirstPublishedDate = TODAY';
        }
        return Database.getQueryLocator(query);
    }     
    global void execute(Database.BatchableContext BC, List<Knowledge__kav> knowList) {
        PSCGamificationService.createKnowledgeRelatedUAA(knowList);
    }   
        
    global void finish(Database.BatchableContext BC) {
        
    }
}