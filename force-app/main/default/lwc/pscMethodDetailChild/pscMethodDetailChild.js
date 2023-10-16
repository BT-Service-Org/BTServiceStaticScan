import { LightningElement , api } from 'lwc';

export default class PscMethodDetailChild extends LightningElement {
    @api componentType;
    @api recordId;
    @api fieldApiName;
    @api objectApiName;
    displayFieldValueCmp;
    displayMatrixCmp;
    displayRelatedValueCmp;
    displayRelatedTilesCmp;
    displayRelatedOutcomesCmp;

    connectedCallback(){
        if(this.componentType==='Field'){
            this.displayFieldValueCmp = true;
        }
        else if(this.componentType==='Matrix'){
            this.displayMatrixCmp = true;
        }
        else if(this.componentType==='ValueList'){
            this.displayRelatedValueCmp = true;
        }
        else if(this.componentType==='Tiles'){
            this.displayRelatedTilesCmp = true;
        }
        else if(this.componentType==='Outcomes'){
            this.displayRelatedOutcomesCmp = true;
        }
    }
}