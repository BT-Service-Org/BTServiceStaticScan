public class BedrockSupportUtilities {
    public void preparePAOnboardingRecords(List<String> passedPAIds) {
        List<PA_Onboarding__c> passedPAs = 
            [select Id,Name,RecordTypeId,Candidate_Email__c from PA_Onboarding__c where Id=:passedPAIds AND (NOT Name like '%Template%')];
        System.debug('@@preparePAOnboardingRecords:1-passedPAIds:count: '+passedPAs.size());
        if ( passedPAs.size() <= 0 ) {
            System.debug('@@###@@preparePAOnboardingRecords:passedPA size <= 0 '+
                         ' or PA Onboarding record was a template--leaving preparePAOnboardingRecords!!');
            return;
        }
        List<List<String>> newPAs = new List<List<String>>();
        List<String> newPA = new List<String>();
        
        Id SCRecordTypeId = [select Id from RecordType where Name Like 'SC Onboarding' Limit 1].Id;
        Id PARecordTypeId = [select Id from RecordType where Name Like 'Onboarding' Limit 1].Id;
        Id MuleSoftRecordTypeId = [select Id from RecordType where Name Like 'MuleSoft Onboarding' Limit 1].Id;

        System.debug('@@preparePAOnboardingRecords:SCRecordTypeId: '+SCRecordTypeId+' for SC_Onboarding');
        System.debug('@@preparePAOnboardingRecords:PARecordTypeId: '+PARecordTypeId+' for PA_Onboarding');
        System.debug('@@prepareMuleSoftOnboardingRecords:MuleSoftRecordTypeId: '+MuleSoftRecordTypeId+' for MuleSoft_Onboarding');

        Map<Id, PA_Onboarding_Property__c> paTemplateMap = new Map<Id, PA_Onboarding_Property__c>();
        paTemplateMap.put(SCRecordTypeId,PA_Onboarding_Property__c.getValues('SC Template Onboarding Id'));
        paTemplateMap.put(PARecordTypeId,PA_Onboarding_Property__c.getValues('Template PA Onboarding Id'));
        paTemplateMap.put(MuleSoftRecordTypeId,PA_Onboarding_Property__c.getValues('MuleSoft Template Onboarding Id'));
        try {
            System.debug('@@preparePAOnboardingRecords:PATemplateValues:SCRecordTypeId: '+SCRecordTypeId+
                         ' for SC Template Onboarding Id:key: '+
                         paTemplateMap.get(SCRecordTypeId).Key__c+
                         ' value: '+
                         paTemplateMap.get(SCRecordTypeId).Value__c+
                         ' all: '+
                         paTemplateMap.get(SCRecordTypeId));
        } catch (NullPointerException e) {
            System.debug('@@preparePAOnboardingRecords:PATemplateValues:SCRecordTypeId is NULL: '+
                        e.getMessage());
        }

        System.debug('@@preparePAOnboardingRecords:PATemplateValues:PARecordTypeId: '+PARecordTypeId+
                     ' for Template PA Onboarding Id:key: '+
                     paTemplateMap.get(PARecordTypeId).Key__c+
                     ' value: '+
                     paTemplateMap.get(PARecordTypeId).Value__c+
                     ' all: '+
                     paTemplateMap.get(PARecordTypeId));

        System.debug('@@prepareMuleSoftOnboardingRecords:MuleSoftTemplateValues:MuleSoftRecordTypeId: '+MuleSoftRecordTypeId+
                     ' for Template PA Onboarding Id:key: '+
                     paTemplateMap.get(MuleSoftRecordTypeId).Key__c+
                     ' value: '+
                     paTemplateMap.get(MuleSoftRecordTypeId).Value__c+
                     ' all: '+
                     paTemplateMap.get(MuleSoftRecordTypeId));
        
        String recId        = null;
        List<String> recIds = new List<String>();
        List<String> skills = new List<String>();

        //Get the template to copy from, either SC or PA
        System.debug('@@preparePAOnboardingRecords:2-processing '+passedPAs.size()+' records');
        for (PA_Onboarding__c pas: passedPAs) {
            System.debug('@@preparePAOnboardingRecords:looping:recordTypeId: '+pas.RecordTypeId);
            try { 
                if ( (paTemplateMap.get(SCRecordTypeId).Value__c != null) &&
                    paTemplateMap.get(pas.RecordTypeId).Value__c == paTemplateMap.get(SCRecordTypeId).Value__c ) {
                    System.debug('@@preparePAOnboardingRecords:setting recId for recordTypeId: '+pas.RecordTypeId);
                    recId = paTemplateMap.get(SCRecordTypeId).Value__c;
                    System.debug('@@1-preparePAOnboardingRecords:PATemplate recId: '+recId);
                } else { 
                    if ((paTemplateMap.get(MuleSoftRecordTypeId).Value__c != null) &&
                      paTemplateMap.get(pas.RecordTypeId).Value__c == paTemplateMap.get(MuleSoftRecordTypeId).Value__c) {
                        System.debug('@@prepareMuleSoftOnboardingRecords:MuleSoftTemplateValues:MuleSoftRecordTypeId: '+MuleSoftRecordTypeId+
                                     ' for Template MuleSoft Onboarding Id:key: '+
                                     paTemplateMap.get(MuleSoftRecordTypeId).Key__c+
                                     ' value: '+
                                     paTemplateMap.get(MuleSoftRecordTypeId).Value__c+
                                     ' all: '+
                                     paTemplateMap.get(MuleSoftRecordTypeId));
                               recId = paTemplateMap.get(MuleSoftRecordTypeId).Value__c;
                        System.debug('@@2-prepareMuleSoftOnboardingRecords:PATemplate recId: '+recId);
                    } else {
                        System.debug('@@preparePAOnboardingRecords:PATemplateValues:PARecordTypeId: '+PARecordTypeId+
                                     ' for Template PA Onboarding Id:key: '+
                                     paTemplateMap.get(PARecordTypeId).Key__c+
                                     ' value: '+
                                     paTemplateMap.get(PARecordTypeId).Value__c+
                                     ' all: '+
                                     paTemplateMap.get(PARecordTypeId));
                               recId = paTemplateMap.get(PARecordTypeId).Value__c;
                        System.debug('@@2-preparePAOnboardingRecords:PATemplate recId: '+recId);
                    }
                }
            } catch (Exception e) {
                recId = paTemplateMap.get(PARecordTypeId).Value__c;
                System.debug('@@2.5-preparePAOnboardingRecords:PATemplate recId: '+recId);
            }
            System.debug('@@3-preparePAOnboardingRecords:PATemplate recId: '+recId);
            recIds.add(recId);
            newPA = new List<String>();
            newPA.add(pas.Id);
            newPA.add(pas.RecordTypeId);
            newPA.add(recId);
            newPA.add(pas.Candidate_Email__c);
            newPAs.add(newPA);
        }
        System.debug('@@4-preparePAOnboardingRecords:PATemplate recIds loaded: '+recIds.size());
        System.debug('@@5-preparePAOnboardingRecords:newPAs loaded: '+newPAs.size());

        //Take the list of records from the template above and get all the learning domain records
        Map<String,List<Learning_Domain__c>> domainMap = new Map<String,List<Learning_Domain__c>>();
        List<Learning_Domain__c> domains = new List<Learning_Domain__c>();
        String wRecId = 'XXX';
        System.debug('@@preparePAOnboardingRecords:Looking for learning paths for: '+recIds);
        List<Learning_Domain__c> domainsIn = [Select  Id,Baseline_Assessment_Date__c,Baseline_Rating__c,
                                              Category__c,Final_Assessment_Date__c,Notes__c,Quiz_Complete__c,
                                              Skill__c,Badge_Video__c,Badge_Quiz__c,PA_Onboarding__c,
                                              Candidate_Name__c,Candidate_Email__c,Sequence__c
                                              from Learning_Domain__c
                                              where PA_Onboarding__c = :recIds
                                              order by PA_Onboarding__c,Sequence__c ];
        for (Learning_Domain__c ld: domainsIn) {
            if ( String.ValueOf(ld.PA_Onboarding__c) != wRecId ) {
                if ( wRecId != 'XXX') {
                    domainMap.put(wRecId,domains);
                    domains = new List<Learning_Domain__c>();
                    wRecId = ld.PA_Onboarding__c;
                } else {
                    wRecId = ld.PA_Onboarding__c;                                             }
            }
            domains.add(ld);
            skills.add(ld.Skill__c);
            System.debug('@@preparePAOnboardingRecords:LearningDomain PA_Onboarding__c: '+
                         ld.PA_Onboarding__c+' seq: '+ld.Sequence__c+
                         ' category: '+ld.Category__c+' Skill: '+ld.Skill__c+
                         ' Candidate Email: '+ld.Candidate_Email__c);
        }
        domainMap.put(wRecId,domains);
        
        System.debug('@@preparePAOnboardingRecords:Found for learning paths(size: '+domains.size()+'): '+domains+
                    ' skills: '+skills);
        System.debug('@@preparePAOnboardingRecords:LearningDomain MAP: '+domainMap);
        
        //Now lets take the learning domain records and find the rubric for them
        Map<String,List<Rubric__c>> rubricMap = new Map<String,List<Rubric__c>>();
        List<Rubric__c> rubrics = new List<Rubric__c>();
        Map<Id,List<Rubric_Objective__c>> rubricObjMap = new Map<Id,List<Rubric_Objective__c>>();
        wRecId = 'XXX';
        System.debug('@@preparePAOnboardingRecords:looking for Rubrics with recIds: '+recIds);
        List<Rubric__c> rubricsIn = [select Id,Name,Candidate_Name__c,Learning_Domain__r.PA_Onboarding__c,Learning_Domain__c,
                                     Learning_Domain__r.Skill__c,Bedrock__c,
                                     (select Rubric__c,Objective__c,Score_Definition_1__c,
                                      Score_Definition_3__c,Skill__c,
                                      Score_Definition_5__c,Skill_Definition__c,
                                      Domain_Rubric_Objective__c, Special_Objective__c
                                      from Rubrics_Objectives__r)
                                     from Rubric__c
                                     where Learning_Domain__r.PA_Onboarding__c = :recIds ];
        for (Rubric__c rub: rubricsIn) {
            System.debug('@@preparePAOnboardingRecords:Rubric for PA_Onboarding__c: '+
                         'candidate: '+rub.Candidate_Name__c+
                         ' Rubric Name: '+rub.Name+
                         ' Learning_Domain__r.PA_Onboarding__c: '+rub.Learning_Domain__r.PA_Onboarding__c+
                         ' Learning_Domain__c: '+rub.Learning_Domain__c+
                         ' skill: '+rub.Learning_Domain__r.Skill__c);
            System.debug('@@preparePAOnboardingRecords:Rubric Objectives for Rubric: '+rub.Id+
                         rub.Rubrics_Objectives__r);
            if ( String.ValueOf(rub.Learning_Domain__r.PA_Onboarding__c) != wRecId ) {
                if ( wRecId != 'XXX') {
                    rubricMap.put(wRecId,rubrics);
                    rubrics = new List<Rubric__c>();
                    //wRecId = rub.Learning_Domain__r.PA_Onboarding__c;
                    wRecId = rub.Learning_Domain__c;
                } else {
                    //wRecId = rub.Learning_Domain__r.PA_Onboarding__c;
                    wRecId = rub.Learning_Domain__c;
                }
                rubrics.add(rub);
                //rubricObjMap.put(rub.Id,rub.Rubrics_Objectives__r);
            }
        }
        rubricMap.put(wRecId,rubrics);
        System.debug('@@preparePAOnboardingRecords:Found for rubrics(size: '+rubrics.size()+'): '+rubrics);
        System.debug('@@preparePAOnboardingRecords:Rubric MAP: '+rubricMap);
    
        //now to build and insert the onboarding record components: learning domains & related rubric & rubric objectives
        List<Learning_Domain__c> newDomains = new List<Learning_Domain__c>();
        Learning_Domain__c       newDomain  = new Learning_Domain__c();
        List<Rubric__c>          newRubrics = new List<Rubric__c>();
        Rubric__c                newRubric  = new Rubric__c();
        //Rubric_Objective__c    newRubricObj  = new Rubric_Objective__c();
        
        System.debug('@@preparePAOnboardingRecords:################looping through records to load###########');
        for (List<String> loopNewPA: newPAs) {
            System.debug('@@preparePAOnboardingRecords:Looping through PA Onboarding Id: '+loopNewPA[0]+
                        ' template record type: '+loopNewPA[1]+
                        ' template record id: '+loopNewPA[2]);
            System.debug('@@preparePAOnboardingRecords:Looping through Learning domains for each PA Onboarding Id: '+
                         loopNewPA[2]+' cloning and replacing with Id: '+loopNewPA[0]);
            for (Learning_Domain__c ld2: domainMap.get(loopNewPA[2])){
                                    System.debug('>>>>>@@preparePAOnboardingRecords:NEW LearningDomain PA_Onboarding__c: '+
                                                 loopNewPA[0]+' oldId: '+ld2.Id+' seq: '+ld2.Sequence__c+
                                                 ' category: '+ld2.Category__c+' Skill: '+ld2.Skill__c+
                                                 ' unique id: '+ld2.Id);
                //add clone logic here
                newDomain = new Learning_Domain__c();
                newDomain = ld2.clone(false, true); //do a deep clone
                newDomain.PA_Onboarding__c = loopNewPA[0];
                newDomain.Candidate_Email__c=loopNewPA[3];
                newDomain.Unique_Id__c = ''+loopNewPA[0]+'~'+ld2.Id;
                newDomains.add(newDomain);

            }            
        }
        insert newDomains;
        System.debug('@@preparePAOnboardingRecords:NEW domains INSERTED: '+newDomains.size());
        newRubric  = new Rubric__c();
        newRubrics = new List<Rubric__c>();
        List<Learning_Domain__c> newDomains2 = new List<Learning_Domain__c>(); 
        List<String> rubricArgs = new List<String>();
        String rubricLookup = '';

        for (Learning_Domain__c ld3: newDomains){
            //strip the PA_Onboarding__c id from the unique_id__c key to lookup the rubric key
            rubricArgs = ld3.Unique_Id__c.split('~',0);
            rubricLookup = rubricArgs.get(1);
            System.debug('>>>>>@@preparePAOnboardingRecords:NEWLY Inserted LearningDomain PA_Onboarding__c: '+
                         ld3.Id+' seq: '+ld3.Sequence__c+
                         ' category: '+ld3.Category__c+' Skill: '+ld3.Skill__c+
                         ' Unique Id: '+ld3.Unique_Id__c+' rubric key: '+rubricLookup);
           
            System.debug('>>>>>>>>>>@@preparePAOnboardingRecords:looping through Rubric records to load###########');
            try {
                for (Rubric__c rub3: rubricMap.get(rubricLookup)) {
                    System.debug('>>>>>>>>>>@@preparePAOnboardingRecords:NEW Rubrics: '+
                                 ' new Learning Domain Id: '+newDomain.Id+
                                 ' Learning_Domain__c: '+rub3.Learning_Domain__c+
                                 ' candidate: '+rub3.Candidate_Name__c+
                                 ' Rubric Name: '+rub3.Name+
                                 ' skill: '+rub3.Learning_Domain__r.Skill__c);
                    //add clone logic here
                    newRubric = new Rubric__c();
                    newRubric = rub3.clone(false, true); //do a deep clone
                    newRubric.Learning_Domain__c = ld3.Id;
                    newRubric.Comments__c = rub3.Id;
                    newRubrics.add(newRubric);
                    newDomain = ld3;
                    System.debug('>>>>>>>>>>@@preparePAOnboardingRecords:updating domain:Id: '+
                                 newDomain.Id+' unique Id: '+newDomain.Unique_Id__c+' new unique Id: '+
                                 ld3.Candidate_Email__c+ld3.Category__c+ld3.Skill__c);
                    newDomain.Unique_Id__c = ld3.Candidate_Email__c+ld3.Category__c+ld3.Skill__c;
                    newDomains2.add(newDomain);
                    rubricObjMap.put(rub3.Id,rub3.Rubrics_Objectives__r);
                    
                }
            } catch (Exception e) {
                System.debug('>>>>>>>>>>>>>>>No Rubric records to extract: '+ld3.Id+' message: '+e.getMessage());
            }
            
        }
        
        insert newRubrics;
        System.debug('@@preparePAOnboardingRecords:NEW Rubrics: '+newRubrics.size());
        System.debug('@@preparePAOnboardingRecords:Rubric Objectives MAP: '+rubricObjMap);
        
        Rubric_Objective__c newRubricObjective        = new Rubric_Objective__c();
        List<Rubric_Objective__c> newRubricObjectives = new List<Rubric_Objective__c>();
        List<Rubric__c>          newRubrics2          = new List<Rubric__c>();
        Rubric__c                newRubric2           = new Rubric__c();
        for (Rubric__c rub4: newRubrics){
            System.debug('>>>>>&&&preparePAOnboardingRecords:NEWLY Inserted Rubrics PA_Onboarding__c: '+
                         rub4.Id+' Learning Domain: '+rub4.Learning_Domain__c+' old Id: '+rub4.Comments__c+
                         ' Skill: '+rub4.Skill__c+' objectives: '+rubricObjMap);
           
            System.debug('>>>>>>>>>>>>>>>&&&preparePAOnboardingRecords:looping through Rubric Objective records to load###########');
            newRubric2 = rub4;
            System.debug('>>>>>>>>>>>>>>>&&&preparePAOnboardingRecords:updating rubric:Id: '+
                         newRubric2.Id+' comment(old rubrics Id): '+newRubric2.Comments__c);
            try {
                for (Rubric_Objective__c rubObj: rubricObjMap.get(rub4.Comments__c)) {
                    System.debug('>>>>>>>>>>>>>>>&&&preparePAOnboardingRecords:NEW Rubric Objective: '+
                                 ' new Rubric Id: '+rub4.Id+' objective: '+rubObj.Objective__c+
                                 ' skill: '+rubObj.Skill__c+
                                 ' skill definition: '+rubObj.Skill_Definition__c);
                    //add clone logic here
                    newRubricObjective = new Rubric_Objective__c();
                    newRubricObjective = rubObj.clone(false, true); //do a deep clone
                    newRubricObjective.Rubric__c = rub4.Id;
                    newRubricObjectives.add(newRubricObjective);
                }
                newRubric2.Comments__c='';
                newRubrics2.add(newRubric2);
            } catch (Exception e) {
                System.debug('>>>>>>>>>>>>>>>No Rubric Objective records to extract: '+rub4.Id+' message: '+e.getMessage());
            }
            
        }
        insert newRubricObjectives;
        System.debug('@@preparePAOnboardingRecords:NEW Rubric Objectives: '+newRubricObjectives.size());
        try {
            upsert newDomains2;
            System.debug('@@preparePAOnboardingRecords:updated domains: '+newDomains2.size());
        } catch (DMLException dme) {
            System.debug('Attempted to replace Unique_Id__c on Learning Domain with "Email+Category+Skill"'+
                        '-but it creates a duplicate.  So, it will not proceed and be left to the ID of the '+
                        'old learning domain record.');
        }
        try {
            upsert newRubrics2;
            System.debug('@@preparePAOnboardingRecords:updated rubrics: '+newRubrics2.size());
        } catch (DMLException dme) {
            System.debug('Attempted to replace Comments__c Rurics with blank'+
                        '-but it was not permitted.  So, it will not proceed and be left to the ID of the '+
                        'old Rubric record.');
        }
    
    }

}