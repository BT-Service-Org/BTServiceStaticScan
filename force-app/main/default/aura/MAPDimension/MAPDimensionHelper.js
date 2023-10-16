({
	getCurrentCapabilityId: function(cmp){
		var currentCapabilityId = cmp.get("v.interview.currentCapabilityId");
		return currentCapabilityId || this.getCapabilities(cmp)[0].id;
	},
	getCapabilities: function(cmp){
		return cmp.get("v.dimension.capabilities");
	},
	getCapability: function(cmp){
		return cmp.get("v.capability");
	},
	getCapabilityById: function(cmp, capabilityId){
		return this.getCapabilities(cmp).find((capability) => { return capability.id === capabilityId; })
	},
	setCapability: function(cmp, capabilityId){
		cmp.set("v.capability", this.getCapabilityById(cmp, capabilityId));
		this.setSubmitButtonVisibility(cmp);
	},
	setSubmitButtonVisibility: function(cmp){
        let visible = (!cmp.get("v.dimension.next") && !cmp.get("v.capability.next"));
        if(visible !== cmp.get("v.interview.showSubmitButton")){
         	cmp.set("v.interview.showSubmitButton", visible);   
        }
	},
	getPreviousCapability: function(cmp) {
		this.setCapability(cmp, this.getCapability(cmp).previous); 
	},
	getNextCapability: function(cmp) {
		this.setCapability(cmp, this.getCapability(cmp).next); 
	},
	getPreviousDimension: function(cmp) {
		$A.enqueueAction(cmp.get("v.onPrevious"));
	},
	getNextDimension: function(cmp) {
		$A.enqueueAction(cmp.get("v.onNext"));
	},
	getInterviewDimensionId: function(cmp){
		var dimensionId = cmp.get("v.dimension.id");
		var interviewDimensions = cmp.get("v.interview.interviewDimensions");
		var interviewDimension = interviewDimensions.find((item) => { return item.dimensionId === dimensionId; });
		return interviewDimension ? interviewDimension.id : null;
	},
	showHideTooltip: function(cmp, show){
		cmp.set("v.showTooltip", show);
		if(show) setTimeout(this.showHideTooltip.bind(this, cmp, false), 10000);
	},
	fireEvent: function(name, param){
		$A.get("e."+name).setParams(param).fire();
	},
	scrollIntoView: function(cmp, auraId){
		var view = cmp.find(auraId || "dimension");
		if(view) {
			view = view.getElement();
			if(view) {
				view = view.parentElement || view;
				view.scrollIntoView();
			}
		}
	},
	updateNotApplicable: function(cmp, key){
		key = "v."+key+".inapplicable";
		var inapplicable = cmp.get(key);
		cmp.set(key, !inapplicable);
		cmp.set(key, inapplicable);
	},
	updateProgress: function(cmp){
		var progress = cmp.find("progress");
		if(progress) progress.update();
	}
})