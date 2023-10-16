import { LightningElement,api,track } from 'lwc';
import getResults from '@salesforce/apex/LwcMultiLookupController.getResults';

export default class LwcMultiLookup extends LightningElement {
    @api objectname ;
    @api fieldName = 'Name';
    @api Label;
    @api labelname;
    @track searchRecords = [];
    @track selectedRecords = [];
    @api required = false;
    @api iconname = 'action:new_account'
    @api LoadingText = false;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @api includeRecords = [];

    @api
    clearSelected(){
        this.selectedRecords = [];
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        this.messageFlag = false;
    }

    searchField(event) {
        var currentText = event.target.value;
        var selectRecId = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            selectRecId.push(this.selectedRecords[i].recId);
        }
        this.LoadingText = true;
        getResults({ objectName: this.objectname, fieldName: this.fieldName, value: currentText, selectedRecId : selectRecId , includerecordsIds : this.includeRecords})
        .then(result => {
            this.searchRecords= result;
            this.LoadingText = false;
            
            this.txtclassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length == 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.log('-------error-------------'+error);
            console.log(error);
        });
        
    }
    
   setSelectedRecord(event) {
        var recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        let newsObject = { 'recId' : recId ,'recName' : selectName };
        this.selectedRecords.push(newsObject);
        this.txtclassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        let selRecords = this.selectedRecords;
		this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        const selectedEvent = new CustomEvent('selected', { detail: {selRecords}, });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    removeRecord (event){
        let selectRecId = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            if(event.detail.name !== this.selectedRecords[i].recId)
                selectRecId.push(this.selectedRecords[i]);
        }
        this.selectedRecords = [...selectRecId];
        let selRecords = this.selectedRecords;
        const selectedEvent = new CustomEvent('selected', { detail: {selRecords}, });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}