public with sharing class SolutionFinderBuzzWord implements Comparable {

    @AuraEnabled public String wordAssociationName {get;set;}
    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String label {get;set;}
    @AuraEnabled public String definition {get;set;}
    @AuraEnabled public String url {get;set;}
    @AuraEnabled public String probability {get;set;}
    @AuraEnabled public List<SolutionFinderDetail> details {get;set;}

    public SolutionFinderBuzzWord() {}

    public SolutionFinderBuzzWord(Solution_Finder_Buzz_Word__mdt record) {
        this.name = record.DeveloperName;
        this.label = record.Title__c;
        this.definition = record.Definition__c;
        this.url = record.More_Information_URL__c;
        this.probability = record.Probability__c;
        this.details = new List<SolutionFinderDetail>();
    }

    public SolutionFinderBuzzWord(Solution_Finder_Word_Association__mdt record) {
        this.wordAssociationName = record.DeveloperName;
        this.name = record.Solution_Finder_Buzz_Word__r.DeveloperName;
        this.label = record.Solution_Finder_Buzz_Word__r.Title__c;
        this.definition = record.Solution_Finder_Buzz_Word__r.Definition__c;
        this.url = record.Solution_Finder_Buzz_Word__r.More_Information_URL__c;
        this.probability = record.Solution_Finder_Buzz_Word__r.Probability__c;
        this.details = new List<SolutionFinderDetail>();
    }

    public void setDetails(List<Solution_Finder_Detail__mdt> detailRecords) {
        for (Solution_Finder_Detail__mdt detailRecord : detailRecords) {
            this.details.add(new SolutionFinderDetail(detailRecord));
        }
    }

    @AuraEnabled
    public static Id saveBuzzWord(String namespace, String name, String label, String definition, String url, String probability, String optionName, String details) {

        List<SolutionFinderDetail> detailRecords = new List<SolutionFinderDetail>();
        try {
            detailRecords = (List<SolutionFinderDetail>)JSON.deserialize(details, List<SolutionFinderDetail>.class);
        } catch (Exception e) {
            System.debug('Error deserializing details: ' + e.getMessage());
        }

        String masterLabel;
        if (label == null) {
            return null;
        } else {
            masterLabel = label.length() > 40 ? label.substring(0, 40) : label;
        }

        Boolean isNewRecord;

        if (name == null) {
            isNewRecord = true;
            name = namespace + '_' + SolutionFinderIndex.getNextName(SolutionFinderConstants.BUZZ_WORD_INDEX_NAME);
        } else {
            isNewRecord = false;
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Buzz_Word__mdt', name, masterLabel);
        request.addProperty('Namespace__c', namespace);
        request.addProperty('Title__c', label);
        request.addProperty('Definition__c', definition);
        request.addProperty('More_Information_URL__c', url);
        request.addProperty('Probability__c', probability);
        request.stage();

        // Save details
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
                request.addProperty('Solution_Finder_Buzz_Word__c', name);
                request.addProperty('Label__c', detailRecord.Label);
                request.addProperty('URL__c', detailRecord.url);
                request.stage();
            }
        }

        // Delete any related details no longer included in the payload
        Set<String> detailNames = new Set<String>();
        for (Integer i = 0; i < detailRecords.size(); i++) {
            SolutionFinderDetail detailRecord = detailRecords[i];
            detailNames.add(detailRecord.name);
        }
        for (Solution_Finder_Detail__mdt detailRecord :
                [SELECT Id, DeveloperName, MasterLabel
                FROM Solution_Finder_Detail__mdt
                WHERE Solution_Finder_Buzz_Word__r.DeveloperName =: name
                AND DeveloperName NOT IN: detailNames
                WITH SECURITY_ENFORCED
                LIMIT 1000]) {
            request.init('Solution_Finder_Detail__mdt', detailRecord.DeveloperName, 'DELETED');
            request.addProperty('Solution_Finder_Buzz_Word__c', null);
            request.stage();
        }

        // Recommend the new solution for the current option
        if (optionName != null && isNewRecord) {
            String recoName = namespace + '_' + SolutionFinderIndex.getNextName(SolutionFinderConstants.WORD_ASSOCIATION_INDEX_NAME);
            String recoLabel = optionName + '_' + name;
            request.init('Solution_Finder_Word_Association__mdt', recoName, recoLabel);
            request.addProperty('Solution_Finder_Option__c', optionName);
            request.addProperty('Solution_Finder_Buzz_Word__c', name);
            request.stage();
        }

        return request.execute();
    }

    public Integer compareTo(Object otherObject) {
        SolutionFinderBuzzWord otherRecord = (SolutionFinderBuzzWord)otherObject;
        if (this.label == null || otherRecord.label == null) {
            return 0;
        } else {
            return this.label.compareTo(otherRecord.label);
        }
    }
}