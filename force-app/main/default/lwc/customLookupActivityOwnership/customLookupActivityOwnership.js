import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivityOwnerList from '@salesforce/apex/RasicComponentHandler.activityOwnerList';
import getActivityRecords from '@salesforce/apex/RasicComponentHandler.getActivityRecords';
import createNewActivity from 'c/createNewActivity';
import createNewRole from 'c/createNewRole';


export default class CustomLookupActivityOwnership extends LightningElement {

    @api recordId;
    @api selectedActivityOwnerShipRecord = [];  // use for Activity ownership Record data pass from lwc to flow
    @api methodByActivityListToInsert = [];     // use for Method By Activity Record data pass from lwc to flow
    @api deleteActivityOwnershipRecord = [];     // use for old delte Activity ownership Record data pass from lwc to flow
    @api deleteMethodByActivity = [];            // use for old delete Method By Activity Record data pass from lwc to flow

    selectedActivity = null;
    activityFields = ['Activity__c.Name', 'Activity__c.Related_Method__r.Name'];
    roleFields = ['Role__c.Name'];
    relatedMethodName = '';
    selectedActivityName = '';
    activityOwnershipData = [];
    showActivityData = false;
    selectedRasicValue = null;
    selectedRole = null;
    roleRecords = [];
    showRoleData = false;
    roleTableData = [];
    isShowEditModal = false;
    selectedActivityRoleId = null;
    activityTableData = [];

    activityColumns = [
        { label: 'Activity', fieldName: 'Name' },
        { label: 'Related Method', fieldName: 'RelatedMethodName' },
        {
            type: "button", typeAttributes: {
                label: 'Edit', name: 'Edit', title: 'Edit', disabled: false, value: 'edit', iconPosition: 'left'
            }
        }
    ];

    roleColumns = [
        { label: 'Role', fieldName: 'RoleName' },
        { label: 'Rasic', fieldName: 'RasicValueString' },
        {
            type: "button", typeAttributes: {
                label: 'Edit', name: 'Edit', title: 'Edit', disabled: false, value: 'edit', iconPosition: 'left'
            }
        }
    ];

    @wire(getRecord, { recordId: '$selectedActivity', fields: '$activityFields' })
    findActivityName({ error, data }) {
        if (data) {
            this.relatedMethodName = data.fields.Related_Method__r.displayValue;
            this.selectedActivityName = data.fields.Name.value;
        } else if (error) {
            console.error('Error:', error);
        }
    }

    /**Wire Method to get the Role Name */
    @wire(getRecord, { recordId: '$selectedRole', fields: '$roleFields' })
    findRoleName({ error, data }) {
        let index = this.roleRecords.findIndex(ele => ele.Id == this.selectedRole);
        if (data && index == -1) {
            const roleData = data;
            let roleName = roleData.fields.Name.value;
            this.roleRecords.push({ 'Id': this.selectedRole, 'Name': roleName });
        }
    }

    connectedCallback(){
        if(this.selectedActivityOwnerShipRecord.length > 0){
            let sessionData = sessionStorage.getItem('activityOwnershipData');
            if(sessionData){
                this.activityOwnershipData = JSON.parse(sessionData);
                this.roleRecords = JSON.parse(sessionStorage.getItem('roleRecords'));
                this.showActivityData = true;
            }
        }else{
            sessionStorage.removeItem('activityOwnershipData');
            sessionStorage.removeItem('roleRecords');
            getActivityOwnerList({ methodId: this.recordId}).then(result=>{
                if(result){
                    let activityIds = [];
                    for(let i=0; i < result.length; i++){
                        activityIds.push(result[i].Activity__c);
                        this.roleRecords.push({ 'Id': result[i].Role__c, 'Name': result[i].Role__r.Name });
                        this.activityOwnershipData.push(JSON.parse(JSON.stringify(result[i])));
                    }
    
                    if(activityIds.length > 0){
                        getActivityRecords({activityIds: activityIds}).then(activityRecords=>{
                            for(let i=0; i < this.activityOwnershipData.length; i++){
                                let currentRecord = this.activityOwnershipData[i];
                                let activityRecord = activityRecords.find(ele=> ele.Id == currentRecord.Activity__c);
                                currentRecord.activityName = activityRecord.Name;
                                currentRecord.relatedMethodName = activityRecord.Related_Method__r?.Name;
                                currentRecord.activityRoleId = currentRecord.Activity__c+'-'+currentRecord.Role__c;
                                currentRecord.selectedRasicValue = this.importRasicValue(currentRecord);
                            }
    
                            this.showActivityData = true;
                            
                        });
                    }
                }
            });
        }
        
    }

