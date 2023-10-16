public class AddROs2LDsBatch implements
	Database.Batchable<sObject>, Database.Stateful {
        
        private List<Rubric_Objective__c> rubricObjectives = new List<Rubric_Objective__c>();
        
        private String ldSkill = '';
        private String ldCategory = '';
        
        private List <String> rubricStatus = new List<String> ();
        private List <String> droIds = new List<String> ();
        private List <String> onBoardingIds2Update = new List<String> ();
        private List <String> rubrics2Ignore = new List<String>();
        
        private Integer rubricsUpdated = 0;
        
        public AddROs2LDsBatch (String paramSkill, 
                                List<String> paramRubricStatus,
                                List<String> paramDROIds,
                                List<String> paramOnBoardingIds 
                                ) {
         	ldSkill = paramSkill;
            
            if (paramRubricStatus != null) {
                rubricStatus = paramRubricStatus;
            }
                                   
            if (paramDROIds != null) {
                droIds = paramDROIds;
            }
                                    
            if (paramOnBoardingIds != null) {
                onBoardingIds2Update = paramOnBoardingIds;
            }
            system.debug('rubricStatus : ' + rubricStatus.size()); 
            system.debug('droIds : ' + droIds.size()); 
            system.debug('onBoardingIds2Update : ' + onBoardingIds2Update.size()); 
            
            // Get Rubric objectives form the template learning domain with skill <ldSkill>
            // AND which the DROs <droIds>    
            
            rubricObjectives = [SELECT 
                          			Id, 
                                 	Score__c, 
                                 	Score_Comments__c, 
                                 	Special_Objective__c,
                                	Domain_Rubric_Objective__c
                          		FROM 
                          			Rubric_Objective__c 
                          		WHERE 
                          			Rubric__c IN (SELECT 
                                    		      	Id 
                                                  FROM 
                                          			Rubric__c 
                                                  WHERE 
                                          			Learning_Domain__r.PA_Onboarding__r.Name = '** Template DO NOT DELETE **' 
                                                  AND 
                                          			Learning_Domain__r.Skill__c = :ldSkill
                                                 ) 
                          		AND 
                          			Domain_Rubric_Objective__C IN :droIds 
                               ];
                                    
            system.debug('# of Rubric Objectives : ' + rubricObjectives.size());    
            system.debug('droIds : ' + droIds.size());        
            
            // Get all Rubric ids from Rubric Objectives which have the skill <ldSkill>
            // AND DROs in <paramDROIds>  
            
            List <Rubric_Objective__c> ros2Ignore = [SELECT 
                                                     	Id,
                                                        Rubric__C 
                                                     FROM
                                                     	Rubric_objective__c 
                                                     WHERE
                                                     	Skill__c = :ldSkill 
                                                     AND 
                                                     	Domain_Rubric_Objective__c IN :droIds
                                                    ]; 
            
            system.debug('ros2Ignore is ' + ros2Ignore.size());
            for(Rubric_Objective__c ro2Ignore: ros2Ignore) {
                if (!rubrics2Ignore.contains(ro2Ignore.Rubric__c)) {
                    rubrics2Ignore.add(ro2Ignore.Rubric__c);
                    system.debug('rubric [' + ro2Ignore.Rubric__c +'] will be skipped');
                }
            }
            system.debug('rubrics2Ignore is ' + rubrics2Ignore.size());                        
			                                    
        }

        //Get learning domains assigned to all active OnBoarding records
        public Database.QueryLocator start(Database.BatchableContext bc) {
            
            if (onBoardingIds2Update.size() > 0) {
                system.debug('onBoardingIds2Update is not empty');
                system.debug('rubrics2Ignore is ' + rubrics2Ignore.size());
                return Database.getQueryLocator(
                	'SELECT Id ' +
                    'FROM Rubric__c ' +
                    'WHERE Status__c IN :rubricStatus '+
                    'AND Skill__c = :ldSkill '+
                    'AND Learning_Domain__c IN ' +
                    	'(SELECT Id FROM Learning_Domain__c where PA_Onboarding__c IN :onBoardingIds2Update)' +
                    'AND ID NOT IN :rubrics2Ignore'
                );
             } else {
                 system.debug('onBoardingIds2Update is empty');
                 system.debug('rubrics2Ignore is ' + rubrics2Ignore.size());
                 return Database.getQueryLocator(
                 	'SELECT Id ' +
                    'FROM Rubric__c ' +
                    'WHERE Status__c IN :rubricStatus ' +
                    'AND Skill__c = :ldSkill '+
                    'AND Learning_Domain__r.Status__C != \'Badged\' '+
                    'AND Learning_Domain__c IN ' +
                    	'(SELECT Id FROM Learning_Domain__c where PA_Onboarding__r.Active_User__c = true)' +
                    'AND ID NOT IN :rubrics2Ignore'
                );
             }
            
        }
        
        public void execute(Database.BatchableContext bc, List<SObject> scope) {
            // this list will contain Rubric objectives for all rubrics
            List <Rubric_Objective__c> masterClonedRubricObjectives = new List<Rubric_Objective__c>();
            
            if (scope == null || scope.isEmpty()){
                system.debug('Scope is Empty') ;
            } else {
                system.debug('Scope is ' + scope.size()) ;
                for(SObject rubric: scope) {
               		system.debug('Processing Rubric id - [' + rubric.Id + ']') ; 
               		List<Rubric_Objective__c> clonedRubricObjectives = rubricObjectives.deepClone();
               		for(Rubric_Objective__c clonedRubricObjective: clonedRubricObjectives) {
                   		clonedRubricObjective.Rubric__c = rubric.Id;
               		}
                    rubricsUpdated = rubricsUpdated + 1;
                	// add to master masterCloneObjectives list
            		masterClonedRubricObjectives.addall(clonedRubricObjectives);
            	}
            
            	system.debug('***** masterClonedRubricObjectives - [' + masterClonedRubricObjectives.size() + ']') ;
           
            	if(!Test.isRunningTest()){
                	insert masterClonedRubricObjectives; 
            	}
            }
            
        }
        
        public void finish(Database.BatchableContext bc){
            
            System.debug(rubricsUpdated + ' Rubrics updated.');
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