@IsTest
public with sharing class SolutionFinder_Test {

    testMethod public static void testGetSettings() {

        Test.startTest();
        SolutionFinder.getSettings();
        Test.stopTest();
    }

    testMethod public static void testAssignments() {

        final String SEARCH_CRITERIA = 'Example';

        Test.startTest();
        SolutionFinderAssignments.getUsers();
        SolutionFinderAssignments.getAssignments(SEARCH_CRITERIA);
        Test.stopTest();
    }

    testMethod public static void testSaveAssignment() {

        final String USER_ID = 'Example';
        final String OPTION_NAME = 'Example';
        final String ROLE = 'User';

        Test.startTest();
        SolutionFinderAssignment.saveAssignment(USER_ID, OPTION_NAME, ROLE);
        Test.stopTest();
    }

    testMethod public static void testBuzzWord() {

        Solution_Finder_Buzz_Word__mdt buzzWordRecord = new Solution_Finder_Buzz_Word__mdt();
        Solution_Finder_Word_Association__mdt wordAssocitionRecord = new Solution_Finder_Word_Association__mdt();

        Test.startTest();
        SolutionFinderBuzzWord buzzWord = new SolutionFinderBuzzWord(buzzWordRecord);
        buzzWord = new SolutionFinderBuzzWord(wordAssocitionRecord);
        Test.stopTest();
    }

    testMethod public static void testBuzzWords() {

        final String OPTION_NAME = 'Example';

        Test.startTest();
        SolutionFinderBuzzWords.getBuzzWords(OPTION_NAME);
        Test.stopTest();
    }

    testMethod public static void testSaveBuzzWord() {

        final String DETAIL_NAME = 'Example';
        final String DETAIL_LABEL = 'Example';
        final String DETAIL_URL = 'https://Example';

        final String NAMESPACE = 'Example';
        final String NAME = null;
        final String LABEL = 'Example';
        final String DEFINITION = 'Example';
        final String URL = null;
        final String PROBABILITY = null;
        final String OPTION_NAME = 'Example';

        List<SolutionFinderDetail> details = new List<SolutionFinderDetail>();
        Solution_Finder_Detail__mdt detailRecord = new Solution_Finder_Detail__mdt();
        detailRecord.DeveloperName = DETAIL_NAME;
        detailRecord.Label__c = DETAIL_LABEL;
        detailRecord.URL__c = DETAIL_URL;
        details.add(new SolutionFinderDetail(detailRecord));

        Test.startTest();
        SolutionFinderBuzzWord.saveBuzzWord(NAMESPACE, NAME, LABEL, DEFINITION, URL, PROBABILITY, OPTION_NAME, JSON.serialize(details));
        Test.stopTest();
    }

    testMethod public static void testComparison() {

        final String NAMESPACE = 'Example';
        final String NAME = null;

        Test.startTest();
        SolutionFinderComparison.getComparison(NAMESPACE, NAME);
        Test.stopTest();
    }

    testMethod public static void testSaveComparison() {

        final String SOLUTION_NAME = 'Example';
        final String PROPERTY_NAME = 'Example';
        final String PROPERTY_DATA_TYPE = 'Text';
        final String VALUE = 'Example';

        List<SolutionFinderComparison.Change> changes = new List<SolutionFinderComparison.Change>();
        SolutionFinderComparison.Change change = new SolutionFinderComparison.Change(SOLUTION_NAME, PROPERTY_NAME, PROPERTY_DATA_TYPE, VALUE);
        changes.add(change);

        Test.startTest();
        SolutionFinderComparison.saveComparison(JSON.serialize(changes));
        Test.stopTest();
    }

    testMethod public static void testContext() {

        final String NAMESPACE = 'Example';
        final String NAME = 'Example';

        Test.startTest();
        SolutionFinderContext.getContext(NAMESPACE, NAME, null);
        SolutionFinderContext.getContext(NAMESPACE, null, null);
        Test.stopTest();
    }

    testMethod public static void testSaveOption() {

        final String NAMESPACE = 'Example';
        final String NAME = null;
        final String PARENT_NAMESPACE = 'Example';
        final String PARENT_NAME = null;
        final String TITLE = 'Example';
        final String DESCRIPTION = 'Example';
        final String NEXT_QUESTION = 'Example';
        final String NEXT_QUESTION_HELP_TEXT = 'Example';
        final String FEEDBACK_SLACK_CHANNEL = null;
        final String FEEDBACK_EMAIL = null;

        Test.startTest();
        SolutionFinderOption.saveOption(NAMESPACE, NAME, PARENT_NAMESPACE, PARENT_NAME, TITLE, DESCRIPTION, NEXT_QUESTION, NEXT_QUESTION_HELP_TEXT, FEEDBACK_SLACK_CHANNEL, FEEDBACK_EMAIL);
        Test.stopTest();
    }

    testMethod public static void testDeleteRecommendation() {

        final String NAME = 'Example';

        Test.startTest();
        SolutionFinderRecommendation.deleteRecommendation(NAME);
        Test.stopTest();
    }

    testMethod public static void testDeleteWordAssociation() {

        final String NAME = 'Example';

        Test.startTest();
        SolutionFinderWordAssociation.deleteWordAssociation(NAME);
        Test.stopTest();
    }

    testMethod public static void testSaveRecommendation() {

        final String NAMESPACE = 'Example';
        final String NAME = null;
        final String OPTION_NAME = 'Example';
        final String SOLUTION_NAME = 'Example';

        Test.startTest();
        SolutionFinderRecommendation.saveRecommendation(NAMESPACE, NAME, OPTION_NAME, SOLUTION_NAME);
        Test.stopTest();
    }

    testMethod public static void testSaveSettings() {

        final String NAMESPACE = 'Example';
        final String PARENT_NAMESPACE = 'Example';
        final String PARENT_NAME = 'Example';
        final String FEEDBACK_SLACK_CHANNEL = null;
        final String FEEDBACK_EMAIL = null;

        Test.startTest();
        SolutionFinderSettings.saveSettings(NAMESPACE, PARENT_NAMESPACE, PARENT_NAME, FEEDBACK_SLACK_CHANNEL, FEEDBACK_EMAIL);
        Test.stopTest();
    }

    testMethod public static void testSolutions() {

        final String OPTION_NAME = 'Example';

        Test.startTest();
        SolutionFinderSolutions.getSolutions(OPTION_NAME);
        Test.stopTest();
    }

    testMethod public static void testSaveSolution() {

        final String DETAIL_NAME = 'Example';
        final String DETAIL_LABEL = 'Example';
        final String DETAIL_URL = 'https://Example';

        final String NAMESPACE = 'Example';
        final String NAME = null;
        final String LABEL = 'Example';
        final String DESCRIPTION = 'Example';
        final String EXPORT_NOTE = 'Example';

        Test.startTest();

        List<SolutionFinderDetail> considerations = new List<SolutionFinderDetail>();
        List<SolutionFinderDetail> limitations = new List<SolutionFinderDetail>();
        List<SolutionFinderDetail> stories = new List<SolutionFinderDetail>();

        Solution_Finder_Detail__mdt detailRecord = new Solution_Finder_Detail__mdt();
        detailRecord.DeveloperName = DETAIL_NAME;
        detailRecord.Label__c = DETAIL_LABEL;
        detailRecord.URL__c = DETAIL_URL;

        considerations.add(new SolutionFinderDetail(detailRecord));
        limitations.add(new SolutionFinderDetail(detailRecord));
        stories.add(new SolutionFinderDetail(detailRecord));

        SolutionFinderSolution.saveSolution(NAMESPACE, NAME, LABEL, DESCRIPTION, EXPORT_NOTE, JSON.serialize(considerations), JSON.serialize(limitations), JSON.serialize(stories), 'Example');
        Test.stopTest();
    }

    testMethod public static void testSortBuzzWords() {

        final String LABEL_A = 'A';
        final String LABEL_B = 'B';

        Test.startTest();
        SolutionFinderBuzzWord a = new SolutionFinderBuzzWord();
        a.label = LABEL_A;

        SolutionFinderBuzzWord b = new SolutionFinderBuzzWord();
        b.label = LABEL_B;

        a.compareTo(b);
        Test.stopTest();
    }

    testMethod public static void testSortRecommendations() {

        final String LABEL_A = 'A';
        final String LABEL_B = 'B';

        Test.startTest();
        SolutionFinderRecommendation a = new SolutionFinderRecommendation();
        a.solutionLabel = LABEL_A;

        SolutionFinderRecommendation b = new SolutionFinderRecommendation();
        b.solutionLabel = LABEL_B;

        a.compareTo(b);
        Test.stopTest();
    }

    testMethod public static void testSortSolutions() {

        final String LABEL_A = 'A';
        final String LABEL_B = 'B';

        Test.startTest();
        SolutionFinderSolution a = new SolutionFinderSolution();
        a.label = LABEL_A;

        SolutionFinderSolution b = new SolutionFinderSolution();
        b.label = LABEL_B;

        a.compareTo(b);
        Test.stopTest();
    }

    testMethod public static void testTree() {

        Test.startTest();
        SolutionFinderTree.getTree(null);
        Test.stopTest();
    }

    testMethod public static void testUserSearch() {

        final String VALUE = 'Example';
        final String NAME = 'Example';
        final String LABEL = 'Example';
        final String ICON_NAME = 'Example';
        final Boolean DISABLED = false;

        Test.startTest();
        SolutionFinderUserSearch.search(null);
        SolutionFinderUserSearch.ColumnTypeAttributes attributes = new SolutionFinderUserSearch.ColumnTypeAttributes(VALUE, NAME, LABEL, ICON_NAME, DISABLED);
        Test.stopTest();
    }

    testMethod public static void testUserSearchResultColumns() {

        Test.startTest();
        SolutionFinderUserSearch.getSearchResultColumns();
        Test.stopTest();
    }

    testMethod public static void testSaveWordAssociation() {

        final String NAMESPACE = 'Example';
        final String NAME = null;
        final String OPTION_NAME = 'Example';
        final String BUZZ_WORD_NAME = 'Example';

        Test.startTest();
        SolutionFinderWordAssociation.saveWordAssociation(NAMESPACE, NAME, OPTION_NAME, BUZZ_WORD_NAME);
        Test.stopTest();
    }
}