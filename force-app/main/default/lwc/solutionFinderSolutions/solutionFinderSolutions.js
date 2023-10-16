import { LightningElement, api } from 'lwc';

export default class SolutionFinderSolutions extends LightningElement {
    @api optionName;
    @api solutions = [];
    @api noRecordsMessage;
    @api button;
    
    get solutionsExist() {
        return this.solutions.length > 0;
    }

    handleEdit(event) {
        this.dispatchEvent(new CustomEvent("edit", { detail: event.detail }));
    }

    handleLoading(event) {
        this.dispatchEvent(new CustomEvent("loading", { detail: event.detail }));
    }
}