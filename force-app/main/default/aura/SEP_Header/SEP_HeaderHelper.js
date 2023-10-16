({
	navigate: function(cmp, objectName, recordId){
		window.open("/lightning/r/" + objectName + "/" + recordId + "/view", '_blank');
	},
	fireEvent: function(name, param){
		$A.get("e."+name).setParams(param).fire();
	}
})