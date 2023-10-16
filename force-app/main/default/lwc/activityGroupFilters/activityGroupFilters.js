import { LightningElement ,api, wire, track} from 'lwc';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

import EN_ACT_OBJECT from '@salesforce/schema/Enablement_Activity__c';
import PRIORITY_FIELD from '@salesforce/schema/Enablement_Activity__c.Priority__c';
import STATUS_FIELD from '@salesforce/schema/Enablement_Activity__c.Status__c';

import LEARNING_OBJECT from '@salesforce/schema/Enablement_Item__c';
import CATEGORY_FIELD from '@salesforce/schema/Enablement_Item__c.Category__c';
import TYPE_FIELD from '@salesforce/schema/Enablement_Item__c.Type__c';

import getActivitiesList from '@salesforce/apex/ActivityGroupFilterController.getActivitiesList';
import getActivityGroups from '@salesforce/apex/ActivityGroupFilterController.getActivityGroups';
import getAllDomains from '@salesforce/apex/ActivityGroupFilterController.getAllDomains';
import updateActivityStatus from '@salesforce/apex/ActivityGroupFilterController.updateActivityStatus';

import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Enablement_Journey__c.RecordType.DeveloperName'
];

const closedStatuses = ["Completed", "Canceled", "Not Required", "Restricted"];

import { subscribe, publish, MessageContext } from "lightning/messageService";
import ENABLEMENT_CHANNEL from "@salesforce/messageChannel/EnablementAppMessageChannel__c";

import ENABLEMENT_REFRESH_CHANNEL from "@salesforce/messageChannel/EnablementAppRefresh__c";
  
export default class ActivityGroupsTemplate extends LightningElement {

    
    //INITIALIZATION START --------------------------------
    @api recordId;
    @track domainOptions;
    @track groupOptions;
    @track priorityOptions;
    @track categoryOptions;
    @track typeOptions;
    @track statusOptions;
    @track error;
    @track data ;

    @api selectedDomain = '';
    @api selectedActivityGroup = '';
    @api selectedStatus = '';
    @api selectedPriority = '';
    @api selectedCategory = '';
    @api selectedType = '';
    @api daysLeftToComplete = 7;
    @api activityNameSearch = '';
    @api includeClosed = false;

    @api hoursRequired = 0;
    @api hoursSpent = 0;
    @api hoursRemaining = 0 ;

    @api selectedStatusMassUpdate = '';
    @api messageForUpdate = '';

    @api activitySectionTitle = 'Activities';
    @track showLoader = false;
    @track hideTable = false;
    @track isInvalidForUpdate = true;


    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track numberOfRecordsSelected ;

    hasRenderedCallbackExecuted = false;
    isInitialLoad = true;

    //Get the current ENABLEMENT JOURNEY record
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    enJourneyRec;

