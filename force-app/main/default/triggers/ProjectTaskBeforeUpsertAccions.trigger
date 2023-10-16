trigger ProjectTaskBeforeUpsertAccions on ProjectTask__c bulk (before insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
				
			/*
			  This trigger calculates the end date
			*/
			List<String> idsProjectTask = new List<String>();
			for (ProjectTask__c p : Trigger.new) {
				idsProjectTask.add(p.project__c);	
			}
			
			List<ProjectTask__c> taskInProject = [SELECT Id, project__c FROM ProjectTask__c WHERE project__c in: idsProjectTask];
			
			for (ProjectTask__c p : Trigger.new) {	
				//Set the correlative taskPosition in project
				Integer countTask = 0;
				Integer countSizeProject = 0;
				for (ProjectTask__c projectT : taskInProject) {
					if (projectT.Project__c == p.Project__c) {
						countSizeProject++;
					}	
				}
				Long projectTaskQuantity = countSizeProject;
				p.Task_Position__c = projectTaskQuantity + 1; 
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}