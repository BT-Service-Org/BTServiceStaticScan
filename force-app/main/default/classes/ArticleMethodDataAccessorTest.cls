@isTest
public with sharing class ArticleMethodDataAccessorTest {
    @isTest
    public static void getArticleMethodsByMethodId_shouldReturnArticleMethods() {
        ArticleMethodDataAccessorMock articleMethodDAMock = new ArticleMethodDataAccessorMock();
        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );

        Article_Method__c mockArticleMethod = new Article_Method__c(
            Id = MockSObjectBuilder.getMockId(Article_Method__c.getSObjectType()),
            Method__r = mockMethod
        );

        articleMethodDAMock.articleMethods.add(mockArticleMethod);

        Test.startTest();
        List<Article_Method__c> returnedArticleMethods = new ArticleMethodDataAccessor().getArticleMethodsByMethodId(mockMethod.Id);
        List<Article_Method__c> returnedArticleMethodsMock = articleMethodDAMock.getArticleMethodsByMethodId(mockMethod.Id);
        Test.stopTest();

        System.assertEquals(1, returnedArticleMethodsMock.size(), 'should return 1 article method');
    }
}