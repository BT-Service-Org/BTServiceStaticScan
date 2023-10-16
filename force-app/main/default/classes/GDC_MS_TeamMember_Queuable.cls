public class GDC_MS_TeamMember_Queuable implements Queueable{
    
    public List<gdc_ms_TeamMember__c> TeamMemberList= new List<gdc_ms_TeamMember__c>();
    public Set<Id> setOfUserIds = new Set<Id>();
    public List<gdc_ms_TeamMember__c> listOfTeamMember;
    public Map<Id,gdc_ms_TeamMember__c> mapUserIdVsTeamMember;
    public Map<Id,gdc_ms_TeamMember__c> managerTeamMemberMap;
    public GDC_MS_TeamMember_Queuable(Set<Id> setUserIds) {
        setOfUserIds = setUserIds;
    }
    public void execute(QueueableContext context) {
        Set<Id> setOfNextLevelUsers = new Set<Id>();
        List<User> listOfUser = [Select id,Title,Name,ManagerId,isActive,(Select id from gdc_Team_Members__r) from User where ManagerId IN :setOfUserIds];
        listOfTeamMember = new list<gdc_ms_TeamMember__c>([SELECT Id,gdc_ms_MappedUser__c FROM gdc_ms_TeamMember__c WHERE
                                                                                               gdc_ms_MappedUser__c In :setOfUserIds]);
        
        
        managerTeamMemberMap= new Map<Id,gdc_ms_TeamMember__c>();
        
        for(gdc_ms_TeamMember__c teamMember : listOfTeamMember){
            if(!managerTeamMemberMap.containsKey(teamMember.gdc_ms_MappedUser__c)){
                managerTeamMemberMap.put(teamMember.gdc_ms_MappedUser__c, teamMember);
            }
        }
        if(!listOfUser.isEmpty()) {
            for(User user: listOfUser){
                setOfNextLevelUsers.add(User.Id);
                TeamMemberList.add(addTeamMember(user)); 
            }
        }
        
        if(!TeamMemberList.isEmpty()){
            Database.UpsertResult[] results = Database.upsert(TeamMemberList);
            for (Database.UpsertResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        Log.error(err.getMessage(),context.getJobId() );
                    }
                } 
            } 
        }
        
        if(!setOfNextLevelUsers.isEmpty()) {
            Database.executeBatch(new GDC_MS_TeamMember_Batch(setOfNextLevelUsers),2000);
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
        newTeamMember.gdc_ms_Manager__c = (!managerTeamMemberMap.isEmpty() && managerTeamMemberMap.containsKey(user.managerId)) ? managerTeamMemberMap.get(user.managerId).id : null;
        return newTeamMember;
    }
}