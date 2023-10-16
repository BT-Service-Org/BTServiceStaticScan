public with sharing class SolutionFinderContext {

    @AuraEnabled public String namespace {get;set;}
    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String parentNamespace {get;set;}
    @AuraEnabled public String parentName {get;set;}
    @AuraEnabled public String label {get;set;}
    @AuraEnabled public String description {get;set;}
    @AuraEnabled public String question {get;set;}
    @AuraEnabled public String helpText {get;set;}
    @AuraEnabled public String answerLabel {get;set;}
    @AuraEnabled public String questionLabel {get;set;}
    @AuraEnabled public String feedbackSlackChannel {get;set;}
    @AuraEnabled public String feedbackEmail {get;set;}
    @AuraEnabled public List<SolutionFinderOption> options {get;set;}
    @AuraEnabled public List<SolutionFinderOption> history {get;set;}
    @AuraEnabled public List<SolutionFinderRecommendation> recommendations {get;set;}
    @AuraEnabled public List<SolutionFinderBuzzWord> buzzWords {get;set;}
    @AuraEnabled public String role {get;set;}

    public SolutionFinderContext(String namespace, String name) {
        this.namespace = namespace;
        this.name = name;
        this.init();
    }

    private void init() {
        this.initCurrentItem();
        this.initOptions();
        this.initHistory();
        this.initRole();
        this.initRecommendations();
        this.initProperties();
        this.initBuzzWords();
    }

    private void initCurrentItem() {
        if (this.name == null) {
            this.question = 'Welcome!  What type of solution can I help you with?';
            this.helpText = 'Please select from one of the options below.';
        } else {
            List<Solution_Finder_Option__mdt> items =
                [SELECT Id, Title__c, Parent_Namespace__c, Parent_Name__c, DeveloperName, MasterLabel, Description__c,
                    Next_Question__c, Next_Question_Help_Text__c, Answer_Label__c, Question_Label__c,
                    Feedback_Slack_Channel__c, Feedback_Email__c
                 FROM Solution_Finder_Option__mdt
                 WHERE Namespace__c = : this.namespace
                 AND DeveloperName = : this.name
                 WITH SECURITY_ENFORCED
                 LIMIT 1];
            if (items.size() > 0) {
                this.parentNamespace = items[0].Parent_Namespace__c;
                this.parentName = items[0].Parent_Name__c;
                this.label = items[0].Title__c;
                this.description = items[0].Description__c;
                this.question = items[0].Next_Question__c;
                this.helpText = items[0].Next_Question_Help_Text__c;
                this.answerLabel = items[0].Answer_Label__c;
                this.questionLabel = items[0].Question_Label__c;
                this.feedbackSlackChannel = items[0].Feedback_Slack_Channel__c;
                this.feedbackEmail = items[0].Feedback_Email__c;

                //recordSelection(this.name, this.parentName);
            }
        }
    }

    @future
    private static void recordSelection(String name, String parentOptionName) {
        /*
        Selection__c selection = new Selection__c();
        selection.Option_Name__c = name;
        selection.Parent_Option_Name__c = parentOptionName;
        insert selection;
        */
    }

    private void initOptions() {
        this.options = new List<SolutionFinderOption>();
        for (Solution_Finder_Option__mdt record : getOptions()) {
            this.options.add(new SolutionFinderOption(record));
        }
    }

    private List<Solution_Finder_Option__mdt> getOptions() {
        List<Solution_Finder_Option__mdt> options;
        if (this.name == null) {
            options = getAssignedOptions();
        } else {
            options = getChildOptions();
        }
        return options;
    }

    private List<Solution_Finder_Option__mdt> getAssignedOptions() {
        List<Solution_Finder_Option__mdt> options = new List<Solution_Finder_Option__mdt>();
        List<String> myAssignedOptionNames = getAssignedOptionNames();
        options = [SELECT Id, Title__c, Parent_Namespace__c, Parent_Name__c, Namespace__c, DeveloperName, MasterLabel,
                        Description__c, Next_Question__c, Next_Question_Help_Text__c, Answer_Label__c, Question_Label__c,
                        Feedback_Slack_Channel__c, Feedback_Email__c
                    FROM Solution_Finder_Option__mdt
                    WHERE Parent_Namespace__c =: this.namespace
                    AND Parent_Name__c =: this.name
                    AND DeveloperName IN : myAssignedOptionNames
                    WITH SECURITY_ENFORCED
                    ORDER BY Title__c
                    LIMIT 100];
        return options;
    }

    private List<String> getAssignedOptionNames() {
        List<String> optionNames = new List<String>();
        for (Solution_Finder_Permission__c assignment : getAssignments()) {
            optionNames.add(assignment.Option_Name__c);
        }
        return optionNames;
    }

    private List<Solution_Finder_Permission__c> getAssignments() {
        return [SELECT Id, Option_Name__c, Role__c
                FROM Solution_Finder_Permission__c
                WHERE OwnerId =: UserInfo.getUserId()
                WITH SECURITY_ENFORCED
                LIMIT 10000];
    }

    private List<Solution_Finder_Option__mdt> getChildOptions() {
        return [SELECT Id, Title__c, Parent_Namespace__c, Parent_Name__c, Namespace__c, DeveloperName, MasterLabel,
                    Description__c, Next_Question__c, Next_Question_Help_Text__c, Answer_Label__c, Question_Label__c,
                    Feedback_Slack_Channel__c, Feedback_Email__c
                FROM Solution_Finder_Option__mdt
                WHERE Parent_Namespace__c =: this.namespace
                AND Parent_Name__c =: this.name
                WITH SECURITY_ENFORCED
                ORDER BY Title__c
                LIMIT 100];
    }

    private void initHistory() {
        this.history = new List<SolutionFinderOption>();
        Integer loopsRemaining = 10;
        String parentNamespace = this.namespace;
        String parentName = this.name;
        Solution_Finder_Option__mdt option;
        while(true) {
            option = getParentOption(parentNamespace, parentName);
            if (option == null || loopsRemaining == 0) {
                break;
            }
            this.history.add(new SolutionFinderOption(option));
            parentNamespace = option.Parent_Namespace__c;
            parentName = option.Parent_Name__c;
            loopsRemaining--;
        }
        this.reverseHistory();
    }

    private void reverseHistory() {
        List<SolutionFinderOption> reversedHistory = new List<SolutionFinderOption>();
        for (Integer i = this.history.size() - 1; i >= 0; i--) {
            reversedHistory.add(this.history[i]);
        }
        this.history = reversedHistory;
    }

    private void initRole() {
        String myRole = 'User';
        List<String> historicOptionNames = new List<String>();
        for (SolutionFinderOption historicOption : this.history) {
            historicOptionNames.add(historicOption.name);
        }
        Set<String> roles = new Set<String>();
        for (Solution_Finder_Permission__c assignment :
                [SELECT Id, Option_Name__c, Role__c
                 FROM Solution_Finder_Permission__c
                 WHERE OwnerId =: UserInfo.getUserId()
                 AND Option_Name__c IN : historicOptionNames
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            roles.add(assignment.Role__c);
        }
        if (roles.contains('Administrator')) {
            myRole = 'Administrator';
        } else if (roles.contains('Contributor')) {
            myRole = 'Contributor';
        }
        this.role = myRole;
    }

    private Solution_Finder_Option__mdt getParentOption(String namespace, String name) {
        Solution_Finder_Option__mdt parentOption;
        if (name != null) {
            List<Solution_Finder_Option__mdt> options =
                [SELECT Id, Title__c, Parent_Namespace__c, Parent_Name__c, Namespace__c, DeveloperName, MasterLabel,
                    Description__c, Next_Question__c, Next_Question_Help_Text__c, Answer_Label__c, Question_Label__c,
                    Feedback_Slack_Channel__c, Feedback_Email__c
                FROM Solution_Finder_Option__mdt
                WHERE Namespace__c =: namespace
                AND DeveloperName =: name
                WITH SECURITY_ENFORCED
                ORDER BY Title__c
                LIMIT 1];
            if (options.size() == 1) {
                parentOption = options[0];
            }
        }
        return parentOption;
    }

    private void initRecommendations() {
        this.recommendations = new List<SolutionFinderRecommendation>();
        for (Solution_Finder_Recommendation__mdt record : getRecommendations()) {
            this.recommendations.add(new SolutionFinderRecommendation(record));
        }
        String key;
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfConsiderations = getMapOfConsiderations();
        for (SolutionFinderRecommendation recommendation : this.recommendations) {
            key = recommendation.solutionNamespace + '.' + recommendation.solutionName;
            recommendation.setConsiderations(mapOfConsiderations.get(key));
        }
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfLimitations = getMapOfLimitations();
        for (SolutionFinderRecommendation recommendation : this.recommendations) {
            key = recommendation.solutionNamespace + '.' + recommendation.solutionName;
            recommendation.setLimitations(mapOfLimitations.get(key));
        }
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfStories = getMapOfStories();
        for (SolutionFinderRecommendation recommendation : this.recommendations) {
            key = recommendation.solutionNamespace + '.' + recommendation.solutionName;
            recommendation.setStories(mapOfStories.get(key));
        }
        this.recommendations.sort();
    }

    private List<Solution_Finder_Recommendation__mdt> getRecommendations() {
        return [SELECT Id, DeveloperName, Solution_Finder_Solution__r.Namespace__c, Solution_Finder_Solution__r.DeveloperName,
                    Solution_Finder_Solution__r.MasterLabel, Percentage__c, Solution_Finder_Solution__r.Title__c,
                    Solution_Finder_Solution__r.Description__c, Solution_Finder_Solution__r.Export_Note__c
                FROM Solution_Finder_Recommendation__mdt
                WHERE Solution_Finder_Option__r.Namespace__c =: this.namespace
                AND Solution_Finder_Option__r.DeveloperName =: this.name
                AND Solution_Finder_Solution__c <> null
                WITH SECURITY_ENFORCED
                ORDER BY MasterLabel
                LIMIT 100];
    }

    private Map<String, List<Solution_Finder_Detail__mdt>> getMapOfConsiderations() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfConsiderations = new Map<String, List<Solution_Finder_Detail__mdt>>();
        Set<String> solutionNamespaces = new Set<String>();
        Set<String> solutionNames = new Set<String>();
        String key;
        for (SolutionFinderRecommendation recommendation : this.recommendations) {
            solutionNamespaces.add(recommendation.solutionNamespace);
            solutionNames.add(recommendation.solutionName);
            key = recommendation.solutionNamespace + '.' + recommendation.solutionName;
            mapOfConsiderations.put(key, new List<Solution_Finder_Detail__mdt>());
        }
        List<Solution_Finder_Detail__mdt> records;
        for (Solution_Finder_Detail__mdt detail :
                [SELECT Id, DeveloperName, Solution_Finder_Solution__r.Namespace__c, Solution_Finder_Solution__r.DeveloperName,
                    Label__c, URL__c
                 FROM Solution_Finder_Detail__mdt
                 WHERE Solution_Finder_Solution__r.Namespace__c IN : solutionNamespaces
                 AND Solution_Finder_Solution__r.DeveloperName IN : solutionNames
                 AND Type__c = 'Consideration'
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            key = detail.Solution_Finder_Solution__r.Namespace__c + '.' + detail.Solution_Finder_Solution__r.DeveloperName;
            records = mapOfConsiderations.get(key);
            if (records != null) {
                records.add(detail);
            }
        }
        return mapOfConsiderations;
    }

    private Map<String, List<Solution_Finder_Detail__mdt>> getMapOfLimitations() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfLimitations = new Map<String, List<Solution_Finder_Detail__mdt>>();
        Set<String> solutionNamespaces = new Set<String>();
        Set<String> solutionNames = new Set<String>();
        String key;
        for (SolutionFinderRecommendation recommendation : this.recommendations) {
            solutionNamespaces.add(recommendation.solutionNamespace);
            solutionNames.add(recommendation.solutionName);
            key = recommendation.solutionNamespace + '.' + recommendation.solutionName;
            mapOfLimitations.put(key, new List<Solution_Finder_Detail__mdt>());
        }
        List<Solution_Finder_Detail__mdt> records;
        for (Solution_Finder_Detail__mdt detail :
                [SELECT Id, DeveloperName, Solution_Finder_Solution__r.Namespace__c, Solution_Finder_Solution__r.DeveloperName,
                    Label__c, URL__c
                 FROM Solution_Finder_Detail__mdt
                 WHERE Solution_Finder_Solution__r.Namespace__c IN : solutionNamespaces
                 AND Solution_Finder_Solution__r.DeveloperName IN : solutionNames
                 AND Type__c = 'Limitation'
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            key = detail.Solution_Finder_Solution__r.Namespace__c + '.' + detail.Solution_Finder_Solution__r.DeveloperName;
            records = mapOfLimitations.get(key);
            if (records != null) {
                records.add(detail);
            }
        }
        return mapOfLimitations;
    }

    private Map<String, List<Solution_Finder_Detail__mdt>> getMapOfStories() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfStories = new Map<String, List<Solution_Finder_Detail__mdt>>();
        Set<String> solutionNamespaces = new Set<String>();
        Set<String> solutionNames = new Set<String>();
        String key;
        for (SolutionFinderRecommendation recommendation : this.recommendations) {
            solutionNamespaces.add(recommendation.solutionNamespace);
            solutionNames.add(recommendation.solutionName);
            key = recommendation.solutionNamespace + '.' + recommendation.solutionName;
            mapOfStories.put(key, new List<Solution_Finder_Detail__mdt>());
        }
        List<Solution_Finder_Detail__mdt> records;
        for (Solution_Finder_Detail__mdt detail :
                [SELECT Id, DeveloperName, Solution_Finder_Solution__r.Namespace__c, Solution_Finder_Solution__r.DeveloperName,
                    Label__c, URL__c
                 FROM Solution_Finder_Detail__mdt
                 WHERE Solution_Finder_Solution__r.Namespace__c IN : solutionNamespaces
                 AND Solution_Finder_Solution__r.DeveloperName IN : solutionNames
                 AND Type__c = 'Story'
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            key = detail.Solution_Finder_Solution__r.Namespace__c + '.' + detail.Solution_Finder_Solution__r.DeveloperName;
            records = mapOfStories.get(key);
            if (records != null) {
                records.add(detail);
            }
        }
        return mapOfStories;
    }

    private void initProperties() {
        Set<Id> solutionIds = new Set<Id>();
        for (SolutionFinderRecommendation recommendation : this.recommendations) {
            solutionIds.add(recommendation.solutionId);
        }
        Map<Id, List<Solution_Finder_Property__mdt>> mapOfProperties = getMapOfProperties(solutionIds);
        for (SolutionFinderRecommendation recommendation : this.recommendations) {
            if (mapOfProperties.containsKey(recommendation.solutionId)) {
                recommendation.setProperties(mapOfProperties.get(recommendation.solutionId));
            }
        }
    }

    private Map<Id, List<Solution_Finder_Property__mdt>> getMapOfProperties(Set<Id> solutionIds) {
        Map<Id, List<Solution_Finder_Property__mdt>> mapOfProperties = new Map<Id, List<Solution_Finder_Property__mdt>>();
        List<Solution_Finder_Property__mdt> listOfProperties;
        for (Solution_Finder_Property__mdt property : getPropertyRecords(solutionIds)) {
            listOfProperties = mapOfProperties.get(property.Solution_Finder_Solution__c);
            if (listOfProperties == null) {
                listOfProperties = new List<Solution_Finder_Property__mdt>();
            }
            listOfProperties.add(property);
            mapOfProperties.put(property.Solution_Finder_Solution__c, listOfProperties);
        }
        return mapOfProperties;
    }

    private List<Solution_Finder_Property__mdt> getPropertyRecords(Set<Id> solutionIds) {
        return [SELECT Id, DeveloperName, MasterLabel, Title__c, Data_Type__c, Default_Value__c, Display_Order__c,
                    Display_in_Preview__c, Solution_Finder_Solution__c
                FROM Solution_Finder_Property__mdt
                WHERE Solution_Finder_Solution__c IN : solutionIds
                WITH SECURITY_ENFORCED
                ORDER BY Display_Order__c, MasterLabel
                LIMIT 500];
    }

    private void initBuzzWords() {
        this.buzzWords = new List<SolutionFinderBuzzWord>();
        for (Solution_Finder_Word_Association__mdt record : getWordAssociations()) {
            this.buzzWords.add(new SolutionFinderBuzzWord(record));
        }
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfDetails = getMapOfDetails(buzzWords);
        for (SolutionFinderBuzzWord buzzWord : this.buzzWords) {
            buzzWord.setDetails(mapOfDetails.get(buzzWord.name));
        }
        this.buzzWords.sort();
    }

    private List<Solution_Finder_Word_Association__mdt> getWordAssociations() {
        return [SELECT Id, DeveloperName, Solution_Finder_Buzz_Word__r.DeveloperName, Solution_Finder_Buzz_Word__r.MasterLabel,
                    Solution_Finder_Buzz_Word__r.Title__c, Solution_Finder_Buzz_Word__r.Definition__c,
                    Solution_Finder_Buzz_Word__r.More_Information_URL__c, Solution_Finder_Buzz_Word__r.Probability__c
                FROM Solution_Finder_Word_Association__mdt
                WHERE Solution_Finder_Option__r.Namespace__c =: this.namespace
                AND Solution_Finder_Option__r.DeveloperName =: this.name
                AND Solution_Finder_Buzz_Word__c <> null
                WITH SECURITY_ENFORCED
                ORDER BY MasterLabel
                LIMIT 100];
    }

    private Map<String, List<Solution_Finder_Detail__mdt>> getMapOfDetails(List<SolutionFinderBuzzWord> buzzWords) {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfDetails = new Map<String, List<Solution_Finder_Detail__mdt>>();
        for (SolutionFinderBuzzWord buzzWord : buzzWords) {
            mapOfDetails.put(buzzWord.name, new List<Solution_Finder_Detail__mdt>());
        }
        Set<String> buzzWordNames = mapOfDetails.keySet();
        List<Solution_Finder_Detail__mdt> records;
        for (Solution_Finder_Detail__mdt detail :
                [SELECT Id, DeveloperName, Solution_Finder_Buzz_Word__r.DeveloperName, Label__c, URL__c
                 FROM Solution_Finder_Detail__mdt
                 WHERE Solution_Finder_Buzz_Word__r.DeveloperName IN : buzzWordNames
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            records = mapOfDetails.get(detail.Solution_Finder_Buzz_Word__r.DeveloperName);
            if (records != null) {
                records.add(detail);
            }
        }
        return mapOfDetails;
    }

    @AuraEnabled(cacheable=true)
    public static SolutionFinderContext getContext(String namespace, String name, String cacheBuster) {
        return new SolutionFinderContext(namespace, name);
    }
}