public with sharing class SolutionFinderComparison {

    private String namespace;
    private String name;
    @AuraEnabled public SolutionFinderContext context {get;set;}
    private Set<String> solutionNames;
    @AuraEnabled public Map<String, Object> mapOfValues {get;set;}
    private Set<String> propertiesFound;
    @AuraEnabled public List<SolutionFinderComparisonProperty> properties {get;set;}
    private Boolean includeAllProperties;

    public class Change {
        private String solutionName;
        private String propertyName;
        private String propertyDataType;
        private String value;

        public Change(String solutionName, String propertyName, String propertyDataType, String value) {
            this.solutionName = solutionName;
            this.propertyName = propertyName;
            this.propertyDataType = propertyDataType;
            this.value = value;
        }

        public String getName() {
            System.debug('value: ' + this.value);
            String name = propertyName + '_' + solutionName;
            if (name.length() > 80) {
                name = name.substring(0, 80);
            }
            return name;
        }

        public String getLabel() {
            String label = propertyName + ' - ' + solutionName;
            if (label.length() > 80) {
                label = label.substring(0, 80);
            }
            return label;
        }

        public String getPropertyName() {
            return this.value == 'REMOVED' ? null : this.propertyName;
        }

        public String getSolutionName() {
            return this.value == 'REMOVED' ? null : this.solutionName;
        }

        public String getTextValue() {
            return this.propertyDataType == 'Text' ? value : null;
        }

        public Decimal getNumberValue() {
            return this.propertyDataType == 'Number' && !String.isBlank(this.value) ? Decimal.valueOf(value) : null;
        }

        public Boolean getBooleanValue() {
            return this.propertyDataType == 'Boolean' ? Boolean.valueOf(value) : false;
        }
    }

    public SolutionFinderComparison(String namespace, String name, Boolean includeAllProperties) {
        this.namespace = namespace;
        this.name = name;
        this.includeAllProperties = includeAllProperties;
        this.init();
    }

    public SolutionFinderComparison(String namespace, String name) {
        this(namespace, name, false);
    }

    private void init() {
        this.context = SolutionFinderContext.getContext(this.namespace, this.name, null);
        this.initSolutions();
        this.initMapOfValues();
        this.initProperties();
        this.populateEmptyValues();
    }

    private void initSolutions() {
        this.solutionNames = new Set<String>();
        for (SolutionFinderRecommendation recommendation : this.context.recommendations) {
            this.solutionNames.add(recommendation.solutionName);
        }
    }

    private void initMapOfValues() {
        String key;
        this.mapOfValues = new Map<String, Object>();
        this.propertiesFound = new Set<String>();
        for (Solution_Finder_Comparison_Value__mdt value :
                [SELECT Id, Solution_Finder_Comparison_Property__r.DeveloperName, Solution_Finder_Comparison_Property__r.Data_Type__c,
                    Solution_Finder_Solution__r.DeveloperName, Text_Value__c, Number_Value__c, Boolean_Value__c
                 FROM Solution_Finder_Comparison_Value__mdt
                 WHERE Solution_Finder_Solution__r.DeveloperName IN : this.solutionNames
                 WITH SECURITY_ENFORCED
                 LIMIT 1000]) {
            key = value.Solution_Finder_Solution__r.DeveloperName + '.' + value.Solution_Finder_Comparison_Property__r.DeveloperName;
            if (value.Solution_Finder_Comparison_Property__r.Data_Type__c == 'Text' && value.Text_Value__c != null) {
                this.mapOfValues.put(key, value.Text_Value__c);
                this.propertiesFound.add(value.Solution_Finder_Comparison_Property__r.DeveloperName);
            } else if (value.Solution_Finder_Comparison_Property__r.Data_Type__c == 'Number' && value.Number_Value__c != null) {
                this.mapOfValues.put(key, value.Number_Value__c);
                this.propertiesFound.add(value.Solution_Finder_Comparison_Property__r.DeveloperName);
            } else if (value.Solution_Finder_Comparison_Property__r.Data_Type__c == 'Boolean') {
                this.mapOfValues.put(key, value.Boolean_Value__c == true);
                this.propertiesFound.add(value.Solution_Finder_Comparison_Property__r.DeveloperName);
            }
        }
    }

    private void initProperties() {
        this.properties =  new List<SolutionFinderComparisonProperty>();
        for (Solution_Finder_Comparison_Property__mdt record : getPropertyRecords()) {
            this.properties.add(new SolutionFinderComparisonProperty(record));
        }
    }

    private List<Solution_Finder_Comparison_Property__mdt> getPropertyRecords() {
        List<Solution_Finder_Comparison_Property__mdt> records;
        if (!this.includeAllProperties) {
            if (this.propertiesFound != null) {
                records = [SELECT Id, DeveloperName, MasterLabel, Title__c, Data_Type__c, Decimal_Places__c
                            FROM Solution_Finder_Comparison_Property__mdt
                            WHERE DeveloperName IN : this.propertiesFound
                            WITH SECURITY_ENFORCED
                            ORDER BY MasterLabel ASC
                            LIMIT 1000];
            }
        } else {
            records = [SELECT Id, DeveloperName, MasterLabel, Title__c, Data_Type__c, Decimal_Places__c
                        FROM Solution_Finder_Comparison_Property__mdt
                        WITH SECURITY_ENFORCED
                        ORDER BY MasterLabel ASC
                        LIMIT 1000];
        }
        return records;
    }

    private void populateEmptyValues() {
        if (this.context != null && this.properties != null) {
            String key;
            for (SolutionFinderRecommendation recommendation : this.context.recommendations) {
                for (SolutionFinderComparisonProperty property : this.properties) {
                    key = recommendation.solutionName + '.' + property.name;
                    if (!this.mapOfValues.containsKey(key)) {
                        this.mapOfValues.put(key, '');
                    }
                }
            }
        }
    }

    @AuraEnabled
    public static SolutionFinderComparison getComparison(String namespace, String name){
        return new SolutionFinderComparison(namespace, name, true);
    }

    @AuraEnabled
    public static void saveComparison(String changeValues){
        try {
            List<Change> changes = (List<Change>)JSON.deserialize(changeValues, List<Change>.class);
            commitChanges(changes);
        } catch (Exception e) {
            System.debug('Error deserializing changes: ' + e);
        }
    }

    private static void commitChanges(List<Change> changes) {
        MetadataRequest request = new MetadataRequest();
        for (Change change : changes) {
            request.init('Solution_Finder_Comparison_Value__mdt', change.getName(), change.getLabel());
            request.addProperty('Solution_Finder_Comparison_Property__c', change.getPropertyName());
            request.addProperty('Solution_Finder_Solution__c', change.getSolutionName());
            request.addProperty('Text_Value__c', change.getTextValue());
            request.addProperty('Number_Value__c', change.getNumberValue());
            request.addProperty('Boolean_Value__c', change.getBooleanValue());
            request.stage();
        }
        request.execute();
    }
}