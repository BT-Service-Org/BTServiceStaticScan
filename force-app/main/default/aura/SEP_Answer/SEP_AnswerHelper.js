({
	setCurrentAnswer: function(cmp, question, answerId, position) {
		question.currentAnswerPosition = position;
		question.response.currentAnswerId = answerId;
		question.response.skip = (answerId === "NA");
		question.updateNAStatus();
	},
	setGoalAnswer: function(cmp, question, answerId, position) {
		question.goalAnswerPosition = position;
		question.response.goalAnswerId = answerId;
		if($A.util.isEmpty(question.response.goalDate)) {
			question.response.goalDate = cmp.get("v.interview.options.defaultGoalDate");
		}
	},
	clearCurrentAnswer: function(cmp, question){
		this.setCurrentAnswer(cmp, question, null, null);
	},
	clearGoalAnswer: function(cmp, question){
		this.setGoalAnswer(cmp, question, null, null);
	},
	isGoalMode: function(cmp){
		return cmp.get("v.interview.options.enableGoalMode")
	},
	isNotApplicable: function(cmp){
		return $A.util.isEmpty(cmp.get("v.level"));
	},
	fireEvent: function(name, param){
		$A.get("e."+name).setParams(param).fire();
	}
})