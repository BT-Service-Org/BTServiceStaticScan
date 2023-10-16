public with sharing class PSCCommentsCtrl {
    @AuraEnabled(cacheable=true)
    public static List<Article_Feedback__c> getCommentData(String parentDetailRecId,String parentFeedbackId){
        String objectApiName = PSCFavoriteCtrl.getObjectApiName(parentDetailRecId);
        String query = 'SELECT Id,Feedback__c,Sentiment__c, CreatedDate,CreatedBy.FirstName,CreatedBy.LastName,CreatedBy.MediumPhotoUrl,(SELECT Id,Feedback__c,CreatedDate,CreatedBy.FirstName,CreatedBy.LastName,CreatedBy.MediumPhotoUrl FROM Article_Feedbacks__r ORDER BY CreatedDate ASC) FROM Article_Feedback__c WHERE RecordType.DeveloperName = \'Feedback\'';
        if(objectApiName == 'Knowledge__kav'){
            String articleNumber = PSCKnowledgeArticlesService.getAllKnowledgeArticleNumber(parentDetailRecId);
            query += ' AND Parent_Knowledge_Article_Number__c =:  articleNumber AND Parent_Feedback__c =: parentFeedbackId';
            
        }
        else if(objectApiName == 'Reusable_Asset__c'){
            query += ' AND Reusable_Asset__c =:  parentDetailRecId AND Parent_Feedback__c =: parentFeedbackId';
        }
        //GKC-1355
        else if(objectApiName == 'PSC_Page__c'){
            query += ' AND PSC_Page__c =:  parentDetailRecId AND Parent_Feedback__c =: parentFeedbackId';
        }
        //GKC-1254
        else if(objectApiName == 'Content_Requests__c'){
            query += ' AND Content_Requests__c =:  parentDetailRecId AND Parent_Feedback__c =: parentFeedbackId';
        }
        query +=  ' ORDER BY CreatedDate DESC';
        List<Article_Feedback__c> afList = Database.query(query);
        return afList;
    }
}