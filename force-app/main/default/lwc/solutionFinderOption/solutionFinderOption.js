import { LightningElement, api } from 'lwc';

export default class SolutionFinderOption extends LightningElement {
    @api option;
    @api visualization;

    get classes() {
        let classes = "option " + this.visualization;
        if (this.option.id === "ADD_NEW") {
            classes += " addNew";
        }
        classes += " slds-p-vertical_large";
        return classes;
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent("clicked", { detail: { option: this.option }}));
    }
}