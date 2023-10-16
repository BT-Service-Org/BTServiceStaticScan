import { LightningElement, api, track } from 'lwc';
import getTree from '@salesforce/apex/SolutionFinderTree.getTree';

export default class SolutionFinderTree extends LightningElement {
    @api recordName;
    @track title;
    @track description;
    @track items;
    @track chart;

    connectedCallback() {
        this.initItems();
    }

    initItems() {
        getTree({ name: this.recordName })
            .then(data => {
                this.title = data.title;
                this.description = data.description;
                this.items = data.items;
            })
            .catch(error => {
                console.log(error);
            })
    }
}