public with sharing class MTH_MarkCompleteModalHandler {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();

    public class MethodNotFoundException extends Exception {
    }

    public static Slack.ModalView buildModal(Id methodId, String projectId, String viewType) {
        Slack.ViewReference viewReference = Slack.View.mth_complete_method_modal.get();
        
        Methods__c[] methods = methodsDA.getMethodsByMethodsIds(new Set<Id>{methodId});

        if(methods.size() != 1){
            throw new MethodNotFoundException();
        }

        Method_Question__c[] methodTextQuestions = methodsDA.getMethodTextQuestionsByMethodId(methods[0].Method__r.Id);
        Method_Question__c[] methodDropdownQuestions = methodsDA.getMethodDropdownQuestionsByMethodId(methods[0].Method__r.Id);
        List<Map<String,Object>> methodDropdownQuestionsMaps = getMethodQuestionsMaps(methodDropdownQuestions);
    

        DateTime now = DateTime.now();
        String formattedToday = now.format('yyyy-MM-dd');
        viewReference.setParameter('today', formattedToday);
        viewReference.setParameter('methodId', methodId);
        viewReference.setParameter('methodName', methods[0].Method__r.Name);
        viewReference.setParameter('methodTextQuestions', methodTextQuestions);
        viewReference.setParameter('methodDropdownQuestions', methodDropdownQuestionsMaps);
        viewReference.setParameter('viewType', viewType);
        viewReference.setParameter('projectId', projectId);
        String servicesOrgDomain = Methodologies_Slack_App_Settings__c.getInstance()
            .Services_Org_URL__c;
        viewReference.setParameter('servicesOrgUrl', servicesOrgDomain);

        return new Slack.ModalView.Builder().viewReference(viewReference).build();
    }

    private static List<Map<String,Object>> getMethodQuestionsMaps(Method_Question__c[] methodDropdownQuestions){
        List<Map<String,Object>> methodDropdownQuestionsMaps = new  List<Map<String,Object>>();
        for (Method_Question__c methodDropdownQuestion : methodDropdownQuestions) {
            Map<String, Object> methodDropdownQuestionMap = new Map<String, Object>();
            methodDropdownQuestionMap.put('Id', methodDropdownQuestion.Id);
            methodDropdownQuestionMap.put('SPSMQuestionId', methodDropdownQuestion.SPSM_Question__r.Id);
            methodDropdownQuestionMap.put('SPSMQuestion', methodDropdownQuestion.SPSM_Question__r.Question__c);
            methodDropdownQuestionMap.put('HelpText', methodDropdownQuestion.SPSM_Question__r.Question_Help_Text__c);
            methodDropdownQuestionMap.put('Mandatory', methodDropdownQuestion.Mandatory__c);
            methodDropdownQuestionMap.put('Options', MTH_DataProviderAnswersLookup.getAnswersByQuestion(methodDropdownQuestion.SPSM_Question__r.Id, methodDropdownQuestion.SPSM_Question__r.Dropdown_Answers__c));
            methodDropdownQuestionsMaps.add(methodDropdownQuestionMap);
        }
        return methodDropdownQuestionsMaps;
    }
}