    disconnectedCallback(){
        sessionStorage.setItem('activityOwnershipData', JSON.stringify(this.activityOwnershipData));
        sessionStorage.setItem('roleRecords', JSON.stringify(this.roleRecords));
    }

    clearSelectedData() {
        this.relatedMethodName = '';
        this.selectedActivityName = '';
        this.selectedRasicValue = null;
        this.selectedRole = null;
        this.selectedActivity = null;
        this.selectedActivityRoleId = null;
    }

    handleAddActivity() {
        this.clearSelectedData();
    }


    handleRasicChange(event) {
        this.selectedRasicValue = event.detail.value;
    }

    get rasicOptions() {
        return [
            { label: 'Responsible', value: 'R' },
            { label: 'Accountable', value: 'A' },
            { label: 'Supports', value: 'S' },
            { label: 'Informed', value: 'I' },
            { label: 'Consulted', value: 'C' },
        ];
    }

    handleAddRole() {
        if (this.isRequiredValidationPassed() && this.isAddRoleValidationPassed()) {
            this.activityOwnershipData = this.reactivePush(this.activityOwnershipData, this.createActivityOwnershipRecord());
            this.showActivityData = true;
            this.clearSelectedData();
        }
    }

    handleEditRole() {
        if (this.isRequiredValidationPassed() && this.isEditRoleValidationPassed()) {
            let updatedActivityOwnershipRecord = this.createActivityOwnershipRecord();
            let index = this.activityOwnershipData.findIndex(ele => ele.activityRoleId == this.selectedActivityRoleId);
            updatedActivityOwnershipRecord.Id = this.activityOwnershipData[index].Id;
            // remove the existing record at above index and add the updated record there
            this.activityOwnershipData.splice(index, 1, updatedActivityOwnershipRecord);
            let activityData = this.activityTableData.find(ele => ele.Id == updatedActivityOwnershipRecord.Activity__c);
            this.refreshRoleTableData(activityData);
            this.handleHideModal()
        }
    }

    reactivePush(arr, element) {
        let tempArr = [];
        tempArr.push(...arr);
        tempArr.push(element);
        arr = [];
        arr.push(...tempArr);
        return arr;
    }

    prepareActivityTableData() {
        let tableData = [];
        for (let i = 0; i < this.activityOwnershipData.length; i++) {
            let currentData = this.activityOwnershipData[i];
            let index = tableData.findIndex(ele => ele.Id == currentData.Activity__c);
            if (index == -1) {
                tableData.push({ 'Name': currentData.activityName, 'RelatedMethodName': currentData.relatedMethodName, 'Id': currentData.Activity__c, 'RolesData': [currentData.activityRoleId] })
            } else {
                tableData[index].RolesData.push(currentData.activityRoleId);
            }
        }
        this.activityTableData = tableData;
        return tableData;
    }

    get activityDisplayList() {
        this.populateOwnershipRecords();
        return this.prepareActivityTableData();
    }

    importRasicValue(activityOwnershipRecord){
        let rasicValue = [];
        if(activityOwnershipRecord.Responsible__c == 'Yes'){
            rasicValue.push('R');
        }
        if(activityOwnershipRecord.Accountable__c == 'Yes'){
            rasicValue.push('A');
        }
        if(activityOwnershipRecord.Support__c == 'Yes'){
            rasicValue.push('S');
        }
        if(activityOwnershipRecord.Informed__c == 'Yes'){
            rasicValue.push('I');
        }
        if(activityOwnershipRecord.Consulted__c == 'Yes'){
            rasicValue.push('C');
        }

        return rasicValue;
    }

