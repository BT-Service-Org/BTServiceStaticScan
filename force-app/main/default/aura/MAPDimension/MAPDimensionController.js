({
	doInit: function(cmp, event, helper) {
		helper.setCapability(cmp, helper.getCurrentCapabilityId(cmp));
		helper.showHideTooltip(cmp, !cmp.get("v.interview.completed"));
	},
	getPreviousCapability: function(cmp, event, helper) {
		helper.getPreviousCapability(cmp);
		helper.scrollIntoView(cmp);
	},
	getNextCapability: function(cmp, event, helper) {
		helper.getNextCapability(cmp);
		helper.scrollIntoView(cmp);
	},
	getPreviousDimension: function(cmp, event, helper) {
		helper.getPreviousDimension(cmp);
		helper.scrollIntoView(cmp);
	},
	getNextDimension: function(cmp, event, helper) {
		helper.getNextDimension(cmp);
		helper.scrollIntoView(cmp);
	},
	showHideTooltip: function(cmp, event, helper){
		helper.showHideTooltip(cmp, !cmp.get("v.showTooltip"));
	},
	hideTooltip: function(cmp, event, helper){
		helper.showHideTooltip(cmp, false);
	},
	handleDimensionChange: function(cmp, event, helper){
		helper.setCapability(cmp, helper.getCurrentCapabilityId(cmp));
		helper.scrollIntoView(cmp);
	},
	handleModeChange: function(cmp, event, helper){
		helper.showHideTooltip(cmp, cmp.get("v.interview.options.showTooltips"));
		helper.scrollIntoView(cmp);
	},
	handleAnswerChange: function(cmp, event, helper){
		helper.updateNotApplicable(cmp, "capability");
		helper.updateNotApplicable(cmp, "dimension");
		helper.updateProgress(cmp);
	},
	showNotes: function(cmp, event, helper){
		helper.fireEvent("c:MAPShowNotes", { type: "Dimension", parentId: helper.getInterviewDimensionId(cmp) });
	},
	skipDimension: function(cmp, event, helper){
		var dimension = cmp.get("v.dimension");
		dimension.inapplicable = true;
		dimension.updateNAStatus();
		helper.updateNotApplicable(cmp, "dimension");
		helper.updateProgress(cmp);
		if(dimension.next) helper.getNextDimension(cmp); 
	},
	skipCapability: function(cmp, event, helper){
		var dimension = cmp.get("v.dimension");
		var capability = cmp.get("v.capability");
		capability.inapplicable = true;
		capability.updateNAStatus();
		helper.updateNotApplicable(cmp, "capability");
		helper.updateProgress(cmp);
		if(capability.next) helper.getNextCapability(cmp); 
		else if(dimension.next) helper.getNextDimension(cmp); 
	}
})