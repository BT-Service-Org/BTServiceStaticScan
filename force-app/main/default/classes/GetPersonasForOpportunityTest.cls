@IsTest
public class GetPersonasForOpportunityTest {

    @TestSetup
    static void makeData(){
        Account acct = new Account(Name='SEP Test 01');
        insert acct;

        Contact ct = new Contact (FirstName='SEP Contact',LastName='LastName',EMail=UserInfo.getUserEmail(),AccountId=acct.Id);
        insert ct;


        Opportunity oppty = new Opportunity(AccountId=acct.Id,Name='SEP Oppty 01',StageName='01 - Discovery',CloseDate=System.today().addDays(60));
        insert oppty;

        MAPDomain__c dom = new MAPDomain__c(Name='SEP Test 01',Active__c=true);
        insert dom;

        MAPAssessment__c assmt = new MAPAssessment__c(ExternalId__c = 'SEP-TESTClass01',
                                                         Assessed_Date__c = System.today(),
                                                         Opportunity__c = oppty.Id,
                                                         Customer__c = acct.Id,
                                                         Summary__c = 'Discovery assessment for SEP Test 01');
        insert assmt;

        MAPPersona__c persona = new MAPPersona__c(Contact__c=ct.Id,
                                                Customer__c=acct.Id,
                                                Domain__c = dom.Id,
                                                ExternalId__c='SEP-TESTClassPersona01');
         insert persona;

         MAPInterview__c intr = new MAPInterview__c(Assessment__c=assmt.Id,Persona__c=persona.Id,ExternalId__c=assmt.Id+'-'+persona.Id);
         insert intr;
    }

    @IsTest
    public static void testGetPersonas(){
        Opportunity oppty = [select Id,Account.Id,Name from Opportunity limit 1];
        
        Test.startTest();
        List<MapInterview__c> interviews  = GetPersonasForOpportunity.getPersonasForOpportunity(oppty.Id);
        System.assert(interviews.size()==1, 'Incorrect inteviews returned');
        Test.stopTest();
    }
}