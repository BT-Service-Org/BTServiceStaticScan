public with sharing class MTH_MarkMethodComplete extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static ProjectAssignmentDAI assignmentDA = new ProjectAssignmentDataAccessor();

    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.ack(new Handler(parameters, context));
    }

    public class Handler implements Slack.RunnableHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public void run() {
            Id methodId = (Id) parameters.get('methodId');
            String projectId = String.valueOf(parameters.get('projectId'));
            String userId = UserInfo.getUserId();
            String viewType = String.valueOf(parameters.get('viewType'));
            
            List<String> answers = new List<String>();
            List<Method_Question_Answers__c> methodAnswers = new List<Method_Question_Answers__c>();
            List<Methods__c> retrievedMethods = methodsDA.getMethodsStatus(new Set<Id>{ methodId });
            List<Project_Assignment__c> retrievedAssignments = assignmentDA.getProjectAssignmentsForUsers(new Set<Id>{ userId });
            String updatedLink = (String) context.getFormData().get('updated-link');
            
            if (retrievedMethods.size() != 1) {
                return;
            }

            if (retrievedAssignments.size() != 1 && String.isBlank(retrievedAssignments[0].Project_Role__c)) {
                return;
            } 

            String userName = retrievedAssignments[0].Project_Role__c;
            List<Method_Question__c> methodQuestions = methodsDA.getMethodQuestionsByMethodId(retrievedMethods[0].Method__r.Id);

            for(Method_Question__c question: methodQuestions){
                String answer = (String) context.getFormData().get(''+question.Id+'-input');
                
               if(String.isBlank(answer)){
                    continue;
                }

                    Method_Question_Answers__c completedMethodAnswer = new Method_Question_Answers__c();
                    completedMethodAnswer.Answer__c = answer;
                    completedMethodAnswer.Answered_By__c = userId;
                    completedMethodAnswer.Method_for_Engagement__c = retrievedMethods[0].Id;
                    completedMethodAnswer.Method_Question__c = question.Id;
                    completedMethodAnswer.PSA_Project__c = projectId;
                    completedMethodAnswer.Role_of_person_who_answered__c = userName;
                    methodAnswers.add(completedMethodAnswer);
            }

            updateCompletedMethod(methodAnswers, retrievedMethods[0], updatedLink);

            // refreshes project manage home view with current information
            // else statement not necessary
            if (viewType == 'home') {
                String teamId = context.getTeamId();
                String slackId = MTH_SlackUserIdHandler.getSlackIdFromContextOrRunningUserId(
                    context
                );
                
                MTH_ManageProjectViewOpen.buildHomeView(projectId, teamId, slackId);
            }
        }
    }

    private static void updateCompletedMethod(List<Method_Question_Answers__c> methodAnswers, Methods__c  method, String updatedLink){
        Methods__c completedMethod = method;
        completedMethod.Completion_Status__c = 'Complete';
        completedMethod.Link_to_New_Template__c = updatedLink; 
        methodsDA.addMethodQuestionAnswers(methodAnswers);
        methodsDA.updateMethods(new List<Methods__c>{ completedMethod });
    }
}