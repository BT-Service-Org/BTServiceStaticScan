import { LightningElement, api } from 'lwc';

export default class SolutionFinderVisualization extends LightningElement {
    @api visualization;

    get cardsSelected() {
        return (this.visualization === "cards");
    }

    get listSelected() {
        return (this.visualization === "list");
    }

    handleCardsClick() {
        this.doSelect("cards");
    }

    handleListClick() {
        this.doSelect("list");
    }

    doSelect(value) {
        this.visualization = value;
        this.dispatchEvent(new CustomEvent("clicked", { detail: { visualization: value }}));
    }
}