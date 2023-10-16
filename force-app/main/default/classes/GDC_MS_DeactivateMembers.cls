public without sharing class GDC_MS_DeactivateMembers {
    @AuraEnabled( cacheable = true )
    public static List <OptionWrapper> fetchUsers() {
        List <OptionWrapper> listUsers = new List <OptionWrapper>();
        for ( gdc_ms_TeamMember__c  u : [ select id ,Name from gdc_ms_TeamMember__c where gdc_ms_isActive__c = true ORDER BY Name ] ) {
            listUsers.add(new OptionWrapper( u.Name, u.Id ));
        }
        return listUsers;
    }
    @AuraEnabled( cacheable = true )
    public static List <OptionWrapper> fetchInactiveUsers() {
        List <OptionWrapper> listUsers = new List <OptionWrapper>();
        list<GDC_MS_Inactive_Team_Members__c> csToUpdate = new list<GDC_MS_Inactive_Team_Members__c>();
        for ( gdc_ms_TeamMember__c  u : [ select id ,Name,gdc_ms_MappedUser__c from gdc_ms_TeamMember__c where gdc_ms_isActive__c = false  ] ) {
            GDC_MS_Inactive_Team_Members__c  mc = GDC_MS_Inactive_Team_Members__c.getInstance(u.gdc_ms_MappedUser__c);
            //system.debug('mc'+mc + '' + mc.gdc_ms_Is_Active__c);
            if(mc.SetupOwnerId == u.gdc_ms_MappedUser__c && !mc.gdc_ms_Is_Active__c && mc.gdc_ms_User_Email_Id__c!=null){
                listUsers.add(new OptionWrapper( u.Name, u.Id ));
            }
        }
        return listUsers;
    }
    @AuraEnabled
    public static string idToActivate(list<id> uId) {
      	list<gdc_ms_TeamMember__c> lstToUpdate = new list<gdc_ms_TeamMember__c>();
        list<GDC_MS_Inactive_Team_Members__c> csToUpdate = new list<GDC_MS_Inactive_Team_Members__c>();
        for ( gdc_ms_TeamMember__c  u : [ select id ,Name,gdc_ms_MappedUser__c,gdc_ms_isActive__c from gdc_ms_TeamMember__c where Id in :uId] ) {
            u.gdc_ms_isActive__c = true;
            GDC_MS_Inactive_Team_Members__c  mc = GDC_MS_Inactive_Team_Members__c.getInstance(u.gdc_ms_MappedUser__c);
            mc.gdc_ms_Is_Active__c = true;
           csToUpdate.add(mc);
           lstToUpdate.add(u);
        }
        	update csToUpdate; 
           	update lstToUpdate;
        	delete csToUpdate; 
        return JSON.serialize(lstToUpdate);
    }
    @AuraEnabled
    public static string idToDeactivate(list<id> uId) {
        //system.debug('uid'+uid);
        list<gdc_ms_TeamMember__c> lstToUpdate = new list<gdc_ms_TeamMember__c>();
        list<GDC_MS_Inactive_Team_Members__c> csToUpdate = new list<GDC_MS_Inactive_Team_Members__c>();
        set<string> errorName = new set<string>();
        
        map<Id,list<gdc_ms_TeamMember__c>> mapIDvsMember = new map<Id,list<gdc_ms_TeamMember__c>>();
        for(gdc_ms_TeamMember__c m : [select id ,Name,gdc_ms_Manager__c,gdc_ms_Manager__r.Name from gdc_ms_TeamMember__c where gdc_ms_isActive__c = true AND gdc_ms_Manager__r.id in :uId]){
            
            if(m.gdc_ms_Manager__c!=null){
                errorName.add(m.gdc_ms_Manager__r.Name);
            }
        }
        
        if(errorName.isEmpty()){
            for(gdc_ms_TeamMember__c u : [SELECT id ,Name, gdc_ms_MappedUser__c,gdc_ms_MappedUser__r.Email,gdc_ms_Manager__c,gdc_ms_isActive__c  FROM gdc_ms_TeamMember__c WHERE Id in :uId]){
                u.gdc_ms_isActive__c = false;
                GDC_MS_Inactive_Team_Members__c  cs = new GDC_MS_Inactive_Team_Members__c ();
                cs.gdc_ms_User_Email_Id__c  = u.gdc_ms_MappedUser__r.Email;
                cs.SetupOwnerId  = u.gdc_ms_MappedUser__c;
                csToUpdate.add(cs);
                lstToUpdate.add(u);
                system.debug('Single User');
                
            }
            //system.debug('list -'+lstToUpdate);
            //system.debug('list -'+csToUpdate);
            insert csToUpdate; 
            update lstToUpdate;
            
            return JSON.serialize(lstToUpdate);
        }
        else{
            system.debug('Error scenario'+errorName);
            return JSON.serialize(errorName);
        }
    }
    public class OptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        public OptionWrapper( String label, String value ) {
            this.label = label;
            this.value = value;
        }
    }
}