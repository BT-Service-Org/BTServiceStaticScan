public without sharing class PSCCoveoSerachTokenGenerator {
    @AuraEnabled
     public static string getToken() {         
        List<String> sourcesToDisplay=new List<String> ();
        String defaultSources =PSCSettingService.getValue ('Services_Central_Default_Sources');
        if(defaultSources!=null && defaultSources!=''){
            sourcesToDisplay.addAll(defaultSources.split(','));
            }
        if(FeatureManagement.checkPermission('Services_Central_Methodology')){
            sourcesToDisplay.add(PSCSettingService.getValue ('Methodology_Source_Name'));
            }
         if(FeatureManagement.checkPermission('Services_Central_Highspot')){
            sourcesToDisplay.add(PSCSettingService.getValue ('Highspot_Source_Name'));
            }
         Map<String, Object> endpoint = CoveoV2.Globals.getEndpointData();
         String searchHubName = getSearchHub();
        String finalFilterString='@gkcsource==(';
        for(String sourceName: sourcesToDisplay){
            finalFilterString=finalFilterString +'\"'+sourceName+'\",';
            }
         finalFilterString= finalFilterString.removeEnd(',')+')';
         System.debug('###'+finalFilterString);
        String token = CoveoV2.Globals.generateSearchToken(new Map<String, Object> {
             'searchHub' => searchHubName, 
             'filter' => finalFilterString
             
         });

         endpoint.put('token', token);
         return JSON.serialize(endpoint);
     }

     public static String getSearchHub() {
        String searchHubName = null;
        if (URL.getSalesforceBaseUrl().toExternalForm().contains('dighqdev')) {
            searchHubName=PSCSettingService.getValue ('CoveoSearchHubDev');
        } else if (URL.getSalesforceBaseUrl().toExternalForm().contains('dighqqa')) {
            searchHubName=PSCSettingService.getValue ('CoveoSearchHubQA');
        } else if (URL.getSalesforceBaseUrl().toExternalForm().contains('qa.')) {
            searchHubName=PSCSettingService.getValue ('CoveoSearchHubUAT');
        } else {
            searchHubName=PSCSettingService.getValue ('CoveoSearchHubDefault');
        }

        return searchHubName;
     }

    }