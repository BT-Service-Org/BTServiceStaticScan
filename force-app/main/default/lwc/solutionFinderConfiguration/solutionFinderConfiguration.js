import { LightningElement, api } from 'lwc';

export default class SolutionFinderConfiguration extends LightningElement {
    @api index;
    @api configurationId;
    @api property;
    @api default;

    get defaultValue() {
        return this.default ? this.default : null;
    }

    get isChecked() {
        try {
            return this.defaultValue === true;
        } catch (e) {
            return false;
        }
    }

    handleKeyUp(event) {
        console.log("key up: " + event.target.value);
        this.dispatchValue(event.target.value);
    }

    handleCheck(event) {
        this.dispatchValue(event.target.checked);
    }

    handleChange(event) {
        this.dispatchValue(event.target.value);
    }

    dispatchValue(value) {
        console.log("dispatching value");
        this.dispatchEvent(new CustomEvent("change", { detail: { index: this.index, configurationId: this.configurationId, property: this.property, value: value }}));
    }
}