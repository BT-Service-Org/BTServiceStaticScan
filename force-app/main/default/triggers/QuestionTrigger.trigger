trigger QuestionTrigger on Question__c (after insert) {
    switch on Trigger.OperationType  {
            when AFTER_INSERT
            {
               QuestionTriggerHandler.shareQuestionwithLeaders(Trigger.new);
            }
        }
}