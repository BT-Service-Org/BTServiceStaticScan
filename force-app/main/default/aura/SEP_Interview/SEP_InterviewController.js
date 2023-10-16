({
	doInit: function(cmp, event, helper) {
		helper.setDimension2(cmp, helper.getCurrentDimension(cmp));
	},
	getPreviousDimension: function(cmp, event, helper) {
		helper.getPreviousDimension(cmp);
	},
	getNextDimension: function(cmp, event, helper) {
		helper.getNextDimension(cmp);
	},
	getDimension: function(cmp, event, helper){
		helper.setDimension(cmp, event.currentTarget.getAttribute("data-selectedItemId"), true);
	},
	showQuestion: function(cmp, event, helper){
		helper.showQuestion(cmp, event.currentTarget.getAttribute("data-dimensionId"), event.currentTarget.getAttribute("data-capabilityId"));
	},
	cancelInterview: function(cmp, event, helper){
		helper.showConfirmModal(cmp, "Cancel");
	},
	saveInterview: function(cmp, event, helper){
		helper.showConfirmModal(cmp, "Save");
	},
	submitInterview: function(cmp, event, helper){
		helper.showConfirmModal(cmp, "Submit");
	},
	closeInterview: function(cmp, event, helper){
		helper.performAction(cmp, "Cancel");
	},
	closeModal: function(cmp, event, helper){
		helper.setConfirmModal(cmp, null);
	},
	closeModalAndConfirm: function(cmp, event, helper){
		helper.performAction(cmp, cmp.get("v.confirmModal").type);
		helper.setConfirmModal(cmp, null);
	}
})