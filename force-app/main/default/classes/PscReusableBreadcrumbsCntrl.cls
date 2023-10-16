public class PscReusableBreadcrumbsCntrl {
    @auraEnabled(cacheable=true)
    public static pscSettings__mdt fetchBreadCrumbs(String developerName){
       return [SELECT Id, Value__c, Label FROM pscSettings__mdt Where DeveloperName=: developerName];
       
    }
}