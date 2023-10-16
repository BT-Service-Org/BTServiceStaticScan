public with sharing class MTH_DataProviderAnswersLookup {
    public static List<Slack.Option> getAnswersByQuestion(String questionId, String answers) {
        if (String.isNotBlank(questionId)) {
            List<String> answerList = answers.split(',');
            
            List<Slack.Option> answerOptions = new List<Slack.Option>();
            if (answerList != null) {
                for (String answer : answerList) {
                    Slack.Option option = new Slack.Option(answer, answer);
                    answerOptions.add(option);
                }
            }
            return answerOptions;
        }
        List<Slack.Option> answerOptions = new List<Slack.Option>();
        return answerOptions;
    }
}