public with sharing class SolutionFinderSolution implements Comparable {

    @AuraEnabled public String recommendationName {get;set;}
    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String label {get;set;}
    @AuraEnabled public String description {get;set;}
    @AuraEnabled public String exportNote {get;set;}
    @AuraEnabled public List<SolutionFinderDetail> considerations {get;set;}
    @AuraEnabled public List<SolutionFinderDetail> limitations {get;set;}
    @AuraEnabled public List<SolutionFinderDetail> stories {get;set;}
    @AuraEnabled public List<SolutionFinderProperty> properties {get;set;}

    public SolutionFinderSolution() {}

    public SolutionFinderSolution(Solution_Finder_Solution__mdt record) {
        this.name = record.DeveloperName;
        this.label = record.Title__c;
        this.description = record.Description__c;
        this.exportNote = record.Export_Note__c;
        this.considerations = new List<SolutionFinderDetail>();
        this.limitations = new List<SolutionFinderDetail>();
        this.stories = new List<SolutionFinderDetail>();
        this.properties = new List<SolutionFinderProperty>();
    }

    public SolutionFinderSolution(Solution_Finder_Recommendation__mdt record) {
        this.recommendationName = record.DeveloperName;
        this.name = record.Solution_Finder_Solution__r.DeveloperName;
        this.label = record.Solution_Finder_Solution__r.Title__c;
        this.description = record.Solution_Finder_Solution__r.Description__c;
        this.exportNote = record.Solution_Finder_Solution__r.Export_Note__c;
        this.considerations = new List<SolutionFinderDetail>();
        this.limitations = new List<SolutionFinderDetail>();
        this.stories = new List<SolutionFinderDetail>();
        this.properties = new List<SolutionFinderProperty>();
    }

    public void setConsiderations(List<Solution_Finder_Detail__mdt> detailRecords) {
        for (Solution_Finder_Detail__mdt detailRecord : detailRecords) {
            this.considerations.add(new SolutionFinderDetail(detailRecord));
        }
    }

    public void setLimitations(List<Solution_Finder_Detail__mdt> detailRecords) {
        for (Solution_Finder_Detail__mdt detailRecord : detailRecords) {
            this.limitations.add(new SolutionFinderDetail(detailRecord));
        }
    }

    public void setStories(List<Solution_Finder_Detail__mdt> detailRecords) {
        for (Solution_Finder_Detail__mdt detailRecord : detailRecords) {
            this.stories.add(new SolutionFinderDetail(detailRecord));
        }
    }

    public void setProperties(List<Solution_Finder_Property__mdt> propertyRecords) {
        for (Solution_Finder_Property__mdt propertyRecord : propertyRecords) {
            this.properties.add(new SolutionFinderProperty(propertyRecord));
        }
    }

    @AuraEnabled
    public static Id saveSolution(String namespace, String name, String label, String description, String exportNote, String considerations, String limitations, String stories, String optionName) {

        String masterLabel;
        if (label == null) {
            return null;
        } else {
            masterLabel = label.length() > 40 ? label.substring(0, 40) : label;
        }

        Boolean isNew;
        if (name == null) {
            isNew = true;
            name = namespace + '_' + SolutionFinderIndex.getNextName(SolutionFinderConstants.SOLUTION_INDEX_NAME);
        } else {
            isNew = false;
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Solution__mdt', name, masterLabel);
        request.addProperty('Namespace__c', namespace);
        request.addProperty('Title__c', label);
        request.addProperty('Description__c', description);
        request.addProperty('Export_Note__c', exportNote);
        request.stage();

        saveDetails(request, namespace, name, considerations, 'Consideration');
        saveDetails(request, namespace, name, limitations, 'Limitation');
        saveDetails(request, namespace, name, stories, 'Story');

        // Recommend the new solution for the current option
        if (optionName != null && isNew) {
            String recoName = namespace + '_' + SolutionFinderIndex.getNextName(SolutionFinderConstants.RECOMMENDATION_INDEX_NAME);
            String recoLabel = optionName + '_' + name;
            request.init('Solution_Finder_Recommendation__mdt', recoName, recoLabel);
            request.addProperty('Solution_Finder_Option__c', optionName);
            request.addProperty('Solution_Finder_Solution__c', name);
            request.stage();
        }

        return request.execute();
    }

    private static void saveDetails(MetadataRequest request, String namespace, String solutionName, String records, String type) {
        System.debug('saving records: ' + records);

        List<SolutionFinderDetail> detailRecords = new List<SolutionFinderDetail>();
        try {
            detailRecords = (List<SolutionFinderDetail>)JSON.deserialize(records, List<SolutionFinderDetail>.class);
        } catch (Exception e) {
            System.debug('Error deserializing details: ' + e.getMessage());
        }

        // Save considerations
        String detailName;
        if (detailRecords.size() > 0) {

            // Count the number of new detail records
            Integer newDetailsCount = 0;
            for (Integer i = 0; i < detailRecords.size(); i++) {
                SolutionFinderDetail detailRecord = detailRecords[i];
                if (String.isEmpty(detailRecord.name)) {
                    newDetailsCount++;
                }
            }

            Decimal index = 0;
            if (newDetailsCount > 0) {
                index = SolutionFinderIndex.getNextIndex(SolutionFinderConstants.DETAIL_INDEX_NAME, newDetailsCount);
            }
            for (Integer i = 0; i < detailRecords.size(); i++) {
                SolutionFinderDetail detailRecord = detailRecords[i];
                
                if (String.isNotEmpty(detailRecord.name)) {
                    detailName = detailRecord.name;
                } else {
                    detailName = namespace + '_' + SolutionFinderConstants.DETAIL_INDEX_NAME + index;
                    index++;
                }

                request.init('Solution_Finder_Detail__mdt', detailName, detailRecord.getMasterLabel());
                request.addProperty('Solution_Finder_Solution__c', solutionName);
                request.addProperty('Label__c', detailRecord.Label);
                request.addProperty('URL__c', detailRecord.url);
                request.addProperty('Type__c', type);
                request.stage();
            }
        }

        // Delete any related details no longer included in the payload
        deleteDetails(request, solutionName, detailRecords, type);
    }

    private static void deleteDetails(MetadataRequest request, String solutionName, List<SolutionFinderDetail> detailRecords, String type) {
        
        Set<String> detailNames = new Set<String>();
        for (Integer i = 0; i < detailRecords.size(); i++) {
            SolutionFinderDetail detailRecord = detailRecords[i];
            detailNames.add(detailRecord.name);
        }

        for (Solution_Finder_Detail__mdt detailRecord :
                [SELECT Id, DeveloperName, MasterLabel
                FROM Solution_Finder_Detail__mdt
                WHERE Solution_Finder_Solution__r.DeveloperName =: solutionName
                AND Type__c = : type
                AND DeveloperName NOT IN: detailNames
                WITH SECURITY_ENFORCED
                LIMIT 1000]) {
            request.init('Solution_Finder_Detail__mdt', detailRecord.DeveloperName, 'DELETED');
            request.addProperty('Solution_Finder_Solution__c', null);
            request.addProperty('Label__c', null);
            request.addProperty('URL__c', null);
            request.stage();
        }
    }

    public Integer compareTo(Object otherRecord) {
        SolutionFinderSolution otherSolution = (SolutionFinderSolution)otherRecord;
        return this.label.compareTo(otherSolution.label);
    }
}