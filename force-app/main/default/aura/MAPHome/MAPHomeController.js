({
	doInit: function(cmp, event, helper){
		helper.initPersona(cmp);
	},
	handleViewAssessment: function(cmp, event, helper){
		helper.setAssessment(cmp, event.currentTarget.getAttribute("data-assessmentId"));
	},
	handleCreateAssessment: function(cmp, event, helper) {
		cmp.set("v.summary", ""); 
		helper.setScreen(cmp, "MAPCreateAssessment");
	},
	saveAssessment: function(cmp, event, helper) {
		var summary = cmp.get("v.summary"); 
		if(helper.isEmpty(summary)) return;
		helper.resetScreen(cmp); 
		helper.createAssessment(cmp, summary);
	},
	cancelAssessment: function(cmp, event, helper){
		helper.setScreen(cmp, "MAPPersona");
	},
	handleViewInterview: function(cmp, event, helper){
		helper.setInterview(cmp, event.currentTarget.getAttribute("data-interviewId"));
	},
	handleCreateInterview: function(cmp, event, helper) {
		helper.resetScreen(cmp); 
		helper.createInterview(cmp);
	},
	handleCancelInterview: function(cmp, event, helper){
		helper.cancelInterview(cmp);
	},
	handleSaveInterview: function(cmp, event, helper){ 
		helper.saveInterview(cmp);
	},
	handleSubmitInterview: function(cmp, event, helper){
		helper.resetScreen(cmp); 
		helper.submitInterview(cmp);
	},
	handleOptionChange: function(cmp, event, helper){
		cmp.set("v.interview.options", cmp.get("v.interview.options"));
		helper.initAutoSave(cmp);
	},
	showAssessments: function(cmp, event, helper){
		cmp.set("v.assessment", null);
		helper.setScreen(cmp, "MAPPersona");
	},
	closeMessage: function(cmp, event, helper){
		helper.hideMessage(cmp);
	}
})