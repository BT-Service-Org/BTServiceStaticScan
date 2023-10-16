({
	update: function(cmp, value, remove) {
		var items = (cmp.get("v.items") || []);
		var selection = items.reduce((selection, item) => {
			if(item.value === value) item.selected = remove ? false : !item.selected; 
			if(item.selected) selection.push(item.value); 
			return selection;
		}, []);
		cmp.set("v.items", items);
		cmp.set("v.selection", selection);
	}
})