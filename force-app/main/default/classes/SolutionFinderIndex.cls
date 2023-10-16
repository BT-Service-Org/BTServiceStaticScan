public with sharing class SolutionFinderIndex {

    public static String getNextName(String type) {
        Decimal nextIndex = getNextIndex(type, 1);
        return type + nextIndex;
    }

    public static Decimal getNextIndex(String type, Integer quantity) {

        Decimal currentIndex = -1;
        List<Solution_Finder_Index__mdt> records =
            [SELECT Id, Index__c
             FROM Solution_Finder_Index__mdt
             WHERE DeveloperName = : type
             WITH SECURITY_ENFORCED
             LIMIT 1];
        if (records.size() == 1) {
            currentIndex = records[0].Index__c;
        }
        Decimal nextIndex = currentIndex + 1;
        saveNextIndex(type, currentIndex + quantity);
        return Integer.valueOf(nextIndex);
    }

    private static void saveNextIndex(String type, Decimal index) {

        if (type == null || index == null) {
            return;
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Index__mdt', type, type);
        request.addProperty('Index__c', index);
        request.execute();
    }
}