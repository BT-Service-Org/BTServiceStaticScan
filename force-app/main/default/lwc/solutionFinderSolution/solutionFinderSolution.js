import { LightningElement, api } from 'lwc';
import createRecommendation from '@salesforce/apex/SolutionFinderRecommendation.saveRecommendation';
import deleteRecommendation from '@salesforce/apex/SolutionFinderRecommendation.deleteRecommendation';

export default class SolutionFinderSolution extends LightningElement {
    @api optionName;
    @api solution;
    @api button;

    get showRecommend() {
        return this.button === "recommend";
    }

    get showRemove() {
        return this.button === "remove";
    }

    handleEditClicked(event) {
        this.dispatchEvent(new CustomEvent("edit", { detail: { solution: this.solution }}));
    }

    handleRecommend() {
        this.broadcastLoading();
        createRecommendation({ 'optionName': this.optionName, 'solutionName': this.solution.name })
            .then(data => {
                // no action required
            })
            .catch(error => {
                console.log("Error creating recommendation: " + JSON.stringify(error));
            })
    }

    handleRemove() {
        this.broadcastLoading();
        deleteRecommendation({ 'name': this.solution.recommendationName })
            .then(data => {
                // no action required
            })
            .catch(error => {
                console.log("Error deleting recommendation: " + JSON.stringify(error));
            })
    }

    broadcastLoading() {
        this.dispatchEvent(new CustomEvent("loading"));
    }
}