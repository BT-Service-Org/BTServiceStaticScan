({
	doInit: function(cmp, event, helper) {
		if(!helper.isNotApplicable(cmp)){
			cmp.set("v.answer", cmp.get("v.question.answers." + cmp.get("v.level")));
			cmp.set("v.globalAnswer", cmp.get("v.interview.globalAnswerSet.answers." + cmp.get("v.level")));
		} else {
			cmp.set("v.answer", { id: "NA", value: "" });
		}
	},
	selectAnswer: function(cmp, event, helper){
		event.preventDefault();

		var question = cmp.get("v.question");
		var answerId = cmp.get("v.answer.id");
		var position = cmp.get("v.position");

		if(!helper.isNotApplicable(cmp)){
			if(helper.isGoalMode(cmp)){
				if(!$A.util.isUndefinedOrNull(question.response.currentAnswerId)){
					if(question.response.currentAnswerId !== answerId) {
						if(question.currentAnswerPosition < position){
							helper.setGoalAnswer(cmp, question, answerId, position);
						} else if(question.currentAnswerPosition > position){
							helper.setCurrentAnswer(cmp, question, answerId, position);
						}
					} else {
						helper.clearCurrentAnswer(cmp, question);
						helper.clearGoalAnswer(cmp, question);
					}
				} else {
					helper.setCurrentAnswer(cmp, question, answerId, position);
					helper.clearGoalAnswer(cmp, question);
				}
			} else {
				helper.setCurrentAnswer(cmp, question, answerId, position);
				helper.clearGoalAnswer(cmp, question);
			}
		} else {
			helper.setCurrentAnswer(cmp, question, answerId, position);
			helper.clearGoalAnswer(cmp, question);
		}
		helper.fireEvent("c:MAPAnswerChange", { questionId: question.id });
	},
	showNotes: function(cmp, event, helper){
		event.stopPropagation();
		helper.fireEvent("c:MAPShowNotes", { type: "Response", parentId: cmp.get("v.question.response.id") });
	}
})