import { LightningElement, api, wire, track } from 'lwc';
import getDeliverablesList from '@salesforce/apex/PSCDeliverablesCtrl.getDeliverablesList';

export default class PscDeliverablesList extends LightningElement {
    @api recId;
    @track deliverables = [];

    @wire(getDeliverablesList, { methodId: '$recId' })
    wiredDeliverablesData({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null) {
                this.deliverables = data;
            }
        }
        if (error) {
            console.error('error->', error);
        }
    }
}