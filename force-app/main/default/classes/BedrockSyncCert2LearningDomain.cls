/*****************************************
* File: BedrockSyncCert2LearningDomain
* Author: Sriram Venkatraman
* Description: This apex class is used to sync Designer Certs to Candidates' Learning Domains
******************************************/
global class BedrockSyncCert2LearningDomain implements Schedulable {
  global void execute(SchedulableContext ctx) {
    List<Bedrock_Badge_Cert_Mapping__mdt> bbcList = [select Label, External_Certification__c, Org62_Badge_Name__c from Bedrock_Badge_Cert_Mapping__mdt];
	Bedrock_Monitoring__mdt monitoring = [select Email_To__c, Enabled__c from Bedrock_Monitoring__mdt where DeveloperName  = 'Badge_Cert_Sync'];

    Map<String, String> sfuCertSkillMap = new Map<String, String>();
    for (Bedrock_Badge_Cert_Mapping__mdt bbc : bbcList) {
      sfuCertSkillMap.put(bbc.External_Certification__c, bbc.Label);
    }

    String finalMsg = '';
    
    if (monitoring != null) {
        System.Debug('Monitoring Enabled: ' + monitoring.Enabled__c);
      	System.Debug('Monitoring Emails: ' + monitoring.Email_To__c);
        System.Debug('Skill Sets to Sync: ' + sfuCertSkillMap);
  	}
    
    try {
        List<Badge_Data__c> badges = [select PA_Onboarding__c,
                                             PA_Onboarding__r.name,
                                             Id,
                                             Name
                                      from   Badge_Data__c
                                      where  PA_Onboarding__c in (select PA_Onboarding__c
                                                                  from   Learning_Domain__c
                                                                  where  PA_Onboarding__r.Candidate__r.IsActive = true
                                                                  and    Badge_Data__c = null)
                                      and Name in :sfuCertSkillMap.KeySet()];
//                                      and lastmodifieddate >= LAST_N_DAYS:30];
    
        System.Debug('Total SFU Badged: ' + badges.size());
        finalMsg += 'Total SFU Badged: ' + badges.size();
    
        Map<String, String> badgeMap = new Map<String, String>();
        List<Id> pas = new List<Id>();
        for (Integer i = 0; i < badges.size(); i++) {
            badgeMap.put(badges[i].PA_Onboarding__c + sfuCertSkillMap.get(badges[i].Name), badges[i].Id);
            pas.add(badges[i].PA_Onboarding__c);
        }
    
        List<Learning_Domain__c> lds = [select PA_Onboarding__c,
                                                PA_Onboarding__r.name,
                                                Id,
                                                Badge_Data__c,
                                                Skill__c
                                        from Learning_Domain__c
                                        where PA_Onboarding__r.Candidate__r.IsActive = true
                                        and PA_Onboarding__c in :pas
                                        and Badge_Data__c = null
                                       ];
    
        System.Debug('Potential Candidates Learning Domain to Updates: ' + lds.size());
        finalMsg += '\nPotential Candidates Learning Domain to Updates: ' + lds.size();
    
        List<Learning_Domain__c> ldsToUpdate = new List<Learning_Domain__c>();
        String bm;
        for (Integer i = 0; i < lds.size(); i++) {
            bm = badgeMap.get(lds[i].PA_Onboarding__c + lds[i].Skill__c);
            if (bm != null && lds[i].Badge_Data__c != bm) {
                ldsToUpdate.add(new Learning_Domain__c(Id = lds[i].Id,
                                                       Badge_Data__c = bm));
                //System.Debug(lds[i].Id + ', ' + badgeMap.get(lds[i].PA_Onboarding__c + lds[i].Skill__c));
            }
        }
    
        System.Debug('Final Candidate Learning Domain Updates: ' + ldsToUpdate.size());
        finalMsg += '\nFinal Candidate Learning Domain Updates: ' + ldsToUpdate.size();
        System.Debug(ldsToUpdate);
        update ldsToUpdate;

        // Send success message if monitoring flag is enabled
        if (monitoring != null) {
            if (monitoring.Enabled__c && monitoring.Email_To__c != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(monitoring.Email_To__c.split(','));
                mail.setSubject('BedrockSyncCert2LearningDomain Execution on ' + System.now());
                mail.setPlainTextBody(finalMsg);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }

    } catch (Exception e) {
        System.Debug('Exception: ' + e.getMessage());

        // Send email to monitoring users about the error
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'sriram.venkatraman@salesforce.com'});
        if (monitoring != null) 
            if (monitoring.Email_To__c != null)
		        mail.setToAddresses(monitoring.Email_To__c.split(','));
        
        mail.setSubject('Error!! Running BedrockSyncCert2LearningDomain Process');
        mail.setPlainTextBody(e.getMessage());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }    
  }
}