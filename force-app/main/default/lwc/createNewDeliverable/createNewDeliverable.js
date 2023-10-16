import LightningModal from 'lightning/modal';
import { createRecord } from 'lightning/uiRecordApi';

export default class CreateNewDeliverable extends LightningModal {
    requiredField = '';
    handleSave() {
        var name = this.template.querySelector('lightning-input').value;
        if(name === undefined || name === '') {
            this.requiredField = 'Please fill the required field'
        }else {
            var fields = {'Name' : name};
            var objRecordInput = {'apiName' : 'Deliverables__c', fields};
            createRecord(objRecordInput).then(response => {
                this.close('success:'+response.id);
            })
            .catch(error => {
                this.close('failure');
            });
        } 
    }
}