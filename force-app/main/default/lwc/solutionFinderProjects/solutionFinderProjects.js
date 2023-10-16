import { LightningElement, track } from 'lwc';
import getProjects from '@salesforce/apex/SolutionFinderProjects.getProjects';
import createProject from '@salesforce/apex/SolutionFinderProjects.createProject';

export default class SolutionFinderProjects extends LightningElement {
    @track projects;
    newProjectName;

    connectedCallback() {
        this.initProjects();
    }

    initProjects() {
        getProjects()
            .then(results => {
                this.projects = results;
            })
            .catch(error => {
                console.log("Error getting projects: " + error);
            })
    }

    handleProjectSelected(event) {
        this.commitSelection(event.detail);
    }

    handleNewProjectKeyUp(event) {
        this.newProjectName = event.target.value;
    }

    handleCreateProjectClick() {
        createProject({ name: this.newProjectName })
            .then(results => {
                this.commitSelection(results);
            })
            .catch(error => {
                console.log("Error creating new project: " + error);
            })
    }

    commitSelection(project) {
        this.dispatchEvent(new CustomEvent("select", { detail: project }));
    }
}