@isTest
public with sharing class MTH_TestDataProviderAnswersLookup {

    @isTest
    private static void getSlackOptions_givenQuestionIdAndAnswers_shouldReturnAsSlackOption() {

        Test.startTest();
        List<Slack.Option> options = MTH_DataProviderAnswersLookup.getAnswersByQuestion('test', 'answer1,answer2,answer3');
        Test.stopTest();

        System.assertEquals('answer1', options[0].getText(), 'should return correct option text');
    }

    @isTest
    private static void getSlackOptions_givenBlankQuestionIdAndAnswers_shouldReturnEmptySlackOptions() {

        Test.startTest();
        List<Slack.Option> options = MTH_DataProviderAnswersLookup.getAnswersByQuestion('', 'answer1,answer2,answer3');
        Test.stopTest();

        System.assert(options.size() == 0, 'should return no options');
    }
}