import { LightningElement, api } from 'lwc';

export default class SolutionFinderEditComparisonValue extends LightningElement {
    @api propertyName;
    @api solutionName;
    @api propertyDataType;
    @api mapOfValues;

    get value() {
        var value = "";
        if (this.propertyName && this.solutionName) {
            var key = this.solutionName + '.' + this.propertyName;
            value = this.mapOfValues[key];
        }
        return value;
    }

    get isText() {
        return this.propertyDataType && this.propertyDataType === "Text";
    }

    get isNumber() {
        return this.propertyDataType && this.propertyDataType === "Number";
    }

    get isBoolean() {
        return this.propertyDataType && this.propertyDataType === "Boolean";
    }

    get textValue() {
        if (this.value === true) {
            return "true";
        } else if (this.value === false) {
            return "false";
        } else {
            return "REMOVED";
        }
    }

    get booleanOptions() {
        return [
            { label: "", value: "REMOVED" },
            { label: "True", value: "true" },
            { label: "False", value: "false" }
        ];
    }

    handleBooleanValueChange(event) {
        this.commitChange(event.detail.value);
    }

    handleValueChange(event) {
        this.commitChange(event.target.value);
    }

    commitChange(value) {
        this.dispatchEvent(new CustomEvent("valuechanged", { detail: { propertyName: this.propertyName, solutionName: this.solutionName, propertyDataType: this.propertyDataType, value: value }}));
    }
}