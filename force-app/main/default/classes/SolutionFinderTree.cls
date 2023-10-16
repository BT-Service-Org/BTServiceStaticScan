public with sharing class SolutionFinderTree {
    
    private String name;
    private Map<String, List<Solution_Finder_Option__mdt>> mapOfRecords {get;set;}

    @AuraEnabled public String title {get;set;}
    @AuraEnabled public String description {get;set;}
    @AuraEnabled public String nextQuestion {get;set;}
    @AuraEnabled public List<Item> items {get;set;}

    public class Item {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String metatext {get;set;}
        @AuraEnabled public String nextQuestion {get;set;}
        @AuraEnabled public Boolean expanded {get;set;}
        @AuraEnabled public List<Item> items {get;set;}

        public Item(Solution_Finder_Option__mdt record, Map<String, List<Solution_Finder_Option__mdt>> mapOfRecords) {
            this.name = record.DeveloperName;
            this.label = record.MasterLabel;
            this.metatext = record.Description__c;
            this.nextQuestion = record.Next_Question__c;
            this.expanded = true;
            this.initItems(mapOfRecords);
        }

        private void initItems(Map<String, List<Solution_Finder_Option__mdt>> mapOfRecords) {
            this.items = new List<Item>();
            if (mapOfRecords.containsKey(this.name)) {
                for (Solution_Finder_Option__mdt record : mapOfRecords.get(this.name)) {
                    this.items.add(new Item(record, mapOfRecords));
                }
            }
        }
    }

    public SolutionFinderTree(String name) {
        this.name = name;
        this.init();
    }

    private void init() {
        this.initRecord();
        this.initRecords();
        this.createTree();
    }

    private void initRecord() {
        List<Solution_Finder_Option__mdt> records =
            [SELECT DeveloperName, MasterLabel, Description__c, Next_Question__c
             FROM Solution_Finder_Option__mdt
             WHERE DeveloperName = : this.name
             WITH SECURITY_ENFORCED
             LIMIT 1];
        if (records.size() > 0) {
            Solution_Finder_Option__mdt record = records[0];
            this.name = record.DeveloperName;
            this.title = record.MasterLabel;
            this.description = record.Description__c;
            this.nextQuestion = record.Next_Question__c;
        }
    }

    private void initRecords() {
        this.mapOfRecords = new Map<String, List<Solution_Finder_Option__mdt>>();
        List<Solution_Finder_Option__mdt> records;

        for (Solution_Finder_Option__mdt record :
                [SELECT Parent_Name__c, DeveloperName, MasterLabel, Description__c, Next_Question__c
                 FROM Solution_Finder_Option__mdt
                 WITH SECURITY_ENFORCED
                 ORDER BY Parent_Name__c, MasterLabel
                 LIMIT 10000]) {
            records = this.mapOfRecords.get(record.Parent_Name__c);
            if (records == null) {
                records = new List<Solution_Finder_Option__mdt>();
            }
            records.add(record);
            this.mapOfRecords.put(record.Parent_Name__c, records);
        }
    }

    private void createTree() {
        this.items = new List<Item>();
        if (this.mapOfRecords.containsKey(this.name)) {
            for (Solution_Finder_Option__mdt record : this.mapOfRecords.get(this.name)) {
                this.items.add(new Item(record, this.mapOfRecords));
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static SolutionFinderTree getTree(String name) {
        return new SolutionFinderTree(name);
    }
}