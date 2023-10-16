({
	doInit: function(cmp, event, helper){
		var question = cmp.get("v.question");
		if(question.response.currentAnswerId || question.response.goalAnswerId){
			var levels = cmp.get("v.domain.levels");
			levels.forEach((level, ind) => {
				var answer = question.answers[level];
				if(answer){
					if(question.response.currentAnswerId === answer.id){
						question.currentAnswerPosition = ind;
					} else if(question.response.goalAnswerId === answer.id){
						question.goalAnswerPosition = ind;
					}
				}
			});
			cmp.set("v.question", question);
		}
		helper.checkParentStatus(cmp, question);
		cmp.set("v.initDone", true);
	},
	onAnswerChange: function(cmp, event, helper){
		var question = cmp.get("v.question");
		helper.checkParentStatus(cmp, question);
	}
})