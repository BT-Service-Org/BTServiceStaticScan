public with sharing class SolutionFinderWordAssociation {

    @AuraEnabled
    public static Id saveWordAssociation(String namespace, String name, String optionName, String buzzWordName) {

        if (optionName == null || buzzWordName == null) {
            return null;
        }

        String label = optionName + '_' + buzzWordName;
        if (name == null) {
            name = namespace + '_' + SolutionFinderIndex.getNextName(SolutionFinderConstants.WORD_ASSOCIATION_INDEX_NAME);
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Word_Association__mdt', name, label);
        request.addProperty('Namespace__c', namespace);
        request.addProperty('Solution_Finder_Option__c', optionName);
        request.addProperty('Solution_Finder_Buzz_Word__c', buzzWordName);
        return request.execute();
    }

    @AuraEnabled
    public static Id deleteWordAssociation(String name) {

        if (name == null) {
            return null;
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Word_Association__mdt', name, 'DELETED');
        request.addProperty('Solution_Finder_Option__c', null);
        request.addProperty('Solution_Finder_Buzz_Word__c', null);
        return request.execute();
    }
}