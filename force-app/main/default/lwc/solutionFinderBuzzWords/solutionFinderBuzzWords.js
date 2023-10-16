import { LightningElement, api } from 'lwc';

export default class SolutionFinderBuzzWords extends LightningElement {
    @api buzzWords;
    @api hideTitle;
    @api showEditBuzzWordsButton;

    get noBuzzWords() {
        return (this.buzzWords == null || this.buzzWords.length === 0);
    }

    handleEditClick() {
        this.dispatchEvent(new CustomEvent("editbuzzwords"));
    }

    handleBuzzWordClicked(event) {
        this.dispatchEvent(new CustomEvent("buzzwordclicked", { detail: event.detail }));
    }
}