    populateOwnershipRecords(){
        this.selectedActivityOwnerShipRecord=[];
        for(let i=0;i<this.activityOwnershipData.length;i++){
            let record = {};
            let data = this.activityOwnershipData[i];
            record.Activity__c = data.Activity__c;
            record.Role__c = data.Role__c;
            record.Method__c = data.Id ? this.recordId : null;
            record.Id = data.Id;

            record.Responsible__c = data.Responsible__c;
            record.Accountable__c = data.Accountable__c;
            record.Support__c = data.Support__c;
            record.Informed__c = data.Informed__c;
            record.Consulted__c = data.Consulted__c;

            this.selectedActivityOwnerShipRecord.push(record);
        }
    }

    createActivityOwnershipRecord() {
        let activityOwnershipRecord = {};
        activityOwnershipRecord.activityName = this.selectedActivityName;
        activityOwnershipRecord.relatedMethodName = this.relatedMethodName;
        activityOwnershipRecord.Role__c = this.selectedRole;
        activityOwnershipRecord.activityRoleId = this.selectedActivity + '-' + this.selectedRole;
        activityOwnershipRecord.Activity__c = this.selectedActivity;
        activityOwnershipRecord.selectedRasicValue = this.selectedRasicValue;


        activityOwnershipRecord.Responsible__c = this.IsRasicValuePresent('R') ? 'Yes' : 'No';
        activityOwnershipRecord.Accountable__c = this.IsRasicValuePresent('A') ? 'Yes' : 'No';
        activityOwnershipRecord.Support__c = this.IsRasicValuePresent('S') ? 'Yes' : 'No';
        activityOwnershipRecord.Informed__c = this.IsRasicValuePresent('I') ? 'Yes' : 'No';
        activityOwnershipRecord.Consulted__c = this.IsRasicValuePresent('C') ? 'Yes' : 'No';
        return activityOwnershipRecord;
    }

    IsRasicValuePresent(val) {
        if (this.selectedRasicValue) {
            let arr = Object.values(this.selectedRasicValue);
            if (arr.findIndex(value => value == val) != -1) {
                return true;
            }
        }

        return false;
    }

    callRoleAction(event) {
        this.selectedActivityRoleId = event.detail.row.activityRoleId;
        let activityOwnershipRecord = this.activityOwnershipData.find(ele => ele.activityRoleId == this.selectedActivityRoleId);
        this.selectedActivity = activityOwnershipRecord.Activity__c;
        this.relatedMethodName = activityOwnershipRecord.relatedMethodName;
        this.selectedRole = activityOwnershipRecord.Role__c;
        this.selectedRasicValue = activityOwnershipRecord.selectedRasicValue;
        this.isShowEditModal = true;
    }

    /** this function use for hide modal */
    handleHideModal() {
        this.isShowEditModal = false;
        this.clearSelectedData();
    }

    handleRoleChange(event) {
        this.selectedRole = event.target.value;
    }

    isRequiredValidationPassed() {
        if (!this.selectedActivity) {
            this.showToast('Validation Error', 'Please select Activity', 'error', 'dismissable');
            return false;
        }
        if (!this.selectedRole) {
            this.showToast('Validation Error', 'Please select Role', 'error', 'dismissable');
            return false;
        }
        if (!this.selectedRasicValue) {
            this.showToast('Validation Error', 'Please select RASIC Values', 'error', 'dismissable');
            return false;
        }

        return true;
    }

    isAddRoleValidationPassed() {

        if (this.activityOwnershipData.findIndex(ele => ele.activityRoleId == this.selectedActivity + '-' + this.selectedRole) != -1) {
            this.showToast('Validation Error', 'Activity for selected role is already added. Please select different values.', 'error', 'dismissable');
            return false;
        }

        if (this.IsRasicValuePresent('R') && (this.activityOwnershipData.findIndex(ele => ele.Responsible__c == 'Yes' && ele.Activity__c == this.selectedActivity) != -1)) {
            this.showToast('Validation Error', 'One Activity can only have 1 Responsible RASIC Value', 'error', 'dismissable');
            return false;
        }

        if (this.IsRasicValuePresent('A') && (this.activityOwnershipData.findIndex(ele => ele.Accountable__c == 'Yes' && ele.Activity__c == this.selectedActivity) != -1)) {
            this.showToast('Validation Error', 'One Activity can only have 1 Accountable RASIC Value', 'error', 'dismissable');
            return false;
        }

        return true;
    }

