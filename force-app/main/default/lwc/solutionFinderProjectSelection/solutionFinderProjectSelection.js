import { LightningElement, api } from 'lwc';
import createProject from '@salesforce/apex/SolutionFinderProjects.createProject';

const STATE_MINIMIZED = "minimized";
const STATE_MAXIMIZED = "maximized";

export default class SolutionFinderProjectSelection extends LightningElement {
    @api project;
    @api newProjectName;
    @api state;
    @api displaySelectProject = false;

    connectedCallback() {
        console.log("cancel button? " + this.displayCancelButton);
    }

    get projectName() {
        return this.project ? this.project.name : "Select a Project";
    }

    get displayCancelButton() {
        return this.state === STATE_MAXIMIZED;
    }

    get displayExpandButton() {
        return this.state === STATE_MINIMIZED;
    }

    handleProjectSelected(event) {
        this.commitSelection(event.detail);
        this.displaySelectProject = false;
    }

    handleCancelSelection() {
        this.displaySelectProject = false;
    }

    handleViewProjectClick(event) {
        this.dispatchEvent(new CustomEvent("view"));
    }

    handleProjectChangeClick() {
        this.displaySelectProject = true;
    }

    handleNewProjectKeyUp(event) {
        this.newProjectName = event.target.value;
    }

    handleCreateProject() {
        if (this.newProjectName) {
            createProject({ name: this.newProjectName })
            .then(results => {
                this.commitSelection(results);
                this.displaySelectProject = false;
            })
            .catch(error => {
                console.log("Error creating new project: " + error);
                this.displaySelectProject = false;
            })
        }
    }

    handleCancelClick() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    commitSelection(project) {
        this.dispatchEvent(new CustomEvent("select", { detail: project }));
    }
}