import { LightningElement, api } from 'lwc';

export default class SolutionFinderDetails extends LightningElement {
    @api details = [];
    @api title = "Detail";

    get columns() {
        return [{
            "name": "label",
            "label": this.title,
            "classes": "slds-col slds-size_7-of-12 slds-p-around_x-small"
        },{
            "name": "url",
            "label": "More Information URL (optional)",
            "classes": "slds-col slds-size_4-of-12 slds-p-around_x-small"
        }];
    }

    @api
    getDetails() {
        return this.details;
    }

    connectedCallback() {
        if (this.details == null || this.details.length == 0) {
            this.details = [];
        } else {
            let indexedDetails = [];
            for (let i = 0; i < this.details.length; i++) {
                indexedDetails.push({
                    "index": i,
                    "name": this.details[i].name,
                    "label": this.details[i].label,
                    "url": this.details[i].url,
                });
            }
            this.details = indexedDetails;
        }
    }

    addBlankRow() {
        let newDetails = this.details;
        newDetails.push({
            "index": this.recordCount(),
            "name": "",
            "label": "",
            "url": ""
        });
        this.details = newDetails;
    }

    recordCount() {
        let count = 0;
        if (this.details != null && this.details.length > 0) {
            count = this.details.length;
        }
        return count;
    }

    handleAddRowClick() {
        this.addBlankRow();
    }

    handleChange(event) {
        let index = event.detail.index;
        let property = event.detail.property;
        let value = event.detail.value;
        let updatedDetails = [];
        let updatedDetail;
        for (let i = 0; i < this.details.length; i++) {
            updatedDetail = {
                index: this.details[i].index,
                name: this.details[i].name,
                label: this.details[i].label,
                url: this.details[i].url
            }
            if (this.details[i].index === index) {
                updatedDetail[property] = value;
            }
            updatedDetails.push(updatedDetail);
        }
        this.details = updatedDetails;
    }

    handleDelete(event) {
        let index = event.detail;
        let updatedDetails = [];
        for (let i = 0; i < this.details.length; i++) {
            if (this.details[i].index !== index) {
                updatedDetails.push({
                    "index": updatedDetails.length,
                    "name": this.details[i].name,
                    "label": this.details[i].label,
                    "url": this.details[i].url
                })
            }
        }
        this.details = updatedDetails;
    }
}