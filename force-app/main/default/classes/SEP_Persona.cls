public with sharing class SEP_Persona {
    @AuraEnabled
    public String personaId {get; set;}

    @AuraEnabled
    public String domainName {get; set;}

    @AuraEnabled
    public String externalId {get; set;}

}