import { LightningElement, api, track } from 'lwc';
import saveActivity from '@salesforce/apex/SolutionFinderActivity.saveActivity';

const ACTIVITY_COMPARISON_VIEWED = 'Comparison Viewed';

export default class SolutionFinderRecommendations extends LightningElement {
    @api project;
    @api selectedOption;
    @api recommendations;
    @api hideTitle;
    @api showEditRecommendationsButton;

    get noRecommendations() {
        return (this.recommendations == null || this.recommendations.length === 0);
    }

    get showCompare() {
        return this.recommendations && this.recommendations.length > 1;
    }

    get compareUrl() {
        return "/apex/SolutionFinderCompare?namespace=" + this.selectedOption.namespace + "&name=" + this.selectedOption.name;
    }

    handleCompareClick() {
        this.recordComparisonViewedActivity(this.selectedOption.name);
    }

    handleEditClick() {
        this.dispatchEvent(new CustomEvent("editrecommendations"));
    }

    handleSave(event) {
        this.dispatchEvent(new CustomEvent("save", { detail: event.detail }));
    }

    recordComparisonViewedActivity(optionName) {
        saveActivity({ recordTypeName: ACTIVITY_COMPARISON_VIEWED, optionName: optionName })
            .then(results => {
                // no action required
            })
            .catch(error => {
                console.log("Error saving activity: " + e);
            })
    }
}