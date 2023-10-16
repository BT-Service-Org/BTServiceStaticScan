import { LightningElement, api } from 'lwc';

export default class SolutionFinderProject extends LightningElement {
    @api project;

    get name() {
        return this.project ? this.project.name : "...";
    }

    handleClick(event) {
        this.dispatchEvent(new CustomEvent("select", { detail: this.project }));
    }
}