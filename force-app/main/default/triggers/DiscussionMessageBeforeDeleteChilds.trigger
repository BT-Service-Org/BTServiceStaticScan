trigger DiscussionMessageBeforeDeleteChilds on DiscussionMessage__c (before delete) {
	
	/*	for (DiscussionMessage__c m : Trigger.old) {
			
			List<DiscussionMessage__c> childs = new List<DiscussionMessage__c>(); 
			
			SampleClass s = new Sampleclass();
          
          	childs = s.GetChildsMessage(m,childs);
          	
          	for (DiscussionMessage__c me : childs) {
          	
          	 
          			delete me;
          	 	
          	}
          	
          	
		}
	*/
}