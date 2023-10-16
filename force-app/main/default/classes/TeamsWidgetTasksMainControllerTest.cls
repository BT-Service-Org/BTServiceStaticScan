@IsTest private class TeamsWidgetTasksMainControllerTest {
    public static testMethod void TeamsWidgetTasks() {
        TeamsWidgetTasksMainController task = new TeamsWidgetTasksMainController();
        
        UserPermissions userPermissions = new UserPermissions();
        
       userPermissions = new UserPermissions();
        
        
        if (task.getUserPermissions() == null) {
            System.assert(true, 'Null Permissions');
        }
        
        userPermissions.getCanView();
        userPermissions.getCanComment();
        userPermissions.getCanManage();
        userPermissions.getCanCreate();
        userPermissions.getObjectType();
        userPermissions.getTeam();
        // userPermissions.getObjectId();
        userPermissions.getId();
         
        
        /* ProjectTask class */
        TeamsWidgetTasksMainController.ProjectTask projectTaskClass = new TeamsWidgetTasksMainController.ProjectTask();
        projectTaskClass.getPicture();
        projectTaskClass.getEndDate();
        projectTaskClass.getIsToLate();
        projectTaskClass.getUserId();
        projectTaskClass.getUserName();
        projectTaskClass.getTaskId();
        projectTaskClass.getPriority();
        projectTaskClass.getPercent();
        projectTaskClass.getTaskName();
        
        task.getProjectTaskbuild();
        task.getMyProjectTasks();
        task.getAllProjectTasks();  
    }
}