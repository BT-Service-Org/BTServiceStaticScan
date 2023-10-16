import { LightningElement, api } from 'lwc';

export default class SolutionFinderProbabilityBadge extends LightningElement {
    @api probability;

    get classes() {
        let classes = "badge";
        if (this.probability) {
            classes += " " + this.probability.toLowerCase();
        }
        return classes;
    }
}