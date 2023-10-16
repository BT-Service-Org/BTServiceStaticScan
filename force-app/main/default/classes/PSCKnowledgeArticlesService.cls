public with sharing class PSCKnowledgeArticlesService {
    public static List<Knowledge__kav> getArticleById(Set<String> articleIds, List<String> fieldNames) {
        if (articleIds.isEmpty() || fieldNames.isEmpty()) {
            return new List<Knowledge__kav>();
        }
        String fieldQuery = String.join(fieldNames, ', ');
        String q = 'SELECT ' + String.escapeSingleQuotes(fieldQuery) + ' ' +
                'FROM Knowledge__kav '  + ' ' +
                'WHERE Id IN :articleIds ' +
                'AND PublishStatus = \'Online\'';
        List<Knowledge__kav> articles = Database.query(q);

        Set<String> fieldsToExclude = new Set<String>{ 'IsVisibleInPrm', 'IsVisibleInCsp' };
        inaccessibleFieldsCheck(AccessType.READABLE, articles, fieldsToExclude);

        return articles;
    }

    private static void inaccessibleFieldsCheck(AccessType accessCheckType, List<SObject> records, Set<String> fieldsToExclude) {
        SObjectAccessDecision decision = Security.stripInaccessible(accessCheckType, records);

        Map<String,Set<String>> removedFieldsMap = decision.getRemovedFields();

        if (!removedFieldsMap.isEmpty()) {
            Set<String> removedFields = removedFieldsMap.values()[0];
            removedFields.removeAll(fieldsToExclude);
            String objectName = new List<String>(removedFieldsMap.keySet())[0];

            if (!removedFields.isEmpty()) {
                String fields = String.join(new List<String>(removedFields), ', ');
                throw new AuraHandledException('No access to ' + fields + ' field(s)' +
                        ' in the ' + objectName + ' object');
            }
        }
    } 

    public static Vote upsertUserVoteUtility(String parentId,String type,String recId){
        Vote voteObj = new Vote();
        if(recId != null){
            voteObj.Id = recId;
        }
        else{
            voteObj.ParentId = parentId;
        }
        voteObj.Type = type;
        
        upsert voteObj Id;
        return voteObj;
    }

    public static VoteCountWrapper getVoteCountUtility(String parentId){
        VoteCountWrapper voteCountWrapObj = new VoteCountWrapper();
        voteCountWrapObj.upVoteCount = 0;
        voteCountWrapObj.downVoteCount = 0;

        String objectApiName = PSCFavoriteCtrl.getObjectApiName(parentId);
        
        if(objectApiName == 'Knowledge__ka'){
            List<AggregateResult> voteCountList = [SELECT count(Id) voteCount,Type 
                                                FROM vote 
                                                WHERE ParentId =:parentId
                                                WITH SECURITY_ENFORCED
                                                GROUP BY Type
                                                ];

            for(AggregateResult aggr:voteCountList){
                if((String)aggr.get('Type')=='5'){
                    voteCountWrapObj.upVoteCount = Integer.valueOf(aggr.get('voteCount'));
                }
                else if((String)aggr.get('Type')=='1'){
                    voteCountWrapObj.downVoteCount = Integer.valueOf(aggr.get('voteCount'));
                }
            }
        }
        else if (objectApiName == 'Reusable_Asset__c') {
            List<AggregateResult> voteCountList = [SELECT count(Id) voteCount,Sentiment__c 
                                                        FROM Article_Feedback__c 
                                                        WHERE Reusable_Asset__c =:parentId
                                                        AND RecordType.DeveloperName = 'Vote'
                                                        GROUP BY Sentiment__c
                                                        ];

            for(AggregateResult aggr:voteCountList){
                if((String)aggr.get('Sentiment__c')=='Up'){
                    voteCountWrapObj.upVoteCount = Integer.valueOf(aggr.get('voteCount'));
                }
                else if((String)aggr.get('Sentiment__c')=='Down'){
                    voteCountWrapObj.downVoteCount = Integer.valueOf(aggr.get('voteCount'));
                }
            }
        }
        return voteCountWrapObj;
    }

    public static UserVoteWrapper getUserVoteUtility(String parentId){
        List<vote> userVotes = [SELECT Id,Type 
                                FROM vote 
                                WHERE ParentId =:parentId
                                AND CreatedById =:userInfo.getUserId()
                                WITH SECURITY_ENFORCED
                                ];

        UserVoteWrapper userVoteWrapperObj = new UserVoteWrapper();
        userVoteWrapperObj.userUpVoted = false;
        userVoteWrapperObj.userDownVoted = false;

        if(userVotes != null && !userVotes.isEmpty()){
            userVoteWrapperObj.userVoteId = userVotes[0].Id;
            if(userVotes[0].Type=='5'){
                userVoteWrapperObj.userUpVoted = true;
            }
            else if(userVotes[0].Type=='1'){
                userVoteWrapperObj.userDownVoted = true;
            }
        }
        
        return userVoteWrapperObj;
    }

    public static String getAllKnowledgeArticleNumber(Id knowledgeArticleVersion){
        String getArticleNumber = [SELECT Id,KnowledgeArticleId,ArticleNumber
                                    FROM Knowledge__kav
                                    WHERE Id=:knowledgeArticleVersion]?.ArticleNumber;

        return getArticleNumber;
    }

    public class VoteCountWrapper{
        @AuraEnabled
        public Integer upVoteCount;
        @AuraEnabled
        public Integer downVoteCount;
    }

    public class UserVoteWrapper{
        @AuraEnabled
        public Boolean userUpVoted;
        @AuraEnabled
        public Boolean userDownVoted;
        @AuraEnabled
        public String userVoteId;
    }

}