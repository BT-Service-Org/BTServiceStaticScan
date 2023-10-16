import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import getActiveAssessmentDomains from '@salesforce/apex/SEP_QA.getActiveAssessmentDomains';
import getArchivedAssessmentDomains from '@salesforce/apex/SEP_QA.getArchivedAssessmentDomains';
import updateAssessmentDomains from '@salesforce/apex/SEP_QA.updateAssessmentDomains';
import sepEstimatorAssessmentsConfirmModal from 'c/sepEstimatorAssessmentsConfirmModal';

export default class SepEstimatorAssessmentsDomainsArchiveModal extends LightningModal {
    @api estimateId;
    @api selStreamAssId;
    @api streamAssessmentName;
    @api isArchive;
    @track gridData;
    @track selectedRows = [];
    isLoading = false;
    showForm = true;
    errorMsg;
    successMsg;
    isError = false;
    sortBy;
    sortDirection;
    logPrefix = 'SEP --- ';
    columns = [
        { label: 'Domain', fieldName: 'Name', sortable: "true" },
    ];

    get modalHeader() {
        return (this.isArchive ? 'Archive' : 'Restore') + ' Stream Assessment Domains';
    }

    fetchActiveAssessmentDomains() {
        this.isLoading = true;
        getActiveAssessmentDomains({estimateId: this.estimateId, streamAssessmentId: this.selStreamAssId}).then(result => {
            console.log(this.logPrefix, 'Assessment Active Domains ---');
            console.log(result);
            if(result == null || result == undefined) {
                this.errorMsg = 'The selected Assessment does not have any Active Domains!';
                this.showForm = false;
                this.isError = true;
            } else {
                this.gridData = result;
                this.isError = false;
            }
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = this.showForm = false;
            this.isError = true;
            this.errorMsg = 'Failed to fetch Active Domains, ' + JSON.stringify(error);
        });
    }

    fetchArchivedAssessmentDomains() {
        this.isLoading = true;
        getArchivedAssessmentDomains({estimateId: this.estimateId, streamAssessmentId: this.selStreamAssId}).then(result => {
            console.log(this.logPrefix, 'Assessment Archived Domains ---');
            console.log(result);
            if(result == null || result == undefined) {
                this.errorMsg = 'The selected Assessment does not have any Archived Domains!';
                this.showForm = false;
                this.isError = true;
            } else {
                this.gridData = result;
                this.isError = false;
            }
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = this.showForm = false;
            this.isError = true;
            this.errorMsg = 'Failed to fetch Archived Domains, ' + JSON.stringify(error);
        });
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.gridData));
        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });
        this.gridData = parseData;

    }

    async handleArchive() {
        console.log(this.logPrefix, 'Archive Assessment Domains ---');
        if(this.selectedRows.length <= 0) {
            this.errorMsg = 'Please select at least one Domain to continue!';
            return;
        }
        if(this.selectedRows.length >= this.gridData.length) {
            this.errorMsg = 'At least one Domain must be present on the Assessment!';
            return;
        }
        this.selectedRows.forEach(e => {
            e.isActive__c = false;
        });
        let alertText = 'Your responses are about to be removed for ' + this.selectedRows.length + ' Domain(s). Click confirm in order to proceed.';
        const confirmResult = await sepEstimatorAssessmentsConfirmModal.open({
            size: 'small',
            modalTitle: this.streamAssessmentName,
            modalMessage: alertText
        });
        console.log(confirmResult);
        if(confirmResult == 'confirm') {
            this.updateAssessmentDomainsStatus();
        }
    }

    handleRestore() {
        console.log(this.logPrefix, 'Restore Assessment Domains ---');
        if(this.selectedRows.length <= 0) {
            this.errorMsg = 'Please select at least one Domain to continue!';
            return;
        }
        this.selectedRows.forEach(e => {
            e.isActive__c = true;
        });
        this.updateAssessmentDomainsStatus();
    }

    updateAssessmentDomainsStatus() {
        this.isLoading = true;
        updateAssessmentDomains({domain2Assesments: this.selectedRows}).then(response => {
            let jsonResponse = JSON.parse(response);
            console.log(this.logPrefix, 'Update assessment domain response ---');
            console.log(jsonResponse);
            this.isError = jsonResponse.isError;
            if(jsonResponse.isError) {
                this.errorMsg = jsonResponse.message;
            } else {
                this.successMsg = jsonResponse.message;
            }
            this.isLoading = this.showForm = false;
        }).catch(error => {
            this.isLoading = this.showForm = false;
            this.isError = true;
            this.errorMsg = 'Failed to update selected Assessment Domains! ' + JSON.stringify(error);
        });
    }

    handleCloseAlert() {
        this.errorMsg = false;
    }

    handleCancel() {
        this.close('okay');
    }

    connectedCallback() {
        if(this.isArchive) {
            this.fetchActiveAssessmentDomains();
        } else {
            this.fetchArchivedAssessmentDomains();
        }
    }
}