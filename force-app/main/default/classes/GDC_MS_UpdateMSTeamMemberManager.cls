/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This is a batch class, used for setting the managers for team member records.
 ****************************/

 public class GDC_MS_UpdateMSTeamMemberManager implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id,gdc_ms_Manager__c,gdc_ms_MappedUser__r.ManagerId from gdc_ms_TeamMember__c where SystemModStamp = TODAY';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<id> managerId = new Set<id> ();
        for(sObject s : scope){
            managerId.add(((gdc_ms_TeamMember__c)s).gdc_ms_MappedUser__r.ManagerId);
        }
        
        List<gdc_ms_TeamMember__c> Managers = [Select id,gdc_ms_MappedUser__c from gdc_ms_TeamMember__c where gdc_ms_MappedUser__c in :managerId];
        Map<id,id> managerUserIdMap = new Map<id,id>();
        for(gdc_ms_TeamMember__c member : Managers){
            managerUserIdMap.put(member.gdc_ms_MappedUser__c,member.id);
        }
        
        for(sObject s : scope){
            ((gdc_ms_TeamMember__c)s).gdc_ms_Manager__c = managerUserIdMap.get(((gdc_ms_TeamMember__c)s).gdc_ms_MappedUser__r.ManagerId);
        } 
        Database.SaveResult[] srList = Database.update(scope);
        for (Database.SaveResult sr : srList) {
             if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    Log.error(err.getMessage(),BC.getJobId() );
                }
            }
        }
    }
    
    
    
    public void finish(Database.BatchableContext BC){
    }
}