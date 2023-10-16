import { LightningElement, api } from 'lwc';
import saveWordAssociation from '@salesforce/apex/SolutionFinderWordAssociation.saveWordAssociation';
import deleteWordAssociation from '@salesforce/apex/SolutionFinderWordAssociation.deleteWordAssociation';

export default class SolutionFinderWordAssociation extends LightningElement {
    @api settings;
    @api optionName;
    @api buzzWord;
    @api button;

    get showAdd() {
        return this.button === "add";
    }

    get showRemove() {
        return this.button === "remove";
    }

    handleEditClicked(event) {
        this.dispatchEvent(new CustomEvent("edit", { detail: { buzzWord: this.buzzWord }}));
    }

    handleAdd() {
        this.broadcastLoading();
        saveWordAssociation({ namespace: this.settings.namespace, optionName: this.optionName, buzzWordName: this.buzzWord.name })
            .then(data => {
                // no action required
            })
            .catch(error => {
                console.log("Error creating word association: " + JSON.stringify(error));
            })
    }

    handleRemove() {
        this.broadcastLoading();
        deleteWordAssociation({ name: this.buzzWord.wordAssociationName })
            .then(data => {
                // no action required
            })
            .catch(error => {
                console.log("Error deleting word association: " + JSON.stringify(error));
            })
    }

    broadcastLoading() {
        this.dispatchEvent(new CustomEvent("loading"));
    }
}