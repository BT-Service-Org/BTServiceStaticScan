public class ItemsToApproveController {
    
    public ItemsToApproveController(){
        
    }
    
    public List<ProcessInstanceWorkItem> getWorkItems(){
        List<ProcessInstanceWorkItem> results = new List<ProcessInstanceWorkItem>();
        List<ProcessInstanceWorkItem> allItems = [SELECT originalActor.name, processInstance.targetObjectId,
                                                  ProcessInstance.TargetObject.name, processInstance.status,
                                                  processinstance.ProcessDefinition.name, ProcessInstance.CreatedDate
                                                 FROM ProcessInstanceWorkItem
                                                 WHERE ActorId = :UserInfo.getUserID() AND processInstance.status=: 'Pending'];
        for(ProcessInstanceWorkItem thisItem : allItems){
            results.add(thisItem);
        }
        Return results;
    }

}