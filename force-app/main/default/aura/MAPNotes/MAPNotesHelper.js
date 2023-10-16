({
	local: 0,

	getLocalId: function(){ return "local_Note_" + this.local++; },
	isLocalId: function(id){ return id.startsWith('local_'); },
	getNotes: function(cmp){ return cmp.get("v.notes") || []; },
	setNotes: function(cmp, notes){ return cmp.set("v.filteredNotes", notes); },
	getParentId: function(cmp) { return cmp.get("v.note.parentId"); },

	getNewNote: function(cmp, parentId){
		return { id: this.getLocalId(), parentId: parentId, action: "Insert", types: [] };
	},
	addNote: function(cmp, note){
		var notes = this.getNotes(cmp);
		note.type = note.types.join(";");
		notes.push(note);
		cmp.set("v.notes", notes);
		this.filterNotes(cmp);
	},
	removeNote: function(cmp, noteId){
		var notes = this.getNotes(cmp);
		var ind = notes.findIndex((note) => {
			return note.id === noteId;
		});	
		if(ind >= 0){
			var note = notes[ind];
			if(this.isLocalId(note.id)){
				notes.splice(ind, 1);
			} else {
				note.action = "Delete";
			}
		}
		this.filterNotes(cmp);
	},
	filterNotes: function(cmp){
		var notes = this.getNotes(cmp);
		var parentId = this.getParentId(cmp);
		var filteredNotes = notes.filter((note) => {
			note.types = (note.type || "").split(";");
			return note.parentId === parentId && note.action !== "Delete";
		});
		this.setNotes(cmp, filteredNotes);
	},
	clear: function(cmp, parentId){
		cmp.set("v.note", this.getNewNote(cmp, parentId));
	}
})