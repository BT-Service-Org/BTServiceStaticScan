({
	initSEP_Base : function(cmp, event, helper) {
		//Extracts the value of a wrapped object
		if(!helper.wrapper.prototype.value){
			helper.wrapper.prototype.value = function(){ 
				return this._wrapped; 
			};
		}
	}
})