import { LightningElement, api } from 'lwc';

export default class SolutionFinderEditComparisonProperty extends LightningElement {
    @api property;

    get title() {
        return this.property ? this.property.title : "";
    }

    handleEditClick() {
        this.dispatchEvent(new CustomEvent("edit", { detail: { property: this.property }}));
    }
}