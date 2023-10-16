import { LightningElement, api, wire, track } from 'lwc';
import REQUEST_CONTENT from '@salesforce/schema/Content_Requests__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import createContentRequest from '@salesforce/apex/PSCRequestContentCtrl.createContentRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PscRequestContentModal extends LightningElement {
    @track industryData;
    @track productData;
    @track roleData;
    @track contentDocumentIds = [];
    showSpinner = false;
    recordTypeId = '';
    requestContentId = '';

    @wire(getObjectInfo, { objectApiName: REQUEST_CONTENT })
    wiredContentRecordId({ data, error }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;

        }
        else if (error) {
            console.error(error);
        }
    }

    @api showModalBox() {
        this.showSpinner = true;
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
    }

    async handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        if (uploadedFiles) {
            this.contentDocumentIds.push(...uploadedFiles.map(item => item.documentId));
        }
    }

    closeModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.hide();
    }

    async handleSuccess(event) {
        this.showSpinner=true;
        try {
            this.requestContentId = event.detail.id;
            await createContentRequest({
                requestContentId: this.requestContentId,
                contentIdString: JSON.stringify(this.contentDocumentIds),

            }).then(result => {
                this.showSpinner=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Request Submitted Successfully',
                        variant: 'success'
                    })
                );
                this.closeModal();
            }).catch(err => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Some Error Occurred',
                        variant: 'error'
                    }));
                console.error(err)
            })
        }
        catch (e) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Some Error Occurred',
                    variant: 'error'
                }));
        }

    }
    handleCancel() {
        this.closeModal();
    }

    handleLoad() {
        this.showSpinner = false;
    }
}