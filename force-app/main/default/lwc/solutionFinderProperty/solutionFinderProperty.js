import { LightningElement, api, track } from 'lwc';

export default class SolutionFinderProperty extends LightningElement {
    @api property;
    @track updatedProperty;

    connectedCallback() {
        if (this.property) {
            this.updatedProperty = JSON.parse(JSON.stringify(this.property));
        }
    }

    get dataTypeOptions() {
        return [
            { label: "Checkbox", value: "Checkbox" },
            { label: "Color", value: "Color" },
            { label: "Date", value: "Date" },
            { label: "Date/Time", value: "Date/Time" },
            { label: "Email", value: "Email" },
            { label: "Number", value: "Number" },
            { label: "Password", value: "Password" },
            { label: "Telephone", value: "Telephone" },
            { label: "Text", value: "Text" },
            { label: "Textarea", value: "Textarea" },
            { label: "Time", value: "Time" },
            { label: "Toggle", value: "Toggle" },
            { label: "URL", value: "URL" }
        ];
    }

    handleDataTypeChange(event) {
        this.updatedProperty.dataType = event.detail.value;
        this.dispatchChanges();
    }

    handleLabelKeyUp(event) {
        this.updatedProperty.label = event.target.value;
        this.dispatchChanges();
    }

    handleDefaultValueKeyUp(event) {
        this.updatedProperty.defaultValue = event.target.value;
        this.dispatchChanges();
    }

    dispatchChanges() {
        this.dispatchEvent(new CustomEvent("change", { detail: this.updatedProperty }));
    }

    handleDeleteClick() {
        if (confirm('Are you sure?')) {
            this.dispatchEvent(new CustomEvent("delete", { detail: this.updatedProperty }));
        }
    }
}