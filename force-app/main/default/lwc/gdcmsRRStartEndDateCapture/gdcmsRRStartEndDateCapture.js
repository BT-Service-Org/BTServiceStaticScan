import { LightningElement } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setCurrentQuarter from '@salesforce/apex/GDCMS_NominationScreenController.setCurrentQuarter';
import createManagerRecords from '@salesforce/apex/GDCMS_NominationScreenController.createManagerRecords';
import getCurrentQuarter from '@salesforce/apex/GDCMS_NominationScreenController.getCurrentQuarter';

export default class GdcmsRRStartEndDateCapture extends LightningElement {

    startDateInput = '';
    endDateInput = '';
    curretQuarter = '';

    connectedCallback() {
        getCurrentQuarter()
            .then(result => {
                if (result != undefined) {
                    console.log(JSON.stringify(result));
                    this.startDateInput = result.gdc_ms_QuarterStartDate__c;
                    this.endDateInput = result.gdc_ms_QuarterEndDate__c;
                    this.curretQuarter = result.gdc_ms_Quarter__c;
                }
            })
            .catch(error => {
                alert(error);
            });
    }

    async handleSave(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.name === "startDate") {
                    this.startDateInput = field.value;
                }

                if (field.name === "endDate") {
                    this.endDateInput = field.value;
                }
            });

            if (this.startDateInput !== '' && this.endDateInput !== '') {
                const result = await setCurrentQuarter({ startDate: this.startDateInput, endDate: this.endDateInput });
                console.log(result);
                if (result.length > 2) {
                    this.showToast('Invalid Input', result, 'warning');
                } else {

                    const confirmResult = await LightningConfirm.open({
                        message: 'As per the entered dates the Nominations will be open for Quarter : ' + result,
                        variant: 'header',
                        theme: 'warning',
                        label: 'Confirm Nomination Quarter !'
                    });

                    await this.createManagerRecords(confirmResult, result);
                }
            } else {
                this.showToast('Invalid Input', 'Please select the dates to enable rewards and recognition for new quarter', 'warning');
            }
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    async createManagerRecords(correctInput, result) {
        if (correctInput === true) {
            this.curretQuarter = result;
            createManagerRecords({ startDate: this.startDateInput, endDate: this.endDateInput, quarter: result })
                .then(result => {
                    this.showToast('Success', 'The Quarter has been updated.', 'success');
                })
                .catch(error => {
                    alert(error);
                });
        }
    }
}