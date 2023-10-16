import { LightningElement, api } from 'lwc';

export default class SepAssessmentCompletionProgress extends LightningElement {
    @api totalaverage = 0;
    @api totalq = 0;
    @api answeredq = 0;
    @api isAssessment = false;
    size = 'large';

    get percentage() {
        if(this.isAssessment == 'true'){
            return this.replaceNan(this.totalaverage);
        } else {
            const avgValue = Math.round((this.answeredq / this.totalq) * 100)
            return this.replaceNan(avgValue);
        }
    }

   @api updateProgress(answeredQ, totalQ) {
        this.answeredq = answeredQ;
        this.totalq = totalQ;
      }

    replaceNan(v) {
        return isNaN(v) ? 0 : v;
    }

    get shouldDisplayPercentage() {
        return this.percentage !== 100;
    }
}