public with sharing class GamificationSearchAnalytics {
    public static Id recordTypeId = Schema.SObjectType.User_Achievement_Activity__c.getRecordTypeInfosByDeveloperName().get('Tracking').getRecordTypeId();
    private final static String SEARCH_ANALYTICS_API = 'https://analytics.cloud.coveo.com/rest/ua/v15/stats/combinedData';

    @InvocableMethod(label='Get Search Analytics')
    public static void getSearchAnalytics(List<SearchAnalyticsCriteria> criteria) {
        for (SearchAnalyticsCriteria query : criteria) {
            // Define the input parameters
            String fromDate = String.valueOf(query.startDate) + 'T00:00:00.000Z';
            String toDate = String.valueOf(query.endDate) + 'T00:00:00.000Z';
            
            String apiKey = PSCSettingService.getValue ('CoveoSearchAnalyticsKey');
            String searchHubName = PSCCoveoSerachTokenGenerator.getSearchHub();
            String searchQuery = EncodingUtil.urlEncode('cause=="searchFromLink" AND SEARCHHUBNAME == "' + searchHubName + '"', 'UTF-8');
            String endPoint = SEARCH_ANALYTICS_API + '?access_token=' + apiKey + '&m=PerformSearch&from=' + fromDate + '&to=' + toDate + '&f=' + searchQuery + '&d=username&d=actionCause';
            System.debug(endPoint);

            // Create a new HTTP request object
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('GET');

            // Send the HTTP request to get the Coveo search analytics results
            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                // Process the response data
                String responseData = response.getBody();
                if (responseData != null) {
                    processResults(responseData);
                }
                
            } else {
                System.debug('The API request failed with status code: ' + response.getStatusCode());
                System.debug(response.getBody());
            }

        }

    }

    private static void processResults(String responseData) {
        System.debug('responseData');
        Datetime activityDate = System.now();
        Map<String, Object> responseResult = (Map<String, Object>) JSON.deserializeUntyped(responseData);
        List<Object> rows = (List<Object>) responseResult.get('combinations');
        Map<String,Integer> userCounts = new Map<String,Integer>();

        for (Object row:rows) {
            Map<String,Object> rowObj = (Map<String,Object>) row;
            String emailAddress = (String) rowObj.get('userName');
            userCounts.put(emailAddress, (Integer) rowObj.get('PerformSearch'));
        }

        System.debug(userCounts.keySet());

        List<User> users = [SELECT Id,FederationIdentifier FROM User WHERE FederationIdentifier in :userCounts.keySet()];
        List<User_Achievement_Activity__c> userActivities = new List<User_Achievement_Activity__c>();
        if (users.size() > 0) {
            for (User user: users) {
                User_Achievement_Activity__c result = new User_Achievement_Activity__c();
                result.User__c = user.Id;
                result.Award_Date__c = activityDate;
                result.RecordTypeId = recordTypeId;
                result.Activity_Count__c = userCounts.get(user.FederationIdentifier);
                result.Activity__c = 'Search';
                userActivities.add(result);
            }
        }
        
        if (Schema.SObjectType.User_Achievement_Activity__c.isCreateable()) {
            Database.insert(userActivities);
        }

    }

    public class SearchAnalyticsCriteria {
        @InvocableVariable(label='Start Date' required=true)
        public Date startDate;

        @InvocableVariable(label='End Date' required=true)
        public Date endDate;
    }

}