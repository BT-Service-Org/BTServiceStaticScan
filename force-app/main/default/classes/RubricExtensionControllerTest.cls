@isTest (SeeAllData=true)
public class RubricExtensionControllerTest{
    
    public static testMethod void RubricExtensionControllerTest() {
        
        Test.startTest();
        // Setup test data
        Account act = new Account(Name='Salesforce.com');
        insert act;
        
        // Create a Standard User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User evalu = new User(Alias = 'evalu', Email='evalu@testorg.com', EmailEncodingKey='UTF-8', FirstName='Primary', 
                          LastName='Evaluator', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='peval234235qwerqewu@awerw23432er.com', Role__c='Program Architect', 
                          Organization__c='Services - West', Title__c='Program Architect');
        insert evalu;
        System.Debug('---- New Primary Evaluator ID: ' + evalu.Id);

        // Create a Standard User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', FirstName='Rubric', 
                          LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='su@testorsafddsfwerwr243g.com', Role__c='Program Architect', 
                          Organization__c='Services - West', Title__c='Program Architect');
        insert u;
        System.Debug('---- New User ID: ' + u.Id);

        // Create a Contact
        System.Debug('---- Creating Contact');
        Contact con = new Contact(Firstname='First',Lastname='Last',AccountId=act.Id,Email='standarduser@testorg.com');
        insert con;
       
        System.Debug('---- Contact Created');
        
        // Create PA Onboarding Object
        //String mentor = UserInfo.getUserId();
        System.Debug('---- Creating PA Onboarding Record');
        PA_Onboarding__c pa = new PA_Onboarding__c(Name='PA-Test', Mentor__c=u.Id,
                                                  Program_Start_Date__c=Date.today(),Contact__c=con.Id,RecordTypeId=Schema.SObjectType.PA_Onboarding__c.getRecordTypeInfosByName().get('PA').getRecordTypeId());
        insert pa;
        System.Debug('---- PA Onboarding Record Created');
        
        List<Learning_Domain__c> lds = [select skill__c, pa_onboarding__r.name from Learning_Domain__c where PA_Onboarding__c = :pa.id];
        System.debug('All PA LDs: ' + lds);
       
        // Create Learning Domain Object
        Learning_Domain__c learnDom = new Learning_Domain__c(PA_Onboarding__c=pa.Id, Skill__c='Pottery');
        insert learnDom;
        
        // Create Rubric Object
        Rubric__c rub = new Rubric__c(Learning_Domain__c=learnDom.Id);
        insert rub;
        
        // Create related Rubric Objective
        Rubric_Objective__c rubObj = new Rubric_Objective__c (Skill_Definition__c='This is the first definition', Rubric__c=rub.Id);
        insert rubObj;   
        
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c,Evaluation_Date__c, Status__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:rub.Id];

        
        ApexPages.StandardController sc = new ApexPages.standardController(rub);
        Test.setCurrentPage(Page.RubricObjEdit);
        RubricExtensionController rubExtn = new RubricExtensionController(sc);
        
        rubExtn.objectives[0].Score__c=5;
        rubExtn.objectives[0].Score_Comments__c='Test Comments';
        system.debug(rub.Rubrics_Objectives__r.get(0));
        PageReference pageRef = rubExtn.saveScores();
        System.debug('>>>>> pageRef after saveScores :'+pageRef);       
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c,Evaluation_Date__c, Status__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:rub.Id];
  
  
        // Beginning of System Asserts, verify pageRef and URL First
        System.assertEquals(null,pageRef);
        System.assertEquals(5,rub.Rubrics_Objectives__r.get(0).Score__c);
        System.assertEquals('Test Comments',rub.Rubrics_Objectives__r.get(0).Score_Comments__c);
        System.assertEquals(true,ApexPages.hasMessages());
        System.assertEquals('Scores saved successfully!!!',ApexPages.getMessages().get(0).getSummary());
        
        rubExtn.grade();
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c,Evaluation_Date__c, Status__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c, Grade_Status__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:rub.Id];
               
        system.assertEquals('In Progress', rub.status__c);
        system.assertEquals(null, rub.Rubrics_Objectives__r.get(0).Grade_status__c);

