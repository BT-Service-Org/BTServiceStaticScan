import { LightningElement, api } from 'lwc';

export default class SolutionFinderHistory extends LightningElement {
    @api history;
    @api hideTitle;

    get isHistoryEmpty() {
        let isEmpty = true;
        if (this.history) {
            isEmpty = (this.history.length === 0);
        }
        return isEmpty;
    }

    handleOptionClicked(event) {
        this.dispatchEvent(new CustomEvent("optionclicked", { detail: event.detail }));
    }
}