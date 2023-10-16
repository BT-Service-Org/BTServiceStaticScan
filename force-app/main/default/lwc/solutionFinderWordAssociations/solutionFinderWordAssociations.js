import { LightningElement, api } from 'lwc';

export default class SolutionFinderWordAssociations extends LightningElement {
    @api settings;
    @api optionName;
    @api buzzWords = [];
    @api noRecordsMessage;
    @api button;
    
    get buzzWordsExist() {
        return this.buzzWords.length > 0;
    }

    handleEdit(event) {
        this.dispatchEvent(new CustomEvent("edit", { detail: event.detail }));
    }

    handleLoading(event) {
        this.dispatchEvent(new CustomEvent("loading", { detail: event.detail }));
    }
}