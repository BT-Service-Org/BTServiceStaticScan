@IsTest private class TeamsWidgetMilestonesTest {
    
    public static testMethod void TeamsWidgetMilestones() {
        TeamsWidgetMilestonesController m = new TeamsWidgetMilestonesController();
        
        TeamsWidgetMilestonesController.ProjectTasks projectTaskClass = new TeamsWidgetMilestonesController.ProjectTasks();
        
         projectTaskClass.getPicture();
          projectTaskClass.getEndDate();
          projectTaskClass.getIsToLate();
          projectTaskClass.getUserId();
          projectTaskClass.getUserName();
          projectTaskClass.getTaskId();
          projectTaskClass.getPriority();

          projectTaskClass.getTaskName();
        
        m.setTeamId('a0B30000001xHJcEAM');
        String team = m.getTeamId();
        if(team == null){
            System.assert(false, 'getTeamId error');
        }
        
        //COMMENT
        Integer listS = m.getListSize();
        if(listS == null){
            System.assert(false, 'getListSize error');
        }
        
        UserPermissions userPermissions = new UserPermissions();
        userPermissions = m.getUserPermissions();
        
        List<TeamsWidgetMilestonesController.ProjectTasks> listP = m.getAllProjectTasks();
        
         

    }
}