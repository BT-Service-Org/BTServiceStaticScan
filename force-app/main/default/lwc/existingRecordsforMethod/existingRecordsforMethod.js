import { LightningElement,track, wire, api } from 'lwc';
import getRecordsList from '@salesforce/apex/ExistingMethodRelatedRecords.getRecordsList';
import deleteSelectedRecord from '@salesforce/apex/ExistingMethodRelatedRecords.deleteSelectedRecord';
import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
const actions = [
    { label: 'Delete', name: 'delete' },
];
const columnsArtifact=[
    {label: 'Artefact Description', fieldName: 'Method_Version_Description__c'},{label: 'Artefact Link', fieldName: 'Link__c'},
    {label: 'Artefact Type', fieldName: 'Type__c'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },   
];
const columnsDeliverable=[
        {label: 'Role', fieldName: 'Role__c'},{label: 'Deliverable', fieldName: 'Deliverable__c'},
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        },   
];
const columnsDocument=[
    {label: 'Title', fieldName: 'Title'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },   
];
export default class ExistingRecordsforMethod extends LightningElement {
    @api methodRecordId; 
    @api objApiName;
    @api deleteDeliverables = '';
    @api defaultDeliverables = '';
    @api deleteFies = '';
    @api defaultFiles = '';
    @api deleteTemplates = '';
    @api defaultTemplates = '';
    @track error;
    @track tempList;
    @track columns;
    @track actions = actions;
    @track showLoadingSpinner = false;
    @track hasTableData ;
    existingDeliverables = [];
    existingTemplates = [];
    existingFiles = [];

    connectedCallback(){
        if(this.deleteDeliverables =='' && this.objApiName =='Method_by_Deliverables__c'){
            var remainingDeliverables = sessionStorage.getItem('remainingDeliverables')
            if( remainingDeliverables !== undefined || remainingDeliverables !== null) sessionStorage.removeItem('remainingDeliverables');
        }
        if(this.deleteTemplates =='' && this.objApiName =='Templates__c'){
            var remainingTemplates = sessionStorage.getItem('remainingTemplates');
            if(remainingTemplates !== undefined || remainingTemplates !== null) sessionStorage.removeItem('remainingTemplates');
        }
        if(this.deleteFies =='' && this.objApiName =='ContentDocumentLink'){
            var remainingFiles = sessionStorage.getItem('remainingFiles');
            if(remainingFiles !== undefined || remainingFiles !== null) sessionStorage.removeItem('remainingFiles');
        }
    }

