import { LightningElement, api } from 'lwc';

export default class SolutionFinderDetailField extends LightningElement {
    @api detail;
    @api property;
    @api value;

    get value() {
        let value = "";
        if (this.detail && this.property) {
            value = this.detail[this.property];
        }
        return value;
    }

    handleChange(event) {
        this.dispatchEvent(new CustomEvent("change", { detail: { index: this.detail.index, property: this.property, value: event.target.value }}));
    }
}