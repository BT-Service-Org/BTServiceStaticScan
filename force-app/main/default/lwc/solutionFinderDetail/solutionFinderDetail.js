import { LightningElement, api } from 'lwc';

export default class SolutionFinderDetail extends LightningElement {
    @api detail = {};
    @api columns = [];

    handleChange(event) {
        this.dispatchEvent(new CustomEvent("change", { detail: event.detail }));
    }

    handleDeleteClick() {
        this.dispatchEvent(new CustomEvent("delete", { detail: this.detail.index }));
    }
}