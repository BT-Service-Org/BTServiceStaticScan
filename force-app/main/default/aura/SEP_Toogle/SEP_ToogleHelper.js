({
	getToogle: function(cmp) {
		return cmp.find("toogle").getElement();
	},
	fireOnChangeEvent: function(cmp){
		var onChange = cmp.get("v.onChange");
		if(onChange) $A.enqueueAction(onChange);
	}
})