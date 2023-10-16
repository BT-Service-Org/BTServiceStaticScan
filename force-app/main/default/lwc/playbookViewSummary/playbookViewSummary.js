import { LightningElement, api, track } from "lwc";

export default class PlaybookViewSummary extends LightningElement {
    expandedStages = [];
    @track stageArray = [];

    @api get stageObj() {
        return this.stageArray;
    }

    set stageObj(stages) {
        if (stages) {
            let array = JSON.parse(JSON.stringify(stages));

            array.forEach((eachStage, index) => {
                eachStage.keyName = "stages" + index;
                this.expandedStages.push(eachStage.keyName);
                eachStage.StageTitle = "Stage: " + eachStage.StageTitle;

                eachStage.expandedOutcomes = [];
                if(eachStage.outcomeVsStageMethodOutcomeIds)
                {
                    eachStage.outcomeVsStageMethodOutcomeIds.forEach((eachOutcome, index) => {
                        eachOutcome.keyName = "outcome" + index;
                        eachOutcome.outcomeName = "Outcome Order: "+eachOutcome.outcomeOrder+"   Outcome: "+ eachOutcome.outcomeName;
    
                        eachStage.expandedOutcomes.push(eachOutcome.keyName);
    
                        eachOutcome.expandedMethods = [];
                        if(eachOutcome.stageMethodOutcomes)
                        {
                            eachOutcome.stageMethodOutcomes.forEach((eachMethod, index) => {
                                eachMethod.keyName = "method" + index;
                                eachMethod.methodName = "Method: " + eachMethod.methodName;
                                eachMethod.methodOutcomeName = "Outcome: " + eachMethod.outcomeName;
                                eachOutcome.expandedMethods.push(eachMethod.keyName);
                            });
                        }
                    });
                }
            });

            this.stageArray = array;
        }
    }

    handleCloseAddOutcomes() {
        this.dispatchEvent(
            new CustomEvent("closebuttonclicked", {
                detail: {
                    message: "close view sumary"
                }
            })
        );
    }
}