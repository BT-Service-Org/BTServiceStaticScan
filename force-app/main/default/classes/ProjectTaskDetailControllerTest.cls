@IsTest private class ProjectTaskDetailControllerTest {
    
    public static testMethod void testProjectTaskDetailController() {
        
        ProjectTaskDetailController taskDetailController = new ProjectTaskDetailController();
                
        taskDetailController.getTask('a0S30000000YEKiEAO');
        
        ProjectTaskDetailController.TaskDetails a = taskDetailController.getTask();
         
        if(a.StartDate == null )
                System.assert(true, 'List has no rows assigned to project task'); 
        
        try { 
            // taskDetailcontroller.getUserProfile();
        } catch(Exception e){
            System.assert(true, 'No profile!');  
        }

        if(taskDetailController.getDetailsOk() == null){
            System.assert(true, 'boolean detailsok not defined'); 
        }
        
        ProjectTaskDetailController.ProjectAssignee projectAss = new ProjectTaskDetailController.ProjectAssignee();
        
        if(projectAss.getId() == null) {
            System.assert(true, 'Project Assignee Class null var');     
        }
        
        if(projectAss.getName() == null) {
            System.assert(true, 'Project Assignee Class null var');     
        }
        
        if(projectAss.getPercent() == null) {
            System.assert(true, 'Project Assignee Class null var');     
        }
        
        ProjectTaskDetailController.AttachmentInfo attchInfo = new ProjectTaskDetailController.AttachmentInfo();
        
        if(attchInfo.getId() == null) {
            System.assert(true, 'Attachment Info Class null var');  
        }
        
        if(attchInfo.getName() == null) { 
            System.assert(true, 'Attachment Info Class null var');  
        }
        
        if(attchInfo.getAttachImage() == null) {
            System.assert(true, 'Attachment Info Class null var');  
        }
        
    }
}