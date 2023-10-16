import { LightningElement, api } from 'lwc';
import saveBuzzWord from '@salesforce/apex/SolutionFinderBuzzWord.saveBuzzWord';

export default class SolutionFinderBuzzWordForm extends LightningElement {
    @api settings;
    @api optionName;
    @api name;
    @api label;
    @api definition;
    @api url;
    @api probability;
    @api details;
    isLoaded = false;

    renderedCallback() {
        if (!this.isLoaded) {
            let firstInput = this.template.querySelector('lightning-input');
            if (firstInput) {
                firstInput.focus();
            }
            this.isLoaded = true;
        }
    }

    get probabilityOptions() {
        return [
            { label: "- None -", value: "" },
            { label: "Never", value: "Never" },
            { label: "Low", value: "Low" },
            { label: "Low-Medium", value: "Low-Medium" },
            { label: "Medium", value: "Medium" },
            { label: "Medium-High", value: "Medium-High" },
            { label: "High", value: "High" },
            { label: "Always", value: "Always" }
        ]
    }

    handleLabelChange(event) {
        this.label = event.target.value;
    }

    handleDefinitionChange(event) {
        this.definition = event.target.value;
    }

    handleUrlChange(event) {
        this.url = event.target.value;
    }

    handleProbabilityChange(event) {
        this.probability = event.target.value;
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    handleSave() {
        let detailsForm = this.template.querySelector('c-solution-finder-details');
        let details = detailsForm.getDetails();
        saveBuzzWord({ namespace: this.settings.namespace, name: this.name, label: this.label, definition: this.definition, url: this.url, probability: this.probability, optionName: this.optionName, details: JSON.stringify(details) })
            .then(data => {
                this.clearInput();
                this.waitForSave(data);
            })
            .catch(error => {
                console.log('Error saving buzz word: ' + JSON.stringify(error));
            })
    }

    waitForSave(jobId) {
        this.dispatchEvent(new CustomEvent("loading"));
    }

    clearInput() {
        let inputs = this.template.querySelectorAll('lightning-input, lightning-textarea');
        if (inputs) {
            for (let i = 0; i < inputs.length; i++) {
                inputs[i].value = "";
            }
        }
    }
}