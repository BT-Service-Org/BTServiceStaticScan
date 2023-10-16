public with sharing class PSCReusableVoteCtrl {
    @AuraEnabled(cacheable=true)
    public static PSCKnowledgeArticlesService.VoteCountWrapper getVoteCount(String parentId){
        //GKC-1355 Start
        String sanitprntId = String.escapeSingleQuotes(parentId);
        String fieldName=  Id.valueOf(sanitprntId).getSObjectType().getDescribe().getName();
        String countQuery= 'SELECT count(Id) voteCount,Sentiment__c FROM Article_Feedback__c WHERE '+String.escapeSingleQuotes(fieldName)+' =:sanitprntId AND RecordType.DeveloperName = \'Vote\' WITH USER_MODE GROUP BY Sentiment__c';
        List<AggregateResult> voteCountList =  Database.query(countQuery);
        //GKC-1355 End

        PSCKnowledgeArticlesService.VoteCountWrapper voteCountWrapObj = new PSCKnowledgeArticlesService.VoteCountWrapper();
        voteCountWrapObj.upVoteCount = 0;
        voteCountWrapObj.downVoteCount = 0;

        for(AggregateResult aggr:voteCountList){
            if((String)aggr.get('Sentiment__c')=='Up'){
                voteCountWrapObj.upVoteCount = Integer.valueOf(aggr.get('voteCount'));
            }
            else if((String)aggr.get('Sentiment__c')=='Down'){
                voteCountWrapObj.downVoteCount = Integer.valueOf(aggr.get('voteCount'));
            }
        }

        return voteCountWrapObj;
    }

    @AuraEnabled(cacheable=true)
    public static PSCKnowledgeArticlesService.UserVoteWrapper getUserVote(String parentId){
        String sanitprntId = String.escapeSingleQuotes(parentId);
        //GKC-1355 Start
        String fieldName=  Id.valueOf(sanitprntId).getSObjectType().getDescribe().getName();
        String userVotesQuery= 'SELECT Id,Sentiment__c FROM Article_Feedback__c WHERE '+String.escapeSingleQuotes(fieldName)+'=:sanitprntId AND CreatedById =\''+userInfo.getUserId()+'\' AND RecordType.DeveloperName = \'Vote\' WITH USER_MODE';
        List<Article_Feedback__c> userVotes =  Database.query(userVotesQuery);
        //GKC-1355 End

        PSCKnowledgeArticlesService.UserVoteWrapper userVoteWrapperObj = new PSCKnowledgeArticlesService.UserVoteWrapper();
        userVoteWrapperObj.userUpVoted = false;
        userVoteWrapperObj.userDownVoted = false;

        if(userVotes != null && !userVotes.isEmpty()){
            userVoteWrapperObj.userVoteId = userVotes[0].Id;
            if(userVotes[0].Sentiment__c=='Up'){
                userVoteWrapperObj.userUpVoted = true;
            }
            else if(userVotes[0].Sentiment__c=='Down'){
                userVoteWrapperObj.userDownVoted = true;
            }
        }
        
        return userVoteWrapperObj;
    }

    @AuraEnabled
    public static Article_Feedback__c upsertUserVote(String parentId,String voteId,String sentiment){
        Article_Feedback__c afObj = new Article_Feedback__c();
        if(voteId != null && voteId != ''){
            afObj.Id = voteId;
            afObj.Sentiment__c = sentiment;
                update as user afObj;
        }
        else{
            String sanitprntId = String.escapeSingleQuotes(parentId);
            //GKC-1355
            String fieldName=  Id.valueOf(sanitprntId).getSObjectType().getDescribe().getName();//GKC-1355
            String userVotesQuery='SELECT Id,Sentiment__c FROM Article_Feedback__c WHERE '+String.escapeSingleQuotes(fieldName)+'=:sanitprntId AND CreatedById =\''+userInfo.getUserId()+'\' AND RecordType.DeveloperName = \'Vote\' WITH USER_MODE';
            List<Article_Feedback__c> userVotes = Database.query(userVotesQuery);

            if(userVotes != null && !userVotes.isEmpty()){
                afObj.Id = voteId;
                afObj.Sentiment__c = sentiment;
                    update as user afObj;
            }
            else{
                //GKC-1355
                if(fieldName =='PSC_Page__c'){
                afObj.PSC_Page__c = parentId;
            }//GKC-1254
            else if(fieldName =='Content_Requests__c'){
                afObj.Content_Requests__c = parentId;
            }
            else{
                afObj.Reusable_Asset__c = parentId;
            }
                afObj.Sentiment__c = sentiment;
                afObj.Status__c = 'New';
                afObj.RecordTypeId = Schema.SObjectType.Article_Feedback__c.getRecordTypeInfosByDeveloperName().get('Vote').getRecordTypeId();
                insert as user afObj;
            }
        }
        return afObj;
    }
}