public with sharing class SolutionFinderAssignment {
    
    @AuraEnabled public String userId {get;set;}
    @AuraEnabled public String optionName {get;set;}
    @AuraEnabled public String role {get;set;}

    /*
     * To be used if we want metadata rather than data assignments
     * 
    public SolutionFinderAssignment(Solution_Finder_Assignment__mdt record) {
        this.userId = record.User_Id__c;
        this.optionName = record.Option_Name__c;
        this.role = record.Role__c;
    }
    */

    public SolutionFinderAssignment(Solution_Finder_Permission__c record) {
        this.userId = record.OwnerId;
        this.optionName = record.Option_Name__c;
        this.role = record.Role__c;
    }

    @AuraEnabled
    public static void saveAssignment(String userId, String optionName, String role){

        // Delete existing assignments
        List<Solution_Finder_Permission__c> existingPermissions =
            [SELECT Id
            FROM Solution_Finder_Permission__c
            WHERE OwnerId =: userId
            AND Option_Name__c =: optionName
            WITH SECURITY_ENFORCED
            LIMIT 100];
        delete existingPermissions;

        // If any role other than no access is requested create the proper record.
        if (role != 'No Access') {
            String name = userId + '-' + optionName;
            name = name.length() > 40 ? name.substring(0, 40) : name;
            name = name.removeEnd('_');

            Solution_Finder_Permission__c record = new Solution_Finder_Permission__c();
            record.OwnerId = userId;
            record.Option_Name__c = optionName;
            record.Role__c = role;
            insert record;
        }
        /*
         * To be used if we want metadata rather than data assignments
         *
        String masterLabel = userId + '-' + optionName;
        masterLabel = masterLabel.length() > 40 ? masterLabel.substring(0, 40) : masterLabel;

        String name = masterLabel.replace('@salesforce.com', '').replace('-', '_').replace('@', '_').replace('.', '_');
        name = name.length() > 40 ? name.substring(0, 40) : name;
        name = name.removeEnd('_');

        // Null values to remove access
        if (role == 'No Access') {
            userId = null;
            optionName = null;
            role = null;
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Assignment__mdt', name, masterLabel);
        request.addProperty('User_Id__c', userId);
        request.addProperty('Option_Name__c', optionName);
        request.addProperty('Role__c', role);
        return request.execute();
        */
    }
}