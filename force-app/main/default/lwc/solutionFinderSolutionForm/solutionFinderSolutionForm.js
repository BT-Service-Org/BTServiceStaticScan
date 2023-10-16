import { LightningElement, api } from 'lwc';
import saveSolution from '@salesforce/apex/SolutionFinderSolution.saveSolution';

export default class SolutionFinderSolutionForm extends LightningElement {
    @api settings;
    @api optionName;
    @api name;
    @api label;
    @api description;
    @api exportNote;
    @api considerations;
    @api limitations;
    @api stories;
    @api properties;
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

    handleLabelChange(event) {
        this.label = event.target.value;
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleExportNoteChange(event) {
        this.exportNote = event.target.value;
    }

    handleConsiderationsChange(event) {
        this.considerations = event.target.value;
    }

    handleLimitationsChange(event) {
        this.limitations = event.target.value;
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    handleSave() {
        let considerationsForm = this.template.querySelector('c-solution-finder-details[data-id="considerations"]');
        if (considerationsForm) this.considerations = considerationsForm.getDetails();

        let limitationsForm = this.template.querySelector('c-solution-finder-details[data-id="limitations"]');
        if (limitationsForm) this.limitations = limitationsForm.getDetails();

        let storiesForm = this.template.querySelector('c-solution-finder-details[data-id="stories"]');
        if (storiesForm) this.stories = storiesForm.getDetails();

        let propertiesForm = this.template.querySelector('c-solution-finder-properties[data-id="properties"]');
        if (propertiesForm) this.properties = propertiesForm.getProperties();

        saveSolution({ namespace: this.settings.namespace, name: this.name, label: this.label, description: this.description, exportNote: this.exportNote, considerations: JSON.stringify(this.considerations), limitations: JSON.stringify(this.limitations), stories: JSON.stringify(this.stories), optionName: this.optionName })
            .then(data => {
                this.clearInput();
                this.waitForSave(data);
            })
            .catch(error => {
                console.log('Error saving solution: ' + JSON.stringify(error));
            })
    }

    waitForSave(jobId) {
        this.dispatchEvent(new CustomEvent("loading"));
    }

    clearInput() {
        let firstInput = this.template.querySelector('lightning-input');
        if (firstInput) {
            firstInput.value = "";
            firstInput.focus();
        }
    }
}