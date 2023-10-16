public class GDC_DA_PSAssignBatch implements Database.Batchable<sObject> {
	
     public Database.QueryLocator start(Database.BatchableContext BC){
        GDCDAPermission__c cs = GDCDAPermission__c.getOrgDefaults();
        Id userId = (Id)cs.UserId__c;
        String fieldName = cs.FieldName__c  ;
        DateTime lastRunTime = (DateTime)cs.LastRunTime__c;
        List<PermissionSet> pslist = [SELECT Id FROM PermissionSet WHERE Name in ('GDC_DA_Project_Delivery_Assurance_Permission_GeoLead','GDC_DA_Project_Delivery_Assurance_Permission')];
        String query = 'SELECT id,Title,Name,isActive from User WHERE isActive = true AND '+fieldName+'  =:userId and id NOT in (SELECT AssigneeId from PermissionSetAssignment where PermissionSetId IN:pslist )';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<PermissionSetAssignment> permissionSetinsertList = new List<PermissionSetAssignment>();
        PermissionSet leadPS = [SELECT Id, Label FROM PermissionSet WHERE Name = 'GDC_DA_Project_Delivery_Assurance_Permission_GeoLead'];
        PermissionSet teamMemberPS = [SELECT Id, Label FROM PermissionSet WHERE Name = 'GDC_DA_Project_Delivery_Assurance_Permission'];
        for(sobject s : scope){
            User user = (User)s;
            if(user.Title.containsIgnoreCase('Manager')){
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = leadPS.id , AssigneeId = user.Id );
                permissionSetinsertList.add(psa);
            }else{
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = teamMemberPS.id , AssigneeId = user.Id );
                permissionSetinsertList.add(psa);
            }        
        }
        
        Database.SaveResult[] srList = Database.insert(permissionSetinsertList, false);
    }
    
    
    public void finish(Database.BatchableContext BC){
        GDCDAPermission__c  cs = GDCDAPermission__c.getOrgDefaults();
        cs.LastRunTime__c = DateTime.now();
        update cs;
    }
}