    isEditRoleValidationPassed() {

        let tempOwnershipData = [];

        // excluding the currently selected data from an existing data
        for (let i = 0; i < this.activityOwnershipData.length; i++) {
            let currentRecord = this.activityOwnershipData[i];

            if (currentRecord.activityRoleId != this.selectedActivityRoleId) {
                tempOwnershipData.push(currentRecord);
            }
        }

        if (tempOwnershipData.findIndex(ele => ele.activityRoleId == this.selectedActivity + '-' + this.selectedRole) != -1) {
            this.showToast('Validation Error', 'Activity for selected role is already added. Please select different values.', 'error', 'dismissable');
            return false;
        }

        if (this.IsRasicValuePresent('R') && (tempOwnershipData.findIndex(ele => ele.Responsible__c == 'Yes' && ele.Activity__c == this.selectedActivity) != -1)) {
            this.showToast('Validation Error', 'One Activity can only have 1 Responsible RASIC Value', 'error', 'dismissable');
            return false;
        }

        if (this.IsRasicValuePresent('A') && (tempOwnershipData.findIndex(ele => ele.Accountable__c == 'Yes' && ele.Activity__c == this.selectedActivity) != -1)) {
            this.showToast('Validation Error', 'One Activity can only have 1 Accountable RASIC Value', 'error', 'dismissable');
            return false;
        }

        return true;
    }

    /** this function use for create new Activity */
    async createActivity() {
        const result = await createNewActivity.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
        });
        if (result != undefined) {
            if (result?.hasOwnProperty('id')) {
                this.showToast('Success', 'A new Activity Created', 'success', 'dismissable');
            } else {
                this.showToast('ERROR', 'Something went wrong, contact System administrator', 'error', 'dismissable');
            }
        }
    }


    handleActivityChange(event) {
        this.selectedActivity = event.target.value;
    }

    refreshRoleTableData(currentActivityData) {
        this.roleTableData = [];

        for (let i = 0; i < currentActivityData?.RolesData?.length; i++) {
            let activityRoleId = currentActivityData.RolesData[i];
            let activityOwnerShipRecord = this.activityOwnershipData.find(ele => ele.activityRoleId == activityRoleId);
            if (activityOwnerShipRecord) {
                let roleName = (this.roleRecords.find(ele => ele.Id == activityOwnerShipRecord.Role__c)).Name;
                let rasicValues = [];
                if (activityOwnerShipRecord.Responsible__c == 'Yes') {
                    rasicValues.push('R')
                }
                if (activityOwnerShipRecord.Accountable__c == 'Yes') {
                    rasicValues.push('A')
                }
                if (activityOwnerShipRecord.Support__c == 'Yes') {
                    rasicValues.push('S')
                }
                if (activityOwnerShipRecord.Informed__c == 'Yes') {
                    rasicValues.push('I')
                }
                if (activityOwnerShipRecord.Consulted__c == 'Yes') {
                    rasicValues.push('C')
                }

                this.roleTableData = this.reactivePush(this.roleTableData, { 'activityRoleId': activityOwnerShipRecord.activityRoleId, 'RoleName': roleName, 'RasicValueString': rasicValues.join() });
            }
        }
        this.showRoleData = true;
    }

    /** this function use for get the roles for current edit activity */
    callActivityAction(event) {
        let currentActivityData = event.detail.row;
        this.refreshRoleTableData(currentActivityData);
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

    /** this function use for create new Role */
    async createRole() {
        const result = await createNewRole.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
        });
        if (result != undefined) {
            if (result?.hasOwnProperty('id')) {
                this.showToast('Success', 'A new Role Created', 'success', 'dismissable');
            } else {
                this.showToast('ERROR', 'Something went wrong, contact System administrator', 'error', 'dismissable');
            }
        }
    }


}