trigger ContributionTeamTrigger on Contribution_Team__c (after insert, after update, after delete,after undelete) {

        switch on Trigger.OperationType  {
            when AFTER_INSERT, AFTER_UNDELETE
            {
                ContributionTeamTriggerHandler.shareQuestionwithLeaders(Trigger.new);
                ContributionTeamTriggerHandler.addPermissionSet(JSON.serialize(Trigger.new));
                ContributionTeamTriggerHandler.shareCTwithLeaders(Trigger.new);

            }
            when AFTER_UPDATE
            {
                ContributionTeamTriggerHandler.shareAndUnshareRecords(Trigger.newMap, Trigger.oldMap);
                ContributionTeamTriggerHandler.addAndRemovePermissionSet(Trigger.new, Trigger.oldMap);
            }
            when  AFTER_DELETE
            {
                ContributionTeamTriggerHandler.unShareQuestionwithLeaders(Trigger.old);
                ContributionTeamTriggerHandler.removePermissionSet(JSON.serialize(Trigger.old));
                ContributionTeamTriggerHandler.unShareCTwithLeaders(Trigger.old);
            }
        }

}