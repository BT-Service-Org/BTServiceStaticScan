/****************************
* Created By - Kushagra, Sehrab and Vibhor
* Purpose - This class is used to schedule the GDC_MS_AutomateMSTeamMember_Batch class run.
****************************/
global class GDC_MS_TeamMemberBatch_Schedulable implements Schedulable { 
    global void execute (SchedulableContext ctx) {
        GDC_MS_RootTeamMember__c  mc = GDC_MS_RootTeamMember__c.getOrgDefaults();
        Id rootMember = (Id)mc.gdc_ms_RootTeamMemberID__c;
        Set<Id> managerIds = new Set<Id>();
        User user = [Select id,Title,Name,ManagerId,isActive,(Select id from gdc_Team_Members__r) from User where id =:rootMember limit 1];
        
        gdc_ms_TeamMember__c newTeamMember = new gdc_ms_TeamMember__c();
        newTeamMember.Name = user.Name;
        newTeamMember.gdc_ms_Designation__c = user.Title;
        newTeamMember.gdc_ms_MappedUser__c  = user.id;
        newTeamMember.gdc_ms_isActive__c = user.IsActive;
        newTeamMember.id = user.gdc_Team_Members__r?.id;
        managerIds.add(user.id);
        Database.UpsertResult[] results = Database.upsert(new List<gdc_ms_TeamMember__c> {newTeamMember});
        for (Database.UpsertResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    Log.error(err.getMessage() );
                }
            }
        } 
        GDC_MS_TeamMember_Batch obj = new GDC_MS_TeamMember_Batch(managerIds);
        Database.executeBatch(obj,2000);
        
    } 
}