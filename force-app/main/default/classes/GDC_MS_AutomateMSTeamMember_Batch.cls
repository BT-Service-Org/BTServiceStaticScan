/****************************
* Created By - Kushagra, Sehrab and Vibhor
* Purpose - This is a batch class, used for querying user records present in GDC and creating a team member 
* for each of those user records.
****************************/

public class GDC_MS_AutomateMSTeamMember_Batch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        GDC_MS_RootTeamMember__c  mc = GDC_MS_RootTeamMember__c.getOrgDefaults();
        Id rootMember = (Id)mc.gdc_ms_RootTeamMemberID__c;
        String fieldName = mc.gdc_ms_RootTeamMemberFieldName__c ;
        DateTime lastRunTime = (DateTime)mc.gdc_ms_LastRunTimestamp__c;
        String query = 'Select id,Title,Name,ManagerId,isActive, Mgmt_Chain_Hierarchy_Level_06__c,(Select id from gdc_Team_Members__r) from User where  '+fieldName+' =:rootMember';
        if(lastRunTime!=null){
            query += ' and SystemModStamp > :lastRunTime';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<gdc_ms_TeamMember__c> TeamMemberList= new List<gdc_ms_TeamMember__c>();
        for(sobject s : scope){
            TeamMemberList.add(addTeamMember((User)s));
            System.debug(addTeamMember((User)s));
        }
        Database.UpsertResult[] results = Database.upsert(TeamMemberList);
        for (Database.UpsertResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    Log.error(err.getMessage(),BC.getJobId() );
                }
            }
        }
    }
    
    public gdc_ms_TeamMember__c addTeamMember(User user){
        gdc_ms_TeamMember__c newTeamMember = new gdc_ms_TeamMember__c();
        newTeamMember.Name = user.Name;
        newTeamMember.gdc_ms_Designation__c = user.Title;
        newTeamMember.gdc_ms_MappedUser__c  = user.id;
        newTeamMember.gdc_ms_isActive__c = user.IsActive;
        newTeamMember.id = user.gdc_Team_Members__r?.id;
        newTeamMember.Ownerid = user.id;
        return newTeamMember;
    }
    
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new GDC_MS_UpdateMSTeamMemberManager());
        GDC_MS_RootTeamMember__c  mc = GDC_MS_RootTeamMember__c.getOrgDefaults();
        mc.gdc_ms_LastRunTimestamp__c = DateTime.now();
        update mc; 
    }
}