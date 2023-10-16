import { LightningElement, api, track } from 'lwc';

export default class SolutionFinderComparisonPropertyForm extends LightningElement {
    @api selectedProperty;
    @track propertyTitle;
    @track propertyDataType;
    @track propertyDecimalPlaces;

    connectedCallback() {
        this.propertyTitle = this.title;
        this.propertyDataType = this.dataType;
        this.propertyDecimalPlaces = this.decimalPlaces;
    }

    get title() {
        return this.selectedProperty ? this.selectedProperty.title : "";
    }

    get dataType() {
        return this.selectedProperty ? this.selectedProperty.dataType : "Text";
    }

    get decimalPlaces() {
        return this.selectedProperty && this.selectedProperty.decimalPlaces ? this.selectedProperty.decimalPlaces.toString() : "0";
    }

    get showDecimalPlaces() {
        return this.propertyDataType === "Number";
    }

    get dataTypeOptions() {
        return [
            { label: 'Text', value: 'Text' },
            { label: 'Number', value: 'Number' },
            { label: 'Boolean', value: 'Boolean' }
        ];
    }

    get decimalPlacesOptions() {
        return [
            { label: '0', value: '0' },
            { label: '1', value: '1' },
            { label: '2', value: '2' }
        ];
    }

    handleKeyUp(event) {
        this.propertyTitle = event.target.value;
    }

    handleDataTypeSelected(event) {
        this.propertyDataType = event.detail.value;
    }

    handleDecimalPlacesSelected(event) {
        this.propertyDecimalPlaces = event.detail.value;
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent("save", { detail: { property: this.selectedProperty,
                                                                title: this.propertyTitle,
                                                                dataType: this.propertyDataType,
                                                                decimalPlaces: this.propertyDecimalPlaces }}));
    }
}