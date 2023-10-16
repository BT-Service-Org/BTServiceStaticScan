import { track, wire } from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import OUTCOME_OBJECT from '@salesforce/schema/Outcome__c';
import TITLE_FIELD from '@salesforce/schema/Outcome__c.Title__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Outcome__c.Description__c';
import LightningModal from 'lightning/modal';


export default class CreateOutcome extends LightningModal {
    @track objectInfo;
    
    methodRecordTypeId;
    fields=[TITLE_FIELD, DESCRIPTION_FIELD];

    @wire(getObjectInfo, {objectApiName: OUTCOME_OBJECT})
    objectInfo;

    get recordTypeId(){
        const rtis = this.objectInfo.data.recordTypeInfos;
        this.methodRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Method')
        return this.methodRecordTypeId; 
    }

    handleSuccess(event){
        this.close(event.detail);
    }

    handleCancel(event){
        this.close(event.detail);
    }
}