@IsTest
public class SEP_CreateAssessmentAndPersonasTest {
    @TestSetup
    static void setupData(){
        Account acct = new Account(Name='SEP Test 01');
        insert acct;

        Contact ct = new Contact (FirstName='SEP Contact',LastName='LastName',EMail=UserInfo.getUserEmail(),AccountId=acct.Id);
        insert ct;


        Opportunity oppty = new Opportunity(AccountId=acct.Id,Name='SEP Oppty 01',StageName='01 - Discovery',CloseDate=System.today().addDays(60));
        insert oppty;

        MAPDomain__c dom = new MAPDomain__c(Name='SEP Test 01',Active__c=true);
        insert dom;
    }

    @IsTest
    public static void testAssessmentPersonaInterviewCreate(){
        Opportunity oppty = [select Id,Account.Id,Name from Opportunity limit 1];
        MAPDomain__c dom = [select Id,NAme from MApDomain__c limit 1];
        CreateAsssesmentRequest req = new CreateAsssesmentRequest();
        req.opportunityId=oppty.Id;
        req.domainIds = new List<String>{dom.Id};
        Test.startTest();
        List<List<MAPPersona__c>> resp = SEP_CreateAssessmentAndPersonas.createAssessmentAndPersonas(new List<CreateAsssesmentRequest>{req});
        System.assert(resp.size()==1,'Response size is not 1');
        Test.stopTest();
    }
}