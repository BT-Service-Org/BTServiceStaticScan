({
	getQuestions: function(cmp) {
		var questions = [];
		var counter = { answered: 0, answeredWithGoal: 0, skipped: 0, notAnswered: 0 };
		var dimensions = cmp.get("v.domain.dimensions");
		var dindex = 0, dimension = dimensions[dindex];
		while(dimension){
			var cindex = 0
			var capability = dimension.capabilities[cindex];
			while(capability){
				var qindex = 0
				var question = capability.questions[qindex];
				while(question){
					questions.push(question);
					if(question.response.skip){
						counter.skipped++;
					} else if(question.response.currentAnswerId){
						if(question.response.goalAnswerId){
							counter.answeredWithGoal++;
						} else {
							counter.answered++
						}
					} else {
						counter.notAnswered++;
					}
					question = capability.questions[++qindex];
				}
				capability = dimension.capabilities[++cindex];
			}
			dimension = dimensions[++dindex];
		}
		cmp.set("v.questions", questions);
		cmp.set("v.counter", counter);
	}
})