/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Company:       Salesforce
Description:   MAP Data Utility

History
Date            Author             Comments
--------------------------------------------------------------------------------------
01-03-2018      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/

public with sharing class SEPDataUtility {

	private static Id notApplicableAnswerId;

	public static Persona getPersonaData(Id personaId){
		return (new Persona(getPersona(personaId)));
	}

	public static Assessment createNewAssessment(Id customerId, String summary){
		MAPAssessment__c assessment = new MAPAssessment__c(Customer__c = customerId, Summary__c = summary);
		insert assessment;
		assessment = getAssessment(assessment.Id);
		return (new Assessment(assessment));
	}

	public static Interview createNewInterview(Id personaId, Id assessmentId){
		MAPInterview__c interview = new MAPInterview__c(
			Persona__c = personaId, 
			Assessment__c = assessmentId, 
			Interview_Date__c = Date.today()
		);
		insert interview;
		return (new Interview(getInterview(interview.Id)));
	}

	public static Map<String, Id> saveInterview(Interview interview){
		upsert interview.getInterviewDimensions();
		upsert interview.getResponses();
		insert interview.getInsertableNotes();
		        
        Database.DeleteResult[] delNotes = Database.delete(interview.getDeletableNotes(), false);
		for (Database.DeleteResult result : delNotes)
        {
			if (result.isSuccess())
            continue;
            
            for(Database.Error error : result.getErrors()) {
                System.debug('The following error has occurred when saving notes: ');                    
                System.debug(error.getStatusCode() + ': ' + error.getMessage());
                System.debug('Note fields that affected this error: ' + error.getFields());
            }
        }
        
		update interview.getRecord();
		return interview.setRecordIds();
	}
        
	private static MAPPersona__c getPersona(Id personaId){
		return [
			SELECT Id, Customer__r.Id, Customer__r.Name, Contact__r.Id, Contact__r.Name, 
				Domain__r.Name, Domain__r.Active__c, Domain__r.Dimension_Count__c, Domain__r.Levels__c 
			FROM MAPPersona__c WHERE Id =: personaId
		];
	}

	private static List<MAPAssessment__c> getAssessments(Id customerId){
		return [
			SELECT Id, Name, Customer__c, Completed__c, CreatedDate, CreatedBy.Name, Summary__c,
				(SELECT Id, Persona__c, Assessment__c, Name, Level__c, CreatedBy.Name, LastModifiedBy.Name, Score__c, 
					Completed__c, Guided__c, Interview_Date__c, Goal_Date__c, CreatedDate, LastModifiedDate 
				FROM Interviews__r ORDER BY CreatedDate LIMIT 100)
			FROM MAPAssessment__c WHERE Customer__c =: customerId ORDER BY CreatedDate LIMIT 100
		];
	}

	private static List<MAPInterviewDimension__c> getInterviewDimensions(Set<Id> interviewIds, Set<Id> dimensionIds, Set<Id> questionIds){
		return [
			SELECT Id, Interview__c, Dimension__c, Level__c, Skip__c,
				(SELECT Id, Interview_Dimension__c, Interview_Dimension__r.Interview__c, Interview_Dimension__r.Dimension__c, 
					Capability__c, Question__c, Current_State__c, Goal_State__c, Priority__c, Score__c, Effort__c, Goal_Date__c, Skip__c 
				FROM Responses__r WHERE Question__c IN: questionIds)
			FROM MAPInterviewDimension__c WHERE Interview__c IN: interviewIds AND Dimension__c IN: dimensionIds
		];
	}

	private static List<MAPDimension__c> getDimensions(Id domainId){
		return [
			SELECT Id, Name, Sequence__c, Domain__c, Theme__c,
				(SELECT Id, Name, Sequence__c, Dimension__c, Query__c FROM Capabilities__r)
			FROM MAPDimension__c WHERE Domain__c =: domainId
		];
	}

	private static List<MAPQuestion__c> getQuestions(Set<Id> capabilityIds){
		return [
			SELECT Id, Capability__c, Capability__r.Dimension__c, Name, Query__c, Help__c, Sequence__c, Follow_Up__c,
				(SELECT Id, Question__c, Level__c, Description__c FROM Answers__r)
			FROM MAPQuestion__c WHERE Capability__c IN: capabilityIds
		];
	}

	private static List<MAPNote__c> getNotes(Set<Id> parentIds){
		return [
			SELECT Id, Type__c, Content__c, Assessment__c, Interview__c, Interview_Dimension__c, Response__c 
			FROM MAPNote__c WHERE Assessment__c IN: parentIds OR Interview__c IN: parentIds OR Interview_Dimension__c IN: parentIds OR Response__c IN: parentIds
		];
	}

	private static MAPAssessment__c getAssessment(Id assessmentId){
		return [
			SELECT Id, Name, Customer__c, Completed__c, CreatedDate, CreatedBy.Name, Summary__c
			FROM MAPAssessment__c WHERE Id =: assessmentId
		];
	}

	private static MAPInterview__c getInterview(Id interviewId){
		return [
			SELECT Id, Persona__c, Assessment__c, Name, Level__c, CreatedBy.Name, LastModifiedBy.Name, Score__c, 
				Completed__c, Guided__c, Interview_Date__c, Goal_Date__c, CreatedDate, LastModifiedDate
			FROM MAPInterview__c WHERE Id =: interviewId
		];
	}

	private static Boolean isLocalId(String id){
		return id.startsWith('local_');
	}

	private static String getRecordId(String id){
		return !isLocalId(id) ? id : null;
	}

	private static Id getNotApplicableAnswerId(){
		if(notApplicableAnswerId == null){
			notApplicableAnswerId = [SELECT Id FROM MAPAnswer__c WHERE Level__c = 'N/A' LIMIT 1].Id;
		}
		return notApplicableAnswerId;
	}

	public class Persona{
		public Id id;
		public Account customer; 
		public Contact contact; 
		public Domain domain;

		public Map<Id, Dimension> dimensions;
		public Map<Id, Capability> capabilities;
		public Map<Id, Question> questions;
		public Map<Id, Answer> answers;
		public Map<Id, Assessment> assessments;
		public Map<Id, Interview> interviews;
		public Map<Id, InterviewDimension> interviewDimensions;
		public Map<Id, Response> responses;
		public Map<Id, Note> notes;

		public List<MAPMetaUtility.PicklistValue> goalDates, priorities, efforts, noteTypes;

		public Persona(MAPPersona__c persona){
			id = persona.Id; 
			customer = persona.Customer__r;
			contact = persona.Contact__r; 
			domain = new Domain(persona.Domain__r);

			dimensions = new Map<Id, Dimension>();
			capabilities = new Map<Id, Capability>();
			questions = new Map<Id, Question>();
			answers = new Map<Id, Answer>();
			assessments = new Map<Id, Assessment>();
			interviews = new Map<Id, Interview>();
			interviewDimensions = new Map<Id, InterviewDimension>();
			responses = new Map<Id, Response>();
			notes = new Map<Id, Note>();

			getDimension();
			getQuestions();
			getAssessments();
			getInterviewDimensions();
			getNotes();
			getResponsePicklistValues();
		}

		private void getDimension(){
			for(MAPDimension__c dimension : getDimensions(domain.Id)){
				dimensions.put(dimension.Id, new Dimension(dimension));
				for(MAPCapability__c capability : dimension.Capabilities__r){
					capabilities.put(capability.Id, new Capability(capability));
				}
			}
		}

		private void getQuestions(){
			for(MAPQuestion__c question : getQuestions(capabilities.keySet())){
				questions.put(question.Id, new Question(question));
				for(MAPAnswer__c answer : question.Answers__r){
					answers.put(answer.Id, new Answer(answer));
				}
			}
		}

		private void getAssessments(){
			for(MAPAssessment__c assessment : getAssessments(customer.Id)){
				assessments.put(assessment.Id, new Assessment(assessment));
				for(MAPInterview__c interview : assessment.Interviews__r){
					interviews.put(interview.Id, new Interview(interview));
				}
			}
		}

		private void getInterviewDimensions(){
			for(MAPInterviewDimension__c interviewDimension : getInterviewDimensions(interviews.keySet(), dimensions.keySet(), questions.keySet())){
				interviewDimensions.put(interviewDimension.Id, new InterviewDimension(interviewDimension));
				for(MAPResponse__c response : interviewDimension.Responses__r){
					responses.put(response.Id, new Response(response));
				}
			}
		}

		private void getNotes(){
			for(MAPNote__c note : getNotes(getNoteParentIds())){
				notes.put(note.Id, new Note(note));
			}
		}

		private Set<Id> getNoteParentIds(){
			Set<Id> parentIds = new Set<Id>();
			parentIds.addAll(assessments.keySet());
			parentIds.addAll(interviews.keySet());
			parentIds.addAll(interviewDimensions.keySet());
			parentIds.addAll(responses.keySet());
			return parentIds;
		}

		private void getResponsePicklistValues(){
			goalDates = MAPMetaUtility.getPicklistValues('MAPResponse__c', 'Goal_Date__c');
			priorities = MAPMetaUtility.getPicklistValues('MAPResponse__c', 'Priority__c');
			efforts = MAPMetaUtility.getPicklistValues('MAPResponse__c', 'Effort__c');
			noteTypes = MAPMetaUtility.getPicklistValues('MAPNote__c', 'Type__c');
		}
	}

	public class Domain{
		public Id id;
		public String name;
		public Boolean isActive;
		public Decimal dimensionsCount;
		public Set<String> levels;

		public Domain(MAPDomain__c domain){
			id = domain.Id; 
			name = domain.Name;
			isActive = domain.Active__c;
			dimensionsCount = domain.Dimension_Count__c;
			levels = new Set<String>((domain.Levels__c != null ? domain.Levels__c : '').split(';'));
		}
	}

	public class Dimension{
		public Id id, domainId;
		public String name, theme;
		public Decimal sequence;

		public Dimension(MAPDimension__c dimension){
			id = dimension.Id; 
			domainId = dimension.Domain__c;
			name = dimension.Name; 
			theme = dimension.Theme__c; 
			sequence = dimension.Sequence__c;
		}
	}

	public class Capability{
		public Id id, dimensionId;
		public String name, query;
		public Decimal sequence;

		public Capability(MAPCapability__c capability){
			id = capability.Id; 
			dimensionId = capability.Dimension__c;
			name = capability.Name;
			query = capability.Query__c;
			sequence = capability.Sequence__c;
		}
	}

	public class Question{
		public Id id, capabilityId, dimensionId, parentId;
		public String name, query, help;
		public Decimal sequence;

		public Question(MAPQuestion__c question){
			System.debug('>>>>>>>>> question.Id = '+question.Id);
			System.debug('>>>>>>>>> question.Name = '+question.Name);
			id = question.Id; 
			capabilityId = question.Capability__c; 
			dimensionId = question.Capability__r.Dimension__c; 
			parentId = question.Follow_Up__c;
			name = question.Name; 
			query = question.Query__c; 
			help = question.Help__c;
			sequence = question.Sequence__c;
			if(!query.endsWith('?')) query += '?';
		}
	}

	public class Answer{
		public Id id, questionId;
		public String level, value;

		public Answer(MAPAnswer__c answer){
			id = answer.Id; 
			questionId = answer.Question__c;
			level = answer.Level__c; 
			value = answer.Description__c;
		}
	}

	public class Assessment{
		public Id id, customerId;
		public String name, createdBy, summary;
		public Boolean completed;
		public DateTime createdAt;

		public Assessment(MAPAssessment__c assessment){
			id = assessment.Id;
			name = assessment.Name;
			customerId = assessment.Customer__c;
			createdBy = assessment.CreatedBy.Name;
			summary = assessment.Summary__c;
			completed = assessment.Completed__c;
			createdAt = assessment.CreatedDate;
		}
	}

	public class Interview{
		public Id id, personaId, assessmentId;
		public String name, level, createdBy, lastModifiedBy;
		public Decimal score;
		public Boolean completed, guided;
		public Date interviewDate, goalDate;
		public DateTime createdAt, lastModifiedAt;
		public List<InterviewDimension> interviewDimensions;
		public List<Note> notes;
		public List<Note> assessmentNotes;

		public Interview(MAPInterview__c interview){
			id = interview.Id; 
			personaId = interview.Persona__c; 
			assessmentId = interview.Assessment__c;
			name = interview.Name; 
			level = interview.Level__c; 
			createdBy = interview.CreatedBy.Name;
			lastModifiedBy = interview.LastModifiedBy.Name;
			score = interview.Score__c; 
			completed = interview.Completed__c; 
			guided = interview.Guided__c; 
			interviewDate = interview.Interview_Date__c; 
			goalDate = interview.Goal_Date__c; 
			createdAt = interview.CreatedDate; 
			lastModifiedAt = interview.LastModifiedDate; 
			interviewDimensions = new List<InterviewDimension>();
		}

		public MAPInterview__c getRecord(){
			return new MAPInterview__c(
				Id = id,
				Interview_Date__c = interviewDate,
				Completed__c = completed
			);
		}

		public List<MAPInterviewDimension__c> getInterviewDimensions(){
			List<MAPInterviewDimension__c> records = new List<MAPInterviewDimension__c>();
			for(InterviewDimension interviewDimension :interviewDimensions){
				records.add(interviewDimension.getRecord());
			}
			return records;
		}

		public List<MAPResponse__c> getResponses(){
			List<MAPResponse__c> records = new List<MAPResponse__c>();
			for(InterviewDimension interviewDimension :interviewDimensions){
				records.addAll(interviewDimension.getResponses());
			}
			return records;
		}

		public List<MAPNote__c> getInsertableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			records.addAll(getAssessmentInsertableNotes());
			records.addAll(getInterviewInsertableNotes());
			records.addAll(getInterviewDimensionInsertableNotes());
			return records;
		}

		private List<MAPNote__c> getAssessmentInsertableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Note note :assessmentNotes){
				if(note.isInsertable()){
					note.parentId = note.assessmentId = assessmentId;
					records.add(note.getRecord());
				}
			}
			return records;
		}

		private List<MAPNote__c> getInterviewInsertableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Note note :notes){
				if(note.isInsertable()){
					note.parentId = note.interviewId = id;
					records.add(note.getRecord());
				}
			}
			return records;
		}

		private List<MAPNote__c> getInterviewDimensionInsertableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(InterviewDimension interviewDimension :interviewDimensions){
				records.addAll(interviewDimension.getInsertableNotes());
			}
			return records;
		}

		public List<MAPNote__c> getDeletableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			records.addAll(getAssessmentDeletableNotes());
			records.addAll(getInterviewDeletableNotes());
			records.addAll(getInterviewDimensionDeletableNotes());
			return records;
		}

		private List<MAPNote__c> getAssessmentDeletableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Note note :assessmentNotes){
				if(note.isDeletable()) records.add(note.getRecord()); 
			}
			return records;
		}

		private List<MAPNote__c> getInterviewDeletableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Note note :notes){
				if(note.isDeletable()) records.add(note.getRecord()); 
			}
			return records;
		}

		private List<MAPNote__c> getInterviewDimensionDeletableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(InterviewDimension interviewDimension :interviewDimensions){
				records.addAll(interviewDimension.getDeletableNotes());
			}
			return records;
		}

		public Map<String, Id> setRecordIds(){
			Map<String, Id> localIdsMap = new Map<String, Id>(); 
			for(InterviewDimension interviewDimension :interviewDimensions){
				interviewDimension.setRecordId(localIdsMap);
			}
			setRecordIds(assessmentNotes, localIdsMap);
			setRecordIds(notes, localIdsMap);
			return localIdsMap;
		}

		private void setRecordIds(List<Note> notes, Map<String, Id> localIdsMap){
			for(Note note :notes){
				if(note.isInsertable()){
					note.setRecordId(localIdsMap);
				}
			}
		}
	}

	public class InterviewDimension{
		public Id interviewId, dimensionId;
		public String id, level;
		public Boolean skip;
		public decimal score;
		public List<Response> responses;
		public List<Note> notes;

		public MAPInterviewDimension__c record;
        
        public InterviewDimension(){}

		public InterviewDimension(MAPInterviewDimension__c interviewDimension){
			id = interviewDimension.Id;
			interviewId = interviewDimension.Interview__c; 
			dimensionId = interviewDimension.Dimension__c; 
			level = interviewDimension.Level__c;
			skip = interviewDimension.Skip__c;
			score = 0;
			responses = new List<Response>();
		}

		public MAPInterviewDimension__c getRecord(){
			return record = new MAPInterviewDimension__c(
				Id = getRecordId(id), 
				Interview__c = interviewId, 
				Dimension__c = dimensionId,
				Skip__c = skip
			);
		}

		public List<MAPResponse__c> getResponses(){
			List<MAPResponse__c> records = new List<MAPResponse__c>();
			for(Response response :responses){
				if(response.currentAnswerId != null){
					response.interviewDimensionId = record.Id;
					records.add(response.getRecord());
				}
			}
			return records;
		}

		public List<MAPNote__c> getInsertableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Note note :notes){
				if(note.isInsertable()){
					note.parentId = note.interviewDimensionId = record.Id;
					records.add(note.getRecord());
				}
			}
			records.addAll(getResponseInsertableNotes());
			return records;
		}

		private List<MAPNote__c> getResponseInsertableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Response response :responses){
				records.addAll(response.getInsertableNotes());
			}
			return records;
		}

		public List<MAPNote__c> getDeletableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Note note :notes){
				if(note.isDeletable()) records.add(note.getRecord()); 
			}
			for(Response response :responses){
				records.addAll(response.getDeletableNotes());
			}
			return records;
		}

		public void setRecordId(Map<String, Id> localIdsMap){
			if(isLocalId(id)) localIdsMap.put(id, record.Id);
			id = record.Id;
			for(Response response :responses){
				if(response.currentAnswerId != null){
					response.setRecordId(localIdsMap);
				}
			}
			for(Note note :notes){
				if(note.isInsertable()){
					note.setRecordId(localIdsMap);
				}
			}
		}
	}

	public class Response{
		public Id interviewId, dimensionId, capabilityId, questionId, goalAnswerId;
		public String id, interviewDimensionId, currentAnswerId, goalDate, priority, effort;
		public Boolean skip;
		public Decimal score;
		public List<Note> notes;

		public MAPResponse__c record;
        
        public Response(){}

		public Response(MAPResponse__c response){
			id = response.Id;
			interviewDimensionId = response.Interview_Dimension__c;
			interviewId = response.Interview_Dimension__r.Interview__c;
			dimensionId = response.Interview_Dimension__r.Dimension__c;
			capabilityId = response.Capability__c; 
			questionId = response.Question__c; 
			currentAnswerId = response.Current_State__c; 
			goalAnswerId = response.Goal_State__c; 
			goalDate = response.Goal_Date__c;
			priority = response.Priority__c;
			effort = response.Effort__c;
			score = response.Score__c != null ? response.Score__c : 0;
			skip = response.Skip__c;
		}

		public MAPResponse__c getRecord(){
			return record = new MAPResponse__c(
				Id = getRecordId(id),
				Interview_Dimension__c = interviewDimensionId, 
				Capability__c = capabilityId, 
				Question__c = questionId, 
				Current_State__c = skip ? getNotApplicableAnswerId() : currentAnswerId, 
				Goal_State__c = goalAnswerId,
				Goal_Date__c = goalDate, 
				Priority__c = priority,
				Effort__c = effort,
				Skip__c = skip
			);
		}

		public List<MAPNote__c> getInsertableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Note note :notes){
				if(note.isInsertable()){
					note.parentId = note.responseId = record.Id;
					records.add(note.getRecord());
				}
			}
			return records;
		}

		public List<MAPNote__c> getDeletableNotes(){
			List<MAPNote__c> records = new List<MAPNote__c>();
			for(Note note :notes){
				if(note.isDeletable())records.add(note.getRecord());
			}
			return records;
		}

		public void setRecordId(Map<String, Id> localIdsMap){
			if(isLocalId(id)) localIdsMap.put(id, record.Id);
			id = record.Id;
			for(Note note :notes){
				if(note.isInsertable()){
					note.setRecordId(localIdsMap);
				}
			}
		}
	}

	public class Note{
		public String id, parentId, assessmentId, interviewId, interviewDimensionId, responseId, type, content, action;

		public MAPNote__c record;
        
        public Note(){}

		public Note(MAPNote__c note){
			id = note.Id;
			assessmentId = note.Assessment__c;
			interviewId = note.Interview__c;
			interviewDimensionId = note.Interview_Dimension__c;
			responseId = note.Response__c;
			parentId = getParentId(note);
			type = note.Type__c;
			content = note.Content__c;
		}

		private String getParentId(MAPNote__c note){
			return assessmentId != null ? assessmentId : interviewId  != null ? interviewId : interviewDimensionId != null ? interviewDimensionId : responseId;
		}

		public Boolean isInsertable(){
			return action == 'Insert';
		}

		public Boolean isDeletable(){
			return action == 'Delete';
		}

		public MAPNote__c getRecord(){
			return record = new MAPNote__c(
				Id = getRecordId(id),
				Type__c = type,
				Content__c = content,
				Assessment__c = assessmentId,
				Interview__c = interviewId,
				Interview_Dimension__c = interviewDimensionId,
				Response__c = responseId
			);
		}

		public void setRecordId(Map<String, Id> localIdsMap){
			if(isLocalId(id)) localIdsMap.put(id, record.Id);
			id = record.Id;
		}
	}
}