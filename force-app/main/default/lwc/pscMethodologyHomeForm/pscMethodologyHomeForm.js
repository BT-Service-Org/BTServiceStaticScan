import {LightningElement,api, wire, track } from 'lwc';
import getMethodologyFormData from '@salesforce/apex/PSCMethodologyHomeFormsCtrl.getMethodologyFormData';
import pscEnagagementTypeDescriptionLabel from '@salesforce/label/c.pscEngagementTypeDescription';
import pscEnagagementTypeTitleLabel from '@salesforce/label/c.pscEngagementTypeTitle';

export default class PscMethodologyHomeForm extends LightningElement {
    @api maxRecords;
    pscEnagagementTypeTitle = pscEnagagementTypeTitleLabel;
    pscEnagagementTypeDescription = pscEnagagementTypeDescriptionLabel;

    @track formsData = [];

    @wire(getMethodologyFormData)
    fetchMethodologyFormData({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null && Object.keys(data).length > 0) {
                this.formsData = JSON.parse(JSON.stringify(data));
            }
        }
        if (error) {
            console.log("error =>", error);
        }

    }


}