({
	onChange: function(cmp, event, helper) {
		helper.updateOptions(cmp);
		helper.fireEvent("c:MAPOptionChange", {});
	},
	onModeChange: function(cmp, event, helper) {
		helper.updateOptions(cmp);
		helper.fireEvent("c:MAPOptionChange", {});
		helper.fireEvent("c:MAPModeChange", {});
	}
})