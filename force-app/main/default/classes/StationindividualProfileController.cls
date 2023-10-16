public class StationindividualProfileController {
    @AuraEnabled
    public static User connectedUser(){
        Id userId = UserInfo.getUserId();
        return [select Username, Name ,Phone, CompanyName, MediumPhotoUrl, Title, Department From User Where Id = :userId];
    }
    
    @AuraEnabled
    public static List <CaseSIWrapper> fetchCases(String recType, String contentType, Boolean togglecase) {
        List<CaseSIWrapper> wrappedList = new List<CaseSIWrapper>();

        List<Case> caseList = new List<Case>();
        Id userId = UserInfo.getUserId();

        User u = [SELECT Id, Name, Email FROM User WHERE Id = :userId];
        Org62_User__x org62User = [SELECT ExternalId, Id, Name__c, Email__c FROM Org62_User__x WHERE Email__c = :u.Email AND Name__c = :u.Name LIMIT 1];

        if (togglecase == true){
            if(recType  == 'The Station Content Request'){
                caseList = Database.query('SELECT CaseNumber, Description, Station_Product__c,Station_Product__r.Id,Station_Product__r.Name, Subject, Priority, Type, CreatedDate, Status, TheStation_Request_Type__c, TheStation_Asset_Type__c FROM Case Where ownerId =:userId AND RecordType.Name = \''+recType+'\' ORDER BY CreatedDate DESC');
            } else {
                caseList = Database.query('SELECT CaseNumber, Description, Station_Product__c,Station_Product__r.Id,Station_Product__r.Name, Subject, Priority, Type, CreatedDate, Status FROM Case Where ownerId =:userId AND RecordType.Name = \''+recType+'\' ORDER BY CreatedDate DESC'  );
            }
            
        }
        else{
            if(recType  == 'The Station Content Request'){
                caseList = Database.query('SELECT CaseNumber, Description, Station_Product__c,Station_Product__r.Id,Station_Product__r.Name, Subject, Priority, Type, CreatedDate, Status, TheStation_Request_Type__c, TheStation_Asset_Type__c, isClosed FROM Case Where ownerId =:userId AND isClosed = false AND RecordType.Name = \''+recType+'\' ORDER BY CreatedDate DESC');
            } else {
                caseList = Database.query('SELECT CaseNumber, Description, Station_Product__c,Station_Product__r.Id,Station_Product__r.Name, Subject, Priority, Type, CreatedDate, Status, isClosed FROM Case Where ownerId =:userId AND isClosed= false AND RecordType.Name = \''+recType+'\' ORDER BY CreatedDate DESC'  );
            }
        }

        if (recType == 'The Station SP Record Feedback') {
            List<Strategic_Initiative_c__x> siList = new List<Strategic_Initiative_c__x>();
            if (togglecase==true){ 
                siList = [SELECT Id, Name__c, Type_c__c, CreatedDate__c, Creative_Deliverables_c__c, Request_Priority_c__c, Language_c__c, Team_Program_Area_c__c, Program_Sub_Area_c__c, Requested_By_c__c, Status_c__c, RecordTypeId__c, Ticket_Number_c__c, Request_Description__c 
                FROM Strategic_Initiative_c__x 
                WHERE Requested_By_c__c =:org62User.ExternalId 
                AND RecordTypeId__c IN ('0123y000000AV99AAG')
                ORDER BY CreatedDate__c DESC];
            }
            else{
                siList = [SELECT Id, Name__c, Type_c__c, CreatedDate__c, Creative_Deliverables_c__c, Request_Priority_c__c, Language_c__c, Team_Program_Area_c__c, Program_Sub_Area_c__c, Requested_By_c__c, Status_c__c, RecordTypeId__c, Ticket_Number_c__c, Request_Description__c 
                FROM Strategic_Initiative_c__x 
                WHERE Requested_By_c__c =:org62User.ExternalId 
                AND RecordTypeId__c IN ('0123y000000AV99AAG')
                AND Status_c__c IN ('New', 'Under Review', 'Waiting on User', 'In Development', 'Scoping', 'On Hold', 'In Review', 'Approved')
                ORDER BY CreatedDate__c DESC];
            }

            // sandbox record type id: 0122D0000016JxjQAE
            // prod record type id: 0123y000000AV99AAG
            for (Strategic_Initiative_c__x si : siList) {
                CaseSIWrapper wrapped = new CaseSIWrapper();
                wrapped.wsi = si;
                wrappedList.add(wrapped);
            }
        }

        for (Case lcase : caseList) {
            CaseSIWrapper wrapped = new CaseSIWrapper();
            wrapped.wcase = lcase;
            wrappedList.add(wrapped);
        }  

        wrappedList.sort();
        
        return wrappedList;
    }
    
    @AuraEnabled
    public static List<CaseSIWrapper> fetchSICases(Boolean togglecase) {
        List<CaseSIWrapper> wrappedList = new List<CaseSIWrapper>();

        List<Strategic_Initiative_c__x> caseList = new List<Strategic_Initiative_c__x>();
        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, Name, Email FROM User WHERE Id = :userId];
        
        Org62_User__x org62User = [SELECT ExternalId, Id, Name__c, Email__c FROM Org62_User__x WHERE Email__c = :u.Email AND Name__c = :u.Name LIMIT 1];

        // NOTE - Make sure to update record type id's when pushing to production
        if (togglecase==true){
            caseList = [SELECT Id, Name__c, Type_c__c, CreatedDate__c, Creative_Deliverables_c__c, Request_Priority_c__c, Language_c__c, Team_Program_Area_c__c, Program_Sub_Area_c__c, Requested_By_c__c, Status_c__c, RecordTypeId__c,ExternalId,Ticket_Number_c__c, Request_Description__c 
            FROM Strategic_Initiative_c__x 
            WHERE Requested_By_c__c =:org62User.ExternalId 
            AND RecordTypeId__c IN ('0120M000000AUfwQAG','0120M000001SPkwQAG')
            ORDER BY CreatedDate__c DESC];
        }
        else{
            caseList = [SELECT Id, Name__c, Type_c__c, CreatedDate__c, Creative_Deliverables_c__c, Request_Priority_c__c, Language_c__c, Team_Program_Area_c__c, Program_Sub_Area_c__c, Requested_By_c__c, Status_c__c, RecordTypeId__c,ExternalId,Ticket_Number_c__c, Request_Description__c 
            FROM Strategic_Initiative_c__x 
            WHERE Requested_By_c__c =:org62User.ExternalId 
            AND RecordTypeId__c IN ('0120M000000AUfwQAG','0120M000001SPkwQAG')
            AND Status_c__c IN ('New', 'Under Review', 'Waiting on User', 'In Development', 'Scoping', 'On Hold', 'In Review', 'Approved')
            ORDER BY CreatedDate__c DESC];
        }

        // sandbox record type id: '0122D000000cMYkQAM','0122D000000cKuCQAU'
        // prod record type id: '0120M000000AUfwQAG','0120M000001SPkwQAG'

        for (Strategic_Initiative_c__x si : caseList) {
            CaseSIWrapper wrapped = new CaseSIWrapper();
            wrapped.wsi = si;
            wrappedList.add(wrapped);
        }
        wrappedList.sort();
        return wrappedList;

        //return caseList;
    }

    @AuraEnabled
    public static String getLexOriginUrl() {
        // String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        // NOTE: This change was made because this URL is used for links to records in the org. This url will not forward users to the station
        String prefix = URL.getOrgDomainURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    }
    @AuraEnabled
    public static List<CaseSIWrapper> sortList(List<CaseSIWrapper> inputList) {
        inputList.sort();
        return inputList;
    }
}