    @wire (getRecordsList, {recordId: '$methodRecordId', objectApiName: '$objApiName'}) 
    wiredList(result) {
        this.hasTableData = false;
        this.columns=[];
        this.refreshTable=result;
        if(result.data)
        {
            if(this.objApiName == 'Templates__c') {
                this.tempList=[];
                if(sessionStorage.getItem('remainingTemplates')){
                    var templates = JSON.parse(sessionStorage.getItem('remainingTemplates'));
                    this.tempList = templates !== null ? templates : [];
                    if(this.tempList.length > 0){
                        this.hasTableData = true; 
                        this.columns = columnsArtifact;
                    }
                }
                else if(result?.data?.length>0){
                    this.hasTableData = true; 
                    this.columns = columnsArtifact;
                    this.tempList=result?.data;
                }
                
                /**This is a buffer data that will be used to send remaining ids to the flow (after delete opration)*/
                if (this.tempList.length > 0) {
                    this.existingTemplates = [...this.tempList];
                    for (var index = 0; index < this.existingTemplates?.length; index++) this.defaultTemplates += this.existingTemplates[index]?.Id + ',';
                }
            }
            else if(this.objApiName == 'Method_by_Deliverables__c') {
                let allRecs = result.data;
                let tempArr=[];
                this.tempList=[];
                for(let i=0; i<allRecs.length; i++) {
                    const singleRec = {};
                    singleRec.Id = allRecs[i].Id;
                    singleRec.Deliverable__c = allRecs[i].Deliverable__r?.Name;
                    singleRec.Role__c = allRecs[i].Role__r?.Name;
                    singleRec.ObjectName = 'Method_by_Deliverables__c';
                    tempArr.push(singleRec);
                }
                if(sessionStorage.getItem('remainingDeliverables')){
                    var deliverables = JSON.parse(sessionStorage.getItem('remainingDeliverables'));
                    this.tempList = deliverables !== null ? deliverables : [];
                    if(this.tempList.length > 0){
                        this.hasTableData = true; 
                        this.columns = columnsDeliverable;
                    }
                }
                 else if(tempArr.length>0){
                    this.hasTableData = true; 
                    this.columns = columnsDeliverable;
                    this.tempList.push(...tempArr);
                }
                /**This is a buffer data that will be used to send remaining ids to the flow (after delete opration)*/
                if (this.tempList.length > 0) {
                    this.existingDeliverables = [...this.tempList];
                    for (var index = 0; index < this.existingDeliverables?.length; index++) this.defaultDeliverables += this.existingDeliverables[index]?.Id + ',';
                }
            }
            else if(this.objApiName == 'ContentDocumentLink') {
                let allRecs = result.data;
                let tempArr=[];
                this.tempList=[];
                for(let i=0; i<allRecs.length; i++) {
                    const singleRec = {};
                    singleRec.Id = allRecs[i].Id;
                    singleRec.Title = allRecs[i].ContentDocument.Title;
                    singleRec.ObjectName = 'ContentDocumentLink';
                    tempArr.push(singleRec);
                }
                if(sessionStorage.getItem('remainingFiles')){
                    var files = JSON.parse(sessionStorage.getItem('remainingFiles'));
                    this.tempList = files !== null ? files : [];
                    if(this.tempList.length > 0){
                        this.hasTableData = true; 
                        this.columns = columnsDocument;
                    }
                }
                else if(tempArr.length>0){
                    this.hasTableData = true; 
                    this.columns = columnsDocument;
                    this.tempList.push(...tempArr);
                }
                /**This is a buffer data that will be used to send remaining ids to the flow (after delete opration)*/
                if (this.tempList.length > 0) {
                    this.existingFiles = [...this.tempList];
                    for (var index = 0; index < this.existingFiles?.length; index++) this.defaultFiles += this.existingFiles[index]?.Id + ',';
                }
            }
        }
        else if(result.error)
        {
            this.error = result.error;
        }
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                if (row?.ObjectName === 'Method_by_Deliverables__c') {
                    this.deleteDeliverables += row?.Id + ',';
                    /**This is to delete the Id that is deleted from the UI. */
                    this.existingDeliverables = this.existingDeliverables.filter(record => record?.Id !== row?.Id);
                    this.defaultDeliverables = '';
                    for (var index = 0; index < this.existingDeliverables?.length; index++) this.defaultDeliverables += this.existingDeliverables[index]?.Id + ',';
                }else if (row?.ObjectName === 'ContentDocumentLink') {
                    this.deleteFies += row?.Id + ',';
                    /**This is to delete the Id that is deleted from the UI. */
                    this.existingFiles = this.existingFiles.filter(record => record?.Id !== row?.Id);
                    this.defaultFiles = '';
                    for (var index = 0; index < this.existingFiles?.length; index++) this.defaultFiles += this.existingFiles[index]?.Id + ',';
                }else if (this.objApiName === 'Templates__c') {
                    this.deleteTemplates += row?.Id + ',';
                    /**This is to delete the Id that is deleted from the UI. */
                    this.existingTemplates = this.existingTemplates.filter(record => record?.Id !== row?.Id);
                    this.defaultTemplates = '';
                    for (var index = 0; index < this.existingTemplates?.length; index++) this.defaultTemplates += this.existingTemplates[index]?.Id + ',';
                }
                let tempArr=[...this.tempList];
                this.tempList = [];
                for(var i=0; i<tempArr?.length; i++) {
                    if (tempArr[i]?.Id == row?.Id) tempArr.splice(i, 1);
                }
                this.tempList.push(...tempArr);
                if(row?.ObjectName === 'Method_by_Deliverables__c')
                  sessionStorage.setItem('remainingDeliverables', JSON.stringify(this.tempList));

                if(row?.ObjectName ==='ContentDocumentLink')  
                  sessionStorage.setItem('remainingFiles', JSON.stringify(this.tempList));
                  
                if(this.objApiName === 'Templates__c')
                  sessionStorage.setItem('remainingTemplates', JSON.stringify(this.tempList));
                
                if (this.tempList.length == 0) this.hasTableData = false; 
                //this.handleDeleteRow(row.Id);
                break;
        }
    }
    
    /**~OBSOLATE (Note: We are not doing any DML(delete) from this component, instead we are passing the Ids into flow and do rest there!) */
    handleDeleteRow(recordIdToDelete) {
        this.showLoadingSpinner = true;
        deleteSelectedRecord({deleteIdRecord: recordIdToDelete, objectApiName: this.objApiName})
        .then(result =>{
            this.showLoadingSpinner = false;
            const evt = new ShowToastEvent({
                title: 'Success Message',
                message: 'Record deleted successfully ',
                variant: 'success',
                mode:'dismissible'
            });
            this.dispatchEvent(evt);
            refreshApex(this.refreshTable);
            eval("$A.get('e.force:refreshView').fire();");
        } )
        .catch(error => {
            this.showLoadingSpinner = false;
            //this.error = error;
            console.log('Error is',JSON.stringify(error));
            if(error.body.pageErrors[0].statusCode == 'FIELD_CUSTOM_VALIDATION_EXCEPTION') {
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'You can not Delete record since the Method is published. Please Add new records as required.',
                    variant: 'info',
                    mode:'dismissible'
                });
                this.dispatchEvent(evt);
            }
        });
    }

}