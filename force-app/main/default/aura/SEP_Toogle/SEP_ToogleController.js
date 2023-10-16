({
	doInit: function(cmp, event, helper) {
        let toogle = helper.getToogle(cmp);
		if(toogle) toogle.checked = cmp.get("v.value");
	},
	onChange: function(cmp, event, helper){
		cmp.set("v.value", helper.getToogle(cmp).checked);
		helper.fireOnChangeEvent(cmp);
	}
})