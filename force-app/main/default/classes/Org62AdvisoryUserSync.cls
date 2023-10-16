global class Org62AdvisoryUserSync implements Database.Batchable<sObject>,Schedulable {
   
    private String userQuery = 'select Id, Email, IsActive, Org62Id__c, Hire_Date__c, JobCode__c, Mgmt_Chain_Hierarchy_Level_04__c, ' +
        ' Mgmt_Chain_Hierarchy_Level_02__c,Mgmt_Chain_Hierarchy_Level_03__c,Mgmt_Chain_Hierarchy_Level_05__c,Mgmt_Chain_Hierarchy_Level_06__c, ' +
        ' Mgmt_Chain_Hierarchy_Level_07__c,Mgmt_Chain_Hierarchy_Level_08__c,Mgmt_Chain_Hierarchy_Level_09__c, ' +
        ' Non_CSG_User__c from User where ProfileId != \'00e30000001yIet\' and ' + 
        ' ProfileId != \'00e30000000nc9D\' and UserName != \'%test%\' and UserName != \'%api%\' and UserName != \'%integration%\' ' + 
        ' and UserName != \'salesforce_services%\' and UserName != \'impact_program_%\' and UserName != \'insightssecurity%\' '+
        ' and UserName != \'services_hub%\' and UserName !=\'old%\' and UserName !=\'job_arch%\' and Is_Active_CSG_User__c = true ' +
        ' and Org62Id__c != null and IsActive = true ';  
    
    global void execute(schedulableContext sc) {
        Database.executebatch(this);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query ' + userQuery);
        return Database.getQueryLocator(userQuery);
    }
 
    global void execute(Database.BatchableContext BC,List<sobject> scope)
    {
        System.debug('scope ' + scope);
        List<User> users = (List<User>)scope;
        
        Set<Id> org62Id = new Set<Id>();
        for (User u : users ) {
            
            if (u.Org62Id__c != null) {
                org62Id.add(u.Org62Id__c);
            }
        }
        
        System.debug('org62id ' + org62Id.size());
        
        List<User> updls = new List<User>();
        Map<String, User__x> extUserMap = new Map<String, User__x>();
        for (User__x extu: [select ExternalId,IsActive__c,Hire_Date_c__c,Email__c,Mgmt_Chain_Level_02_c__c ,Mgmt_Chain_Level_03_c__c ,
                Mgmt_Chain_Level_04_c__c, Mgmt_Chain_Level_05_c__c, FederationIdentifier__c, JobCode_c__c from User__x where 
                    ( ExternalId in: org62Id ) ]) {
            extUserMap.put(extu.ExternalId, extu);
        }
        
        Set<Id> uid = new Set<Id>();    
        for (User u : users) {
           System.debug('In the loop' + u);
           if (extUserMap.containskey(u.Org62Id__c)) {
                User__x extUser = extUserMap.get(u.Org62Id__c);
                System.debug('extUser ' + extUser.Hire_Date_c__c + extUser.ExternalId);
                if (extUser.IsActive__c == false) {
                    u.IsActive = false;
                }
                //TODO: read from custom metadata (not Brian Millham, Kaname or Delicia)
                if ( (extUser.Mgmt_Chain_Level_03_c__c != '00530000000cWe9AAE') &&
                     (extUser.Mgmt_Chain_Level_05_c__c != '0053000000BqwUUAAZ') &&
                     (extUser.Mgmt_Chain_Level_04_c__c != '0053000000BqwUUAAZ') ) { 
                    u.Mgmt_Chain_Hierarchy_Level_02__c = null;
                    u.Mgmt_Chain_Hierarchy_Level_03__c = null;
                    u.Mgmt_Chain_Hierarchy_Level_04__c = null;
                    u.Mgmt_Chain_Hierarchy_Level_05__c = null;
                    u.Mgmt_Chain_Hierarchy_Level_06__c = null;
                    u.Mgmt_Chain_Hierarchy_Level_07__c = null;
                    u.Mgmt_Chain_Hierarchy_Level_08__c = null;
                    u.Mgmt_Chain_Hierarchy_Level_09__c = null;
                    u.Non_CSG_User__c = true;
                 
                    uid.add(u.Id);
                }
                updls.add(u);
                
            }
            
         }
        System.debug('upd ls size ' + updls.size() + uid);
            
        //do not execute any triggers on user/contact
        UserContactUtil.doNotExecuteTrigger = true;
        Database.SaveResult[] srList = Database.update(updls, false);
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated user. user ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('User fields that affected this error: ' + err.getFields());
                }
            }
        }
        
  
        /*/update status on onboarding record
        List<PA_Onboarding__c> onbls = new List<PA_Onboarding__c>();
        for (PA_Onboarding__c onb : [select Id, Status__c from PA_Onboarding__c where Candidate__c in: uid]) {
            onb.Status__c = 'Internal Attrition'; 
            onbls.add(onb);
        }
        //do not execute any triggers 
        UserContactUtil.doNotExecuteTrigger = true;
        Database.SaveResult[] srLs = Database.update(onbls, true);
        // Iterate through each returned result
        for (Database.SaveResult sr : srLs) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated onboarding ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Onboarding fields that affected this error: ' + err.getFields());
                }
            }
        }*/

    }

    global void finish(Database.BatchableContext BC) {

    }  
}