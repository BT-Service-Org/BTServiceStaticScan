({
	checkParentStatus: function(cmp, question){
		if(question.parent){
			var firstAnswerId = this.getFirstAnswerId(cmp.get("v.domain.levels"), question.parent.answers);
			var parentAnswerId = question.parent.response.currentAnswerId;
			if(!(parentAnswerId && firstAnswerId && parentAnswerId !== firstAnswerId && parentAnswerId !== "NA")){
				question.currentAnswerId = null;
				question.currentAnswerPosition = null;
				question.hidden = true;
			} else {
				question.hidden = false;
			}
		} else {
			question.hidden = false;
		}
		cmp.set("v.question", question);
	},
	getFirstAnswerId: function(levels, answers){
		var answer = answers[levels[0]];
		return answer ? answer.id : null;
	}
})