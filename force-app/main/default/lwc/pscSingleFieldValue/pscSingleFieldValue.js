import { LightningElement , api } from 'lwc';

export default class PscSingleFieldValue extends LightningElement {
    @api recordId;
    @api fieldApiName;
    @api objectApiName;
    @api title;
}