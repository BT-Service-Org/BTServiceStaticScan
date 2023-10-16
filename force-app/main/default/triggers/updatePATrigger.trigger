trigger updatePATrigger on PA_Onboarding__c (before update) {
    if(!CheckRecursive.isRun()){
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$INSIDE-updatePATrigger####################: '+Trigger.new);
        //List<Certification_Data__c> certDataList=OrgRefresh_CertDataGenTemplate.genBaseCertTemplate(Trigger.new,Trigger.oldMap);
        List<Badge_Data__c> badgeDataList=OrgRefresh_CertDataGenTemplate.genBaseCertTemplate(Trigger.new,Trigger.oldMap);
        //upsert certDataList Cert_Unique_Id__c;
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$PRE-updatePATrigger: '+badgeDataList+' size: '+badgeDataList.size());
        if (badgeDataList.size()>0) {
            upsert badgeDataList Org62_Id__c;
            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$POST-1-updatePATrigger: '+badgeDataList);
        } else {
            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$POST-2-updatePATrigger: badgeDataList was empty--nothing to do');
        }
    }
}