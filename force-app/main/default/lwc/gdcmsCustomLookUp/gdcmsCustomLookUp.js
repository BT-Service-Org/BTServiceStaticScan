import lookUp from '@salesforce/apex/GDCMS_NominationScreenController.search';
import { api, LightningElement, track, wire } from 'lwc';

export default class GdcmsCustomLookUp extends LightningElement {

    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    @api preselectValue = '';

    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;

    searchTerm;

    connectedCallback() {
        //c/gdcmsAssetHomePagealert(this.preselectValue);
        this.selectedName = this.preselectValue;
        this.isValueSelected = true;
        this.searchTerm = this.preselectValue;
    }


    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }


    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        this.searchTerm = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
        let selectedId = '';
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }
}