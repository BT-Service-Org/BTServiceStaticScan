trigger clonePARecord on PA_Onboarding__c (after insert)
{

    if (Trigger.new[0].name.contains('Template')) return;
    
    //List<Certification_Data__c> certDataList=OrgRefresh_CertDataGenTemplate.genBaseCertTemplate(Trigger.new,null);
    List<Badge_Data__c> badgeDataList=OrgRefresh_CertDataGenTemplate.genBaseCertTemplate(Trigger.new,null); 
    //PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('Template PA Onboarding Id');
    
    PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('Template PA Onboarding Id');
    System.debug('RecordTypeId' + trigger.new[0].RecordTypeId);
    if (trigger.new[0].RecordTypeId == '01230000001aMfpAAE') { //move to custom settings
        paTemplate = PA_Onboarding_Property__c.getValues('SC Template Onboarding Id');

    } else {
        paTemplate = PA_Onboarding_Property__c.getValues('Template PA Onboarding Id');
    }
    
    String recId = paTemplate.Value__c;
    System.debug('recid ' + recId);
    List<Learning_Domain__c>  domainList = [Select  Baseline_Assessment_Date__c,Baseline_Rating__c,
                                                    Category__c,Final_Assessment_Date__c,Notes__c,Quiz_Complete__c,
                                                    Skill__c,Badge_Video__c,Badge_Quiz__c
                                            from Learning_Domain__c
                                            where PA_Onboarding__c = :recId
                                            order by Sequence__c ];

    List<Learn__c> learnInsert = new List<Learn__c>();
    List<Build__c> buildInsert = new List<Build__c>();
    List<Apply__c> applyInsert = new List<Apply__c>();
    Map<Id,Rubric__c> rubricMap = new Map<Id,Rubric__c>();
    Map<Id,List<Rubric_Objective__c>> rubricObjMap = new Map<Id,List<Rubric_Objective__c>>();

    for(Learning_Domain__c domain: domainList)
    {
        List<Learn__c> learnTemplate = [Select Name,Level__c,Link__c,Notes__c,Start_Date__c,Completion_Date__c from Learn__c
                                        where Learning_Domain__r.PA_Onboarding__c = :recId
                                        and Learning_Domain__r.Skill__c=:domain.Skill__c ] ;
        List<Build__c> buildTemplate = [Select Name,Completion_Date__c,Level__c,Link__c,Notes__c,Start_Date__c from Build__c
                                        where Learning_Domain__r.PA_Onboarding__c = :recId
                                        and Learning_Domain__r.Skill__c=:domain.Skill__c ];

        List<Rubric__c> rubricTemplate = [select Id,Name,
                                                (select Objective__c,Score_Definition_1__c,
                                                Score_Definition_3__c,
                                                Score_Definition_5__c,Skill_Definition__c,
                                                Domain_Rubric_Objective__c, Special_Objective__c
                                                from Rubrics_Objectives__r)
                                          from Rubric__c
                                          where Learning_Domain__r.PA_Onboarding__c = :recId
                                          and Learning_Domain__r.Skill__c=:domain.Skill__c ];

        Learning_Domain__c domainToInsert = domain.clone(false, true); //do a deep clone
        domainToInsert.PA_Onboarding__c=trigger.new[0].Id;
        insert domainToInsert;
        System.debug(domainToInsert);

        for (Learn__c learnlist : learnTemplate)
        {
            Learn__c learn = learnlist.clone(false, true); //do a deep clone
            learn.Name=learnList.Name;
            learn.Learning_Domain__c = domainToInsert.Id;
            learn.Level__c=learnlist.Level__c;
            learn.Link__c=learnList.Link__c;
            learn.Start_Date__c = NULL;
            learn.Completion_Date__c = NULL;
            learnInsert.add(learn);
        }

        for (Build__c buildlist : buildTemplate)
        {
            Build__c build = buildlist.clone(false, true); //do a deep clone
            build.Name=buildList.Name;
            build.Learning_Domain__c = domainToInsert.Id;
            build.Level__c=buildList.Level__c;
            build.Link__c=buildList.Link__c;
            build.Start_Date__c = NULL;
            build.Completion_Date__c = NULL;
            buildInsert.add(build);
        }

        for (Rubric__c rubric : rubricTemplate)
        {
            Rubric__c newRubric = rubric.clone(false, true); //do a deep clone
            newRubric.Learning_Domain__c = domainToInsert.Id;
            rubricMap.put(rubric.Id,newRubric);
            rubricObjMap.put(rubric.Id,rubric.Rubrics_Objectives__r);
        }
    }

    //insert learnInsert; //learn material has moved to inkling
    //insert buildInsert;
    //insert applyInsert;
    insert rubricMap.values();

    //certification data
    //upsert certDataList Cert_Unique_Id__c;
    upsert badgeDataList Unique_Id__c;

    //Insert Rubric Objectives
    List<Rubric_Objective__c> objToInsert = new List<Rubric_Objective__c>();
    for(Id oldRubricId: rubricMap.keySet())
    {
        Rubric__c rubric = rubricMap.get(oldRubricId);
        for(Rubric_Objective__c obj:rubricObjMap.get(oldRubricId))
        {
            Rubric_Objective__c newObj = obj.clone(false, true);
            newObj.Rubric__c=rubric.Id;
            objToInsert.add(newObj);
        }
    }
    insert objToInsert;
}