    //columns for activity table
    @track columns = [
        { label: " Activity Name",   fieldName: "recordURL",  sortable: true, type: "url", typeAttributes: { label: { fieldName: "Name" }, tooltip:{ fieldName: "Name" }, target: "_parent" }, wrapText:true}, 
        { label: 'Activity Status', fieldName: 'Status__c', type: 'text', sortable: true },
        { label: 'Start Date', fieldName: 'Expected_Start_Date__c', sortable: true, type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit" }, wrapText:true},
        { label: 'Due Date', fieldName: 'Expected_Completion_Date__c', sortable: true, type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit" }, wrapText:true},
        { label: 'Hours Left', fieldName: 'Hours_Remaining__c', type: 'number', sortable: true, wrapText:true },
        { label: 'Priority', fieldName: 'Priority__c', type: 'text', sortable: true, wrapText:true }
        
    ]; 

    connectedCallback() {
        this.showLoader = true;
        //this.handleFilterAction();
        this.handleSubscribe();
    }

    renderedCallback() {
        if(this.enJourneyRec.data && this.hasRenderedCallbackExecuted == false) {
            
            if(this.enJourneyRec.data.fields.RecordType.value.fields.DeveloperName.value == 'Template') {
                this.daysLeftToComplete = undefined;   
            }
            else {
                this.daysLeftToComplete = 7;
            }
            this.handleFilterAction();
            this.hasRenderedCallbackExecuted = true;
        }
    }


    //populate DOMAIN options for filter
    @wire(getAllDomains, {enablementId: '$recordId'})
    WiredDomains({ error, data }) {
        if (data) {
            try {
                let options = [{ label: '--All--', value: '' }];
                for (var key in data) {
                    options.push({ label: data[key].Domain_Name__c, value: data[key].Enablement_Domain__c  });
                }
                this.domainOptions = options;
                    
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
    
    }
     
    //populate ACTIVITY GROUP options for filter
    @wire(getActivityGroups, {enablementId: '$recordId'})
    WiredActivityGroups({ error, data }) {
        if (data) {
            try {
                let options = [{ label: '--All--', value: '' }];
                for (var key in data) {
                    options.push({ label: data[key].Name, value: data[key].Id  });
                }
                this.groupOptions = options;
                    
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
    
    }
     

    //Get metadata info for Enablement Activity object
    @wire(getObjectInfo, { objectApiName: EN_ACT_OBJECT })
    activityMetadata;


    //Get STATUS field picklist values
    @wire(getPicklistValues, { recordTypeId: '$activityMetadata.data.defaultRecordTypeId',  fieldApiName: STATUS_FIELD })
    WiredStatusPicklist({ error, data }) {
        if(data) {
            let options = [{ label: '--All--', value: '' }];
            for (var i = 0; i < data.values.length; i++) { 
                options.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.statusOptions = options;
           
        }
    }

    //Get PRIORITY field picklist values
    @wire(getPicklistValues, { recordTypeId: '$activityMetadata.data.defaultRecordTypeId',  fieldApiName: PRIORITY_FIELD })
    WiredPriorityPicklist({ error, data }) {
        if(data) {
            let options = [{ label: '--All--', value: '' }];
            for (var i = 0; i < data.values.length; i++) { 
                options.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.priorityOptions = options;
           
        }
    }

    //Get metadata info for LEARNING object
    @wire(getObjectInfo, { objectApiName: LEARNING_OBJECT })
    learningMetadata;


    //Get CATEGORY field picklist values
    @wire(getPicklistValues, { recordTypeId: '$learningMetadata.data.defaultRecordTypeId',  fieldApiName: CATEGORY_FIELD })
    WiredCategoryPicklist({ error, data }) {
        if(data) {
            let options = [{ label: '--All--', value: '' }];
            for (var i = 0; i < data.values.length; i++) { 
                options.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.categoryOptions = options;
            
        }
    }

    //Get TYPE field picklist values
    @wire(getPicklistValues, { recordTypeId: '$learningMetadata.data.defaultRecordTypeId',  fieldApiName: TYPE_FIELD })
    WiredTypePicklist({ error, data }) {
        if(data) {
            let options = [{ label: '--All--', value: '' }];
            for (var i = 0; i < data.values.length; i++) { 
                options.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.typeOptions = options;
            
        }
    }


    //INITIALIZATION END --------------------------------


    handleChangeDomain(event) {
        this.selectedDomain = event.detail.value;        
    }

    handleChangeGroup(event) {
        this.selectedActivityGroup = event.detail.value;
    }

    handleChangeStatus(event) {
        this.selectedStatus = event.detail.value;
        let el = this.template.querySelector('[data-id="includeClosedInput"]');
        var includeClosedValue = closedStatuses.includes(this.selectedStatus);
        el.checked = includeClosedValue;
        this.includeClosed = includeClosedValue;
        if(this.selectedStatus != '') {
            el.disabled = true;
        } else {
            el.disabled = false;
        }
        
    }

    handleChangeCategory(event) {
        this.selectedCategory = event.detail.value;
    }

    handleChangeType(event) {
        this.selectedType = event.detail.value;
    }

    handleChangePriority(event) {
        this.selectedPriority = event.detail.value;
    }

    handleChangeStatusMassUpdate(event) {
        this.selectedStatusMassUpdate = event.detail.value;
    }
    
    changeToggle(event){
        this.includeClosed = event.target.checked;
        if(this.template.querySelector('[data-id="includeClosedInput"]').disabled == false)
            this.handleFilterAction();
    }

    handleClearFilter(){
        this.selectedDomain = ''; 
        //if event received, do not clear activityGroup
        if(!this.messageReceived) {
            this.selectedActivityGroup = '';
        } 
        this.messageReceived = false;

        this.selectedStatus = ''; 
        this.selectedCategory = '';  
        this.selectedPriority = '';
        this.selectedType = '';
        this.daysLeftToComplete = undefined;
        this.template.querySelector('[data-id="daysLeftInput"]').value = undefined;

        this.activityNameSearch = '';
        this.template.querySelector('[data-id="nameSearchInput"]').value = '';

        this.template.querySelector('[data-id="includeClosedInput"]').checked = false;
        this.template.querySelector('[data-id="includeClosedInput"]').disabled = false;

        this.handleFilterAction();
    }

    handleFilterAction() {
        this.showLoader = true;
        
        this.populateDaysLeft();

        getActivitiesList({
            enablementId: this.recordId, 
            domainId: this.selectedDomain, 
            activityGroupId: this.selectedActivityGroup, 
            status: this.selectedStatus, 
            category: this.selectedCategory,
            type: this.selectedType,
            priority: this.selectedPriority,
            dateFilter: this.daysLeftToComplete,
            nameFilter: this.activityNameSearch,
            includeClosed: this.includeClosed
        }).then((data) => {
            this.processActivityData(data);
        }).catch((error) => {
            this.error = error;
            console.log(JSON.stringify(error));
            this.showLoader = false;
        });
    }


    populateDaysLeft(){
        var inp1 = this.template.querySelector('[data-id="daysLeftInput"]');
        if(inp1 && this.isInitialLoad == false) {
            if(inp1.value == ''){
                this.daysLeftToComplete = undefined;
            } else {
                this.daysLeftToComplete = inp1.value;
                //disable the Include Closed checkbox is days left are populated
                this.template.querySelector('[data-id="includeClosedInput"]').checked = false;
                this.template.querySelector('[data-id="includeClosedInput"]').disabled = false;
            }
        }

        var inp2 = this.template.querySelector('[data-id="nameSearchInput"]');
        if(inp2) {
            this.activityNameSearch = inp2.value;
        }
        this.isInitialLoad = false;
    }

    invokeActivityStatusUpdate() {        
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.numberOfRecordsSelected = selectedRows.length;
        //validate and then open modal
        if(selectedRows.length > 0 && this.selectedStatusMassUpdate != '' && this.selectedStatusMassUpdate != undefined ) {
            this.isInvalidForUpdate = false;
            this.messageForUpdate = 'You are about to update the status of '+ selectedRows.length +' activity record(s). Do you want to proceed?';
            
            this.openModal();
        }
        else {
            this.isInvalidForUpdate = true;
            this.messageForUpdate = 'Please make sure you have selected the activity records and a status to be updated.';
            
            this.openModal();
        }
        
    }


    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    submitDetails() {
        this.showLoader = true;
        let selectedRowIds= [];
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        for(var i = 0; i < selectedRows.length; i++) {
            console.log("selectedRows[i].Id"+selectedRows[i].Id);
            selectedRowIds.push(selectedRows[i].Id);
            var indexOfStevie = this.data.findIndex(j => j.id == selectedRows[i].id);
            console.log('>>>Indexxx.. '+JSON.stringify(this.data.splice(indexOfStevie,1)));
            this.data = this.data.splice(indexOfStevie,1);
        }

        this.populateDaysLeft();

        updateActivityStatus({
            activityIds: selectedRowIds, 
            statusToBeUpdated: this.selectedStatusMassUpdate,
            enablementId: this.recordId, 
            domainId: this.selectedDomain, 
            activityGroupId: this.selectedActivityGroup, 
            status: this.selectedStatus, 
            category: this.selectedCategory,  
            type: this.selectedType,
            priority: this.selectedPriority,
            dateFilter: this.daysLeftToComplete,
            nameFilter: this.activityNameSearch,
            includeClosed: this.includeClosed
         }).then(data => {
            this.processActivityData(data);
            //publish a message on messaging channel so other components (specially activity groups) can refresh
            const message = { data: 'refresh_event' };
            publish(this.messageContext, ENABLEMENT_REFRESH_CHANNEL, message); 
            this.selectedStatusMassUpdate = '';
            this.isModalOpen = false;
                
        }).catch(error => {
                console.log('Error: ', JSON.stringify(error));
                this.showLoader = false;
        }) 
        
    }


    processActivityData(data) {
        this.hoursRequired = 0;
        this.hoursSpent = 0;
        this.hoursRemaining = 0;

        if(data.length > 0){
            this.hideTable = false;
            this.data = [];  
            for (var i = 0; i < data.length; i++) {  
                let tempRecord = Object.assign({}, data[i]); //cloning object  
                tempRecord.recordURL = "/" + tempRecord.Id;  
                this.data.push(tempRecord);  
                if(tempRecord.Status__c != 'Not Required' && tempRecord.Status__c != 'Restricted') {
                    //populate summary fields
                    if(!isNaN(tempRecord.Hours_Required__c)) {
                        this.hoursRequired += tempRecord.Hours_Required__c;
                    }
                    if(!isNaN(tempRecord.Actual_Hours_Spent__c)) {
                        this.hoursSpent += tempRecord.Actual_Hours_Spent__c;
                    }
                    if(!isNaN(tempRecord.Hours_Remaining__c)) {
                        this.hoursRemaining += tempRecord.Hours_Remaining__c;
                    }
                }
            }   
        } else{
            this.hideTable = true;
        }

        this.activitySectionTitle = 'Activities ('+ data.length +')'
        this.showLoader = false;
    }


    //EVENT HANDLING START ----------------------
    
    @wire(MessageContext)
    messageContext;
    
    subscription = null;
    messageReceived = false;
    
    handleSubscribe() {
        if (this.subscription) {
            return;
        }
  
        this.subscription = subscribe( this.messageContext, ENABLEMENT_CHANNEL,
            (message) => {
                this.handleMessage(message);
            }
        );
    }
  
    handleMessage(message) {
        console.log('msg='+JSON.stringify(message));
        this.selectedActivityGroup = message.data;
        this.messageReceived = true;
        this.handleClearFilter();
    }
  
    //EVENT HANDLING END ----------------------


    //DATATABLE SORTING START ----------------------

    @track sortBy;
    @track sortDirection;

    handleSortActivityData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortActivityData(event.detail.fieldName, event.detail.sortDirection);
    }


    sortActivityData(fieldname, direction) {
        
        let parseData = JSON.parse(JSON.stringify(this.data));
       
        let keyValue = (a) => {
            return a[fieldname];
        };


       let isReverse = direction === 'asc' ? 1: -1;


           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        this.data = parseData;

    }

    //DATATABLE SORTING END ----------------------

}