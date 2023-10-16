@IsTest private class ProjectTaskDetailTest {
    public static testMethod void testProject() { 
		try{
	        ProjectTaskDetailController project = new ProjectTaskDetailController();
	        
	        //
	        ProjectTask__c projectTask = [select 	p.Id,
				                                    p.Team__c,
				                                    p.Team__r.Name, 
				                                    p.Startdate__c, 
				                                    p.Priority__c, 
				                                    p.ParentTask__c, 
				                                    p.Percent_Completed__c,
				                                    p.Name, 
				                                    p.Milestone__c, 
				                                    p.LastModifiedById, 
				                                    p.EndDate__c, 
				                                    p.Duration__c, 
				                                    p.Description__c, 
				                                    p.CreatedById, 
				                                    (Select Id, User__c From ProjectAssignee__r) 	        
				         						from ProjectTask__c p limit 1];
				         						
				         						
			project.param = projectTask.Id;
			project.getTask(projectTask.Id);
	        project.genPermissions();
	        project.getUserPermissions();			
			//project.markComplete();		

	        //
	        ProjectTaskDetailController.TaskDetails TaskDetail   = new ProjectTaskDetailController.TaskDetails();	        
	        TaskDetail.id = projectTask.Id;
	        String id = TaskDetail.id;
	            
	        //
	        ProjectTaskDetailController.ProjectAssignee assigns = new ProjectTaskDetailController.ProjectAssignee();
	        assigns.getId();
	        assigns.setId('Id');
	        assigns.setName('Name');
	        assigns.getPercent();
	        assigns.setPercent(1);
	        
	        //
	        ProjectTaskDetailController.AttachmentInfo attach = new ProjectTaskDetailController.AttachmentInfo();
	        attach.getId();
	        attach.setId('');
	        attach.getName();
	        attach.setName('Name');
	        attach.getAttachImage();
	        attach.setAttachImage('');
	        
	        //
	        TaskDetail.Name = projectTask.Name;
	        String name = TaskDetail.Name;
	        
	        TaskDetail.TeamName = projectTask.Team__r.Name;
	        String teamName = TaskDetail.TeamName;
	        
	        TaskDetail.Priority = projectTask.Priority__c;
	        String priority = TaskDetail.Priority;
	        
	        TaskDetail.Startdate = ((projectTask.Startdate__c).format('MM/dd/yyyy'));
	        String startdate = TaskDetail.Startdate;
	        
	        TaskDetail.DueDate = ((projectTask.EndDate__c).format('MM/dd/yyyy'));
	        String dueDate = TaskDetail.DueDate;
	        
	        TaskDetail.Estimate = (projectTask.Duration__c).intValue();
	        Integer estimate = TaskDetail.Estimate;
	         
	        TaskDetail.Description = projectTask.Description__c;
	        String description = TaskDetail.Description;
	        
	        UserPermissionsTest.UserPermissionsTest();	
		
		}catch(Exception e){
			throw e;
		}
    }
}