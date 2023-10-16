trigger CommunityContributionTrigger on Community_Contribution__c (before insert, before update) {
	
	for (Community_Contribution__c contrib : Trigger.new) {			
		contrib.Community_Leader__c = Util.getValue(contrib.Community__c);
		if (contrib.Status__c == null || contrib.Status__c == '') {
			contrib.Status__c = 'Draft';
		}
		
	}
		
}