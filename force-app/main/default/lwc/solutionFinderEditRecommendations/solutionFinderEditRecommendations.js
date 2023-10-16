import { LightningElement, api, track } from 'lwc';
import getSolutions from '@salesforce/apex/SolutionFinderSolutions.getSolutions';
import { subscribe } from 'lightning/empApi';

export default class SolutionFinderEditRecommendations extends LightningElement {
    @api settings;
    @api optionName;
    @api currentQuestion;
    @api currentHelpText;
    @api previousSelectedOption;
    @track solutions;
    @track displayEditForm = false;
    @track editSolution = {};
    @track isLoading = false;

    connectedCallback() {
        this.initSolutions();
        this.subscribeToPlatformEvents();
    }

    initSolutions() {
        this.isLoading = true;
        getSolutions({ name: this.optionName })
            .then(data => {
                this.solutions = data;
                this.isLoading = false;
            })
            .catch(error => {
                console.log("ERROR: " + JSON.stringify(error));
                this.isLoading = false;
            })
    }

    platformEventCallback(response) {
        this.initSolutions();
        this.displayEditForm = false;
    }

    subscribeToPlatformEvents() {
        subscribe('/event/Solution_Finder_Event__e', -1, this.platformEventCallback.bind(this))
            .then(response => {
                // no action required
            })
            .catch(error => {
                console.log("Error subscribing to platform events: " + error);
            })
    }

    get previousSelection() {
        let previousSelection = "";
        if (this.previousSelectedOption != null) {
            previousSelection = this.previousSelectedOption.title;
        }
        return previousSelection;
    }

    get selectedSolutions() {
        let selected = [];
        if (this.solutions != null && this.solutions.solutions != null && this.solutions.solutions.selected != null) {
            selected = this.solutions.solutions.selected;
        }
        return selected;
    }    

    get recommendedSolutions() {
        let recommended = [];
        if (this.solutions != null && this.solutions.solutions != null && this.solutions.solutions.recommended != null) {
            recommended = this.solutions.solutions.recommended;
        }
        return recommended;
    }

    get otherSolutions() {
        let other = [];
        if (this.solutions != null && this.solutions.solutions != null && this.solutions.solutions.other != null) {
            other = this.solutions.solutions.other;
        }
        return other;
    }

    handleCancel() {
        this.editSolution = {};
        this.displayEditForm = false;
    }

    handleEdit(event) {
        this.editSolution = event.detail.solution;
        this.displayEditForm = true;
    }

    handleLoading(event) {
        this.isLoading = true;
    }
}