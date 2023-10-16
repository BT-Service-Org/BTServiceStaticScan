public with sharing class MTH_MethodDueMsgSender implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();

    private List<Methods__c> methodsAssigned;

    @testVisible
    private static MethodDAI methodDA = new MethodDataAccessor();

    @testVisible
    private static Map<Id, Method__c> methodMap;

    public MTH_MethodDueMsgSender(List<Methods__c> methodsDue) {
        this.methodsAssigned = methodsDue;
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
            sendDueNotificationToUser(methods, usersById);
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
            if (m.Message__c == 'Method Due Reminder Message' || String.isBlank(m.Message__c)) {
                textConfig.put(m.Section__c, m.Text__c);
            }
        }
        return textConfig;
    }

    private void sendDueNotificationToUser(Methods__c methods, Map<Id, User> usersById) {
        Slack.ViewReference view = Slack.view.mth_msg_method_due_reminder.get();
        view.setParameter('methodsName', methods.Method__r.Name);
        Method__c methodRecord = methodMap.get(methods?.Method__r?.Id);
        if(methodRecord != null){
            String communityURL = System.URL.getOrgDomainUrl().toExternalForm().replace('salesforce','site')+methodRecord.Community_URL__c;
            view.setParameter('methodCommunityUrl', communityURL);
        }
        view.setParameter(
            'dueDate',
            MTH_SlackMessageSender.formatDateStringForMessages(methods.End_Date__c)
        );
        view.setParameter('methodsId', methods.Id);
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        List<Map<String, String>> knowledgeMapList = MTH_MethodsAssignMsgSender.createArticleMethodsList(methods.Method__r.Id);
        view.setParameter('knowledgeArticles', knowledgeMapList);
        view.setParameter('hasKnowledgeArticles', knowledgeMapList.size() > 0);
        view.setParameter('textConfig', getTextConfig());
        MTH_SlackMessageSender.sendMessageToUser(usersById.get(methods.Assigned_Resource__c), view);
    }
}