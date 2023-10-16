public with sharing class ArticleMethodDataAccessor implements ArticleMethodDAI{
    public List<Article_Method__c> getArticleMethodsByMethodId(Id methodId){
        return [
            SELECT
                Id,
                Knowledge__r.Id,
                Knowledge__r.Title,
                Knowledge__r.GKC_Community_Url__c
            FROM Article_Method__c
            WHERE Knowledge__r.Include_in_Slack_Journey__c INCLUDES ('Method Assignment')
            AND Knowledge__r.PublishStatus = 'Online'
            AND Method__r.Id = :methodId
            WITH SECURITY_ENFORCED
        ];
    }
}