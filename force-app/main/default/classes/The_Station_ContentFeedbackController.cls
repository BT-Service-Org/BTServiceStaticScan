public with sharing class The_Station_ContentFeedbackController {

    @AuraEnabled
    public static String getFeedbackCaseLocalOwnerId(String localStationContentID){
        Station_Content__c localContent = null;
        String org62UserID = null;
        String localUserID = null;
        localContent = [SELECT Content_Type__c, Content_URL__c, Org62_User__c, OwnerId FROM Station_Content__c WHERE Id =: localStationContentID];

        if (localContent != null) {
            System.debug('*** getFeedbackCaseLocalOwnerId - got local content record ['+localStationContentID+']');
            System.debug('*** getFeedbackCaseLocalOwnerId - Content_Type__c : ' + localContent.Content_Type__c);
            System.debug('*** getFeedbackCaseLocalOwnerId - Content_URL__c : ' + localContent.Content_URL__c);
            System.debug('*** getFeedbackCaseLocalOwnerId - Org62_User__c : ' + localContent.Org62_User__c);
            System.debug('*** getFeedbackCaseLocalOwnerId - OwnerId : ' + localContent.OwnerId);
            String url = localContent.Content_URL__c;
            if (url != null) {
                url = url.replace('/view', '');
            }
            System.debug('*** getFeedbackCaseLocalOwnerId - url : ' + url);
            if (localContent.Content_Type__c == 'Content Version') {
                System.debug('*** getFeedbackCaseLocalOwnerId - Content Version');
                url = url.replace('https://org62.lightning.force.com/lightning/r/', '');
                System.debug('*** getFeedbackCaseLocalOwnerId - CV url : ' + url);
                url = url.replace('ContentDocument/', '');
                System.debug('*** getFeedbackCaseLocalOwnerId - CV url : ' + url);
                Org62_ContentVersion__x contentVersion;
                try {
                    contentVersion = [SELECT OwnerId__c FROM Org62_ContentVersion__x WHERE ContentDocumentId__c = :url AND IsLatest__c = true LIMIT 1];
                    System.debug('*** getFeedbackCaseLocalOwnerId - contentVersion : ' + contentVersion);
                    if (contentVersion != null) {
                        org62UserID = contentVersion.OwnerId__c;
                        System.debug('*** getFeedbackCaseLocalOwnerId - CV org62UserID : ' + org62UserID);
                        localUserID = StationSPController.getLocalUserIDForOrg62UserID(org62UserID);
                        System.debug('*** getFeedbackCaseLocalOwnerId - CV localUserID : ' + localUserID);
                        if (localUserID == null) {
                            System.debug('*** getFeedbackCaseLocalOwnerId - CV failed to get a local user !');
                        } else {
                            System.debug('*** getFeedbackCaseLocalOwnerId - CV found local user id [' + localUserID + ']');
                        }
                    }
                } catch (Exception e) {
                    System.debug('Content Version query exception: ' + e.getMessage() + ' | localUserID : ' + localUserID);
                }
            } else if (localContent.Content_Type__c == 'Success Program') {
                System.debug('*** getFeedbackCaseLocalOwnerId - Success Program');
                url = url.replace('https://org62.lightning.force.com/lightning/r/', '');
                System.debug('*** getFeedbackCaseLocalOwnerId - SP url : ' + url);                
                url = url.replace('Success_Program__c/', '');
                System.debug('*** getFeedbackCaseLocalOwnerId - SP url : ' + url);                
                Success_Program_c__x sp;
                try {                 
                    sp = [SELECT OwnerId__c FROM Success_Program_c__x WHERE ExternalId = :url LIMIT 1];
                    System.debug('*** getFeedbackCaseLocalOwnerId - sp : ' + sp);
                    if (sp != null) {
                        org62UserID = sp.OwnerId__c;
                        System.debug('*** getFeedbackCaseLocalOwnerId - SP org62UserID : ' + org62UserID);
                        localUserID = StationSPController.getLocalUserIDForOrg62UserID(org62UserID);
                        System.debug('*** getFeedbackCaseLocalOwnerId - SP localUserID : ' + localUserID);
                        if (localUserID == null) {
                            System.debug('*** getFeedbackCaseLocalOwnerId - SP failed to get a local user !');
                        } else {
                            System.debug('*** getFeedbackCaseLocalOwnerId - SP found local user id [' + localUserID + ']');
                        }
                    }
                } catch (Exception e) {
                    System.debug('Success Program exception: ' + e.getMessage() + ' | localUserID : ' + localUserID);
                }    
            } else {
                localUserID = localContent.OwnerId;
            }
        }
        if (localUserID == null) {
            User u = [SELECT Id FROM User WHERE name = 'David Mierke' AND alias = 'DMier' LIMIT 1];
            if (u == null) {
                System.debug('*** MAJOR ISSUE - COULD NOT EVEN FIND DAVID MIERKE');
            } else {
                System.debug('*** DAVID MIERKE FOUND - RETURNING HIS ID : ' + u.Id);
                localUserID = u.Id;
            }
        }
        return localUserID;
    }
}