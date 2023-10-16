import { LightningElement, api, track } from 'lwc';
import getConfigurations from '@salesforce/apex/SolutionFinderConfigurations.getConfigurations';

export default class SolutionFinderProjectSummary extends LightningElement {
    @api project;
    @track configurationGroups = [];
    @api savedSolutions = [];

    connectedCallback() {
        this.initConfigurations();
    }

    initConfigurations() {
        getConfigurations({ projectId: this.project.id, cacheBuster: new Date().getTime() })
            .then(results => {
                this.configurationGroups = results;
            })
            .catch(error => {
                console.log("Error getting configurations: " + JSON.stringify(error));
            })
    }

    get name() {
        return this.project ? this.project.name : "...";
    }

    get uploadButtonDisabled() {
        return this.savedSolutions.length === 0;
    }

    handleUploadClick() {
        console.log("Upload - coming soon");
    }

    handleChangeClick() {
        this.dispatchEvent(new CustomEvent("changeproject"));
    }

    handleRefreshConfigurations() {
        this.initConfigurations();
    }
}