import { LightningElement, api } from 'lwc';

export default class SolutionFinderHistoryOption extends LightningElement {
    @api option;

    handleMouseOverDelete() {
        let button = this.template.querySelector('lightning-button-icon');
        button.variant = "error";
    }

    handleDelete() {
        this.dispatchEvent(new CustomEvent("clicked", { detail: { option: this.option }}));
    }
}