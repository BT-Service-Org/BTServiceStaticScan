import { LightningElement, wire, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import OUTCOME_OBJECT from '@salesforce/schema/Outcome__c';
import createOutcome from 'c/createOutcome';
import TITLE_FIELD from '@salesforce/schema/Outcome__c.Title__c';
import RECORD_TYPE_FIELD from '@salesforce/schema/Outcome__c.RecordTypeId';
import {getRecord} from 'lightning/uiRecordApi';

export default class AddMethodOutcome extends LightningElement {

    recordMap = {};
    lookupId = '';
    showData = false;
    tableData = [];

    @api outcomeIdsToBeAdded = [];
    @api outcomeIdsToBeRemoved = [];
    @api existingRecords;
    @api existingOutcomeRecords;

    @wire(getObjectInfo, {objectApiName: OUTCOME_OBJECT})
    objectInfo;

    actions = [{label: 'Delete', name:'delete'}];
    tableColumns = [
        {label : 'Title', fieldName:'title'},
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions },
        }
    ];

    connectedCallback(){

        if(this.outcomeIdsToBeAdded.length == 0 && this.outcomeIdsToBeRemoved.length == 0){
            sessionStorage.removeItem('outcomeRecordMap');
        }

        let recordMap = sessionStorage.getItem('outcomeRecordMap');
        if(recordMap){
            this.recordMap = JSON.parse(recordMap);
        }else if(this.existingOutcomeRecords){
            for(let i = 0;i<this.existingOutcomeRecords.length;i++){
                this.recordMap[this.existingOutcomeRecords[i].Id] =  this.existingOutcomeRecords[i].Title__c;
            }
        }

        this.updateTableData();
        sessionStorage.removeItem('outcomeRecordMap');
    }


    getMethodRecordTypeId(){
        const rtis = this.objectInfo.data.recordTypeInfos;
        this.methodRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Method')
        return this.methodRecordTypeId; 
    }

    disconnectedCallback(){
        sessionStorage.setItem('outcomeRecordMap', JSON.stringify(this.recordMap));
    }

    updateAddedAndRemovedIds(){
        let idsAdded = [];
        let idsRemoved = [];
        let keys = Object.keys(this.recordMap);
        if(this.recordMap && keys.length!=0){
            for(let i in keys ){
                let outcomeId = keys[i];
                if(this.isOutcomeAdded(outcomeId)){
                    idsAdded.push(outcomeId);
                }
            }
        }

        if(this.existingOutcomeRecords && this.existingOutcomeRecords.length>0){
            for(let i = 0;i<this.existingOutcomeRecords.length;i++){
                if(this.isOutcomeRemoved(this.existingOutcomeRecords[i].Id)){
                    idsRemoved.push(this.existingOutcomeRecords[i].Id);
                }
            }
        }
        this.outcomeIdsToBeAdded = idsAdded;
        this.outcomeIdsToBeRemoved = idsRemoved;
    }

    isOutcomeAdded(outcomeId){
        if(this.existingOutcomeRecords && this.existingOutcomeRecords.length > 0){
            let index = this.existingOutcomeRecords.findIndex(rec=>rec.Id == outcomeId);
            if(index >= 0){
                return false;
            }else{
                return true;
            }
        }else{
            return true;
        }
    }

    isOutcomeRemoved(outcomeId){
        let keys = Object.keys(this.recordMap);
        if(this.recordMap && keys.length > 0){
            let index = keys.findIndex(key=>key == outcomeId);
            if(index >= 0){
                return false;
            }else{
                return true;
            }
        }else{
            return true;
        }
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        if(actionName == 'delete'){
            this.deleteRow(event.detail.row);
        }
    }

    deleteRow(row){
        delete this.recordMap[row.id];
        this.updateTableData();
    }
    

    @wire(getRecord, {recordId:'$lookupId', fields:[TITLE_FIELD,RECORD_TYPE_FIELD]})
    recordFetched({error, data}){
        if(data){
            if(data.fields.RecordTypeId.value == this.getMethodRecordTypeId()){
                this.recordMap[this.lookupId]= data.fields.Title__c.value;
                this.updateTableData();
            }else{
                this.showToast('ERROR', 'Outcome of only method record type can be attached.', 'error', 'dismissable');
            }
            
        } else if(error){
            console.error(error);
        }
    }

    updateTableData(){
        let data = [];
        let keys = Object.keys(this.recordMap);
        if(this.recordMap && keys.length!=0){
            this.showData = true;
            for(let id in keys ){
                data.push({title : this.recordMap[keys[id]], id: keys[id]});
            }
        }else{
            this.showData = false;
        }
        this.tableData = data;

        this.updateAddedAndRemovedIds();
    }

    async createOutcomeRecord() {
        const result = await createOutcome.open({
            label: 'New Outcome',
        });
        if(result!=undefined){
            if(result?.hasOwnProperty('id')){
                this.showToast('Success', 'New outcome created successfully', 'success', 'dismissable');
            }else {
                this.showToast('ERROR', 'Something went wrong, contact System administrator', 'error', 'dismissable');
            }
        }
    }

    addOutcome(){
        const lookupElement = this.getLookupElement();
        this.lookupId = lookupElement.value;
        lookupElement.value=null;
    }

    getLookupElement(){
        return this.template.querySelector('lightning-input-field[data-id="outcome-lookup"]');
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

}