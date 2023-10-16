import { LightningElement,track,api,wire } from 'lwc';
import getSpecialistCloudRecords from '@salesforce/apex/methodCreationScreen11Controller.getSpecialistCloudRecords';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATUS_FIELD from '@salesforce/schema/Method_by_Specialist_Cloud__c.Status__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import METHODBySpecialist_OBJECT from '@salesforce/schema/Method_by_Specialist_Cloud__c';
export default class MethodCreationScreen11 extends LightningElement {

@api SpecialistCloud;
@api methodRecordId;
@track error;

connectedCallback(){
    getSpecialistCloudRecords({methodRecordId :this.methodRecordId})
    .then(result=>{
        this.SpecialistCloud = result;
        this.error= undefined;
        console.log('SpecialistCloud'+JSON.stringify(this.SpecialistCloud));
    })
    .catch(error=>{
        this.error=error;
        this.SpecialistCloud = undefined;
    });
}

@wire(getObjectInfo, { objectApiName: METHODBySpecialist_OBJECT })
    MethodBySpecialistInfo;

@wire(getPicklistValues, { recordTypeId: '$MethodBySpecialistInfo.data.defaultRecordTypeId', fieldApiName: STATUS_FIELD})
    StatusPicklistValues;

statusChangeHandler(event){
    this.SpecialistCloud.find(rec=>rec.Specialist_Cloud__c==event.target.dataset.item).Status__c = event.target.value;
    console.log('chngedDetails'+JSON.stringify(this.SpecialistCloud));
}
}