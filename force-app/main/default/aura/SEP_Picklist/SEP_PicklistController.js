({
	doInit: function(cmp, event, helper){
		(cmp.get("v.items") || []).forEach((item) => { item.selected = false; });
	},
	onChange: function(cmp, event, helper) {
		helper.update(cmp, event.currentTarget.getAttribute("data-value"), false);
	},
	removeItem: function(cmp, event, helper){
		helper.update(cmp, event.currentTarget.getAttribute("data-value"), true);
	},
	showHidePanel: function(cmp, event, helper){
		cmp.set("v.show", !cmp.get("v.show"));
	},
	closePanel: function(cmp, event, helper){
		debugger;
	}
})