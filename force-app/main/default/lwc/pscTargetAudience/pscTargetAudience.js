import { LightningElement,api,track,wire } from 'lwc';
import fetchTargetAudience from '@salesforce/apex/PSCRelatedListController.fetchTargetAudience';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
const ROLE_FAMILY_RELATIONSHIP='Role Family Relationship';
const TAG_RELATIONSHP='Tag Relationship';
const actions = [
    { label: 'Delete', name: 'delete' }
];
const columns = [
    { 
        label: 'Name', fieldName: 'roleName',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
         },
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];
export default class pscTargetAudience extends NavigationMixin(LightningElement) {
    hasRecords;
    flagval=false;
    articleRecordTypeId
    @api recordId;
    @api objectApiName;
    @api sObjectrelationshipName;
    @api recordtypename;
    @api title;
    @api shownewbutton;
    objectFieldName='';
    @api  articledata = [];
    columns = columns;
    targetData = [];
    modalHeader='';
    showRoleFamilty=false;
    showTag=false;

    @wire(getObjectInfo, { objectApiName: 'Article_Tags__c' })
    objectInfo({ error, data }) {
        if (data) {
            const recordTypes = data.recordTypeInfos;
            const recordTypeId = Object.keys(recordTypes).find(
                (key) =>
                    recordTypes[key].name === this.recordtypename
            );

            if (recordTypeId) {
                // Use the recordTypeId as needed
                this.articleRecordTypeId = recordTypeId;
            }
        } else if (error) {
            console.error(error);
        }
    }

    @wire(fetchTargetAudience, { relatedRecordId: '$recordId', relationshipName: '$sObjectrelationshipName',recordtypename: '$recordtypename' })
    fetchTargetAudienceData(result) {
        this.targetData = result;
        if (result.data) {
            this.articledata= [];
            let constctobj;
            if (result.data !== null && result.data !== undefined) {
                this.hasRecords=true;
                result.data.forEach(element =>{
                    if(this.recordtypename==ROLE_FAMILY_RELATIONSHIP){
                    constctobj= {"Name":element.Role_Family__r?.Name ,"roleName":'/' + element?.Role_Family__c, "Id":element.Id};
                }
                else if(this.recordtypename==TAG_RELATIONSHP){
                    constctobj= {"Name":element.Tag__r?.Name ,"roleName":'/' + element?.Tag__c, "Id":element.Id};
                }
                this.articledata.push(constctobj);
                });
            }
        else if (result.error) {
            this.error = result.error;
        }
    }
}

    connectedCallback(){
        this.fetchtabledata();
        if(this.recordtypename==ROLE_FAMILY_RELATIONSHIP){
         this.modalHeader='Add Related Target Audience';
         this.showRoleFamilty=true;
        }
        else if(this.recordtypename==TAG_RELATIONSHP){
            this.modalHeader='Add Related Tag';
            this.showTag=true;
        }
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        if(actionName=='delete'){
            deleteRecord(event.detail.row.Id)
            .then(() => {
                const removearticle =event.detail.row.Id;
                this.articledata = this.articledata.filter(item => item.Id !== removearticle);
                this.fetchtabledata();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }

    }

    handleCreateRecord(){
        if(this.sObjectrelationshipName=='Knowledge__c'){
            this.objectFieldName = 'Knowledge__c'
        }
        if(this.sObjectrelationshipName=='Reusable_Asset__c'){
            this.objectFieldName='Reusable_Asset__c'
        }
        this.openModal();
    }

    openModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
    }

    closeModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.hide();
    }

    handleClick(){
       this.closeModal();
    }

    handleSuccess() {
        this.fetchtabledata();
        this.closeModal();
    }

    fetchtabledata(){
        refreshApex(this.targetData);
    }
}