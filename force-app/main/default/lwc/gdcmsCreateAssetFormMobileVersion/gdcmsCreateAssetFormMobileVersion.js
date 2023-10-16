import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RESUABLE_ASSET_OBJ from '@salesforce/schema/gdc_ms_ReusableAsset__c';
import SUBMITTED_BY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Proposed_By__c';
import PROPOSED_BY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Proposed_By_User__c';

import ASSET_TITLE_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Title__c';
import ASSET_DESC_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Description__c';
import ASSET_CLOUDCMPTY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_CloudCompetency__c';
import ASSET_DOMAIN_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IntendedDomainIndustries__c';
import ASSET_IDEACLASS_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IdeaClassification__c';
import ASSET_PRBLMSLVD_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_ProblemSolvedByThisAsset__c';
import ASSET_BENEFIT_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Benefits__c';
import ASSET_ISDESGNREADY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IsDesignReady__c';
import { NavigationMixin } from 'lightning/navigation';

import userId from '@salesforce/user/Id';
export default class GdcmsCreateAssetFormMobileVersion extends NavigationMixin(LightningElement) {
    objectApiName = RESUABLE_ASSET_OBJ;
    proposedByUser = PROPOSED_BY_FIELD;
    submittedBy = SUBMITTED_BY_FIELD
    title = ASSET_TITLE_FIELD
    description = ASSET_DESC_FIELD
    cloudCompetency = ASSET_CLOUDCMPTY_FIELD
    domain = ASSET_DOMAIN_FIELD
    domains;
    ideaClassified = ASSET_IDEACLASS_FIELD
    problmSolved = ASSET_PRBLMSLVD_FIELD
    benefit = ASSET_BENEFIT_FIELD
    benefits;
    isDesignReady = ASSET_ISDESGNREADY_FIELD
    proposedDesignURL;

    defaultRecordTypeId;
    isLoading = false;
    @track selectedDomainValues = [];
    @track selectedBenefitsValues = [];
    isDesignUploadDisabled = true;
    isSaveButtonDisabled = true;

    loggedInUserId= userId ;

    closeModalCreate(recordId) {
        if (typeof recordId !== "object") {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'gdc_ms_ReusableAsset__c',
                    actionName: 'view'
                }
            });
        } else {
            window.history.back();
        }
    }

    @wire(getObjectInfo, { objectApiName: RESUABLE_ASSET_OBJ })
    objectInfo({ data, error }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.handleError(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: ASSET_DOMAIN_FIELD })
    wiredPicklistDomain({ data, error }) {
        if (data) {
            this.domains = data.values
        } else if (error) {
            this.handleError(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: ASSET_BENEFIT_FIELD })
    wiredPicklistBenefits({ data, error }) {
        if (data) {
            this.benefits = data.values
        } else if (error) {
            this.handleError(error);
        }
    }
    handleDomainsSelections(event) {
        if (!event?.detail?.value || event?.detail?.value.length === 0){
            this.template.querySelector('[data-id="requiredField-Domain"]')?.classList.add('slds-has-error');
            this.selectedDomainValues = [];
        } else {
            this.template.querySelector('[data-id="requiredField-Domain"]')?.classList.remove('slds-has-error');
            this.selectedDomainValues = event.detail.value;
        }
    }

    handleBenefitsSelections(event) {
        if (!event?.detail?.value || event?.detail?.value.length === 0){
            this.template.querySelector('[data-id="requiredField-Benefit"]')?.classList.add('slds-has-error');
            this.selectedBenefitsValues = [];
        } else {
            this.template.querySelector('[data-id="requiredField-Benefit"]')?.classList.remove('slds-has-error');
            this.selectedBenefitsValues = event.detail.value;
        }
    }

    handleDesignCheck(event) {
        this.isDesignUploadDisabled = !event.detail.checked;
        if (this.isDesignUploadDisabled)
            this.proposedDesignURL = '';
    }

    handleProposedDesign(event) {
        this.proposedDesignURL = event.target.value;
    }

    handleTermsCondition(event) {
        let checked = event.target.checked;
        this.isSaveButtonDisabled = !checked;
    }

    handleSave() {
        this.template.querySelector('[data-id="buttonSave"')?.click()
    }

    handleSubmit(event) {
        this.isLoading = true;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.gdc_ms_IntendedDomainIndustries__c = this.multiSelectReducer(this.selectedDomainValues);
        fields.gdc_ms_Benefits__c = this.multiSelectReducer(this.selectedBenefitsValues);
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    multiSelectReducer(optionLists) {
        if (optionLists.length <= 0) return;
        let value = optionLists.reduce((previous, current) => `${previous};${current}`, '');
        value = value.replace(';', '');
        return value;
    }

    handleSuccess(event) {
        this.isLoading = false;
        const recordId = event.detail.id;
        this.showToast(`Idea submitted successfully.`, `Thank you for your collaboration.`, `success`);
        this.closeModalCreate(recordId);
    }
    handleError(event) {
        this.isLoading = false;
        let err = event?.detail?.detail;
        this.showToast(`Error Occurred!`, err, `error`);
    }

    showToast(titleText, msgText, variantType) {
        const event = new ShowToastEvent({
            title: titleText,
            message: msgText,
            variant: variantType
        });
        this.dispatchEvent(event);
    }

    get layoutCSS(){
        return  FORM_FACTOR ===  'Small'  ? 'layoutCssMob' : 'layoutCssDesk';
    }

    get genericPaddingCss(){
        return  FORM_FACTOR ===  'Small'  ? 'padding-left: 7%; color:#032D60;': 'padding-left: 21%; color:#032D60; ';
    }

    get footerPadingCss(){
        return  FORM_FACTOR ===  'Small'  ? 'padding-left: 7%' : 'padding-left: 21%';

    }

    get designClass(){
        return  FORM_FACTOR ===  'Small'  ? 'slds-p-left_medium' : '';
    }
}