@IsTest private class TeamsCreateNewTaskControllerTest {
    
    public static testMethod void TestCreateTask()
    {
        TeamsCreateNewTaskController n = new TeamsCreateNewTaskController();
        String type2 = n.getTypeOfAction();
        System.assertEquals(type2,'Add New');   
        n.saveTask();
        n.canUpdate();
        n.saveAssignees();

        n.setParam('0000sdasdas0dasd');
        
        List<SelectOption> percent = n.getPercent();
        if(percent.size() == 0){
            System.assert(false, 'Percent error');
        }
        
        List<SelectOption> member = n.getMembers();
        if(member.size() == 0){
            System.assert(false, 'no members');
        }
        
         List<SelectOption> priority =  n.getPriority();
         if(priority.size() == 0){
            System.assert(false, 'no priority List');
         }
        
        TeamsCreateNewTaskController.dateMyFormat dateMy =  n.getdateMy();
         if(dateMy == null){
            System.assert(false, 'No correct Reference');
         }
         
        
        TeamsCreateNewTaskController.assingTo assign = n.getassingTo();
         if(assign == null){
            System.assert(false, 'No correct Reference');
         }
         
         ProjectTask__c taskP = n.getTask();
         if(taskP == null){
            System.assert(false, 'No correct Reference');
         }
         
         List<SelectOption> perD = n.getPercentDedicated();
        if(perD.size() == 0){
            System.assert(false, 'no priority List');
         }
         
        List<TeamsCreateNewTaskController.assingTo> assTo = n.getAssignMember();
        if(assTo == null){
            System.assert(false, 'no priority List');
         }
         
        ProjectTask__c task = [select id, Team__c from ProjectTask__c limit 1];
        n.getTaskForEdit(task.Team__c, task.Id);
        n.setAttachment(task.Id);
        
        TeamsCreateNewTaskController.dateMyFormat dmf = n.getdateMy();
        if(dmf == null){
            System.assert(false, 'Error >> getdateMy()');
         }
         
        //UserPermissions userPermissions = new UserPermissions(); 
        UserPermissions userPermissions = n.getUserPermissions();
        if(userPermissions == null){
            System.assert(false, 'Error >> getUserPermissions()');
         }
         
         
         List<TeamsCreateNewTaskController.myAttachment> at = n.getAttachment();
         if(at == null){
            System.assert(false, 'Error >> getUserPermissions()');
         }
         
         
         n.param = task.Team__c;
         n.idTask = task.Id; 
         if(n.param != null && n.idTask != null){
            n.getTaskForEdit(n.param, n.idTask);
         }
         
         n.genTempTask();
         
         TeamsCreateNewTaskController.myAttachment mA = new TeamsCreateNewTaskController.myAttachment();
         
         Integer bl = mA.getBodyLenght();
         if(bl == null){
            System.assert(false, 'Error >> getBodyLenght()');
         }
         String idAt = mA.getidAttachment(); 
         if(idAt == null){
            System.assert(false, 'Error >> getidAttachment()');
         }
         String ct = mA.getContentType();
         if(ct == null){
            System.assert(false, 'Error >> getContentType()');
         }
         String na = mA.getNameAttachment(); 
         if(na == null){
            System.assert(false, 'Error >> getNameAttachment()');
         }
        
         
        
         
    }   
}