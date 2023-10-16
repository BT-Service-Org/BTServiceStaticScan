global class BatchBedrockSyncCert2LearningDomain implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global String finalMsg = '';
    global Bedrock_Monitoring__mdt monitoring;
    global Map<String, String> sfuCertSkillMap;
    //global Map<String, String> badgeMap;
    //global List<Id> pas;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<Bedrock_Badge_Cert_Mapping__mdt> bbcList = [SELECT Label, External_Certification__c, Org62_Badge_Name__c 
                                                         FROM Bedrock_Badge_Cert_Mapping__mdt];
        monitoring = [SELECT Email_To__c, Enabled__c 
                      FROM Bedrock_Monitoring__mdt 
                      WHERE DeveloperName  = 'Badge_Cert_Sync'];

        sfuCertSkillMap = new Map<String, String>();
        for (Bedrock_Badge_Cert_Mapping__mdt bbc : bbcList) {
            sfuCertSkillMap.put(bbc.External_Certification__c, bbc.Label);
        }

        if (monitoring != null) {
            System.Debug('Monitoring Enabled: ' + monitoring.Enabled__c);
            System.Debug('Monitoring Emails: ' + monitoring.Email_To__c);
        }
        //Moved the below SOQL and associated logic to Execute method to avoid "Too many query rows: 50001" error
        /*List<Badge_Data__c> badges =   [select  PA_Onboarding__c,
                                                PA_Onboarding__r.name,
                                                Id,
                                                Name
                                        from    Badge_Data__c
                                        where   PA_Onboarding__c in (select PA_Onboarding__c
                                                                    from   Learning_Domain__c
                                                                    where  PA_Onboarding__r.Candidate__r.IsActive = true
                                                                    and    Badge_Data__c = null)
                                        and     State__c = 'Acquired'
                                        and     Name in :sfuCertSkillMap.KeySet()];
    
        System.Debug('Total SFU Badged: ' + badges.size());
        finalMsg += 'Total SFU Badged: ' + badges.size();
        
        badgeMap = new Map<String, String>();
        pas = new List<Id>();
        for (Integer i = 0; i < badges.size(); i++) {
            badgeMap.put(badges[i].PA_Onboarding__c + sfuCertSkillMap.get(badges[i].Name), badges[i].Id);
            pas.add(badges[i].PA_Onboarding__c);
        }*/
        
        return Database.getQueryLocator('select PA_Onboarding__c, PA_Onboarding__r.name, Id, Badge_Data__c, Skill__c ' +
                                        'from Learning_Domain__c ' +
                                        'where PA_Onboarding__r.Candidate__r.IsActive = true ' +
                                        //'and PA_Onboarding__c in :pas ' +
                                        'and Badge_Data__c = null');
    }

    global void execute(Database.BatchableContext bc, List<Learning_Domain__c> lds){
        List<Learning_Domain__c> ldsToUpdate = new List<Learning_Domain__c>();
        Map<String, String> badgeMap = new Map<String, String>();
        Set<Id> paIds = new Set<Id>();
        //Collect PA Onboarding IDs
        for(Learning_Domain__c domain : lds){
            if(domain.PA_Onboarding__c <> null){
                paIds.add(domain.PA_Onboarding__c);
            }
        }

        for(Badge_Data__c badge:[SELECT Id, PA_Onboarding__c, PA_Onboarding__r.name, Name
                                 FROM Badge_Data__c
                                 WHERE PA_Onboarding__c IN :paIds AND State__c = 'Acquired' AND Name IN :sfuCertSkillMap.keySet()]){
                                
                                    badgeMap.put(badge.PA_Onboarding__c + sfuCertSkillMap.get(badge.Name), badge.Id);
                                 } 
        
        String bm;
        for (Integer i = 0; i < lds.size(); i++) {
            bm = badgeMap.get(lds[i].PA_Onboarding__c + lds[i].Skill__c);
            if (bm != null && lds[i].Badge_Data__c != bm) {
                ldsToUpdate.add(new Learning_Domain__c(Id = lds[i].Id, Badge_Data__c = bm));
                recordsProcessed = recordsProcessed + 1;
            }
        }
        finalMsg += '\nLearning Domain Updates in this Batch: ' + ldsToUpdate.size();

        update ldsToUpdate;
    }

    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];

        // Send success message if monitoring flag is enabled
        if (monitoring != null) {
            if (monitoring.Enabled__c && monitoring.Email_To__c != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(monitoring.Email_To__c.split(','));
                mail.setSubject('BatchBedrockSyncCert2LearningDomain Execution on ' + System.now());
                finalMsg = 'Total Learning Domain Updates: ' + recordsProcessed + '\n' + finalMsg;

                mail.setPlainTextBody(finalMsg);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }

    }    
}