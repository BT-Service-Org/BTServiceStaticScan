import { LightningElement, api, wire, track } from 'lwc';
import getMethodOutcomes from '@salesforce/apex/PSCMethodDetailCtrl.getMethodOutcomes';

export default class PscMethodOutcomeList extends LightningElement {
    @api recId;
    @track outcomes = [];

    @wire(getMethodOutcomes, { methodId: '$recId' })
    wiredDeliverablesData({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null) {
                this.outcomes = data;
            }
        }
        if (error) {
            console.error('error->', error);
        }
    }
}