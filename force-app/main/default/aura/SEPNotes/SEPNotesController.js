({
	handleShowNotes: function(cmp, event, helper){
		cmp.set("v.type", event.getParam("type"));
		helper.clear(cmp, event.getParam("parentId"));
		helper.filterNotes(cmp);
		cmp.set("v.show", true);
	},
	addNote: function(cmp, event, helper){
		var note = cmp.get("v.note");
		var content = (note.content || "").trim();
		if(!$A.util.isEmpty(content)){
			helper.addNote(cmp, note);
			helper.clear(cmp, note.parentId);
		}
	},
	removeNote: function(cmp, event, helper){
		helper.removeNote(cmp, event.currentTarget.getAttribute("data-recordId"));
	},
	closeModal: function(cmp, event, helper){
		cmp.set("v.show", false);
	}
})