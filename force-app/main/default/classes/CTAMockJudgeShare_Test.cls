@istest
public class CTAMockJudgeShare_Test {
    public static final String COACH_PERM = 'CTA_Coach';
    @testSetup
    private static void setup() {
        // Initialize the Review Custom Settings
        CTA_Review_Create__c zamunda= new CTA_Review_Create__c ();
        zamunda.name = 'Short - 1. Zamunda Water';
        zamunda.type__c = 'Governance';
        zamunda.sequence__c = 1;
        zamunda.Attempt_time__c= '75 mins';
        zamunda.present_QA_Time__c = '30 mins';
        insert zamunda;
        
        CTA_Review_Create__c univauto= new CTA_Review_Create__c ();
        univauto.name = 'Short - 1B. Universal Auto';
        univauto.type__c = 'NonGovernance';
        univauto.sequence__c = 2;
        univauto.Attempt_time__c= '60 mins';
        univauto.present_QA_Time__c = '30 mins';
        insert univauto;

        Folder theFolder = [Select Id from Folder where Name = 'CTA Scenarios' limit 1];
        
        createScenarioDocs(theFolder.id);
        
        // Pick an evaluator
        PermissionSetAssignment psa = [SELECT AssigneeId, Assignee.name 
                                         FROM PermissionSetAssignment 
                                        WHERE PermissionSet.name='CTA_Coach' 
                                        LIMIT 1];
        Id evaluatorId = psa.AssigneeId;
        
        // Create the Candidate Contact Record
        Contact c = new Contact();
        c.Firstname = 'Harry';
        c.LastName = 'Potty';
        c.email = 'hpotter@griffindor.edu';
        insert c;
        
        // Create the Candidate Record
        CTA_Board_Candidate__c candidate = new CTA_Board_Candidate__c();
        candidate.Candidate__c = c.id;
        candidate.Coach__c = UserInfo.getUserId(); // just take the current running user as the coach
		insert candidate;
        
        createReviews(candidate.id,evaluatorId);
        
    }
    public static testMethod void testEmpty() {
        // None!
        List<CTA_Review_Session__c> reviews = new List<CTA_Review_Session__c>();
        CTAMockJudgeShare.createShares(reviews);
        System.Assert(true,'Nothing to do');  
    }
    
    public static testMethod void testMultiple() {
        List<CTA_Review_Session__c> reviews = [SELECT Id,Evaluator__c,CTA_Board_Candidate__c 
                                               FROM CTA_Review_Session__c];
        CTAMockJudgeShare.createShares(reviews);
        System.Assert(canScoreSession(reviews[0]),'Evaluator must be able to score review session!');         
    }
    
    
    public static testMethod void testNoEvaluator() {
        CTA_Board_Candidate__c candidate = [SELECT Id from CTA_Board_Candidate__c limit 1];
        createReviews(candidate.id,null);
    }

    private static boolean canScoreSession(CTA_Review_Session__c session) {
        System.RunAs(new User(id=session.Evaluator__c)) {
            session.Arch_Rating__c = 3.0;
            session.Send_Scenario_Now__c=true;
            update session;     
        }
        return true;
    }

    private static void createScenarioDocs(Id folderId) {

        List<Document> docs = new List<Document>();
        for(CTA_Review_Create__c current :  CTA_Review_Create__c.getall().values()) {
            // Generate a stub document that is properly named
            Document theDoc = new Document();
            theDoc.name = current.name;
            theDoc.body = Blob.toPDF('Simulated body for Scenario: ' + current.name);
            theDoc.type='pdf';
            theDoc.contentType='application/pdf';
            theDoc.folderId = folderId;
            docs.add(theDoc);
            
            Document key = new Document();
            key.name = 'Key:' + current.name;
            key.body = Blob.toPDF('Simulated KEY body for Scenario: ' + current.name);
            key.type='pdf';
            key.contentType='application/pdf';
            key.folderId = folderId;
            docs.add(key);
        }
        insert docs;
    }
    private static void createReviews(Id candidateId, Id evaluatorId) {
        		// Create the Reviews
		List<CTA_Review_Session__c> reviews = new List<CTA_Review_Session__c>();
        for (CTA_Review_Create__c master : CTA_Review_Create__c.getall().values()) {
            CTA_Review_Session__c current = new CTA_Review_Session__c();
            current.Attempt_Time__c= master.Attempt_Time__c;
            current.Evaluation_Date__c = System.now().date();
            current.CTA_Board_Candidate__c=candidateId;
            current.Evaluator__c = evaluatorId;
            current.Scenario__c = master.name;
            reviews.add(current);
        }
        insert reviews;

    }
}