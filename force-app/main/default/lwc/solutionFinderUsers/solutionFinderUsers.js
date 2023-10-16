import { LightningElement, api } from 'lwc';

export default class SolutionFinderUsers extends LightningElement {
    @api project;

    connectedCallback() {
        this.initUsers();
    }

    initUsers() {
        console.log("getting users: " + JSON.stringify(this.project));
    }
}