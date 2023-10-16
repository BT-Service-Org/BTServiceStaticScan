import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RESUABLE_ASSET_OBJ from '@salesforce/schema/gdc_ms_ReusableAsset__c';
import SUBMITTED_BY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Proposed_By__c';
import ASSET_TITLE_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Title__c';
import ASSET_DESC_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Description__c';
import ASSET_CLOUDCMPTY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_CloudCompetency__c';
import ASSET_DOMAIN_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IntendedDomainIndustries__c';
import ASSET_IDEACLASS_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IdeaClassification__c';
import ASSET_PRBLMSLVD_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_ProblemSolvedByThisAsset__c';
import ASSET_BENEFIT_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Benefits__c';
import ASSET_ISDESGNREADY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IsDesignReady__c';
export default class GdcmsCreateAssetForm extends LightningElement {
    objectApiName = RESUABLE_ASSET_OBJ;

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

    defaultRecordTypeId;
    isLoading = false;
    @track selectedDomainValues = [];
    @track selectedBenefitsValues = [];
    isDesignUploadDisabled = true;
    isSaveButtonDisabled = true;

    renderedCallback() {
        this.template.querySelector('c-gdcms-base-modal').displayModal(true);
    }
    closeModalCreate() {
        this.dispatchEvent(new CustomEvent('close'));
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
        this.selectedDomainValues = event.detail.value;
    }

    handleBenefitsSelections(event) {
        this.selectedBenefitsValues = event.detail.value;
    }

    handleDesignCheck(event) {
        this.isDesignUploadDisabled = !event.detail.checked;
    }

    handleTermsCondition(event) {
        let checked = event.target.checked;
        this.isSaveButtonDisabled = !checked;
    }

    handleSave() {
        this.template.querySelector('[data-id="buttonSave"')?.click()
    }

    handleSubmit(event) {
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
        const recordId = event.detail.id;
        this.showToast(`Idea submitted successfully.`, `Thank you for your collaboration.`, `success`);
        this.closeModalCreate();
    }
    handleError(event) {
        console.error('onerror', JSON.stringify(event))
        this.showToast(`Error Occurred!`, `Please contact your system administrator.`, `error`);
    }

    showToast(titleText, msgText, variantType) {
        const event = new ShowToastEvent({
            title: titleText,
            message: msgText,
            variant: variantType
        });
        this.dispatchEvent(event);
    }

}