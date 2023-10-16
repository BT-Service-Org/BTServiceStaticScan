({
	onChange: function(cmp, event, helper) {
		helper.updateOptions(cmp);
		helper.fireEvent("c:SEP_OptionChange", {});
	},
	onModeChange: function(cmp, event, helper) {
		helper.updateOptions(cmp);
		helper.fireEvent("c:SEP_OptionChange", {});
		helper.fireEvent("c:SEP_ModeChange", {});
	}
})