import { LightningElement,api, track, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import createNewDeliverable from 'c/createNewDeliverable';

export default class CustomLookupDeliverables extends LightningElement {
    showMessage = false;
    count = 0;
    selectedDeliverable = '';
    selectedRole = '';
    deliverableField;
    deliverableName;
    roleField;
    roleName;
    deliverableValue='';
    requiredField;
    @track addedDeliverables = [];
    @api selectedDeliverables='';
    @api selectedRoles='';
    @api recordId;

    /**This is to get already selected deliverables and roles from sessionstorage on click of back button in flow screen */
    connectedCallback() {
        if(this.selectedDeliverables !== '' || this.selectedRoles !== '') {
            var deliverables = JSON.parse(sessionStorage.getItem('deliverables'));
            this.addedDeliverables = deliverables !== null ? deliverables : [];
            this.showMessage = this.addedDeliverables.length > 0 ? true : false;
            this.count = deliverables[deliverables.length - 1].id;
            // console.log('deliverable: '+sessionStorage.getItem('deliverables'));
        }else {
            /**Clearing the session storage that we use to store the deliverables and roles- FLOW: Create_Method */
            var deliverables = sessionStorage.getItem('deliverables')
            if( deliverables !== undefined || deliverables !== null) sessionStorage.removeItem('deliverables');
        }
    }

    /**Wire Method to get the Deliverable Name */
    @wire(getRecord, { recordId: '$selectedDeliverable', fields: '$deliverableField' })
    findDeliverableName( {error, data} ) {
        if (error) {

        } else if (data) {
            const deliverableData = data;
            this.deliverableName = deliverableData.fields.Name.value
        }
    }
    /**Wire Method to get the Role Name */
    @wire(getRecord, { recordId: '$selectedRole', fields: '$roleField' })
    findRoleName( {error, data} ) {
        if (error) {

        } else if (data) {
            const roleData = data;
            this.roleName = roleData.fields.Name.value
        }
    }

    handleDeliverableChange(event) {
        this.selectedDeliverable = event.target.value;
        this.deliverableField = ['Deliverables__c.Name'];
    }
    handleRoleChange(event) {
        this.selectedRole = event.target.value;
        this.roleField = ['Role__c.Name'];
    }
    /**This is to create the Method by Deliverables records */
    handleSave() {
        var fields = {'Method__c' : this.recordId, 'Role__c' : this.selectedRole, 'Deliverable__c' : this.selectedDeliverable};
        var objRecordInput = {'apiName' : 'Method_by_Deliverables__c', fields};
        createRecord(objRecordInput).then(response => {
            this.showToast('Success', 'Deliverable has been added for this method', 'success', 'dismissable');
            this.clearCache();
        }).catch(error => {
            this.showToast('ERROR', 'Something went wrong, contact system administrator', 'error', 'dismissable');
            this.clearCache();
        });
    }
    /**This is to reuse the lightning toast message api */
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
    /**This is to clear the input field values */
    clearCache() {
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(element => {
            element.value = '';
        });
        this.selectedDeliverable = '';
        this.selectedRole = '';
    }
    /**This is to add the recordId in the respected list */
    handleAdd() {
        if(this.selectedDeliverable === '') this.requiredField = 'Please fill the Deliverable field'
        if(this.selectedRole === '') this.requiredField = 'Please fill the Role field'
        if(this.selectedDeliverable === '' && this.selectedRole === '') this.requiredField = 'Please fill all the required field'
        if(this.selectedDeliverable !== '' && this.selectedRole !== '') {
            this.requiredField = '';
            this.selectedDeliverables += this.selectedDeliverable !== '' ? this.selectedDeliverable + ';' : 'NA;';
            this.selectedRoles += this.selectedRole !== '' ? this.selectedRole + ';' : 'NA;';
            if ( this.selectedRole!=='' || this.selectedDeliverable!=='' ) {
                this.count++;
                const rolewithDeliverable = {};
                rolewithDeliverable.id = this.count;
                rolewithDeliverable.role = this.roleName;
                rolewithDeliverable.deliverable = this.deliverableName;
                this.addedDeliverables.push(rolewithDeliverable);
            }
    
            /**adding data to sessionstorage to render already selected Deliverables and Roles on click on back button in Flow screen */
            sessionStorage.setItem('deliverables', JSON.stringify(this.addedDeliverables));
    
            this.showMessage = this.addedDeliverables.length > 0 ? true : false;
            this.clearCache();
            this.showToast('Success', 'Deliverable has been added for this method', 'success', 'dismissable');
        }
    }

    async createDeliverable() {
        const result = await createNewDeliverable.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
        });
        console.log(result);
        if(result?.includes('success')){
            var recordId = result.split(':')[1];
            console.log(recordId);
            this.deliverableValue = recordId;
            this.selectedDeliverable = recordId;
            this.deliverableField = ['Deliverables__c.Name'];
            this.showToast('Success', 'A new Deliverable is Created ', 'success', 'dismissable');
        }else if(result === 'failure') {
            this.showToast('ERROR', 'Something went wrong, contact system administrator', 'error', 'dismissable');
        }
    }

}