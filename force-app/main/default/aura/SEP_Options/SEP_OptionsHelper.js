({
	updateOptions: function(cmp) {
		var interview = cmp.get("v.interview");
		var options = interview.options || {};
		if(options.enableFocusMode){
			options.enableDetailMode = true;
			options.showTooltips = false;
			options.showProgressBar = false;
			options.showExamples = false;
		}
		if(interview.completed){
			options.enableAutoSave = false;
		}
		options.showExamples = false;
		cmp.set("v.interview.options", options);
	},
	fireEvent: function(name, param){
		$A.get("e."+name).setParams(param).fire();
	}
})