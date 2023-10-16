import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import { createRecord } from 'lightning/uiRecordApi';

import TAG_OBJECT from '@salesforce/schema/Tag__c';
import NAME_FIELD from '@salesforce/schema/Tag__c.Name';
import PSC_Same_Tag_ProductError from '@salesforce/label/c.PSC_Same_Tag_ProductError';
export default class PscPills extends LightningElement {
    @api tabs;
    @api label;
    @api hideDelete = false;
    @api knowledgeId;
    @api parentType;
    showSpinner = true;
    newTag;
    errorFound = false;
    errorMsg;
    tagId = undefined;
    tagError = false;

    handleButtonClick(event) {
        this.showModal();
    }
    showModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
    }
    handleLoad(event) {
        this.showSpinner = false;
        this.tagId = undefined;
        this.newTag = undefined;
    }

    closeModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.hide();
    }
    handleSuccess(event) {
        let tagType = this.tabs[this.tabs.length - 1] ? this.tabs[this.tabs.length - 1] : {};
        if (!this.tagError) {
            const toastMessage = ('typeProduct' in tagType ? 'Product ' : 'typeIndustry' in tagType ? 'Industry ' : 'typeRole' in tagType ? 'Audience ' : 'typeTag' in tagType ? 'Tag ' : '') + 'Record Added Successfully';
            this.refreshArticleData(toastMessage);
            this.showSpinner = false;
            if (this.tagId == undefined) {
                this.closeModal();
            }
        }
    }

    refreshArticleData(toastMessage) {
        const refreshEvent = new CustomEvent('refreshpilldata');

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: toastMessage,
                variant: 'success'
            })
        );
        this.dispatchEvent(refreshEvent);
    }

    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        let tagCreation = false;
        let fields = event.detail.fields;
        this.errorFound = false;
        this.tagError = false;
        if (this.parentType == 'Knowledge') {
            fields['Knowledge__c'] = this.knowledgeId;
        }
        else if (this.parentType == 'Reusable') {
            fields['Reusable_Asset__c'] = this.knowledgeId;
        }
        if (this.tabs[this.tabs.length - 1].typeTag) {
            if ((fields['Tag__c'] === undefined || fields['Tag__c'] === null || fields['Tag__c'] === '') && this.newTag === undefined) {
                this.errorMsg = 'Please enter a tag';
                this.errorFound = true;
                return;
            }
            else if (fields['Tag__c'] !== undefined && fields['Tag__c'] !== null && fields['Tag__c'] !== '' && this.newTag !== undefined) {
                this.errorMsg = 'Please enter only one tag';
                this.errorFound = true;
                return;
            }
            else if ((fields['Tag__c'] === undefined || fields['Tag__c'] === null || fields['Tag__c'] === '') && this.newTag !== undefined) {
                tagCreation = true;
                this.createTagRecord(this.newTag)
                    .then(result => {
                        this.tagId = result;
                        if (this.tagId == undefined) {
                            return;
                        }

                        fields['Tag__c'] = this.tagId;
                        this.template.querySelector('lightning-record-edit-form').submit(fields);
                        this.closeModal();
                    })
                    .catch(error => {
                        this.tagError = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error,
                                variant: 'error'
                            })
                        );
                    })
            }
        }
        if (!tagCreation) {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
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

    async deleteItem(event) {
        const datasetId = event.currentTarget.dataset.id;
        const result = await LightningConfirm.open({
            message: 'Are you sure to delete this item?',
            variant: 'header',
            label: 'Confirm Delete',
            theme: 'inverse'
        });
        if (result) {
            deleteRecord(datasetId)
                .then(() => {
                    this.refreshArticleData("Deleted successfully")
                })
                .catch(error => {
                    console.log('error->', error);
                });
        }
    }

    handleTagChange(event) {
        this.newTag = event.target.value;
    }


    createTagRecord(tagName) {

        const fields = {};  
        fields[NAME_FIELD.fieldApiName] = tagName;
        const recordInput = { apiName: TAG_OBJECT.objectApiName, fields };
        return new Promise((resolve, reject) => {
            createRecord(recordInput)
                .then(result => {
                    resolve(result.id);

                })
                .catch(error => {
                    let errormessage;
                    if (error.body.output.fieldErrors.hasOwnProperty('Name')) {
                        errormessage = error.body.output.fieldErrors.Name[0].message;
                    }
                    else if (error.body.output.errors.hasOwnProperty('Name')) {
                        errormessage = error.body.output.errors.Name[0].message;
                    }
                    else if(error?.body?.output?.errors[0]?.message==PSC_Same_Tag_ProductError){
                        errormessage=PSC_Same_Tag_ProductError;
                    }
                    else {
                        errormessage = error.body.message;
                    }
                    reject(errormessage);
                })
        })
    }
}