import {LightningElement, track, wire, api} from 'lwc';
import fetchData from '@salesforce/apex/ServicesMethodFilter.fetchData';

// importing to show toast notifictions
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {  publish,createMessageContext,releaseMessageContext } from 'lightning/messageService';



// datatable columns
const columns = [
    {
        label: 'Stage',
        fieldName: 'Stage',
        type: 'text',
        sortable: true
    },
    {
        label: 'Method Number',
        fieldName: 'methodNumber',
        type: 'text',
        sortable: true
    },
    {
        label: 'Method Name',
        fieldName: 'methodNameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'methodName' }, 
        target: '_blank'},
        sortable: true
       
    },
    
    {
        label: 'Grouping',
        fieldName: 'grouping',
        type: 'picklist',
        wrapText: true,
        sortable: true,
        
    },
    {
        label: 'Delivery Owner Role (Responsible)',
        fieldName: 'deliveryOwnerRole',
        type: 'text',
        wrapText: true,
        sortable: true,
    },
    {
        label: 'Waterfall',
        fieldName: 'waterfall',
        type: 'boolean',
        wrapText: true,
        wrapText: true,
        sortable: true,
    },
    {
        label: 'Agile',
        fieldName: 'agile',
        type: 'boolean',
        wrapText: true,
        sortable: true,
    },
    {
        label: 'Micro',
        fieldName: 'micro',
        type: 'picklist',
        wrapText: true,
        sortable: "true",
       
    },
    {
        label: 'Small',
        fieldName: 'small',
        type: 'picklist',
        wrapText: true,
        sortable: true,
       
    },
    {
        label: 'Medium',
        fieldName: 'medium',
        type: 'text',
        wrapText: true,
        sortable: true,
    },
    {
        label: 'Large',
        fieldName: 'large',
        type: 'text',
        wrapText: true,
        sortable: true,
    },
    {
        label: 'Program',
        fieldName: 'program',
        type: 'text',
        wrapText: true,
        sortable: true,
    },
    {
        label: 'Tier1',
        fieldName: 'tier1',
        type: 'text',
        wrapText: true,
        sortable: true,
    },
    {
        label: 'Tier2',
        fieldName: 'tier2',
        type: 'text',
        wrapText: true,
        sortable: true,
    },
];
export default class ServicesMethodRecordsView extends LightningElement {

    @api stageFilter;
    @api recordId;
    @track data;
    @track dataClone;
    @track dataAfterTextSearch;
    @track columns = columns;
    @track searchterm;
    @track searchField;
    @track filterArray={};
    @track sortBy;
    @track sortDirection;
    @track searchActivity =[];
    @track isLoading=true;
    @track filterOptions = [
       {label:'Nice to Use', value:'Nice to Use'},
        {label:'Should Use', value:'Should Use'},
        {label:'Must Use', value:'Must Use'},
        {label: 'Won\'t Use', value :'Won\'t Use'},
    ];
  //filter labels
    @track microLabel ='Micro'; 
    @track SmallLabel ='Small'; 
    @track largeLabel ='Large'; 
    @track programlLabel ='Program'; 
    @track tierlLabel = 'Tier1';
    @track tier2Label = 'Tier2';
    @track methodNameLabel = 'Method Name';
    @track groupingLabel = 'Grouping';
    @track deliveryOwnerLabel = 'Delivery Owner Role';
    @track methodNumberLabel = 'Method Number';
    
    //MessageChannel Variables
    channel;
    context = createMessageContext();
    
   connectedCallback() {
        fetchData( {filter: this.stageFilter})
        .then(data => {
            this.data = data;
            this.dataClone = data;
            this.dataAfterTextSearch = data;
            this.isLoading = false;
        }).catch(error => {
            console.log('error '+JSON.stringify( error));
            
        });
    }

    
    handlefilterChange(event){
        var searchField = event.detail.payload.value;
        var searchterm = event.detail.payload.source;
        this.filterRecs(searchterm,searchField);
    }

    filterListView(event){
        this.searchterm = event.target.value;
        this.filterRecs(this.searchterm,this.searchField);
            //.filter( r => !this.filterAccountSizeValue || r.EO_Account_Size__c == this.filterAccountSizeValue);
    }
    filterRecs(searchterm,searchField){
        let results = [];
      
             this.filterArray[searchterm] = searchField;
   for (var propName in this.filterArray) {
    if (this.filterArray[propName] == null || this.filterArray[propName] == undefined || this.filterArray[propName] == '' || this.filterArray[propName] == [] ) {
        
      delete  this.filterArray[propName];
    }
  }
                 results = this.dataClone.filter(elem => {
                    return Object.keys(this.filterArray).every(elem2 => {
                    
                     if(elem2 == 'methodName' || elem2 == 'grouping' || elem2 == 'deliveryOwnerRole'){
                        return elem[elem2]!=null && elem[elem2].toLowerCase().includes(this.filterArray[elem2].toLowerCase());
                        }
                        else if(elem2 == 'methodNumber'){
                            return elem[elem2]!=null && elem[elem2].toString().includes(this.filterArray[elem2]);
                            }
                        else{
                         return this.filterArray[elem2]!=null && this.filterArray[elem2].includes(elem[elem2]);
                        }
            
                    });
                   
                });
       
            this.data = results;  
            this.dataAfterTextSearch = results;
        
}
handleSelect(event){

    let source = event.detail.payload.source;
    let values = event.detail.payload.values;
    if(source != 'methodName' && source != 'deliveryOwnerRole' && source !='methodNumber'){
        source =  source.toLowerCase();
    }
   
   this.filterArray[source] = values;
   for (var propName in this.filterArray) {
   
    if (this.filterArray[propName] == null || this.filterArray[propName] == undefined || this.filterArray[propName] == '' || this.filterArray[propName] == [] ) {
        
      delete  this.filterArray[propName];
    }
  }
    let results = [];
    let commonList =[];

    var filterDataAfterTextSearch = this.dataClone.filter(elem => {
        return Object.keys(this.filterArray).every(elem2 => {
        
         if(elem2 == 'methodName' || elem2 == 'grouping' || elem2 == 'deliveryOwnerRole'){
         return elem[elem2]!=null && elem[elem2].toLowerCase().includes(this.filterArray[elem2].toLowerCase());
         }
       else if(elem2 == 'methodNumber'){
            return elem[elem2]!=null && elem[elem2].toString().includes(this.filterArray[elem2]);
            }
         else{
          return this.filterArray[elem2]!=null && this.filterArray[elem2].includes(elem[elem2]);
         }

        });
       
    });
    this.data = filterDataAfterTextSearch;
   
}
doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
}
sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.data));
    //let parseData = this.data;
    // Return the value stored in the field
    let keyValue = (a) => {
        return a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === 'asc' ? 1: -1;
    // sorting data
    this.data = parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
    });
   // this.data = parseData;
}    
   

}