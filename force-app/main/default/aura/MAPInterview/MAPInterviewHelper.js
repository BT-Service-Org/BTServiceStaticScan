({
	getCurrentDimension: function(cmp){
		var currentDimensionId = cmp.get("v.interview.currentDimensionId");
		return currentDimensionId ? this.getDimensionById(cmp, currentDimensionId) : this.getDimensions(cmp)[0];
	},
	getDimensions: function(cmp){
		return cmp.get("v.domain.dimensions");
	},
	getDimension: function(cmp){
		return cmp.get("v.dimension");
	},
	getDimensionById: function(cmp, dimensionId){
		return this.getDimensions(cmp).find((dimension) => { 
			return dimension.id === dimensionId; 
		}); 
	},
	getPreviousDimension: function(cmp) {
		this.setDimension(cmp, this.getDimension(cmp).previous, false); 
	},
	getNextDimension: function(cmp) {
		this.setDimension(cmp, this.getDimension(cmp).next, true);
	},
	setDimension: function(cmp, dimensionId, next){
		var dimension = this.getDimensionById(cmp, dimensionId);
		var capability = dimension.capabilities[next ? 0 : dimension.capabilities.length - 1];
		this.setCurrentIds(cmp, dimension.id, capability.id);
		this.setDimension2(cmp, dimension);
	},
	setDimension2: function(cmp, dimension){
		this.updateStatus(cmp);
		cmp.set("v.dimension", dimension);
		dimension = cmp.find("dimension");
		if(dimension) dimension.handleDimensionChange();
	},
	updateStatus: function(cmp){
		this.getDimensions(cmp).forEach((dimension) => {
			dimension.updateStatus(); 
		});
	},
	setCurrentIds: function(cmp, dimensionId, capabilityId){
		var interview = cmp.get("v.interview");
		interview.currentDimensionId = dimensionId;
		interview.currentCapabilityId = capabilityId;
		cmp.set("v.interview", interview);
	},
	showQuestion: function(cmp, dimensionId, capabilityId){
		var interview = cmp.get("v.interview");
		interview.currentDimensionId = dimensionId;
		interview.currentCapabilityId = capabilityId;
		this.setDimension2(cmp, this.getCurrentDimension(cmp));
	},
	performAction: function(cmp, type){
		var action = cmp.get("v.on" + type);
		if(action) $A.enqueueAction(action);
	},
	showConfirmModal: function(cmp, type){
		this.setConfirmModal(cmp, { show: true, type: type });
	},
	setConfirmModal: function(cmp, data){
		cmp.set("v.confirmModal", data);
	}
})