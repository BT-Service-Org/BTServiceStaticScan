({
	showCustomer: function(cmp, event, helper){
		helper.navigate(cmp, "Contact", event.currentTarget.getAttribute("data-recordId"));
	},
	showContact: function(cmp, event, helper){
		helper.navigate(cmp, "Contact", event.currentTarget.getAttribute("data-recordId"));
	},
	showAssessment: function(cmp, event, helper){
		helper.navigate(cmp, "MAPAssessment__c", event.currentTarget.getAttribute("data-recordId"));
	},
	showInterview: function(cmp, event, helper){
		helper.navigate(cmp, "MAPInterview__c", event.currentTarget.getAttribute("data-recordId"));
	},
	showAssessmentNotes: function(cmp, event, helper){
		helper.fireEvent("c:MAPShowNotes", { type: "Assessment", parentId: cmp.get("v.assessment.id") });
	},
	showInterviewNotes: function(cmp, event, helper){
		helper.fireEvent("c:MAPShowNotes", { type: "Interview", parentId: cmp.get("v.interview.id") });
	},
	showHideOptionsPanel: function(cmp, event, helper){
		cmp.set("v.showOptionsPanel", !cmp.get("v.showOptionsPanel"));
	},
	hideOptionsPanel: function(cmp, event, helper){
		cmp.set("v.showOptionsPanel", false);
	}
})