/*
    Class: PS_ArticleSearchCommandHandler
    Description: Slash command handler used in Digital HQ Slack App
    Author: Scott Ratliff (sratliff@salesforce.com)
*/
public with sharing class PS_ArticleSearchCommandHandler extends Slack.SlashCommandDispatcher {
    private static String externalUrl = null;
    private final static String SLACK_APP_CLIENT = 'searchFromSlackApp';
    private final static String SEARCH_SOURCE = 'Services_Central_Search_Source';
    private final static String METHODOLOGY_SOURCE = 'Methodology_Search_Source';
    private final static String MULESOFT_SOURCE = 'Catalyst Knowledge Hub';
    private final static String GOOGLE_DRIVE_SOURCE = 'Google Drive';
    private final static String MULESOFT_URL = 'https://knowledgehub.mulesoft.com/s/article/';
    private final static String GOOGLE_DRIVE_URL = 'https://drive.google.com/field/d/';
    private static String servicesCentralSource = PSCSettingService.getValue(SEARCH_SOURCE);
    private static String methodologySource = PSCSettingService.getValue(METHODOLOGY_SOURCE);
    
    public override Slack.ActionHandler invoke(
        Slack.SlashCommandParameters parameters,
        Slack.RequestContext context) {
            return Slack.ActionHandler.modal(new Handler(parameters, context));
        }
    
        public class Handler implements Slack.ModalHandler {
            Slack.SlashCommandParameters parameters;
            Slack.RequestContext context;
            String locale = UserInfo.getLocale();
    
            public Handler(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
                this.parameters = parameters;
                this.context = context;
            }
    
            public Slack.ModalView call() {
                String text = (String) this.parameters.getText();

                if (externalUrl == null) {
                    externalUrl = getExternalUrl();
                }

                Slack.ViewReference viewReference = Slack.View.article_search_results.get();
                Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
                viewReference.setParameter('searchText', text);
                viewReference.setParameter('searchResults', executeSearch(text, locale));

                viewReference.setParameter('userSlackId', context.getUserId());
                String searchLink = externalUrl + '/global-search/@uri?#q=' + text + '&source=relevancy';
                viewReference.setParameter('searchLink', searchLink);
                return new Slack.ModalView.Builder().viewReference(viewReference).build();
            }    
 
            /* 
            * Executes the the search using the keywords entered in the slash command.   
            */
            private List<String> executeSearch(String keywords, String locale) {
                System.debug('keywords are '+ keywords);
                List<String> results = new List<String>();

                String tokenPayload = PSCCoveoSerachTokenGenerator.getToken();
                Map<String,Object> tokenMap = (Map<String,Object>) JSON.deserializeUntyped(tokenPayload);
                String token = (String) tokenMap.get('token');
                
                if (token != null) {
                String[] includeFields = new String[]{'publicurl','objecttype','urihash','collection','source','sfpage_description__c','sfurlname__c','sfpage_title__c','sfid','sfdescription__c','sfmethod_number__c','sfsummary','title','language','permanentid','@foldingcollection','@foldingparent','@foldingchild'};
                CoveoV2.SearchApiResponse response = CoveoV2.SearchApiClient.executeQuery(
                    new Map<String,Object>{
                        'q' => keywords,
                        'fieldsToInclude' => includeFields,
                        'sortCriteria' => 'relevancy',
                        'numberOfResults' => 10,
                        'parentField' => '@foldingchild',
                        'childField' => '@foldingparent',
                        'filterField' => '@foldingcollection',
                        'locale' => locale
                },
                'Bearer ' + token);
                
                logSearchEvent(keywords,locale,token, response);
                if (response.totalCount > 0) {
                    for (Object result : response.rawResults) {
                        Map<String,Object> m = (Map<String,Object>) result;
                        Object parentResult = m.get('parentResult');
                        String resultItem;
                        if (parentResult == null) {
                            resultItem = buildResult(m);
                        } else {
                            resultItem = buildResult(parentResult);
                        }
                        results.add(resultItem);
                    }
                    System.debug('returned: ' + results.size());
                } else {
                    results.add('Sorry, your search returned 0 results. Please try a different search.');
                }
            } else {
                results.add('The search is currently unavailable right now.  Please try again later');
            }

            return results;
        }

        /*
        * Takes the search results and parses out necessary fields, then differentiates the link based on Reusable Assets and Articles.   Finally formats the results for Slack
        */
        private String buildResult(Object result) {
            Map<String,Object> resultMap = (Map<String,Object>) result;
            String title = (String) resultMap.get('title');
            String printableUri = (String) resultMap.get('printableUri');
            Object rawFields = resultMap.get('raw');
            Map<String,Object> rawValues = (Map<String,Object>) rawFields;
            String sourceLocation = (String) rawValues.get('source');
            String publicUrl = (String) rawValues.get('publicurl');
            String articleId = (String) rawValues.get('sfid');
            
            String link;
            String excerpt = (String) resultMap.get('excerpt');
            if (sourceLocation == servicesCentralSource) {
                String objectType = (String) rawValues.get('objecttype');
                excerpt = (String) rawValues.get('sfsummary');
                if (objectType == 'Reusable_Asset__c') {
                    link = externalUrl + '/reusable-asset?recordId=' + articleId;
                } else if (objectType == 'Content_Requests__c') {
                    link = externalUrl + '/content-request?name=' + rawValues.get('sfurlname__c');
                    excerpt = (String) rawValues.get('sfdescription__c');
                } else if (objectType == 'PSC_Page__c') {
                    title = (String) rawValues.get('sfpage_title__c');
                    link = externalUrl + '/page-viewer?name=' + rawValues.get('sfurlname__c');
                    excerpt = (String) rawValues.get('sfpage_description__c');
                } else {
                    link = externalUrl + '/article/' + articleId + '/view';
                }
            } else if (sourceLocation == methodologySource) {
                link = externalUrl + '/method?methodnumber=' + rawValues.get('sfmethod_number__c');
                excerpt = (String) rawValues.get('sfdescription__c');
            } else if (sourceLocation == MULESOFT_SOURCE ) {
                link = MULESOFT_URL + articleId + '/view';
            } else if (sourceLocation == GOOGLE_DRIVE_SOURCE) {
                link = (String) resultMap.get('clickUri');
            } else if (publicUrl != null) {
                link = publicUrl;
            } else {
                link = printableUri;
            }

            excerpt = shortenExcerpt(excerpt);
            return '<' + link + '|' + title + '>\n' + excerpt;

        }

        /*
        * Search analytics: Log the search event in Coveo Analytics for dashboard and further processing
        */
        private void logSearchEvent(String keywords, String locale, String searchToken, CoveoV2.SearchApiResponse response) {

            CoveoV2.AnalyticsApi.SearchEvent searchEvent = new CoveoV2.AnalyticsApi.SearchEvent(
                response,
                locale,
                keywords,
                SLACK_APP_CLIENT
            );

            CoveoV2.AnalyticsApiClient myAnalyticsClient = new CoveoV2.AnalyticsApiClient();
            myAnalyticsClient.token = searchToken;
            CoveoV2.AnalyticsApiClient.Response resp = myAnalyticsClient.logSearchEvent(searchEvent, null );

        }
    }

    /*
    * Retrieves and stores the external url in a static String to avoid multiple SOQL calls.
    */
    public static String getExternalUrl() {
        if (Schema.sObjectType.Site.fields.Id.isAccessible() && Schema.sObjectType.SiteDetail.fields.SecureURL.isAccessible()) {
            String siteId = [SELECT Id FROM Site WHERE Name = 'Services_Central1' LIMIT 1].Id;
            String sitePrefix = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :siteId].SecureUrl;

            if (sitePrefix != null) {
                return sitePrefix;
            } else {
                System.debug('Cannot determine external site prefix');
                return null;
            }
        } else {
            return null;
        }
    
    }

    /*
    * Shortens the excerpt to a maximum of 250 characters.
    */
    private static String shortenExcerpt(String excerpt) {
        String description = '';
        if (excerpt != null) {
            description = excerpt.stripHtmlTags();
            if (description.length() > 250) {
                description = description.substring(0,description.lastIndexOfChar(32, 245)) + '...';
            }
        }

        return description;
    }

}