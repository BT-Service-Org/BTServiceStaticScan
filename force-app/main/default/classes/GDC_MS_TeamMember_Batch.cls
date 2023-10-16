public class GDC_MS_TeamMember_Batch implements Database.Batchable<sObject>{
    
    public Set<Id> setUserIds = new Set<Id>();
    public GDC_MS_TeamMember_Batch(Set<Id> setIds) {
        this.setUserIds= setIds;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        GDC_MS_RootTeamMember__c  mc = GDC_MS_RootTeamMember__c.getOrgDefaults();
        Id rootMember = (Id)mc.gdc_ms_RootTeamMemberID__c;
        String query = 'Select Id FROM User WHERE Name = \'DONT USE\' AND ManagerId = :rootMember LIMIT 1';
        if(!setUserIds.isEmpty()) {
            query = 'Select id,Title,Name,ManagerId,isActive,(Select id from gdc_Team_Members__r) from User where ManagerId IN :setUserIds';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<PermissionSetAssignment> permissionSetinsertList = new List<PermissionSetAssignment>();
        List<PermissionSet> permSetGdc = [SELECT Id, Label FROM PermissionSet WHERE Name = 'GDC_MS_Permisson_Set'];
        List<PermissionSetAssignment> lstofPSA = new List<PermissionSetAssignment>([SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permSetGdc[0].id]);
        Set<Id> setAssignees= new Set<Id>();
        for(PermissionSetAssignment objPSA : lstofPSA){
            if(!setAssignees.contains(objPSA.AssigneeId)){
                setAssignees.add(objPSA.AssigneeId);
            }
        }
        for(sobject s : scope){
            User objUser = (User)s;
            if(objUser.isActive && (setAssignees.isEmpty() || (!setAssignees.isEmpty() && !setAssignees.contains(objUser.Id)))){
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permSetGdc[0].id , AssigneeId = objUser.Id );
                permissionSetinsertList.add(psa);
            }
        }
        if(!permissionSetinsertList.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(permissionSetinsertList, false);
            for (Database.SaveResult sr : srList) {
                 if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        Log.error(err.getMessage(),BC.getJobId() );
                    }
                }
            }
        }
        if(!setUserIds.isEmpty()) {
            System.enqueueJob(new GDC_MS_TeamMember_Queuable(setUserIds));
        }
    }
    
    public void finish(Database.BatchableContext BC){ 
    }
}