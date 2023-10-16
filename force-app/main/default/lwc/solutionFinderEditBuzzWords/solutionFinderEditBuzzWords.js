import { LightningElement, api, track } from 'lwc';
import getBuzzWords from '@salesforce/apex/SolutionFinderBuzzWords.getBuzzWords';
import { subscribe } from 'lightning/empApi';

export default class SolutionFinderEditBuzzWords extends LightningElement {
    @api settings;
    @api optionName;
    @api currentQuestion;
    @api currentHelpText;
    @api previousSelectedOption;
    @track buzzWords;
    @track displayEditForm = false;
    @track editBuzzWord = {};
    @track isLoading = false;

    connectedCallback() {
        this.initBuzzWords();
        this.subscribeToPlatformEvents();
    }

    initBuzzWords() {
        this.isLoading = true;
        getBuzzWords({ name: this.optionName })
            .then(data => {
                this.buzzWords = data;
                this.isLoading = false;
            })
            .catch(error => {
                console.log("ERROR: " + JSON.stringify(error));
                this.isLoading = false;
            })
    }

    platformEventCallback(response) {
        this.initBuzzWords();
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

    get selectedBuzzWords() {
        let selected = [];
        if (this.buzzWords != null && this.buzzWords.buzzWords != null && this.buzzWords.buzzWords.selected != null) {
            selected = this.buzzWords.buzzWords.selected;
        }
        return selected;
    }    

    get recommendedBuzzWords() {
        let recommended = [];
        if (this.buzzWords != null && this.buzzWords.buzzWords != null && this.buzzWords.buzzWords.recommended != null) {
            recommended = this.buzzWords.buzzWords.recommended;
        }
        return recommended;
    }

    get otherBuzzWords() {
        let other = [];
        if (this.buzzWords != null && this.buzzWords.buzzWords != null && this.buzzWords.buzzWords.other != null) {
            other = this.buzzWords.buzzWords.other;
        }
        return other;
    }

    handleCancel(event) {
        this.editBuzzWord = {};
        this.displayEditForm = false;
    }

    handleEdit(event) {
        this.editBuzzWord = event.detail.buzzWord;
        this.displayEditForm = true;
    }

    handleLoading(event) {
        this.isLoading = true;
    }
}