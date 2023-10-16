import { LightningElement,wire,track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getActivityGroups from "@salesforce/apex/ActivityGroupController.getActivityGroups";
import { subscribe, publish, MessageContext } from "lightning/messageService";
import ENABLEMENT_CHANNEL from "@salesforce/messageChannel/EnablementAppMessageChannel__c";
import ENABLEMENT_REFRESH_CHANNEL from "@salesforce/messageChannel/EnablementAppRefresh__c";


const columns = [
    {type: "button-icon",fixedWidth:60, typeAttributes: {  
        label: 'View Activities',  
        name: 'ViewActivities',  
        title: 'View Activities',
        iconName: 'utility:table',
        variant:'bare' 
    } , wrapText:true},
    {label: 'Name', fieldName: 'nameUrl', sortable: true, type: 'url', 
        typeAttributes: {
            label: { fieldName: 'name' },
            tooltip:{ fieldName: 'name' },
            target: '_parent'
        }
        , wrapText:true},
    { label: 'Status', fieldName: 'percentage', sortable: true , type: 'proRing',
        typeAttributes: {
            percentval: { fieldName: 'percentage' },
            style: { fieldName: 'style' },
            title: { fieldName: 'percentageString' }
        }
        , wrapText:true}, 
    { label: 'End Date', fieldName: 'endDate', sortable: true , type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit" }
    , wrapText:true}
];


export default class ActivityGroupLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @track dataTableInput = [];
    @track columns = columns;
    @track flagIndicatingDataHasBeenLoadedInVariables = false;
    @track totalCount; 

    @track viewAll = false;
    @track showViewLinks = true;

    @track activityGroupArray = [];
    @track sectionHeader = 'Activity Groups';
    @track showLoader = false;
    @api maxNumberOfRecords = 8;

    connectedCallback() {
        this.handleSubscribe();
        this.initializeActivityGroupsList();
    }

    initializeActivityGroupsList(){

        this.showLoader = true;
        console.log('this.recordId='+this.recordId);
        getActivityGroups({onboardingId: this.recordId})
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

    /*@wire(getActivityGroups,{onboardingId: '$recordId'}) 
    wired({error, data}){
    }*/

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


    //EVENT HANDLING START ----------------------

    @wire(MessageContext)
    messageContext;

    handleRowAction(event) {
        const message = { data: event.detail.row.actGrpId };
        publish(this.messageContext, ENABLEMENT_CHANNEL, message);
    }

    
    subscription = null;
    
    handleSubscribe() {
        if (this.subscription) { return; }
  
        this.subscription = subscribe( this.messageContext, ENABLEMENT_REFRESH_CHANNEL,
            (message) => { this.handleMessage(message); }
        );
    }
  
    handleMessage(message) {
        console.log('msg 1='+JSON.stringify(message));
        this.initializeActivityGroupsList();
    }
  
    //EVENT HANDLING END ----------------------



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

}