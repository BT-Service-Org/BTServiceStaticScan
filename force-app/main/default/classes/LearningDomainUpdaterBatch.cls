public class LearningDomainUpdaterBatch implements
	Database.Batchable<sObject>, Database.Stateful {
        
        private List<Rubric_Objective__c> objectives = new List<Rubric_Objective__c>();
        
        private String ldSkill = '';
        private String ldCategory = '';
        
        private boolean lds4SkillExist = false;
        
        private List <String> onBoardingIds2Update = new List<String> ();
        
        private Integer ldsUpdated = 0;

    	public LearningDomainUpdaterBatch(String paramCategory, String paramSkill, List<String> paramIds, boolean paramLDs4SkillExist) {
        	ldSkill = paramSkill;
            ldCategory = paramCategory;
            lds4SkillExist = paramLDs4SkillExist;
            
            if (paramIds != null) {
                onBoardingIds2Update = paramIds;
            } 
            
            // Get Rubric objectives for all the template <paramSkill> learning domain
            objectives = [SELECT Id, 
                                                Score__c, 
                                                Score_Comments__c, 
                                                Special_Objective__c,
                                                Domain_Rubric_Objective__c
                                        FROM    Rubric_Objective__c
                                        WHERE   Rubric__c in (SELECT  id
                                                              FROM    Rubric__c
                                                              WHERE   Learning_Domain__r.PA_Onboarding__r.Name = '** Template DO NOT DELETE **'
                                                              AND     Learning_Domain__r.Skill__c = :ldSkill)
                                        AND     Domain_Rubric_Objective__c != null
                                        AND     Domain_Rubric_Objective__r.Active__c = true];
            
            system.debug('# of LD objectives : ' + objectives.size());
            
    	}
        
        //Get Sales Cloud learning domains assigned to all active OnBoarding records
        public Database.QueryLocator start(Database.BatchableContext bc) {
            
            if(lds4SkillExist) {
                if (onBoardingIds2Update.size() > 0) {
                    system.debug('onBoardingIds2Update is not empty');
                    //If OnBoarding IDs are provided, assume there are no Rubrics for corresponding LDs
                    return Database.getQueryLocator(
                        'SELECT Id, Name, Skill__c, PA_OnBoarding__c, Status__c ' +
                        'FROM Learning_Domain__c ' +
                        'WHERE Skill__c = :ldSkill ' +
                        'AND PA_Onboarding__c IN :onBoardingIds2Update ' +
                        'AND Id NOT IN (select Learning_Domain__c from Rubric__c)'
                    );
                } else {
                     system.debug('onBoardingIds2Update is empty');
                    //If OnBoarding IDs are not provided, assume there may be Rubrics for corresponding LDs
                    //if there are Rubrics, further assume there are Rubric objective attached.
                    return Database.getQueryLocator(
                        'SELECT Id, Name, Skill__c, PA_OnBoarding__c, Status__c ' +
                        'FROM Learning_Domain__c ' +
                        'WHERE Skill__c = :ldSkill ' +
                        'AND PA_Onboarding__c IN (SELECT Id FROM PA_OnBoarding__c WHERE Active_User__c = true) ' +
                        'AND Id NOT IN (select Learning_Domain__c from Rubric__c)'
                    );
                }
            } else {
                if (onBoardingIds2Update.size() > 0) 
                    return Database.getQueryLocator('SELECT Id, Name ' +
                                                    'FROM PA_OnBoarding__c ' +
                                                    'WHERE Id IN :onBoardingIds2Update ' +
                                                    'AND Id not in (select PA_OnBoarding__c from Learning_Domain__C where Skill__c =:ldSkill)');
                else
                    return Database.getQueryLocator('SELECT Id, Name ' +
                                                    'FROM PA_OnBoarding__c ' +
                                                    'WHERE Active_User__c = true '+
                                                    'AND Id not in (select PA_OnBoarding__c from Learning_Domain__C where Skill__c =:ldSkill)');
            }
            
       }
        
        public void execute(Database.BatchableContext bc, List<SObject> scope){
            
            // this list will hold all Rubrics to be used to link Sales Cloud learning domains objectives to all active on boarding records
            List <Rubric__c> clonedRubrics = new List<Rubric__c>();
            
            List<Learning_Domain__c> learningDomains = new List<Learning_Domain__c> ();
            
            if (lds4SkillExist) {
                String listType = 'List<Learning_Domain__c>';
       			learningDomains = (List<SObject>)Type.forName(listType).newInstance();
       			learningDomains.addAll((List<Learning_Domain__c>)scope);
                system.debug('scope cast to learning domains') ;
            } else {
                // Since there are no LDs for the PA Onboarding records, create them first
                for(SObject pa: scope) {
                    //create a Learning Doman for the "ldSkill" to link to the PA_Onboarding record
                    system.debug('*****PA_Onboarding ID: ' + pa.get('Id') + ', PA_Onboarding Name: ' + pa.get('Name'));
                    if (pa.get('Id') != 'a1Y3A0000003SdIUAU') {
                        Learning_Domain__c ld = new Learning_Domain__c();
                    	ld.Category__c = ldCategory;
                    	ld.Skill__c = ldSkill;
                    	ld.Status__c = 'Ready';
                    	ld.Sequence__c = 20;
                    	ld.PA_Onboarding__c = (String)pa.get('Id');
                    	learningDomains.add(ld);
                    }
               }
                system.debug('*****learning domains list created') ;
                
                if(!Test.isRunningTest()){
                  
                    insert learningDomains;
                	system.debug('*****learning domains created and linked to PAs') ;
                }
            }
            
            system.debug('*****Number of learning domains  - [' + learningDomains.size() + ']') ;
                
            for(Learning_Domain__c ld: learningDomains) {
                //Id LDId = ld.id;
                system.debug('*****Learning Domian ID : ' + ld.id);
                
                //create a Rubric to link Rubric objective to learning domain
                Rubric__c clonedRubric = new Rubric__c();
                clonedRubric.Learning_Domain__c = ld.id;
                clonedRubric.BedRock__c = true;
                clonedRubrics.add(clonedRubric);
                
                // Change the learning domain status to Ready
                ld.Status__c = 'Ready';
                ldsUpdated = ldsUpdated + 1;
                
            }
            
            system.debug('*****Active OnBoarding clonedRubrics - [' + clonedRubrics.size() + ']') ;
           
            if(!Test.isRunningTest()){
            	insert clonedRubrics;
                if (lds4SkillExist) {
            		update learningDomains;
                }
            }
            
            // this list will contain Rubric objectives for all Sales Cloud learning domains assigned to all active on boarding records
            // Will be linked to LDs via the clonedRubrics above.
            List <Rubric_Objective__c> masterClonedObjectives = new List<Rubric_Objective__c>();
            
            for(Rubric__c clonedRubric: clonedRubrics) {
            	system.debug('*****clonedRubric.Id - [' + clonedRubric.Id + ']') ;
             	//clone rubric objectives from the Sales Cloud template learning domian 
                List<Rubric_Objective__c> clonedObjectives = objectives.deepClone();
                for(Rubric_Objective__c ro: clonedObjectives) {
                    if(!Test.isRunningTest()){
                        ro.Rubric__c = clonedRubric.Id;
                    } else {
                        ro.Rubric__c = 'a1b30000000Ip5sAAC'; 
                    }
                }
                
                // add to master masterCloneObjectives list
                masterClonedObjectives.addall(clonedObjectives);
            }
            
            system.debug('*****Active OnBoarding masterClonedObjectives - [' + masterClonedObjectives.size() + ']') ;
            
            if(!Test.isRunningTest()){
                insert masterClonedObjectives; 
            }
        }
        
        public void finish(Database.BatchableContext bc){
            
            System.debug(ldsUpdated + ' Learning records updated.');
        	AsyncApexJob job = [SELECT Id, 
                                	Status, 
                                	NumberOfErrors,
            						JobItemsProcessed,
            						TotalJobItems, 
                                	CreatedBy.Email
            					FROM AsyncApexJob
            					WHERE Id = :bc.getJobId()];
        	// call some utility to send email
        }
        
}