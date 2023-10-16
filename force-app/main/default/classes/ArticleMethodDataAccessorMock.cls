@isTest
public with sharing class ArticleMethodDataAccessorMock implements ArticleMethodDAI{
    public List<Article_Method__c> articleMethods = new List<Article_Method__c>();

    public List<Article_Method__c> getArticleMethodsByMethodId(Id methodId) {
        return articleMethods;
    }
}