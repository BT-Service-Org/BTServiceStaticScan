import { LightningElement, api, track } from 'lwc';

export default class SolutionFinderProperties extends LightningElement {
    @api properties;
    @track updatedProperties;

    connectedCallback() {
        if (!this.properties) {
            this.properties = [];
        }
        this.updatedProperties = [];
        for (var i = 0; i < this.properties.length; i++) {
            var property = JSON.parse(JSON.stringify(this.properties[i]));
            property.index = i;
            this.updatedProperties.push(property);
        }
    }

    @api
    getProperties() {
        return this.updatedProperties;
    }

    handleAddRowClick() {
        this.updatedProperties.push({
            "index": this.recordCount(),
            "name": "",
            "label": "",
            "dataType": "",
            "defaultValue": ""
        });
    }

    recordCount() {
        return this.updatedProperties && this.updatedProperties.length > 0 ? this.updatedProperties.length : 0;
    }

    handlePropertyChange(event) {
        var updatedProperty = event.detail;
        for (let i = 0; i < this.updatedProperties.length; i++) {
            if (this.updatedProperties[i].index === updatedProperty.index) {
                this.updatedProperties[i] = updatedProperty;
            }
        }
    }

    handlePropertyDelete(event) {
        var deletedProperty = event.detail;
        for (let i = 0; i < this.updatedProperties.length; i++) {
            if (this.updatedProperties[i].index === deletedProperty.index) {
                this.updatedProperties.splice(i, 1);
            }
        }
        for (let i = 0; i < this.updatedProperties.length; i++) {
            this.updatedProperties[i].index = i;
        }
    }
}