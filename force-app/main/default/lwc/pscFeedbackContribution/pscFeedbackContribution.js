import { LightningElement, track, wire } from 'lwc';
import getFeedbackData from '@salesforce/apex/PSCFeedbackContributionCtrl.getFeedbackData';
import deleteContentDocument from '@salesforce/apex/PSCContributionService.deleteContentDocument';
import updateContentDocumentLink from '@salesforce/apex/PSCFeedbackContributionCtrl.updateContentDocumentLink';
import pscFeedbackContributionDescriptionLabel from '@salesforce/label/c.pscFeedbackContributionDescription';
import pscFeedbackContributionTitleLabel from '@salesforce/label/c.pscFeedbackContributionTitle';
import pscFeedbackContributionSuccessMessageLabel from '@salesforce/label/c.pscFeedbackContributionSuccessMessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';

export default class PscFeedbackContribution extends LightningElement {

    pscFeedbackContributionTitle = pscFeedbackContributionTitleLabel;
    pscFeedbackContributionDescription = pscFeedbackContributionDescriptionLabel;
    characterCodyImage = PSC_IMAGES + '/characters/Codey.png';
    @track buttonData = [];
    @track clickButtonDetail = {};
    @track modalContent = {};
    contentDocumentIds = []
    feedbackRecordId;
    customRadioData;
    showSpinner = false;

    @wire(getFeedbackData)
    fetchMethodologyFormData({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null && Object.keys(data).length > 0) {
                this.buttonData = JSON.parse(JSON.stringify(data));
            }
        }
        if (error) {
            console.log("error =>", error);
        }
    }

    handleLoad(event) {
        this.showSpinner = false
    }

    async handleSuccess(event) {
        this.feedbackRecordId = event.detail.id;
        if (this.feedbackRecordId && this.contentDocumentIds && this.contentDocumentIds.length > 0) {
            await updateContentDocumentLink({ contentIdString: JSON.stringify(this.contentDocumentIds), recordId: this.feedbackRecordId })
            this.contentDocumentIds = [];
        }
        this.showSpinner = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: pscFeedbackContributionSuccessMessageLabel,
                variant: 'success'
            })
        );
        await this.closeModal();
    }

    handleButtonClick(event) {
        if (event.keyCode == '13' || event.keyCode == undefined) {
            const buttonTitle = event.currentTarget.dataset.id;
            if (buttonTitle && this.buttonData && this.buttonData.length > 0) {
                this.clickButtonDetail = this.buttonData.find(item => item.title === buttonTitle);
                if (this.clickButtonDetail.onClickModal && Object.keys(this.clickButtonDetail.onClickModal).length > 0) {
                    this.modalContent = this.clickButtonDetail.onClickModal;
                    this.showModal();
                }
            }
        }

    }

    showModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
        this.showSpinner = true;
    }

    async closeModal() {
        try {
            await this.handleReset();
            const modal = this.template.querySelector('c-psc-modal');
            modal.hide();
        } catch (error) {
            console.log('error =>', error);
        }
    }

    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        let fields = event.detail.fields;
        if (this.customRadioData) {
            const radioElement = this.template.querySelector('c-psc-custom-radio-group');
            if (radioElement && !this.customRadioData.valid) {
                radioElement.showRequireError();
            } else if (radioElement && this.customRadioData.valid) {
                const { radioInput, textInput, fieldName, otherInputFieldName } = this.customRadioData;
                fields[fieldName] = radioInput;
                fields[otherInputFieldName] = textInput;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                this.showSpinner = true;
            }
        } else if (!this.customRadioData) {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.showSpinner = true;
        }
    }

    async handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.customRadioData = undefined;
        await this.removeContentDocument();
    }

    async removeContentDocument() {
        if (this.contentDocumentIds && this.contentDocumentIds.length > 0) {
            await deleteContentDocument({ contentIdString: JSON.stringify(this.contentDocumentIds) });
        }
    }

    async handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        if (uploadedFiles) {
            this.contentDocumentIds.push(...uploadedFiles.map(item => item.documentId));
        }
    }

    handleCustomRadio(event) {
        this.customRadioData = event.detail;
    }

    handleError(event) {
        event.preventDefault();
        event.stopImmediatePropagation();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: event.detail.detail,
                variant: 'error'
            }));
        this.showSpinner = false;
    }
}