// ------------------------------------------------- Bedrock Starts here -------------------------------------------------------
        // Test for new bedrock grading function
        
        Rubric__c bedrockR = [select Id, Learning_Domain__c, Status__c, Learning_Domain__r.Skill__c, Learning_Domain__r.Status__c, BedRock__c, Primary_Evaluator__c, Evaluation_Date__c, Comments__c from Rubric__c where Learning_Domain__r.PA_Onboarding__r.Id = :pa.Id and Learning_Domain__r.Skill__c = 'Application Design' LIMIT 1];
        bedrockR.Primary_Evaluator__c = evalu.Id;
        System.debug('Bedrock Rubric: ' + bedrockR);
        ApexPages.StandardController bedrocksc = new ApexPages.standardController(bedrockR);
        Test.setCurrentPage(Page.RubricBedRockEdit);
        RubricExtensionController bedrockrubExtn = new RubricExtensionController(bedrocksc);

        // Test resetobjectives
        bedrockrubExtn.resetObjectives();
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c, Average_Score__c, Learning_Domain__r.Status__c, Evaluation_Date__c, Status__c, Comments__c, Locked__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c, Grade_Status__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:bedrockR.Id];
               
        system.assertEquals('Not Started', rub.status__c);
        system.assertEquals(0, rub.Average_Score__c);

        
        bedrockR = [select Id, Learning_Domain__c, Status__c, Learning_Domain__r.Skill__c, Learning_Domain__r.Status__c, BedRock__c, Primary_Evaluator__c, Evaluation_Date__c, Comments__c from Rubric__c where Learning_Domain__r.PA_Onboarding__r.Id = :pa.Id and Learning_Domain__r.Skill__c = 'Application Design' LIMIT 1];
        bedrockR.Primary_Evaluator__c = evalu.Id;
        System.debug('Bedrock Rubric: ' + bedrockR);
        bedrocksc = new ApexPages.standardController(bedrockR);
        Test.setCurrentPage(Page.RubricBedRockEdit);
        bedrockrubExtn = new RubricExtensionController(bedrocksc);

        // Test no comments and grade
        bedrockrubExtn.gradeBedrock();
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c, Learning_Domain__r.Status__c, Evaluation_Date__c, Status__c, Comments__c, Locked__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c, Grade_Status__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:bedrockR.Id];
               
        system.assertEquals('Not Started', rub.status__c);

        system.debug('Page Messages: ' + ApexPages.getMessages());
        system.assertEquals(false, rub.Locked__c);
        system.assertEquals('Scores saved successfully!!!', ApexPages.getMessages()[0].getDetail());
        system.assertEquals('Comments must be entered to grade the candidate.', ApexPages.getMessages()[1].getDetail());

        // Test with fail on all objectives with comments and grade without overall comments
        for (Integer i = 0; i < bedrockrubExtn.objectives.size(); i++) {
            bedrockrubExtn.objectives[i].Score__c=0;
            bedrockrubExtn.objectives[i].Score_Comments__c='Test Comments';
        }
        
        bedrockrubExtn.gradeBedrock();
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c, Learning_Domain__r.Status__c, Evaluation_Date__c, Status__c, Comments__c, Locked__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c, Grade_Status__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:bedrockR.Id];
               
        system.assertEquals('Not Started', rub.status__c);

        system.debug('Page Messages: ' + ApexPages.getMessages());
        system.assertEquals(false, rub.Locked__c);
        system.assertEquals('Scores saved successfully!!!', ApexPages.getMessages()[0].getDetail());
        system.assertEquals('Comments must be entered to grade the candidate.', ApexPages.getMessages()[1].getDetail());

        // Test with fail on all objectives with comments and grade with overall comments; Result should be Fail
        bedrockrubExtn.rubric.Comments__c = 'Test this';
        bedrockrubExtn.gradeBedrock();
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c, Learning_Domain__r.Status__c, Evaluation_Date__c, Status__c, Comments__c, Locked__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c, Grade_Status__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:bedrockR.Id];
               
        system.assertEquals('Fail', rub.status__c);

        system.debug('Page Messages: ' + ApexPages.getMessages());
        system.assertEquals(true, rub.Locked__c);
        system.assertEquals('Scores saved successfully!!!', ApexPages.getMessages()[0].getDetail());
        system.assertEquals('Unfortunately the candidate has failed. Please schedule a full retake of the scenario presentation.', ApexPages.getMessages()[2].getDetail());


        // Test with Pass on all objectives with comments and grade with overall comments; Result should be pass
        bedrockrubExtn.rubric.Locked__c = false;
        bedrockrubExtn.rubric.Comments__c = 'Test this';
        for (Integer i = 0; i < bedrockrubExtn.objectives.size(); i++) {
            bedrockrubExtn.objectives[i].Score__c=5;
            bedrockrubExtn.objectives[i].Score_Comments__c='Test Comments';
        }
        
        bedrockrubExtn.gradeBedrock();
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c, Suppress_Chatter_Post__c, Learning_Domain__r.Status__c, Evaluation_Date__c, Status__c, Comments__c, Locked__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c, Grade_Status__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:bedrockR.Id];
               
        system.assertEquals('Pass', rub.status__c);
        system.debug('Suppress_Chatter_Post__c: ' + rub.Suppress_Chatter_Post__c);

        system.debug('Page Messages: ' + ApexPages.getMessages());
        system.assertEquals(true, rub.Locked__c);
        system.assertEquals(null, rub.Learning_Domain__r.Status__c);
        system.assertEquals('Scores saved successfully!!!', ApexPages.getMessages()[0].getDetail());
        system.assertEquals('Congratulations the candidate has passed the scenario presentation. The badge should be lit up in 62 org shortly.', ApexPages.getMessages()[3].getDetail());

        // Test resetobjectives after pass; expect to fail reset after pass
        bedrockrubExtn.resetObjectives();
        rub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c, Average_Score__c, Learning_Domain__r.Status__c, Evaluation_Date__c, Status__c, Comments__c, Locked__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c, Grade_Status__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:bedrockR.Id];
               
        system.debug('Page Messages: ' + ApexPages.getMessages());
        system.assertEquals('You cannot reset objectives if the candidate has passed', ApexPages.getMessages()[4].getDetail());


        // Test Clone
        bedrockR = [select Id, Learning_Domain__c, Status__c, Learning_Domain__r.Skill__c, Learning_Domain__r.Status__c, BedRock__c, Primary_Evaluator__c, Evaluation_Date__c, Comments__c from Rubric__c where Learning_Domain__r.PA_Onboarding__r.Id = :pa.Id and Learning_Domain__r.Skill__c = 'Application Design' LIMIT 1];
        System.debug('Bedrock Rubric: ' + bedrockR);
        bedrocksc = new ApexPages.standardController(bedrockR);
        Test.setCurrentPage(Page.RubricBedRockEdit);
        bedrockrubExtn = new RubricExtensionController(bedrocksc);

        System.PageReference cp = bedrockrubExtn.cloneRubric();
        Rubric__c clonedrub = [select Id,Learning_Domain__r.Skill__c,Primary_Evaluator__c, Average_Score__c, Learning_Domain__r.Status__c, Evaluation_Date__c, Status__c, Comments__c, Locked__c,
               (select Skill_Definition__c,Rubric__c, Score_Definition_1__c, 
                       Score_Definition_3__c, Score_Definition_5__c,
                       Score_Comments__c, Score__c, Grade_Status__c
                from Rubrics_Objectives__r)
               from Rubric__c where Id=:cp.getParameters().get('Id')];
        system.assertEquals(rub.Rubrics_Objectives__r.size(), clonedrub.Rubrics_Objectives__r.size()); 
        system.assertNotEquals(rub.Id, clonedrub.Id); 
        Test.stopTest();
    }
}