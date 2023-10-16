import { LightningElement, api, track } from 'lwc';

export default class SolutionFinderRecommendation extends LightningElement {
    @api project;
    @api selectedOption;
    @api recommendation;
    @track configurations = [];

    connectedCallback() {
        this.createConfiguration(0);
    }

    get notConfigured() {
        return !this.descriptionExists && !this.considerationsExist && !this.limitationsExist && !this.propertiesExist;
    }

    get descriptionExists() {
        return this.recommendation && this.recommendation.description;
    }

    get considerationsExist() {
        return this.recommendation && this.recommendation.considerations && this.recommendation.considerations.length > 0;
    }

    get limitationsExist() {
        return this.recommendation && this.recommendation.limitations && this.recommendation.limitations.length > 0;
    }

    get storiesExist() {
        return this.recommendation && this.recommendation.stories && this.recommendation.stories.length > 0;
    }

    get propertiesExist() {
        return this.recommendation && this.recommendation.properties && this.recommendation.properties.length > 0;
    }

    addConfigurationClick() {
        this.createConfiguration(this.configurations.length);
    }

    createConfiguration(index) {
        let configuration = {
            index: index,
            properties: {}
        };
        var property;
        for (let i = 0; i < this.recommendation.properties.length; i++) {
            property = this.recommendation.properties[i];
            configuration.properties[property.name] = null;
        }
        this.configurations.push(configuration);
    }

    handleChange(event) {
        let index = event.detail.index;
        let property = event.detail.property;
        let value = event.detail.value;
        var configuration;
        for (let i = 0; i < this.configurations.length; i++) {
            configuration = this.configurations[i];
            if (configuration.index === index) {
                configuration.properties[property.name] = value;
            }
        }
    }

    get configurationsToSave() {
        let configurationsToSave = [];
        var configuration;
        for (let i = 0; i < this.configurations.length; i++) {
            configuration = this.configurations[i];
            configurationsToSave.push({
                optionName: this.selectedOption.name,
                solutionName: this.recommendation.solutionName,
                properties: configuration.properties
            });
        }
        return configurationsToSave;
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent("save", { detail: this.configurationsToSave }));
    }
}