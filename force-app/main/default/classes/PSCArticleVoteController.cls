public with sharing class PSCArticleVoteController {
    @AuraEnabled(cacheable=true)
    public static PSCKnowledgeArticlesService.VoteCountWrapper getVoteCount(String parentId){
        return PSCKnowledgeArticlesService.getVoteCountUtility(parentId);
    }

    @AuraEnabled(cacheable=true)
    public static PSCKnowledgeArticlesService.UserVoteWrapper getUserVote(String parentId){
        return PSCKnowledgeArticlesService.getUserVoteUtility(parentId);
    }

    @AuraEnabled
    public static Vote upsertUserVote(String parentId,String type,String recId){
        return PSCKnowledgeArticlesService.upsertUserVoteUtility( parentId, type, recId);
    }
}