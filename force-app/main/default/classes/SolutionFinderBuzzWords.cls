public with sharing class SolutionFinderBuzzWords {
    
    private String name;
    @AuraEnabled public Map<String, List<SolutionFinderBuzzWord>> buzzWords {get;set;}

    public SolutionFinderBuzzWords(String name) {
        this.name = name;
        this.init();
    }

    private void init() {
        this.initBuzzWords();
    }

    private void initBuzzWords() {
        this.buzzWords = new Map<String, List<SolutionFinderBuzzWord>>();
        initSelectedBuzzWords();
        initRecommendedBuzzWords();
        initOtherBuzzWords();
        initDetails();
    }

    private void initSelectedBuzzWords() {
        System.debug('getting selected buzz words: ' + this.name);
        List<SolutionFinderBuzzWord> listOfBuzzWords = new List<SolutionFinderBuzzWord>();
        for (Solution_Finder_Word_Association__mdt record :
                [SELECT Id, DeveloperName, Solution_Finder_Buzz_Word__r.DeveloperName, Solution_Finder_Buzz_Word__r.MasterLabel,
                    Solution_Finder_Buzz_Word__r.Title__c, Solution_Finder_Buzz_Word__r.Definition__c,
                    Solution_Finder_Buzz_Word__r.More_Information_URL__c, Solution_Finder_Buzz_Word__r.Probability__c
                 FROM Solution_Finder_Word_Association__mdt
                 WHERE Solution_Finder_Option__r.DeveloperName = : this.name
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            listOfBuzzWords.add(new SolutionFinderBuzzWord(record));
        }
        listOfBuzzWords.sort();
        this.buzzWords.put('selected', listOfBuzzWords);
    }

    /**
     * Match the recommendations from the parent record (if applicable)
     */
    private void initRecommendedBuzzWords() {
        List<SolutionFinderBuzzWord> listOfBuzzWords = new List<SolutionFinderBuzzWord>();
        Set<String> selectedNames = new Set<String>();
        for (SolutionFinderBuzzWord buzzWord : this.buzzWords.get('selected')) {
            selectedNames.add(buzzWord.name);
        }
        List<Solution_Finder_Option__mdt> options =
            [SELECT Id, Parent_Name__c
             FROM Solution_Finder_Option__mdt
             WHERE DeveloperName = : this.name
             AND Parent_Name__c <> null
             WITH SECURITY_ENFORCED
             LIMIT 1];
        if (options.size() == 1) {
            String parentName = options[0].Parent_Name__c;
            for (Solution_Finder_Word_Association__mdt recommendation :
                    [SELECT Id, DeveloperName, Solution_Finder_Buzz_Word__r.DeveloperName, Solution_Finder_Buzz_Word__r.MasterLabel,
                        Solution_Finder_Buzz_Word__r.Title__c, Solution_Finder_Buzz_Word__r.Definition__c,
                        Solution_Finder_Buzz_Word__r.More_Information_URL__c, Solution_Finder_Buzz_Word__r.Probability__c
                    FROM Solution_Finder_Word_Association__mdt
                    WHERE Solution_Finder_Option__r.DeveloperName = : parentName
                    AND Solution_Finder_Buzz_Word__r.DeveloperName NOT IN : selectedNames
                    WITH SECURITY_ENFORCED
                    LIMIT 1000]) {
                listOfBuzzWords.add(new SolutionFinderBuzzWord(recommendation));
            }
        }
        listOfBuzzWords.sort();
        this.buzzWords.put('recommended', listOfBuzzWords);
    }

    /**
     * Existing recommendations that are not associated with the
     * parent record.
     */
    private void initOtherBuzzWords() {
        List<SolutionFinderBuzzWord> listOfBuzzWords = new List<SolutionFinderBuzzWord>();
        Set<String> selectedOrRecommendedNames = new Set<String>();
        for (SolutionFinderBuzzWord buzzWord : this.buzzWords.get('selected')) {
            selectedOrRecommendedNames.add(buzzWord.name);
        }
        for (SolutionFinderBuzzWord buzzWord : this.buzzWords.get('recommended')) {
            selectedOrRecommendedNames.add(buzzWord.name);
        }
        for (Solution_Finder_Buzz_Word__mdt buzzWord :
                [SELECT DeveloperName, MasterLabel, Title__c, Definition__c, More_Information_URL__c, Probability__c
                FROM Solution_Finder_Buzz_Word__mdt
                WHERE DeveloperName NOT IN : selectedOrRecommendedNames
                WITH SECURITY_ENFORCED
                LIMIT 1000]) {
            listOfBuzzWords.add(new SolutionFinderBuzzWord(buzzWord));
        }
        listOfBuzzWords.sort();
        this.buzzWords.put('other', listOfBuzzWords);
    }

    private void initDetails() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfDetails = getMapOfDetails();
        for (List<SolutionFinderBuzzWord> listOfBuzzWords : this.buzzWords.values()) {
            for (SolutionFinderBuzzWord buzzWord : listOfBuzzWords) {
                buzzWord.setDetails(mapOfDetails.get(buzzWord.name));
            }
        }
    }

    private Map<String, List<Solution_Finder_Detail__mdt>> getMapOfDetails() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfDetails = new Map<String, List<Solution_Finder_Detail__mdt>>();
        for (List<SolutionFinderBuzzWord> listOfBuzzWords : this.buzzWords.values()) {
            for (SolutionFinderBuzzWord buzzWord : listOfBuzzWords) {
                mapOfDetails.put(buzzWord.name, new List<Solution_Finder_Detail__mdt>());
            }
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

    @AuraEnabled
    public static SolutionFinderBuzzWords getBuzzWords(String name) {
        return new SolutionFinderBuzzWords(name);
    }
}