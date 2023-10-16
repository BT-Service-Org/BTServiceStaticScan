({
	persona: {}, unsaved: [], local: 0,

	getLocalId: function(){ return this.local++; },

	setScreen: function(cmp, screen){ 
		document.body.scrollTop = 0;
    	document.documentElement.scrollTop = 0;  
    	cmp.set("v.screen", screen);
	},
	initStreamAssesment: function(cmp){
		console.info('SEP ', "in init Stream Assessment");
		var pageRef = cmp.get("v.pageReference");
        //var personaId = pageRef.state.c__personaId;
        //var interviewId = pageRef.state.c__interviewId;
        var assessmentId = "a047e000007pAMaAAM" // hard coded for debug pageRef.state.c__assessmentId;
		console.info('SEP ', `Assessment Id: ${assessmentId}`);
		//cmp.set('v.interviewId',interviewId);
		//cmp.set('v.personaId',personaId);
		cmp.set('v.assessmentId',assessmentId);
		
		//var params = { "personaId": personaId };
		//return this.enqueueAction(cmp, "getPersonaData", params).then(this.partial(this.setPersona, cmp));
	},
	setPersona: function(cmp, data){
		this.persona = this.extend(this.persona, data);
		this.initDomain();
		cmp.set("v.customer", this.persona.customer);
		cmp.set("v.contact", this.persona.contact);
		cmp.set("v.domain", this.persona.domain);
		cmp.set("v.assessments", this.values(this.persona.assessments));
		cmp.set("v.notes", this.values(this.persona.notes));
		cmp.set("v.assessment", this.persona.assessments[cmp.get('v.assessmentId')]);
		this.setAssessment(cmp, cmp.get('v.assessmentId'));
		this.setInterview(cmp, cmp.get('v.interviewId'));
		/*if(this.persona.currentAssessmentId && this.has(this.persona.assessments, this.persona.currentAssessmentId)){
			cmp.set("v.assessment", this.persona.assessments[this.persona.currentAssessmentId]);
			this.setScreen(cmp, "SEP_Assessment");
		} else {
			this.persona.currentAssessmentId = null;
			this.setScreen(cmp, "SEP_Persona");
		}*/
	},
	initDomain: function(){
		this.createMissingInterviewDimensions();
		this.createMissingResponses();
		this.getDomainDimensions(this.persona.domain);
		this.each(this.persona.dimensions, this.getDimensionCapabilities);
		this.each(this.persona.capabilities, this.getCapabilityQuestions);
		this.each(this.persona.questions, this.getQuestionAnswers);
		this.each(this.persona.assessments, this.getAssessmentInterviews);
		this.each(this.persona.interviews, this.getInterviewDimensions);
		this.each(this.persona.interviewDimensions, this.getInterviewDimensionResponses);
		this.getGlobalAnswerSet();
		this.setQuestionNumbers();
	},
	createMissingInterviewDimensions: function(){
		var dimensionIds = this.keys(this.persona.dimensions), interviewIds = this.keys(this.persona.interviews);
		var existing = this.reduce(this.persona.interviewDimensions, this.partial(this.getExistingIterator, "interviewId" , "dimensionId"), []);
		this.createMissingInterviewDimensions2(dimensionIds, interviewIds, existing);
	},
	createMissingInterviewDimensions2: function(dimensionIds, interviewIds, existing){
		this.getCombinationIterator(dimensionIds, interviewIds, (dimensionId, interviewId) => {
			if(!existing.includes(interviewId + dimensionId)){
				var interviewDimension = { id: "local_" + this.getLocalId(), dimensionId: dimensionId, interviewId: interviewId };
				this.persona.interviewDimensions[interviewDimension.id] = interviewDimension;
				this.unsaved.push({ type: "InterviewDimension", data: interviewDimension });
			}
		});
	},
	createMissingResponses: function(){
		var questionIds = this.keys(this.persona.questions), interviewIds = this.keys(this.persona.interviews);
		var existing = this.reduce(this.persona.responses, this.partial(this.getExistingIterator, "questionId" , "interviewId"), []);
		this.createMissingResponses2(questionIds, interviewIds, existing);
	},
	createMissingResponses2: function(questionIds, interviewIds, existing){
		this.getCombinationIterator(questionIds, interviewIds, (questionId, interviewId) => {
			if(!existing.includes(questionId + interviewId)){
				var question = this.persona.questions[questionId];
				var response = { 
					id: "local_" + this.getLocalId(), questionId: questionId, interviewId: interviewId, 
					capabilityId: question.capabilityId, dimensionId: question.dimensionId
				};
				this.persona.responses[response.id] = response;
				this.unsaved.push({ type: "Response", data: response });
			}
		});
	},
	getExistingIterator: function(firstKey, secondKey, existing, data){
		existing.push(data[firstKey] + data[secondKey]); return existing;
	},
	getCombinationIterator: function(first, second, callback){
		this.each(first, (item1) => { this.each(second, (item2) => { callback(item1, item2) }) });
	},
	getDomainDimensions: function(domain){
		domain.dimensions = this.createLinkedList(this.where(this.persona.dimensions, { domainId: domain.id }));
	},
	getDimensionCapabilities: function(dimension){
		dimension.updateStatus = this.partial(this.updateStatus, dimension);
		dimension.updateNAStatus = this.partial(this.updateNAStatus, dimension);
		dimension.capabilities = this.createLinkedList(this.where(this.persona.capabilities, { dimensionId: dimension.id }));
	},
	getCapabilityQuestions: function(capability){
		capability.updateNAStatus = this.partial(this.updateNAStatus, null, capability);
		capability.questions = this.createLinkedList(this.filter(this.persona.questions, (question) => { 
			return question.capabilityId === capability.id && !question.parentId;
		}));
	},
	getQuestionAnswers: function(question){
		question.parent = this.persona.questions[question.parentId];
		question.children = this.createLinkedList(this.where(this.persona.questions, { parentId: question.id }));
		question.updateNAStatus = this.partial(this.updateNAStatus, null, null, question);
		question.answers = this.indexBy(this.where(this.persona.answers, { questionId: question.id }), "level");
	},
	getAssessmentInterviews: function(assessment){
		assessment.interviews = this.where(this.persona.interviews, { assessmentId: assessment.id });
		assessment.completedCount = this.size(this.where(assessment.interviews, { completed: true }));
	},
	getInterviewDimensions: function(interview){
		interview.interviewDimensions = this.where(this.persona.interviewDimensions, { interviewId: interview.id });
		interview.responses = this.where(this.persona.responses, { interviewId: interview.id });
	},
	getInterviewDimensionResponses: function(interviewDimension){
		interviewDimension.responses = this.where(this.persona.responses, { 
			interviewId: interviewDimension.interviewId, dimensionId: interviewDimension.dimensionId 
		});
	},
	getGlobalAnswerSet: function(cmp){
		this.persona.globalAnswerSet = this.findWhere(this.persona.answerSets, { type : "Global Answer" }) || {};
		this.persona.globalAnswerSet.answers = this.indexBy(this.where(this.persona.answers, { answerSetId: this.persona.globalAnswerSet.id }), "level");
	},
	setQuestionNumbers: function(){
		var letters = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
		var count = 1, dimension = this.persona.domain.dimensions[0];
		while(dimension){
			var capability = dimension.capabilities[0];
			while(capability){
				var question = capability.questions[0];
				while(question){
					question.number = count++;
					var count2 = 0;
					var child = question.children[0];
					while(child){
						child.number = letters[count2++]; 
						child = this.persona.questions[child.next];
					} 
					question = this.persona.questions[question.next];
				}
				capability = this.persona.capabilities[capability.next];
			}
			dimension = this.persona.dimensions[dimension.next];
		}
		this.persona.domain.totolQuestions = count-1;
	},
	createLinkedList: function(list, number){
		list = this.sortList(list);
		for(var i = 0, len = list.length; i < len; i++){
			if(i > 0) list[i]["previous"] = list[i-1].id;  
			if(i + 1 < len) list[i]["next"] = list[i+1].id; 
			list[i].number = number++;
		}
		return list;
	},
	sortList: function(list){
		this.each(list, (item) => { if(!item.sequence) item.sequence = list.length + 1; });
		return list.sort((a, b) => { return (a.sequence - b.sequence); });
	},
	updateStatus: function(dimension){
		dimension.completed = true;
		dimension.inapplicable = true;
		var capability = dimension.capabilities[0];
		while(capability){
			capability.inapplicable = true;
			var question = capability.questions[0];
			while(question){
				if(question.response.skip || question.response.currentAnswerId === "NA"){
					question.response.skip = true;
					question.response.currentAnswerId = "NA";
				}
				if(!question.response.skip){
					capability.inapplicable = false;
					dimension.inapplicable = false;
				}
				if(!question.response.currentAnswerId){
					dimension.completed = false;
				}
				question = this.persona.questions[question.next];
			}
			capability = this.persona.capabilities[capability.next];
		}
	},
	updateNAStatus: function(dimension, capability, question) {
		if(question) capability = this.persona.capabilities[question.capabilityId];
		if(capability) dimension = this.persona.dimensions[capability.dimensionId];
		if(dimension && !capability && !question && dimension.inapplicable){
			this.each(dimension.capabilities, (capability) => {
				capability.inapplicable = true;
				this.updateQuestionsNAStatus(capability);
			});
		} else if(capability && !question && capability.inapplicable){
			this.updateQuestionsNAStatus(capability);
		} else {
			if(capability) capability.inapplicable = this.isCapabilityNotApplicable(capability); 
			if(dimension) dimension.inapplicable = this.isDimensionNotApplicable(dimension); 
		}
	},
	isDimensionNotApplicable: function(dimension){
		return this.isEmpty(this.find(dimension.capabilities, (capability) => { 
			return !capability.inapplicable; 
		}));
	},
	isCapabilityNotApplicable: function(capability){
		return this.isEmpty(this.find(capability.questions, (question) => { 
			return !(question.response.skip || question.response.currentAnswerId === "NA");
		}));
	},
	updateQuestionsNAStatus: function(capability){
		this.each(capability.questions, (question) => { 
			question.response.skip = true;
			question.response.currentAnswerId = "NA"; 
		});
	},
	setAssessment: function(cmp, assessmentId){
		cmp.set("v.assessment", this.persona.assessments[assessmentId]);
		this.setScreen(cmp, "SEP_Assessment");
	},
	setInterview: function(cmp, interviewId){
		var interview = this.persona.interviews[interviewId];
		interview.options = this.getDefaultOptions(interview.completed);
		interview.goalDates = this.persona.goalDates;
		interview.priorities = this.persona.priorities;
		interview.efforts = this.persona.efforts;
		interview.noteTypes = this.persona.noteTypes;
		interview.globalAnswerSet = this.persona.globalAnswerSet;
		this.setCurrentQuestion(interview);
		this.setInterviewResponses(interview);
		cmp.set("v.interview", interview);
		this.setScreen(cmp, "SEP_Interview");
		this.initAutoSave(cmp);
	},
	getDefaultOptions: function(completed){
		return {
			enableFocusMode: false,
			enableDetailMode: true,
			enableAutoSave: !completed,
			showProgressBar: false,
			showTooltips: true,
			showExamples: false
		};
	},
	setCurrentQuestion: function(interview){
		if(interview.completed) return;
		var currentQuestion = this.getCurrentQuestion(interview);
		if(currentQuestion){
			interview.currentDimensionId = currentQuestion.dimensionId;
			interview.currentCapabilityId = currentQuestion.capabilityId;
		}
	},
	getCurrentQuestion: function(interview){
		var responses = this.indexBy(interview.responses, "questionId");
		var currentQuestion, dimension = this.persona.domain.dimensions[0];
		while(dimension){
			var capability = dimension.capabilities[0];
			while(capability){
				var question = capability.questions[0];
				while(question){
					if(this.has(responses, question.id)){
						var response = responses[question.id];
						if(response.currentAnswerId){
							currentQuestion = question;
						}
					}
					question = this.persona.questions[question.next];
				}
				capability = this.persona.capabilities[capability.next];
			}
			dimension = this.persona.dimensions[dimension.next];
		}
		return currentQuestion;
	},
	setInterviewResponses: function(interview){
		this.each(interview.responses, (response) => { this.persona.questions[response.questionId].response = response; });
	},
	createAssessment: function(cmp, summary){
		var params = { customerId: this.persona.customer.Id, summary: summary };
		return this.enqueueAction(cmp, "createNewAssessment", params).then(this.partial(this.addAssessment, cmp));
	},
	addAssessment: function(cmp, data){
		var assessment = this.extend({ interviews: [], completedCount: 0 }, data);
		this.persona.assessments[assessment.id] = assessment;
		cmp.set("v.assessments", this.values(this.persona.assessments));
		this.setAssessment(cmp, assessment.id);
	},
	createInterview: function(cmp){
		var params = { personaId: cmp.get("v.recordId"), assessmentId: cmp.get("v.assessment.id") };
		return this.enqueueAction(cmp, "createNewInterview", params).then(this.partial(this.addInterview, cmp));
	},
	addInterview: function(cmp, data){
		this.initInterview(data);
		this.persona.interviews[data.id] = data;
		this.setInterview(cmp, data.id);
	},
	initInterview: function(interview){
		var dimensionIds = this.keys(this.persona.dimensions), questionIds = this.keys(this.persona.questions);
		this.createMissingInterviewDimensions2(dimensionIds, [interview.id], []);
		this.createMissingResponses2(questionIds, [interview.id], []);
		this.getInterviewDimensions(interview);
		this.each(interview.interviewDimensions, this.getInterviewDimensionResponses);
	},
	getUpdatableInterview: function(cmp){
		this.setNotes(cmp);
		var interview = this.pick(cmp.get("v.interview"), "id", "assessmentId", "interviewDimensions", "interviewDate", "completed");
		interview.interviewDimensions = this.compact(this.map(interview.interviewDimensions, (interviewDimension) => { 
			var responses = this.filter(interviewDimension.responses, (response) => { return response.currentAnswerId; });
			var notes = this.getNotes(cmp, interviewDimension.id);
			if(this.isNotEmpty(responses) || this.isNotEmpty(notes)){
				interviewDimension = this.pick(interviewDimension, "id", "interviewId", "dimensionId");
				interviewDimension.skip = this.persona.dimensions[interviewDimension.dimensionId].inapplicable;
				interviewDimension.responses = responses;
				interviewDimension.notes = notes;
				if(this.isNotEmpty(responses)){
					this.each(responses, (response) => {
						response.skip = response.currentAnswerId === "NA";
						response.notes = this.getNotes(cmp, response.id);
					});
				}
				return interviewDimension;
			}
		}));
		interview.notes = this.getNotes(cmp, interview.id);
		interview.assessmentNotes = this.getNotes(cmp, interview.assessmentId);
		return interview;
	},
	setNotes: function(cmp){
		this.persona.notes = this.indexBy(cmp.get("v.notes"), "id");
	},
	getNotes: function(cmp, parentId){
		return this.filter(this.persona.notes, (note) => { return note.parentId === parentId; });
	},
	cancelInterview: function(cmp){
		if(!cmp.get("v.interview.completed")){
			this.resetPersona(cmp);
		} else {
			cmp.set("v.interview", null);
			this.setScreen(cmp, "MAPAssessment");
		}
	}, 
	saveInterview: function(cmp){
		if(!this.isSaving){
			this.isSaving = true;
			var params = { interviewJSONString: JSON.stringify(this.getUpdatableInterview(cmp)) };
			this.enqueueAction(cmp, "saveInterview", params).then(this.partial(this.afterSaveInterview, cmp));
		}
	},
	submitInterview: function(cmp){
		var interview = this.getUpdatableInterview(cmp); 
		interview.completed = true;
		var params = { interviewJSONString: JSON.stringify(interview) };
		this.enqueueAction(cmp, "saveInterview", params).then(this.partial(this.afterSubmitInterview, cmp));
	},
	afterSaveInterview: function(cmp, data){
		this.each(data, (value, key) => {
			if(this.has(this.persona.interviewDimensions, key)){
				this.updateList(this.persona.interviewDimensions, key, value);
			} else if(this.has(this.persona.responses, key)){
				this.updateList(this.persona.responses, key, value);
			} else if(this.has(this.persona.notes, key)){
				this.updateList(this.persona.notes, key, value);
			}
		});
		this.updateAutoSaveWithSuccess(cmp);
		this.isSaving = false;
	},
	updateList: function(map, key, value){
		var item = map[key];
		item.id = value;
		item.action = null;
		map[value] = item;
		delete map[key];
	},
	afterSubmitInterview: function(cmp){
		this.showSuccessMessage(cmp, "Interview has been submitted.");
		this.resetPersona(cmp);
	},
	showSuccessMessage: function(cmp, message){
		cmp.set("v.message", { show: true, success: true, body: message });
		setTimeout(this.hideMessage.bind(this, cmp), 5000);
	},
	showErrorMessage: function(cmp, message){
		cmp.set("v.message", { show: true, success: false, body: message });
	},
	hideMessage: function(cmp){
		cmp.set("v.message", { show: false });
	},
	resetScreen: function(cmp){
		this.setScreen(cmp, "");
	},
	resetPersona: function(cmp){
		this.resetScreen(cmp);
		this.persona = { currentAssessmentId: cmp.get("v.assessment.id") };
		cmp.set("v.interview", null);
		cmp.set("v.assessment", null);
		this.unsaved = [];
		this.local = 0;
		this.initStreamAssesment(cmp);
	},
	initAutoSave: function(cmp){
		if(this.isAutoSaveEnabled(cmp) && !this.autoSavaIntevalId){
			this.updateAutoSave(cmp, 60)
			this.autoSavaIntevalId = setInterval(this.auraCallback(() => {
				if(this.isAutoSaveEnabled(cmp)){
					var time = cmp.get("v.autoSave.time");
					if(time) {
						this.updateAutoSave(cmp, time - 1);
					} else if(!this.isSaving) {
						this.saveInterview(cmp); 
					}
				} else if(this.autoSavaIntevalId){
					clearInterval(this.autoSavaIntevalId);
					this.autoSavaIntevalId = null;
				}
			}), 1000);
		}
	},
	isAutoSaveEnabled: function(cmp){
		return cmp.get("v.interview.options.enableAutoSave");
	},
	updateAutoSave: function(cmp, time, message){
		cmp.set("v.autoSave", { time: time, message: this.isUndefined(message) ? cmp.get("v.autoSave.message") : message });
	},
	updateAutoSaveWithSuccess: function(cmp){
		this.updateAutoSave(cmp, 10, "Your changes have been saved.");
		this.delay(this.partial(this.updateAutoSave, cmp, 60, null), 5000);
	},
	enqueueAction: function(cmp, method, params, storable){
        var defer = this.deferred(), action = cmp.get(method.includes(".") ? method : 'c.' + method); 
        if(this.isUndefinedOrNull(action)) defer.reject("No action found");
        defer.promise.then(null, this.partial(this.error, cmp,  "Server Error: " + method, this, params));
        action.setCallback(this, this.partial(this.parseServerResponse, this, defer.resolve, defer.reject));
        if(storable) action.setStorable(); action.setParams(params || {}); $A.enqueueAction(action); 
        return defer.promise;
    },
    parseServerResponse: function(response, resolve, reject){
        if (response.getState() === "SUCCESS") {
            resolve(this.parseJSON(response.getReturnValue()));
        } else if (response.getState() === "ERROR") {
            let errors = response.getError();
            let message = 'Unknown error'; 
            if (this.isArray(errors) && this.isNotEmpty(errors)) {
                message = errors[0].message;
            }
            reject(message);
        }
    }
})