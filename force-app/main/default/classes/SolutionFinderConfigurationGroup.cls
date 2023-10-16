public with sharing class SolutionFinderConfigurationGroup implements Comparable {
    
    @AuraEnabled public String optionName {get;set;}
    @AuraEnabled public String solutionName {get;set;}
    @AuraEnabled public String solutionTitle {get;set;}
    @AuraEnabled public List<SolutionFinderConfiguration> configurations {get;set;}

    public SolutionFinderConfigurationGroup(String optionName, String solutionName) {
        this.optionName = optionName;
        this.solutionName = solutionName;
        this.configurations = new List<SolutionFinderConfiguration>();
    }

    public void addConfiguration(SolutionFinderConfiguration configuration) {
        this.configurations.add(configuration);
    }

    public void enrich(Solution_Finder_Solution__mdt solution) {
        this.solutionTitle = solution.Title__c;
    }

    public Integer compareTo(Object otherObject) {
        Integer result = 0;
        SolutionFinderConfigurationGroup otherGroup = (SolutionFinderConfigurationGroup)otherObject;
        if (this.solutionTitle != null && otherGroup.solutionTitle != null) {
            result = this.solutionTitle.compareTo(otherGroup.solutionTitle);
        }
        return result;
    }

    public static List<SolutionFinderConfigurationGroup> getConfigurationGroups(Id projectId) {
        List<SolutionFinderConfiguration> configurations = getConfigurationObjects(projectId);
        Map<String, SolutionFinderConfigurationGroup> mapOfConfigurationGroups = groupMapOfConfigurations(configurations);
        mapOfConfigurationGroups = enrichConfigurations(mapOfConfigurationGroups);
        mapOfConfigurationGroups = enrichProperties(mapOfConfigurationGroups);
        List<SolutionFinderConfigurationGroup> configurationGroups = sortConfigurations(mapOfConfigurationGroups);
        return configurationGroups;
    }

    private static List<SolutionFinderConfiguration> getConfigurationObjects(Id projectId) {
        List<SolutionFinderConfiguration> configurations = new List<SolutionFinderConfiguration>();
        for (Solution_Finder_Configuration__c record :
                [SELECT Id, Option_Name__c, Solution_Name__c, Properties__c
                 FROM Solution_Finder_Configuration__c
                 WHERE Solution_Finder_Project__c = : projectId
                 WITH SECURITY_ENFORCED
                 ORDER BY CreatedDate ASC
                 LIMIT 10000]) {
            configurations.add(new SolutionFinderConfiguration(record));
        }
        return configurations;
    }

    private static Map<String, SolutionFinderConfigurationGroup> groupMapOfConfigurations(List<SolutionFinderConfiguration> configurations) {
        Map<String, SolutionFinderConfigurationGroup> mapOfGroups = new Map<String, SolutionFinderConfigurationGroup>();
        SolutionFinderConfigurationGroup configurationGroup;
        for (SolutionFinderConfiguration configuration : configurations) {
            if (!mapOfGroups.containsKey(configuration.solutionName)) {
                mapOfGroups.put(configuration.solutionName, new SolutionFinderConfigurationGroup(configuration.optionName, configuration.solutionName));
            }
            configurationGroup = mapOfGroups.get(configuration.solutionName);
            configurationGroup.addConfiguration(configuration);
            mapOfGroups.put(configuration.solutionName, configurationGroup);
        }
        return mapOfGroups;
    }

    private static Map<String, SolutionFinderConfigurationGroup> enrichConfigurations(Map<String, SolutionFinderConfigurationGroup> mapOfConfigurationGroups) {
        Set<String> solutionNames = mapOfConfigurationGroups.keySet();
        SolutionFinderConfigurationGroup configurationGroup;
        for (Solution_Finder_Solution__mdt solution :
                [SELECT Id, DeveloperName, Title__c
                FROM Solution_Finder_Solution__mdt
                WHERE DeveloperName IN : solutionNames
                WITH SECURITY_ENFORCED
                LIMIT 1000]) {
            configurationGroup = mapOfConfigurationGroups.get(solution.DeveloperName);
            if (configurationGroup != null) {
                configurationGroup.enrich(solution);
            }
        }
        return mapOfConfigurationGroups;
    }

    private static Map<String, SolutionFinderConfigurationGroup> enrichProperties(Map<String, SolutionFinderConfigurationGroup> mapOfConfigurationGroups) {
        Set<String> propertyNames = new Set<String>();
        Map<String, Object> properties;
        for (SolutionFinderConfigurationGroup configurationGroup : mapOfConfigurationGroups.values()) {
            for (SolutionFinderConfiguration configuration : configurationGroup.configurations) {
                if (configuration.properties != null) {
                    properties = (Map<String, Object>)JSON.deserializeUntyped(configuration.properties);
                    for (String key : properties.keySet()) {
                        propertyNames.add(key);
                    }
                }
            }
        }
        Map<String, Solution_Finder_Property__mdt> mapOfProperties = new Map<String, Solution_Finder_Property__mdt>();
        for (Solution_Finder_Property__mdt record :
                [SELECT Id, DeveloperName, MasterLabel, Title__c, Data_Type__c, Default_Value__c, Display_in_Preview__c
                FROM Solution_Finder_Property__mdt
                WHERE DeveloperName IN : propertyNames
                WITH SECURITY_ENFORCED
                ORDER BY Display_Order__c ASC
                LIMIT 1000]) {
                    mapOfProperties.put(record.DeveloperName, record);
        }
        SolutionFinderProperty property;
        for (SolutionFinderConfigurationGroup configurationGroup : mapOfConfigurationGroups.values()) {
            for (SolutionFinderConfiguration configuration : configurationGroup.configurations) {
                if (configuration.properties != null) {
                    properties = (Map<String, Object>)JSON.deserializeUntyped(configuration.properties);
                    for (String key : properties.keySet()) {
                        if (mapOfProperties.containsKey(key)) {
                            property = new SolutionFinderProperty(mapOfProperties.get(key));
                            configuration.addPropertyValue(
                                configuration.id,
                                properties.get(key),
                                property);
                        }
                    }
                }
            }
        }
        return mapOfConfigurationGroups;
    }

    private static List<SolutionFinderConfigurationGroup> sortConfigurations(Map<String, SolutionFinderConfigurationGroup> mapOfConfigurationGroups) {
        List<SolutionFinderConfigurationGroup> configurationGroups = mapOfConfigurationGroups.values();
        configurationGroups.sort();
        return configurationGroups;
    }
}