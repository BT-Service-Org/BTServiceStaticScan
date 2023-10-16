import { LightningElement ,api, wire, track} from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

import EN_ACT_OBJECT from '@salesforce/schema/Enablement_Activity__c';
import PRIORITY_FIELD from '@salesforce/schema/Enablement_Activity__c.Priority__c';
import LEARNING_OBJECT from '@salesforce/schema/Enablement_Item__c';
import CATEGORY_FIELD from '@salesforce/schema/Enablement_Item__c.Category__c';

import { updateRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STARTDAYS_FIELD from '@salesforce/schema/Enablement_Activity__c.Days_Until_Start__c';
import DURATION_FIELD from '@salesforce/schema/Enablement_Activity__c.Days_To_Complete__c';
import PUBLISH_FIELD from '@salesforce/schema/Enablement_Activity__c.Publish__c';

import ID_FIELD from '@salesforce/schema/Enablement_Activity__c.Id';

import getEnablementItemsList from '@salesforce/apex/ActivityGroupTemplateFiltersController.getEnablementItemsList';
import getActivityGroups from '@salesforce/apex/ActivityGroupTemplateFiltersController.getActivityGroups';
import getAllTemplates from '@salesforce/apex/ActivityGroupTemplateFiltersController.getAllTemplates';
import addActivities from '@salesforce/apex/ActivityGroupTemplateFiltersController.addActivities';
import removeActivities from '@salesforce/apex/ActivityGroupTemplateFiltersController.removeActivities';
import getAllDomains from '@salesforce/apex/ActivityGroupTemplateFiltersController.getAllDomains';


import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [ 'Enablement_Journey__c.RecordType.DeveloperName' ];

export default class ActivityGroupTemplateFilters extends LightningElement {
    
    //INITIALIZATION START --------------------------------
    @api recordId;
    @track templateOptions;
    @track groupOptions;
    @track domainOptions;
    @track priorityOptions;
    @track categoryOptions;
    @track error;
    @track data ;
    draftValues = [];

    @api selectedShowOption = 'group';
    @api selectedDomain = '';
    @api selectedTemplate = '';
    @api selectedJourney = '';
    @api selectedEnablementJourney = '';
    @api selectedActivityGroup = '';
    @api selectedPriority = '';
    @api selectedCategory = '';
    @api activityNameSearch = '';

    @api modalHeader = '';
    @api messageForUpdate = '';
    @api buttonLabel = 'Update';

    @api activitySectionTitle = 'Activities (0)';
    @track showLoader = false;
    @track hideTable = true;
    @track actGroupDisabled = true;
    @track allFiltersDisabled = false;
    @track isInvalidForUpdate = true;


    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track isAddAction = false;
    @track numberOfRecordsSelected ;

    //Get the current ENABLEMENT JOURNEY record
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    enJourneyRec;

    //columns for activity table
    @track columns = [
        { label: " Activity Name",   fieldName: "recordURL",  sortable: true, type: "url", typeAttributes: { label: { fieldName: "enablementItemName" }, tooltip:{ fieldName: "enablementItemName" }, target: "_parent" }, wrapText:true}, 
        { label: 'Activity Status', fieldName: 'enablementItemStatus', type: 'text', sortable: true, wrapText:true},
        { label: 'Start Days', fieldName: 'enablementItemStartDays', type: "number", sortable: true, wrapText:true},
        { label: 'Duration', fieldName: 'enablementItemDuration', type: 'number', sortable: true, wrapText:true },
        { label: 'Domain', fieldName: 'enablementItemDomain', type: 'text', sortable: true, wrapText:true },
        { label: 'Activity Group', fieldName: 'enablementItemActivityGroup', type: 'text', sortable: true, wrapText:true }
    ];
    
    //columns for activity table WITH inline edit enabled
    @track columnsEditable = [
        { label: " Activity Name",   fieldName: "recordURL",  sortable: true, type: "url", typeAttributes: { label: { fieldName: "enablementItemName" }, tooltip:{ fieldName: "enablementItemName" }, target: "_parent" }, wrapText:true}, 
        { label: 'Activity Status', fieldName: 'enablementItemStatus', type: 'text', sortable: true, wrapText:true},
        { label: 'Start Days', fieldName: 'enablementItemStartDays', type: "number", sortable: true, editable:true, wrapText:true },
        { label: 'Duration', fieldName: 'enablementItemDuration', type: 'number', sortable: true, editable:true, wrapText:true },
        { label: 'Publish', fieldName: 'publish', type: 'boolean', sortable: true, editable:true, wrapText:true },
        { label: 'Domain', fieldName: 'enablementItemDomain', type: 'text', sortable: true, wrapText:true },
        { label: 'Activity Group', fieldName: 'enablementItemActivityGroup', type: 'text', sortable: true, wrapText:true }
    ];

    connectedCallback() {
        //this.showLoader = true;
        //this.handleFilterAction();
        this.filterThisGroup();
        //this.handleSubscribe();

    }

    //Populate SHOW options 
    @api
    get showOptions() {
        let options = [
            { label: 'All Activities', value: 'all' },
            { label: 'Activities in this group', value: 'group' },
            { label: 'Activities not in this group', value: 'notgroup' },
            { label: 'Activities not in this journey', value: 'notjourney' }
        ];

        return options;
    }

    //populate TEMPLATE options for filter
    @wire(getAllTemplates)
    WiredTemplates({ error, data }) {
        if (data) {
            try {
                let options = [{ label: '--None--', value: '' }];
                for (var key in data) {
                    options.push({ label: data[key].Name, value: data[key].Id  });
                }
                this.templateOptions = options;
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

    //populate DOMAIN options for filter
    @wire(getAllDomains, {actGroupId: '$recordId'})
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

    //INITIALIZATION END --------------------------------

    handleChangeTemplate(event) {
         
        if(event.target.name =='templateFilter') {
            this.selectedTemplate = String(event.detail.value);
            this.selectedEnablementJourney = String(event.detail.value);
            this.selectedJourney = '';
        } else {
            this.selectedJourney = String(event.detail.value);
            this.selectedEnablementJourney = String(event.detail.value);
            this.selectedTemplate = '';
        }
        
        getActivityGroups({
            enablementId: this.selectedEnablementJourney
        }).then((data) => {
            if(data && data.length > 0) {
                let options = [{ label: '--All--', value: '' }];
                for (var key in data) {
                    options.push({ label: data[key].Name, value: data[key].Id  });
                }
                this.groupOptions = options;
                this.actGroupDisabled = false;
                
            } else {
                let options = [{ label: '--None--', value: '' }];
                this.groupOptions = options;
                this.actGroupDisabled = true;
                this.selectedTemplate = '';
                this.selectedJourney = '';
                this.selectedEnablementJourney = '';
            }
        }).catch((error) => {
            this.error = error;
            console.log('Error: '+JSON.stringify(error));
        });      
    }

    handleChangeShowOptions(event) {
        this.selectedShowOption = event.detail.value;
        this.filterThisGroup();
    }

    handleChangeGroup(event) {
        this.selectedActivityGroup = event.detail.value;
    }

    handleChangeDomain(event) {
        this.selectedDomain = event.detail.value;        
    }

    handleChangeCategory(event) {
        this.selectedCategory = event.detail.value;
    }

    handleChangePriority(event) {
        this.selectedPriority = event.detail.value;
    }


    handleClearFilter(){
        this.selectedTemplate = ''; 
        this.selectedJourney = '';
        this.selectedEnablementJourney = '';

        this.selectedActivityGroup = '';
        this.groupOptions = [{ label: '--None--', value: '' }];
        this.actGroupDisabled = true;

        this.selectedDomain = ''; 
        this.selectedCategory = '';  
        this.selectedPriority = '';

        this.activityNameSearch = '';
        this.hideTable = true;
        this.data = [];
        this.activitySectionTitle = 'Activities (0)'
        //this.handleFilterAction();
    }

    handleFilterAction() {
        this.showLoader = true;
        
        getEnablementItemsList({
            actGroupId: this.recordId, 
            templateId: this.selectedEnablementJourney, 
            activityGroupId: this.selectedActivityGroup, 
            domainId: this.selectedDomain,
            category: this.selectedCategory,  
            priority: this.selectedPriority,
            selectedShowOption: this.selectedShowOption
        }).then((data) => {
            this.processActivityData(data);
        }).catch((error) => {
            this.error = error;
            console.log(JSON.stringify(error));
            this.showLoader = false;
        });
    }


    addActivitiesToTheGroup() {        
        this.isAddAction = true;
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.numberOfRecordsSelected = selectedRows.length;
        this.modalHeader = 'Add Enablement Activities';
        this.buttonLabel = 'Add Activities';
        //validate and then open modal
        if(selectedRows.length > 0 ) {
            this.isInvalidForUpdate = false;
            this.messageForUpdate = 'You are about to add/move '+ selectedRows.length +' activity record(s) to this group. ';
            let itemsAlreadyAssociated = false;
            let countOfInvalidActivities = 0;
            //validate selections
            for(var i = 0; i < selectedRows.length; i++) {
                console.log('==='+JSON.stringify(selectedRows[i]));
                //if the selected activities are already present in other groups
                if(selectedRows[i].enablementItemActivityGroup != null) {
                    itemsAlreadyAssociated = true;
                }
                //if the selected activities' domains are not associated
                if(selectedRows[i].enablementItemDomain == null) {
                    this.isInvalidForUpdate = true;
                    countOfInvalidActivities++;
                }
            }
            
            if(itemsAlreadyAssociated) {
                this.messageForUpdate += 'Activities assigned to other groups in this journey will be moved. ';
            } 
            this.messageForUpdate += 'Would you like to proceed?';
            //if domains are not associated, override the message
            if(this.isInvalidForUpdate) {
                this.messageForUpdate = 'You are attempting to add '+countOfInvalidActivities+' activity record(s) belonging to a Domain not associated to this journey. Please add the Domain prior to adding the activity.';
            }

            this.openModal();
        }
        else {
            this.isInvalidForUpdate = true;
            this.messageForUpdate = 'Please make sure you have selected the activity records.';
            
            this.openModal();
        }
        
    }

    removeActivitiesFromTheGroup() {   
        this.isAddAction = false;     
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.numberOfRecordsSelected = selectedRows.length;
        this.modalHeader = 'Remove Enablement Activities';
        this.buttonLabel = 'Remove Activities';
        //validate and then open modal
        if(selectedRows.length > 0 ) {
            this.isInvalidForUpdate = false;
            this.messageForUpdate = 'You are about to remove '+ selectedRows.length +' activity record(s) from this group. Would you like to proceed?';
            
            this.openModal();
        }
        else {
            this.isInvalidForUpdate = true;
            this.messageForUpdate = 'Please make sure you have selected the activity records.';
            
            this.openModal();
        }
        
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.showLoader = false;
    }

    submitDetails() {
        this.showLoader = true;
        let selectedRowIds= [];
        let selectedRowItems = [];
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        for(var i = 0; i < selectedRows.length; i++) {            
            selectedRowItems.push(JSON.stringify(selectedRows[i]));
            selectedRowIds.push(selectedRows[i].Id);
        }
        if(this.isAddAction) {
            this.invokeAddActivities( selectedRowItems);
        } else {
            this.invokeRemoveActivities(selectedRowIds);
        }
    }

    invokeAddActivities( selectedRowItems) {
        addActivities({
            enablementGroupId: this.recordId,
            selectedItems: selectedRowItems
        }).then((data) => {
            if(data) {
                this.handleFilterAction();
                this.closeModal();
            }
        }).catch((error) => {
            this.error = error;
            console.log(JSON.stringify(error));
            this.showLoader = false;
        });
    }

    invokeRemoveActivities(selectedRowIds) {
        removeActivities({
            enablementGroupId: this.recordId,
            enablementItemIds: selectedRowIds
        }).then((data) => {
            if(data) {
                this.handleFilterAction();
                this.closeModal();
            }
        }).catch((error) => {
            this.error = error;
            console.log(JSON.stringify(error));
            this.showLoader = false;
        });
    }

    processActivityData(data) {
        if(data.length > 0){
            this.hideTable = false;
            this.data = [];  
            for (var i = 0; i < data.length; i++) {  
                let tempRecord = Object.assign({}, data[i]); //cloning object  
                tempRecord.recordURL = "/" + tempRecord.Id;  
                this.data.push(tempRecord);  

            }   
        } else{
            this.hideTable = true;
        }

        this.activitySectionTitle = 'Activities ('+ data.length +')'
        this.showLoader = false;
    }

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

    filterThisGroup() {
        if(this.selectedShowOption == 'group') {
            this.actGroupDisabled = true;
            this.allFiltersDisabled = true;
            this.handleFilterAction();
        } else {
            this.allFiltersDisabled = false;
            this.handleClearFilter();
            
        }
    }


    handleSaveAction(event) {
        console.log('test=='+ JSON.stringify(event.detail.draftValues));
        this.showLoader = true;

        let fields;
        let recordInput;
        let recordInputs = [];

        for(var i = 0; i < event.detail.draftValues.length; i++) {
            fields = {}; 
            fields[ID_FIELD.fieldApiName] = event.detail.draftValues[i].Id;
            fields[STARTDAYS_FIELD.fieldApiName] = event.detail.draftValues[i].enablementItemStartDays;
            fields[DURATION_FIELD.fieldApiName] = event.detail.draftValues[i].enablementItemDuration;
            fields[PUBLISH_FIELD.fieldApiName] = event.detail.draftValues[i].publish;

            recordInput = {fields};
            recordInputs.push(recordInput);
        }

        console.log('recordInputs='+JSON.stringify(recordInputs));

        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then((result) => {
            console.log('result'+JSON.stringify(result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Activities successfully updated.',
                    variant: 'success'
                })
            );
            // Clear all draft values
            this.draftValues = [];

            // Display fresh data in the datatable
            this.handleFilterAction();
        }).catch(error => {
            // Handle error
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'ERROR: Activities not updated.',
                    variant: 'error'
                })
            );
        });

    }
}