global class GDC_DA_SyncTeamMembersBatch  implements Database.Batchable<sObject>{
    @testvisible private static List<pse_Assignment_c__x> mockedRequests= new List<pse_Assignment_c__x>() ;
    @testvisible private static list<Contact__x> mockedconX = new list<Contact__x>();
    private static boolean testRunFlag = test.isRunningTest();
    global Database.QueryLocator start(Database.BatchableContext ctx){
        String query = 'select pse_Resource_c__c,Resource_Region_c__c,Project_Region_c__c,pse_Start_Date_c__c,pse_End_Date_c__c, pse_Project_c__c,ExternalId FROM pse_Assignment_c__x WHERE Resource_Region_c__c=\'GDC Hyderabad (Contacts Only)\' AND (Project_Region_c__c !=\'Worldwide - Services\' AND Project_Region_c__c !=\'WW - Accelerators\' AND Project_Region_c__c !=\'WW - Services\') AND pse_Status_c__c=\'Scheduled\' AND LastModifiedDate__c >= LAST_N_DAYS:1 AND pse_Is_Billable_c__c= True'; 
        return Database.getQueryLocator(query);  
    }
    
    global void execute (Database.BatchableContext ctx, List<pse_Assignment_c__x> scope){
        Date todaydate= System.today();
        Set <Id> projectIdSet = New Set<Id>();
        Set<Id> contactIdset = new Set <Id>();
        Map<String,String> contactEmailMap = new Map<String,String> ();
        Map<String,User> userMap = new Map<String,User>();
        Map<String,GDC_DA_Project_Setup__c> projectMap = new Map<String,GDC_DA_Project_Setup__c>();
        List<GDC_DA_Team_Member__c> teamMemberList = new List<GDC_DA_Team_Member__c>();
        
        for(pse_Assignment_c__x ass1: scope){
            projectIdSet.add(ass1.pse_Project_c__c);
            contactIdset.add(ass1.pse_Resource_c__c);
            system.debug('contactIdset'+contactIdset);
        }
        
        for (Contact__x con :(testRunFlag?mockedconX :[Select ExternalId, Email__c FROM Contact__x where ExternalId IN : contactIdset])){
            contactEmailMap.put(con.ExternalId,con.Email__c);
        }
        System.debug('contactEmailMap'+contactEmailMap);
        for(User u :[select id,Name,Email from user where Email IN :contactEmailMap.values()]){
            if(!userMap.containskey(u.Email)){
                userMap.put(u.Email,u);
            }
        }
        System.debug('userMap'+userMap);
        
        for(GDC_DA_Project_Setup__c proj:[select id,ExternalId__c,Name,Active__c from GDC_DA_Project_Setup__c where ExternalId__c IN : projectIdSet]){
            
            projectMap.put(proj.ExternalId__c,proj);
        }
        
        for(pse_Assignment_c__x ass : scope){
            System.debug('Line 59');
            if(!projectMap.isEmpty() && projectMap.containsKey(ass.pse_Project_c__c)){
                if(!contactEmailMap.isEmpty() && contactEmailMap.containsKey(ass.pse_Resource_c__c)){
                    GDC_DA_Team_Member__c teamMember = new GDC_DA_Team_Member__c();
                    system.debug('resource'+ass.pse_Resource_c__c);
                    system.debug('resource2'+contactEmailMap.get(ass.pse_Resource_c__c));
                    
                    String contactEmail =contactEmailMap.get(ass.pse_Resource_c__c);
                    system.debug('contactEmail'+contactEmail);
                    If(userMap.containsKey(contactEmail)){
                        teamMember.Name__c = userMap.get(contactEmail).Id;
                        teamMember.ExternalId__c = ass.ExternalId;
                        teamMember.Project__c= projectMap.get(ass.pse_Project_c__c).id;
                        teamMember.Start_Date__c = ass.pse_Start_Date_c__c;
                        teamMember.End_Date__c = ass.pse_End_Date_c__c;
                        teamMemberList.add(teamMember);
                        if(projectMap.get(ass.pse_Project_c__c).Active__c == True && ass.pse_Start_Date_c__c  <= todaydate && ass.pse_End_Date_c__c >= todaydate){
                            teamMember.Active__c = True; 
                        }else{
                            teamMember.Active__c = False; 
                        }
                        
                    }
                }
            }
        }
        
        Database.UpsertResult[] results = Database.Upsert(teamMemberList,GDC_DA_Team_Member__c.Fields.ExternalId__c,false);
        for (Database.UpsertResult result : results) {
            if (result.isSuccess ()){
                System.debug('Record Updated');
            } else{
                for(Database.Error err : result.getErrors()) {
                    Log.error(err.getMessage(),ctx.getJobId() );
                }
            }
        }
    }
    global void finish (Database.BatchableContext ctx){
        
    }  
}