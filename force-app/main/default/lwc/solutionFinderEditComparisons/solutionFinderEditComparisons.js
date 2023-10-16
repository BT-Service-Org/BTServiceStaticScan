import { LightningElement, api, track } from 'lwc';
import getComparison from '@salesforce/apex/SolutionFinderComparison.getComparison';
import saveComparison from '@salesforce/apex/SolutionFinderComparison.saveComparison';
import saveComparisonProperty from '@salesforce/apex/SolutionFinderComparisonProperty.saveComparisonProperty';

const STATE_MATRIX = 'Matrix';
const STATE_PROPERTY_FORM = 'Property Form';

export default class SolutionFinderEditComparisons extends LightningElement {
    @api settings;
    @api optionName;
    @track comparison;
    @track changes;
    @track state = STATE_MATRIX;
    @track selectedProperty;

    connectedCallback() {
        this.initComparison();
    }

    get displayMatrix() {
        return this.state === STATE_MATRIX;
    }

    get displayPropertyForm() {
        return this.state === STATE_PROPERTY_FORM;
    }

    get recommendations() {
        return this.comparison && this.comparison.context && this.comparison.context.recommendations ? this.comparison.context.recommendations : [];
    }

    get properties() {
        return this.comparison && this.comparison.properties ? this.comparison.properties : [];
    }

    get mapOfValues() {
        return this.comparison && this.comparison.mapOfValues ? this.comparison.mapOfValues : [];
    }

    initComparison() {
        if (this.settings && this.settings.namespace && this.optionName) {
            getComparison({ namespace: this.settings.namespace, name: this.optionName })
                .then(results => {
                    this.comparison = results;
                })
                .catch(error => {
                    console.log("Error getting comparison: " + error);
                })
        }
    }

    handleValueChanged(event) {
        var solutionName = event.detail.solutionName;
        var propertyName = event.detail.propertyName;
        var propertyDataType = event.detail.propertyDataType;
        var value = event.detail.value;
        this.stageChange(solutionName, propertyName, propertyDataType, value);
    }

    stageChange(solutionName, propertyName, propertyDataType, value) {
        if (!this.changes) {
            this.changes = [];
        }
        for (var i = this.changes.length - 1; i >= 0; i--) {
            var change = this.changes[i];
            if (change.solutionName === solutionName && change.propertyName === propertyName) {
                this.changes.splice(i, 1);
            }
        }
        this.changes.push({
            solutionName: solutionName,
            propertyName: propertyName,
            propertyDataType: propertyDataType,
            value: value
        });
    }

    handleSave() {
        saveComparison({ changeValues: JSON.stringify(this.changes) })
            .then(results => {
                // no action required
            })
            .catch(error => {
                console.log("Error saving changes: " + JSON.stringify(error));
            })
    }

    handleNewProperty() {
        this.selectedProperty = null;
        this.state = STATE_PROPERTY_FORM;
    }

    handleEditProperty(event) {
        this.selectedProperty = event.detail.property;
        this.state = STATE_PROPERTY_FORM;
    }

    handleFormCancel() {
        this.state = STATE_MATRIX;
    }

    handleFormSave(event) {
        var property = event.detail.property;
        var name = property ? property.name : null;
        var title = event.detail.title;
        var dataType = event.detail.dataType;
        var decimalPlaces = event.detail.decimalPlaces;
        this.state = STATE_MATRIX;
        saveComparisonProperty({ namespace: this.namespace, name: name, title: title, dataType: dataType, decimalPlaces: decimalPlaces })
            .then(results => {
                this.initComparison();
            })
            .catch(error => {
                console.log("Error saving comparison property: " + JSON.stringify(error));
            })
    }
}