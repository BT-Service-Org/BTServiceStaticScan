trigger ProjectTaskAfterUpsertAccions on ProjectTask__c (after insert, after update) {

	/*List<Event> eventList = new List<Event>();
		
	for (ProjectTask__c p : Trigger.new) {
		PrjTaskEventSynchRules rules = new PrjTaskEventSynchRules();
		Event oEvent = rules.applyRulesOnProjectTaskUpsert(p, Trigger.isInsert, Trigger.isUpdate);
		if (oEvent != null) {
			eventList.add(oEvent);
		}
	}//for (ProjectTask__c p : Trigger.new)
	
	if(eventList != null){
		upsert eventList;
	}
	
	*/
}