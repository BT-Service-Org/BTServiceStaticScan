({
	doInit: function(cmp, event, helper){
		var selectedItemId = cmp.get("v.selectedItemId");
		var list = cmp.get("v.data") || [], selectedItem;
		for(var i = 0, len = list.length; i < len; i++){
			var item = list[i]; 
			item._previous = item._next = null; item._inapplicable = item._partial = item._completed = false;
			if(item.id === selectedItemId) selectedItem = item;
			if(i > 0) item._previous = list[i-1];  
			if(i + 1 < len) item._next = list[i+1]; 
		}
		var batch = [], pitem = selectedItem;
		while(pitem._previous && batch.length < 5){
			pitem._previous._inapplicable = pitem._previous.inapplicable;
			pitem._previous._partial = !pitem._previous.completed;
			pitem._previous._completed = pitem._previous.completed;
			batch = [pitem._previous].concat(batch); pitem = pitem._previous;
		}
		batch.push(selectedItem);
		var nitem = selectedItem;
		while(nitem._next && batch.length <= 5){
			batch.push(nitem._next); nitem = nitem._next;
		}
		cmp.set("v.batch", { _previous: pitem._previous, _next: nitem._next, list: batch });
	},
	previousBatch: function(cmp, event, helper){
		var _previous = cmp.get("v.batch._previous");
		var newbatch = [], item = _previous;
		while(item._previous && newbatch.length < 5){
			item._previous._inapplicable = item._previous.inapplicable;
			item._previous._partial = !item._previous.completed;
			item._previous._completed = item._previous.completed;
			newbatch = [item._previous].concat(newbatch); item = item._previous;
		}
		_previous._inapplicable = _previous.inapplicable;
		_previous._partial = !_previous.completed;
		_previous._completed = _previous.completed;
		newbatch.push(_previous)
		cmp.set("v.batch", { _previous: item._previous, _next: _previous._next, list: newbatch });
	},
	nextBatch: function(cmp, event, helper){
		var _next = cmp.get("v.batch._next");
		var newbatch = [_next], item = _next;
		while(item._next && newbatch.length <= 5){
			newbatch.push(item._next); item = item._next;
		}
		cmp.set("v.batch", { _previous: _next._previous, _next: item._next, list: newbatch });
	}
})