public with sharing class MTH_DataProviderMethodsLookup {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static MTH_Pagination paginator = new MTH_Pagination();

    public static Slack.OptionDataResponse getMethodsByName(String projectId, String value) {
        List<Methods__c> currentMethodsToIgnore = [
            SELECT Method__r.Id
            FROM Methods__c
            WHERE PSA_Project__c = :projectId
            WITH SECURITY_ENFORCED
        ];

        Set<Id> idsToIgnore = new Set<Id>();
        for (Methods__c m : currentMethodsToIgnore) {
            idsToIgnore.add(m.Method__r.Id);
        }

        List<Method__c> methods = getSearchedMethods(value, idsToIgnore);

        List<Slack.Option> methodsOptions = new List<Slack.Option>();

        for (Method__c method : methods) {
            Slack.Option option = new Slack.Option(method.Name, method.Id);
            methodsOptions.add(option);
        }

        return new Slack.OptionDataResponse(methodsOptions);
    }

    private static List<Method__c> getSearchedMethods(String value, Set<Id> idsToIgnore) {
        List<Method__c> methods = new List<Method__c>();
        if (String.isNotBlank(value)) {
            String name = '%' + value + '%';
            methods = [
                SELECT Id, Name
                FROM Method__c
                WHERE Name LIKE :name AND Id NOT IN :idsToIgnore
                WITH SECURITY_ENFORCED
                LIMIT 10
            ];
        }

        return methods;
    }

    public static List<Slack.Option> getPageNumbers(String projectId) {
        if (String.isNotBlank(projectId)) {
            String countResultsQuery = methodsDA.getMethodsCountByPSAProjectIdStringQuery(projectId);
            Integer totalPages = paginator.totalPages(countResultsQuery);
            
          
            List<Slack.Option> pageNumOptions = new List<Slack.Option>();
            for (Integer pageNum = 1; pageNum <= totalPages; pageNum++) {
              Slack.Option option = new Slack.Option(String.valueOf(pageNum), String.valueOf(pageNum));
              pageNumOptions.add(option);
            }
            
            return pageNumOptions;
        }
        List<Slack.Option> pageNumOptions = new List<Slack.Option>();
        return pageNumOptions;
    }
}