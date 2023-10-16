public with sharing class sh_URLUtility{

    Public static String GetPrefix(){
    String domainVar;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
       if(sfdcBaseURL.contains('sfservices')){
           domainVar = '/apex';
       }else{
           domainVar ='';
       }
       system.debug('>>>>>>>>>>>>>>>>>>>>>>domain Var '+domainVar);
       return domainVar;
    } 
}