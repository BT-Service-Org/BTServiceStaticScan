global class GDC_DA_SyncProjectBatch  implements Database.Batchable<sObject> {
    @testvisible private static List<pse_Assignment_c__x> mockedRequests= new List<pse_Assignment_c__x>() ;
    @testvisible private static List<pse_Proj_c__x> mockedRequestspseProject= new List<pse_Proj_c__x>() ;
    private static boolean testRunFlag = test.isRunningTest();
    global Database.QueryLocator start(Database.BatchableContext ctx){
        String query = 'select pse_Resource_c__c,Resource_Region_c__c,Project_Region_c__c,pse_Start_Date_c__c,pse_End_Date_c__c, pse_Project_c__c,ExternalId FROM pse_Assignment_c__x WHERE Resource_Region_c__c=\'GDC Hyderabad (Contacts Only)\' AND (Project_Region_c__c !=\'Worldwide - Services\' AND Project_Region_c__c !=\'WW - Accelerators\' AND Project_Region_c__c !=\'WW - Services\') AND pse_Status_c__c=\'Scheduled\' AND pse_Is_Billable_c__c= True'; 
        return Database.getQueryLocator(query);
        
    }
    
    global void execute (Database.BatchableContext ctx, List<pse_Assignment_c__x> scope){
        Set <Id> projectIdSet = New Set<Id>();
        Set<Id> contactIdset = new Set <Id>();
        Map<Id,pse_Proj_c__x> psaProjectMap = new Map <Id,pse_Proj_c__x> ();
        Map<String,String> ProjectIdNameMap= new Map<String,String> ();
        Map<Id,GDC_DA_Project_Setup__c> projectMapToInsert = new Map<Id,GDC_DA_Project_Setup__c>();
        Set<string> namesFilter = new Set<String>();
        Map<String,GDC_DA_Configuration__c> regionCS = GDC_DA_Configuration__c.getAll();
        String regionName;
        for(String name: label.GDC_Project_Name.split(',')){
            namesFilter.add(name);
        }
        
        for(pse_Assignment_c__x ass1: scope){
            projectIdSet.add(ass1.pse_Project_c__c);
            contactIdset.add(ass1.pse_Resource_c__c);
        } 
        For(pse_Proj_c__x p :(testRunFlag?mockedRequestspseProject:[Select Id,Name__c,pse_Start_Date_c__c,pse_End_Date_c__c,ExternalId FROM pse_Proj_c__x Where ExternalId IN :projectIdSet AND LastModifiedDate__c >= LAST_N_DAYS:1 AND (Name__c NOT IN:namesFilter And (NOT Name__c Like 'Z-%') AND (NOT Name__c Like 'Z -%'))])){
            psaProjectMap.put(p.ExternalId,p);
        }
        System.debug('psaProjectMap'+psaProjectMap);
        
        for(pse_Assignment_c__x ass1: scope){
            If(!psaProjectMap.isEmpty() && psaProjectMap.containsKey(ass1.pse_Project_c__c)){
                pse_Proj_c__x proj = psaProjectMap.get(ass1.pse_Project_c__c);
                ProjectIdNameMap.put(proj.ExternalId,proj.Name__c);
                GDC_DA_Project_Setup__c project = new GDC_DA_Project_Setup__c();
                if(ass1.Project_Region_c__c.contains('APAC India') || ass1.Project_Region_c__c.contains('APAC Asia') || ass1.Project_Region_c__c.contains('LATAM') ){
                    regionName = ass1.Project_Region_c__c;
                }else{
                    regionName = ass1.Project_Region_c__c.substring(0,4);
                }
                GDC_DA_Configuration__c  cs = regionCS.get(regionName);
                System.debug('cs'+cs);
                project.ExternalId__c = proj.ExternalId;
                project.Name = proj.Name__c;
                project.Project_Owner__c = cs.Owner__c;
                if(cs.Region__c.contains('India')){
                    project.Region__c ='APAC-In';
                }
                else if(cs.Region__c.contains('Asia') || cs.Region__c.contains('ANZ')){
                    project.Region__c ='APAC (Asia, ANZ)';
                }
                else if(cs.Region__c.contains('LATAM')){
                    project.Region__c ='LATAM';
                }
                else if(cs.Region__c.contains('AMER')){
                    project.Region__c ='AMER';
                }
                else{
                    project.Region__c = cs.Region__c;
                }
                project.Metric_Entry_Start_Date__c = proj.pse_Start_Date_c__c;
                project.Metric_Entry_End_Date__c = proj.pse_End_Date_c__c;
                project.Metrics_Required__c ='Apex Test Coverage %;	Code Quality%;Rejected Defect%';
                project.Comments__c = 'Link to Evaluation Quip (Geo Owner / Lead to Update)'; 
                if(cs.Active__c){
                    project.Active__c = True;
                }
                projectMapToInsert.put(project.ExternalId__c,project);
            }
        } 
        
        Database.UpsertResult[] results = Database.upsert(projectMapToInsert.values(),GDC_DA_Project_Setup__c.Fields.ExternalId__c);
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
        Database.executeBatch(new GDC_DA_SyncTeamMembersBatch());
    }
}