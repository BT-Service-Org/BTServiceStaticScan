public with sharing class PSCSettingService {
    public static String getValue(String key) {
        String value = null;

        List<pscSettings__mdt> settings = [SELECT Value__c 
                                           FROM pscSettings__mdt 
                                           WHERE DeveloperName = :key
                                           WITH SECURITY_ENFORCED];
        if (!settings.isEmpty()) {
            value = settings[0].Value__c;
        }

        return value;
    }

    public static String getEnvSpecificValue(String key) {
        String envSpecificValueStr = null;
        List<PSC_Environment_Variable__mdt> envVariableSettingList = [SELECT Id, prod__c, scdev__c, scqa__c, qa__c
                                                                      FROM PSC_Environment_Variable__mdt 
                                                                      WHERE DeveloperName = :key
                                                                      WITH SECURITY_ENFORCED];
        try{
            String sandboxNameStr = DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();
            String productionInstanceNameStr = 'prod'; // hardcoded because sandboxNameStr will be null in case of Production environment and field created in Custom metadata is prod__c
            String instanceNameStr = sandboxNameStr != null ? sandboxNameStr : productionInstanceNameStr;

            if (envVariableSettingList != null && !envVariableSettingList.isEmpty()) {
                envSpecificValueStr = String.valueOf(envVariableSettingList[0].get(instanceNameStr + '__c'));
            }
        } catch(Exception e) {
            system.debug('Error in PSCMembersCtrl.getEnvSpecificValue : '+ e.getStackTraceString());
        }

        return envSpecificValueStr;
    }
}