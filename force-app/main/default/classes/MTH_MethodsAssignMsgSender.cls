public with sharing class MTH_MethodsAssignMsgSender implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();

    @testVisible
    private static MethodDAI methodDA = new MethodDataAccessor();
    @testVisible
    private static ArticleMethodDAI articleMethodDA = new ArticleMethodDataAccessor();

    @testVisible
    private static Map<Id, Method__c> methodMap;

    private List<Methods__c> methodsAssigned;

    public MTH_MethodsAssignMsgSender(List<Methods__c> methodsAssigned) {
        this.methodsAssigned = methodsAssigned;
    }

    public void execute(System.QueueableContext context) {
        Map<Id, User> usersById = new Map<Id, User>(
            userDA.getSlackUserInfoFromUserIds(getAssignedResourcesFromMethods(methodsAssigned))
        );

        Set<Id> methodIds = new Set<Id>();
        for (Methods__c methods : methodsAssigned) {
            methodIds.add(methods.method__r.Id);
        }

        if(!methodIds.isEmpty()){
            methodMap = new Map<Id, Method__c>(methodDA.getMethodListByMethodIds(methodIds));
        }
        

        for (Methods__c methods : methodsAssigned) {
            sendAssignmentNotificationMessageToUser(methods, usersById);
        }

    }

    private Set<Id> getAssignedResourcesFromMethods(List<Methods__c> methodsList) {
        Set<Id> userIds = new Set<Id>();
        for (Methods__c methods : methodsList) {
            userIds.add(methods.Assigned_Resource__c);
        }
        return userIds;
    }

    private Map<String, String> getTextConfig() {
        List<Methodologies_Slack_App_Message_Text__mdt> configuredMessageTexts = Methodologies_Slack_App_Message_Text__mdt.getAll()
            .values();

        Map<String, String> textConfig = new Map<String, String>();
        for (Methodologies_Slack_App_Message_Text__mdt m : configuredMessageTexts) {
            if (m.Message__c == 'Method Assigned Message' || String.isBlank(m.Message__c)) {
                textConfig.put(m.Section__c, m.Text__c);
            }
        }
        return textConfig;
    }

    private void sendAssignmentNotificationMessageToUser(
        Methods__c methods,
        Map<Id, User> usersById
    ) {
        Slack.ViewReference view = Slack.view.mth_msg_method_assignment_notification.get();
        view.setParameter('methods', createMethodsMap(methods));
        Method__c methodRecord = methodMap.get(methods?.Method__r?.Id);
        if(methodRecord != null){
            String communityURL = System.URL.getOrgDomainUrl().toExternalForm().replace('salesforce','site')+methodRecord.Community_URL__c;
            view.setParameter('methodCommunityUrl', communityURL);
        }
        List<Map<String, String>> knowledgeMapList = createArticleMethodsList(methods.Method__r.Id);
        view.setParameter('knowledgeArticles', knowledgeMapList);
        view.setParameter('hasKnowledgeArticles', knowledgeMapList.size() > 0);
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        
        view.setParameter('textConfig', getTextConfig());
        MTH_SlackMessageSender.sendMessageToUser(usersById.get(methods.Assigned_Resource__c), view);
    }

    private Map<String, String> createMethodsMap(Methods__c methods){
        Map<String, String> methodsMap = new Map<String, String>();
        methodsMap.put('Id', methods.Id);
        methodsMap.put('Name', methods.Method__r.Name);
        methodsMap.put('MethodId', methods.Method__r.Id);
        methodsMap.put('DueDate', MTH_SlackMessageSender.formatDateStringForMessages(methods.End_Date__c));
        return methodsMap;
    }

    public static List<Map<String, String>> createArticleMethodsList(Id methodId){
        List<Map<String, String>> knowledgeMapList = new List<Map<String, String>>();
        List<Article_Method__c> articleMethods = articleMethodDA.getArticleMethodsByMethodId(methodId);
        for (Article_Method__c articleMethod : articleMethods) {
            Map<String, String> knowledgeMap = new Map<String, String>();
            knowledgeMap.put('GKC_Community_Url__c', articleMethod.Knowledge__r.GKC_Community_Url__c);
            knowledgeMap.put('Title', articleMethod.Knowledge__r.Title);
            knowledgeMapList.add(knowledgeMap);
        }

        return knowledgeMapList;
    }
}