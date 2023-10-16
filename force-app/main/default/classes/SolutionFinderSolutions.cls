public with sharing class SolutionFinderSolutions {
    
    private String name;
    @AuraEnabled public Map<String, List<SolutionFinderSolution>> solutions {get;set;}

    public SolutionFinderSolutions(String name) {
        this.name = name;
        this.init();
    }

    private void init() {
        this.initSolutions();
    }

    private void initSolutions() {
        this.solutions = new Map<String, List<SolutionFinderSolution>>();
        this.initSelectedSolutions();
        this.initRecommendedSolutions();
        this.initOtherSolutions();
        this.initDetails();
        this.initProperties();
    }

    private void initSelectedSolutions() {
        List<SolutionFinderSolution> listOfSolutions = new List<SolutionFinderSolution>();
        for (Solution_Finder_Recommendation__mdt record :
                [SELECT Id, DeveloperName, Solution_Finder_Solution__r.DeveloperName, Solution_Finder_Solution__r.MasterLabel,
                    Solution_Finder_Solution__r.Title__c, Solution_Finder_Solution__r.Description__c,
                    Solution_Finder_Solution__r.Export_Note__c
                 FROM Solution_Finder_Recommendation__mdt
                 WHERE Solution_Finder_Option__r.DeveloperName = : this.name
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            listOfSolutions.add(new SolutionFinderSolution(record));
        }
        listOfSolutions.sort();
        this.solutions.put('selected', listOfSolutions);
    }

    /**
     * Match the recommendations from the parent record (if applicable)
     */
    private void initRecommendedSolutions() {
        List<SolutionFinderSolution> listOfSolutions = new List<SolutionFinderSolution>();
        Set<String> selectedNames = new Set<String>();
        for (SolutionFinderSolution solution : this.solutions.get('selected')) {
            selectedNames.add(solution.name);
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
            for (Solution_Finder_Recommendation__mdt recommendation :
                    [SELECT Id, DeveloperName, Solution_Finder_Solution__r.DeveloperName, Solution_Finder_Solution__r.MasterLabel,
                        Solution_Finder_Solution__r.Title__c, Solution_Finder_Solution__r.Description__c, Solution_Finder_Solution__r.Export_Note__c
                    FROM Solution_Finder_Recommendation__mdt
                    WHERE Solution_Finder_Option__r.DeveloperName = : parentName
                    AND Solution_Finder_Solution__r.DeveloperName NOT IN : selectedNames
                    WITH SECURITY_ENFORCED
                    LIMIT 1000]) {
                listOfSolutions.add(new SolutionFinderSolution(recommendation));
            }
        }
        listOfSolutions.sort();
        this.solutions.put('recommended', listOfSolutions);
    }

    /**
     * Existing recommendations that are not associated with the
     * parent record.
     */
    private void initOtherSolutions() {
        List<SolutionFinderSolution> listOfSolutions = new List<SolutionFinderSolution>();
        Set<String> selectedOrRecommendedNames = new Set<String>();
        for (SolutionFinderSolution solution : this.solutions.get('selected')) {
            selectedOrRecommendedNames.add(solution.name);
        }
        for (SolutionFinderSolution solution : this.solutions.get('recommended')) {
            selectedOrRecommendedNames.add(solution.name);
        }
        for (Solution_Finder_Solution__mdt recommendation :
                [SELECT DeveloperName, MasterLabel, Title__c, Description__c, Export_Note__c
                FROM Solution_Finder_Solution__mdt
                WHERE DeveloperName NOT IN : selectedOrRecommendedNames
                WITH SECURITY_ENFORCED
                LIMIT 1000]) {
            listOfSolutions.add(new SolutionFinderSolution(recommendation));
        }
        listOfSolutions.sort();
        this.solutions.put('other', listOfSolutions);
    }

    private void initDetails() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfConsiderations = this.getMapOfConsiderations();
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfLimitations = this.getMapOfLimitations();
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfStories = this.getMapOfStories();
        for (List<SolutionFinderSolution> listOfSolutions : this.solutions.values()) {
            for (SolutionFinderSolution solution : listOfSolutions) {
                solution.setConsiderations(mapOfConsiderations.get(solution.name));
                solution.setLimitations(mapOfLimitations.get(solution.name));
                solution.setStories(mapOfStories.get(solution.name));
            }
        }
    }

    private Map<String, List<Solution_Finder_Detail__mdt>> getMapOfConsiderations() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfConsiderations = new Map<String, List<Solution_Finder_Detail__mdt>>();
        for (List<SolutionFinderSolution> listOfSolutions : this.solutions.values()) {
            for (SolutionFinderSolution solution : listOfSolutions) {
                mapOfConsiderations.put(solution.name, new List<Solution_Finder_Detail__mdt>());    
            }
        }
        Set<String> solutionNames = mapOfConsiderations.keySet();
        List<Solution_Finder_Detail__mdt> records;
        for (Solution_Finder_Detail__mdt detail :
                [SELECT Id, DeveloperName, Solution_Finder_Solution__r.DeveloperName, Label__c, URL__c
                 FROM Solution_Finder_Detail__mdt
                 WHERE Solution_Finder_Solution__r.DeveloperName IN : solutionNames
                 AND Type__c = 'Consideration'
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            records = mapOfConsiderations.get(detail.Solution_Finder_Solution__r.DeveloperName);
            if (records != null) {
                records.add(detail);
            }
        }
        return mapOfConsiderations;
    }

    private Map<String, List<Solution_Finder_Detail__mdt>> getMapOfLimitations() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfLimitations = new Map<String, List<Solution_Finder_Detail__mdt>>();
        for (List<SolutionFinderSolution> listOfSolutions : this.solutions.values()) {
            for (SolutionFinderSolution solution : listOfSolutions) {
                mapOfLimitations.put(solution.name, new List<Solution_Finder_Detail__mdt>());    
            }
        }
        Set<String> solutionNames = mapOfLimitations.keySet();
        List<Solution_Finder_Detail__mdt> records;
        for (Solution_Finder_Detail__mdt detail :
                [SELECT Id, DeveloperName, Solution_Finder_Solution__r.DeveloperName, Label__c, URL__c
                 FROM Solution_Finder_Detail__mdt
                 WHERE Solution_Finder_Solution__r.DeveloperName IN : solutionNames
                 AND Type__c = 'Limitation'
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            records = mapOfLimitations.get(detail.Solution_Finder_Solution__r.DeveloperName);
            if (records != null) {
                records.add(detail);
            }
        }
        return mapOfLimitations;
    }

    private Map<String, List<Solution_Finder_Detail__mdt>> getMapOfStories() {
        Map<String, List<Solution_Finder_Detail__mdt>> mapOfStories = new Map<String, List<Solution_Finder_Detail__mdt>>();
        for (List<SolutionFinderSolution> listOfSolutions : this.solutions.values()) {
            for (SolutionFinderSolution solution : listOfSolutions) {
                mapOfStories.put(solution.name, new List<Solution_Finder_Detail__mdt>());    
            }
        }
        Set<String> solutionNames = mapOfStories.keySet();
        List<Solution_Finder_Detail__mdt> records;
        for (Solution_Finder_Detail__mdt detail :
                [SELECT Id, DeveloperName, Solution_Finder_Solution__r.DeveloperName, Label__c, URL__c
                 FROM Solution_Finder_Detail__mdt
                 WHERE Solution_Finder_Solution__r.DeveloperName IN : solutionNames
                 AND Type__c = 'Story'
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            records = mapOfStories.get(detail.Solution_Finder_Solution__r.DeveloperName);
            if (records != null) {
                records.add(detail);
            }
        }
        return mapOfStories;
    }

    private void initProperties() {
        Map<String, List<Solution_Finder_Property__mdt>> mapOfProperties = this.getMapOfProperties();
        for (List<SolutionFinderSolution> listOfSolutions : this.solutions.values()) {
            for (SolutionFinderSolution solution : listOfSolutions) {
                solution.setProperties(mapOfProperties.get(solution.name));
            }
        }
    }

    private Map<String, List<Solution_Finder_Property__mdt>> getMapOfProperties() {
        Map<String, List<Solution_Finder_Property__mdt>> mapOfProperties = new Map<String, List<Solution_Finder_Property__mdt>>();
        for (List<SolutionFinderSolution> listOfSolutions : this.solutions.values()) {
            for (SolutionFinderSolution solution : listOfSolutions) {
                mapOfProperties.put(solution.name, new List<Solution_Finder_Property__mdt>());    
            }
        }
        Set<String> solutionNames = mapOfProperties.keySet();
        List<Solution_Finder_Property__mdt> records;
        for (Solution_Finder_Property__mdt detail :
                [SELECT Id, DeveloperName, MasterLabel, Title__c, Solution_Finder_Solution__r.DeveloperName, Data_Type__c,
                    Default_Value__c, Display_Order__c, Display_in_Preview__c
                 FROM Solution_Finder_Property__mdt
                 WHERE Solution_Finder_Solution__r.DeveloperName IN : solutionNames
                 WITH SECURITY_ENFORCED
                 ORDER BY Display_Order__c, MasterLabel
                 LIMIT 1000]) {
            records = mapOfProperties.get(detail.Solution_Finder_Solution__r.DeveloperName);
            if (records != null) {
                records.add(detail);
            }
        }
        return mapOfProperties;
    }

    @AuraEnabled
    public static SolutionFinderSolutions getSolutions(String name) {
        return new SolutionFinderSolutions(name);
    }
}