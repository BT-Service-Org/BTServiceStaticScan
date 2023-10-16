trigger GamificationTrigger on Gamification__e (after insert) {
    if(Trigger.isAfter && trigger.isInsert){
		    GamificationTriggerHandler.pscGamification(Trigger.New);
    }
}