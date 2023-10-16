import { LightningElement, api, track } from 'lwc';
import deleteConfiguration from '@salesforce/apex/SolutionFinderConfiguration.deleteConfiguration';
import updateConfigurations from '@salesforce/apex/SolutionFinderConfigurations.updateConfigurations';

const STATE_VIEW = 'view';
const STATE_EDIT = 'edit';

export default class SolutionFinderConfigurationGroup extends LightningElement {
    @api configurationGroup;
    @track state = STATE_VIEW;
    @track selectedConfiguration = {};
    @track selectedProperties = [];

    get solutionName() {
        return this.configurationGroup ? this.configurationGroup.solutionName : "...";
    }

    get configurationCount() {
        return this.configurationGroup && this.configurationGroup.configurations ? this.configurationGroup.configurations.length : 0;
    }

    get configurations() {
        return this.configurationGroup && this.configurationGroup.configurations ? this.configurationGroup.configurations : [];
    }

    get displayView() {
        return this.state === STATE_VIEW;
    }

    get displayEdit() {
        return this.state === STATE_EDIT;
    }

    get properties() {
        var properties = [];
        var configurations = this.configurations;
        for (var i = 0; i < configurations.length; i++) {
            for (var p = 0; p < configurations[i].propertyValues.length; p++) {
                properties.push(configurations[i].propertyValues[p]);
            }
        }
        return properties;
    }

    get columns() {
        var columns = [];
        columns.push({ type: "button-icon", fixedWidth: 40, typeAttributes: { iconName: "utility:edit" }});
        var property;
        var uniqueColumnNames = [];
        var properties = this.properties;
        for (var i = 0; i < properties.length; i++) {
            property = properties[i];
            if (property.property.displayInPreview && uniqueColumnNames.indexOf(property.property.name) == -1) {
                columns.push({
                    fieldName: property.property.name,
                    label: property.property.title
                });
                uniqueColumnNames.push(property.property.name);
            }
        }
        columns.push({ type: "button-icon", fixedWidth: 40, typeAttributes: { iconName: "utility:delete" }});
        return columns;
    }

    get data() {
        var data = [];
        var configurations = this.configurations;
        var obj;
        var configuration;
        var propertyValues;
        for (var i = 0; i < configurations.length; i++) {
            configuration = configurations[i];
            obj = { id: configuration.id };
            for (var p = 0; p < configuration.propertyValues.length; p++) {
                propertyValues = configuration.propertyValues[p];
                obj[propertyValues.property.name] = propertyValues.value;
            }
            data.push(obj);
        }
        return data;
    }

    handleRowAction(event) {
        var row = event.detail.row;
        var action = event.detail.action.iconName;
        if (action === "utility:delete") {
            this.confirmDelete(row.id);
        } else if (action === "utility:edit") {
            this.initEdit(row.id);
        }
    }

    confirmDelete(rowId) {
        if (confirm('Are you sure?')) {
            this.doDelete(rowId);
        }
    }

    doDelete(id) {
        deleteConfiguration({ configurationId: id })
            .then(results => {
                this.initRefresh();
            })
            .catch(error => {
                console.log("Error deleting configuration: " + error);
            })
    }

    initEdit(rowId) {
        var configurations = this.configurations;
        this.selectedProperties = [];
        for (let i = 0; i < configurations.length; i++) {
            if (configurations[i].id === rowId) {
                this.selectedConfiguration = configurations[i];
                for (let p = 0; p < this.selectedConfiguration.propertyValues.length; p++) {
                    var propertyValues = this.selectedConfiguration.propertyValues[p];
                    if (propertyValues) {
                        this.selectedProperties.push({
                            index: p,
                            property: propertyValues,
                            value: propertyValues.value
                        });
                    }
                }
                break;
            }
        }
        console.log(JSON.stringify(this.selectedProperties));
        this.state = STATE_EDIT;
    }

    handleCancelEdit() {
        this.state = STATE_VIEW;
    }

    handleSaveEdit() {
        var updates = [];
        for (let i = 0; i < this.selectedProperties.length; i++) {
            var selectedProperty = this.selectedProperties[i];
            if (selectedProperty.property.value !== selectedProperty.value) {
                console.log("** something changed: " + JSON.stringify(selectedProperty));
                console.log(selectedProperty.property.configurationId + " - " + selectedProperty.value);
                updates.push({
                    id: selectedProperty.property.configurationId,
                    name: selectedProperty.property.property.name,
                    value: selectedProperty.value
                });
            }
        }
        console.log(JSON.stringify(updates));
        this.saveUpdates(updates);
        this.state = STATE_VIEW;
    }

    saveUpdates(updates) {
        updateConfigurations({ updatesString: JSON.stringify(updates) })
            .then(results => {
                console.log("Done!");
                this.initRefresh();
            })
            .catch(error => {
                console.log("Error");
            })
    }

    handleConfigurationChange(event) {
        var index = event.detail.index;
        var value = event.detail.value;
        console.log(JSON.stringify(event.detail));
        var selectedProperty = this.selectedProperties[index];
        if (!selectedProperty) {
            return;
        }
        selectedProperty.value = value;
        console.log(JSON.stringify(selectedProperty));
    }

    initRefresh() {
        this.dispatchEvent(new CustomEvent("refresh"));
    }
}