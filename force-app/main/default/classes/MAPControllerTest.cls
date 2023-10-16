/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Company:       Salesforce
Description:   MAP Controller Test

History
Date            Author             Comments
--------------------------------------------------------------------------------------
16-09-2019      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/
@IsTest
public class MAPControllerTest {
    
    private static testMethod void validateMAPController(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contact contact = new Contact(LastName = 'Test Contact', AccountId = account.Id);
        insert contact;
        
        MAPDomain__c domain = new MAPDomain__c(Name = 'Test Domain', Active__c = true);
        insert domain;
        
        MAPDimension__c dimension = new MAPDimension__c(Name = 'Test Dimension', Domain__c = domain.Id);
        insert dimension;
        
        MAPCapability__c capability = new MAPCapability__c(Name = 'Test Capability', Dimension__c = dimension.Id);
        insert capability;
        
        MAPQuestion__c question = new MAPQuestion__c(Query__c = 'Test Question', Capability__c = capability.Id);
        insert question;
        
        MAPAnswer__c answer = new MAPAnswer__c(Description__c = 'Test Question', Question__c = question.Id);
        insert answer;
        
        MAPPersona__c persona = new MAPPersona__c(Domain__c = domain.Id, Customer__c = account.Id, Contact__c = contact.Id);
        insert persona;
        
        MAPAssessment__c assessment = new MAPAssessment__c(Customer__c = account.Id);
        insert assessment;
        
        MAPInterview__c interview = new MAPInterview__c(Assessment__c = assessment.Id, Persona__c = persona.Id);
        insert interview;
        
        MAPInterviewDimension__c interviewDimension = new MAPInterviewDimension__c(Interview__c = interview.Id, Dimension__c = dimension.Id);
        insert interviewDimension;
        
        MAPResponse__c response = new MAPResponse__c(Interview_Dimension__c = interviewDimension.Id, Capability__c = capability.Id, Question__c = question.Id, Current_State__c = answer.Id);
        insert response;
        
        MAPNote__c note = new MAPNote__c(Response__c = response.Id);
        insert note;
        
        String personaJSONString = MAPController.getPersonaData(persona.Id);
        
        MAPDataUtility.Persona persona2 = (MAPDataUtility.Persona) JSON.deserialize(personaJSONString, MAPDataUtility.Persona.class);
        
        String assessmentJSONString = MAPController.createNewAssessment(persona2.customer.id, 'Test Assessment');
        
        MAPDataUtility.Assessment assessment2 = (MAPDataUtility.Assessment) JSON.deserialize(assessmentJSONString, MAPDataUtility.Assessment.class);
        
        String interviewJSONString = MAPController.createNewInterview(persona2.id, assessment2.id);
        
        MAPDataUtility.Interview interview2 = (MAPDataUtility.Interview) JSON.deserialize(interviewJSONString, MAPDataUtility.Interview.class);

        MAPAnswer__c answer2 = new MAPAnswer__c(Description__c = 'N/A', Level__c = 'N/A');
        insert answer2; 

        MAPDataUtility.InterviewDimension interviewDimension2 = new MAPDataUtility.InterviewDimension();
        interviewDimension2.id = 'local_1';
        interviewDimension2.interviewId = interview2.Id;
        interviewDimension2.dimensionId = dimension.Id;
        interviewDimension2.skip = false;

        MAPDataUtility.Response response2 = new MAPDataUtility.Response();
        response2.id = 'local_2';
        response2.capabilityId = capability.Id;
        response2.questionId = question.Id;
        response2.currentAnswerId = answer.Id;

        MAPDataUtility.Note note2 = new MAPDataUtility.Note();
        note2.id = 'local_3';
        note2.action = 'Insert';
        note2.content = 'Test Response';

        MAPDataUtility.Note note3 = new MAPDataUtility.Note();
        note3.id = 'local_4';
        note3.action = 'Insert';
        note3.content = 'Test Interview Dimension';

        MAPDataUtility.Note note4 = new MAPDataUtility.Note();
        note4.id = 'local_5';
        note4.action = 'Insert';
        note4.content = 'Test Interview';

        MAPDataUtility.Note note5 = new MAPDataUtility.Note();
        note5.id = 'local_6';
        note5.action = 'Insert';
        note5.content = 'Test Assessment';

        response2.notes = new List<MAPDataUtility.Note>{ note2 };
        response2.skip = true;

        interviewDimension2.notes = new List<MAPDataUtility.Note>{ note3 };
        interviewDimension2.responses = new List<MAPDataUtility.Response>{ response2 };

        interview2.notes = new List<MAPDataUtility.Note>{ note4 };
        interview2.assessmentNotes = new List<MAPDataUtility.Note>{ note5 };
        interview2.interviewDimensions = new List<MAPDataUtility.InterviewDimension>{ interviewDimension2 };
        
        MAPController.saveInterview(JSON.serialize(interview2));
    }
}