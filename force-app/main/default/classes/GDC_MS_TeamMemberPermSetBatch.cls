public class GDC_MS_TeamMemberPermSetBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        GDC_MS_RootTeamMember__c  mc = GDC_MS_RootTeamMember__c.getOrgDefaults();
        Id rootMember = (Id)mc.gdc_ms_RootTeamMemberID__c;
        String fieldName = mc.gdc_ms_RootTeamMemberFieldName__c ;
        DateTime lastRunTime = (DateTime)mc.gdc_ms_LastRunTimestamp__c;
        String query = 'Select id,Title,Name,ManagerId,isActive, Mgmt_Chain_Hierarchy_Level_06__c,(Select id from gdc_Team_Members__r) from User where  '+fieldName+'  =:rootMember';
        if(lastRunTime!=null){
            query += ' and SystemModStamp > :lastRunTime';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<PermissionSetAssignment> permissionSetinsertList = new List<PermissionSetAssignment>();
        List<PermissionSet> permSetGdc = [SELECT Id, Label FROM PermissionSet WHERE Name = 'GDC_MS_Permisson_Set'];
        for(sobject s : scope){
            User user = (User)s;
            if(user.gdc_Team_Members__r.size() == 0){
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permSetGdc[0].id , AssigneeId = user.Id );
                permissionSetinsertList.add(psa);
            }
        }
        
        Database.SaveResult[] srList = Database.insert(permissionSetinsertList, false);
        for (Database.SaveResult sr : srList) {
             if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    Log.error(err.getMessage(),BC.getJobId() );
                }
            }
        }
    }
    
    
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new GDC_MS_AutomateMSTeamMember_Batch()); 
    }

}