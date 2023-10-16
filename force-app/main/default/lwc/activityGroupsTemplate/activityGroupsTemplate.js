import { LightningElement,wire,track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getActivityGroups from "@salesforce/apex/ActivityGroupsTemplateController.getActivityGroups";

import { updateRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STARTDAYS_FIELD from '@salesforce/schema/Enablement_Activity_Group__c.Days_Until_Start__c';
import DURATION_FIELD from '@salesforce/schema/Enablement_Activity_Group__c.Days_To_Complete__c';
import ORDER_FIELD from '@salesforce/schema/Enablement_Activity_Group__c.Order__c';

import ID_FIELD from '@salesforce/schema/Enablement_Activity_Group__c.Id';

const columns = [
    
    {label: 'Name', fieldName: 'nameUrl', sortable: true, type: 'url', 
        typeAttributes: { label: { fieldName: 'name' }, tooltip:{ fieldName: 'name' }, target: '_parent' }
        , wrapText:true},
    { label: 'Start Days', fieldName: 'startDays', sortable: true , type: 'Integer', editable: true, initialWidth: 120, wrapText:true }, 
    { label: 'Duration', fieldName: 'duration', sortable: true , type: 'Integer', editable: true, initialWidth: 120, wrapText:true },
    { label: 'Order', fieldName: 'order', sortable: true , type: 'Integer', editable: true, initialWidth: 120, wrapText:true }
    
];


export default class ActivityGroupsTemplate extends NavigationMixin(LightningElement){
    @api recordId;
    @track dataTableInput = [];
    @track columns = columns;
    @track flagIndicatingDataHasBeenLoadedInVariables = false;
    @track totalCount; 
    @track draftValues = [];
    @track viewAll = false;
    @track showViewLinks = true;

    @track activityGroupArray = [];
    @track sectionHeader = 'Activity Groups';
    @track showLoader = false;
    @api maxNumberOfRecords = 8;

    connectedCallback() {
        this.initializeActivityGroupsList();
    }

    initializeActivityGroupsList(){

        this.showLoader = true;

        getActivityGroups({actGroupId: this.recordId})
        .then((data) => {
            console.log('data='+ JSON.stringify(data));
            if(data) {
                //this is the final array into which the flattened response will be pushed. 
                this.activityGroupArray = [];
                let letTotalCount = 0;    
                for (let row of data) {
                        // this const stroes a single flattened row. 
                        const flattenedRow = {}
                        // get keys of a single row — Name, Phone, LeadSource and etc
                        let rowKeys = Object.keys(row); 
                    
                        //iterate 
                        rowKeys.forEach((rowKey) => {
                            
                            //get the value of each key of a single row. John, 999-999-999, Web and etc
                            const singleNodeValue = row[rowKey];
                            //check if the value is a node(object) or a string
                            if(singleNodeValue.constructor === Object){
                                //if it's an object flatten it
                                this._flatten(singleNodeValue, flattenedRow, rowKey)        
                            }else{
                                //if it’s a normal string push it to the flattenedRow array
                                flattenedRow[rowKey] = singleNodeValue;
                            }
                            
                        });
                    
                        //push all the flattened rows to the final array 
                        this.activityGroupArray.push(flattenedRow);
                }
                    
                //assign the array to an array that's used in the template file
                if(this.activityGroupArray.length > this.maxNumberOfRecords) {
                    this.handleViewLess();
                }
                else{
                    this.handleViewAll();
                    this.showViewLinks = false;
                }
                //assign totalcount
                letTotalCount = this.activityGroupArray.length;
                this.totalCount = letTotalCount;
                this.flagIndicatingDataHasBeenLoadedInVariables = true;
                this.sectionHeader = 'Activity Groups ('+ this.activityGroupArray.length + ')';

            }
            this.showLoader = false;
        }).catch((error) => {
            this.error = error;
            console.log('Error: '+JSON.stringify(error));
            this.showLoader = false;
        });
    }


    _flatten = (nodeValue, flattenedRow, nodeName) => {        
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }

    handleViewAll() {
        this.viewAll = true;
        this.dataTableInput = this.activityGroupArray;
        
    }

    handleViewLess() {
        this.viewAll = false;
        this.dataTableInput = this.activityGroupArray.slice(0, this.maxNumberOfRecords);
    }



    //DATATABLE SORTING START ----------------------

    @track sortBy;
    @track sortDirection;

    handleSortActivityGroupData(event) {    
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortActivityGroupData(event.detail.fieldName, event.detail.sortDirection);
    }


    sortActivityGroupData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataTableInput));
        console.log('parseData='+JSON.stringify(parseData));
        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;

            parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            
            return isReverse * ((x > y) - (y > x));
        });
        
        this.dataTableInput = parseData;

    }

    //DATATABLE SORTING END ----------------------


    navigateToNewActivityGroup() {
        const defaultValues = encodeDefaultFieldValues({
            Enablement_Journey__c: this.recordId
        });

        console.log(defaultValues);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Enablement_Activity_Group__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    handleSaveAction(event) {
        console.log('test=='+ JSON.stringify(event.detail.draftValues));

        let fields;
        let recordInput;
        let recordInputs = [];

        for(var i = 0; i < event.detail.draftValues.length; i++) {
            fields = {}; 
            fields[ID_FIELD.fieldApiName] = event.detail.draftValues[i].Id;
            fields[STARTDAYS_FIELD.fieldApiName] = event.detail.draftValues[i].startDays;
            fields[DURATION_FIELD.fieldApiName] = event.detail.draftValues[i].duration;
            fields[ORDER_FIELD.fieldApiName] = event.detail.draftValues[i].order;

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
                    message: 'Activity Groups updated',
                    variant: 'success'
                })
            );
            // Clear all draft values
            this.draftValues = [];

            // Display fresh data in the datatable
            this.initializeActivityGroupsList();
        }).catch(error => {
            // Handle error
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'ERROR: Activity Groups not updated',
                    variant: 'error'
                })
            );
        });

    }

}