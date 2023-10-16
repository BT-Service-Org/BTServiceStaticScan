public with sharing class SolutionFinderConfigurations {

    @AuraEnabled
    public static List<SolutionFinderConfigurationGroup> getConfigurations(Id projectId, String cacheBuster){
        return SolutionFinderConfigurationGroup.getConfigurationGroups(projectId);
    }

    @AuraEnabled
    public static void saveConfiguration(Id projectId, String optionName, String solutionName, String properties){
        Solution_Finder_Configuration__c record = new Solution_Finder_Configuration__c();
        record.Name = solutionName;
        record.Solution_Finder_Project__c = projectId;
        record.Option_Name__c = optionName;
        record.Solution_Name__c = solutionName;
        record.Properties__c = properties;
        insert record;
    }

    @AuraEnabled
    public static void updateConfigurations(String updatesString){
        
        List<SolutionFinderConfigurationUpdate> updates = new List<SolutionFinderConfigurationUpdate>();
        try {
            updates = (List<SolutionFinderConfigurationUpdate>)JSON.deserialize(updatesString, List<SolutionFinderConfigurationUpdate>.class);
        } catch (Exception e) {
            System.debug('Error updating configurations: ' + e);
        }

        Map<Id, List<SolutionFinderConfigurationUpdate>> mapOfUpdates = new Map<Id, List<SolutionFinderConfigurationUpdate>>();
        List<SolutionFinderConfigurationUpdate> configurationUpdates;
        for (SolutionFinderConfigurationUpdate configurationUpdate : updates) {
            configurationUpdates = mapOfUpdates.get(configurationUpdate.id);
            if (configurationUpdates == null) {
                configurationUpdates = new List<SolutionFinderConfigurationUpdate>();
            }
            configurationUpdates.add(configurationUpdate);
            mapOfUpdates.put(configurationUpdate.id, configurationUpdates);
        }

        List<Solution_Finder_Configuration__c> records =
            [SELECT Id, Properties__c
             FROM Solution_Finder_Configuration__c
             WHERE Id IN : mapOfUpdates.keySet()
             WITH SECURITY_ENFORCED
             LIMIT 1000];

        for (Solution_Finder_Configuration__c record : records) {
            configurationUpdates = mapOfUpdates.get(record.Id);
            if (configurationUpdates != null) {
                Map<String, String> mapOfProperties;
                try {
                    mapOfProperties = (Map<String, String>)JSON.deserialize(record.Properties__c, Map<String, String>.class);
                } catch (Exception e) {
                    mapOfProperties = new Map<String, String>();
                }
                for (SolutionFinderConfigurationUpdate configurationUpdate : configurationUpdates) {
                    System.debug('configurationUpdate: ' + configurationUpdate);
                    if (configurationUpdate.name != null) {
                        System.debug('updating map');
                        mapOfProperties.put(configurationUpdate.name, configurationUpdate.value);
                    }
                }
                System.debug('updated properties: ' + mapOfProperties);
                record.Properties__c = JSON.serialize(mapOfProperties);
            }
        }
        System.debug(records);
        update records;
    }
}