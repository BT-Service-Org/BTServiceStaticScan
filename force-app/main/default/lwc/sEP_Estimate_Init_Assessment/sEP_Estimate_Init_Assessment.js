import { LightningElement, track, wire, api} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

const ESTIMATE_FIELDS = [
    'SEP_Estimate__c.Name', 'SEP_Estimate__c.Description__c', 
    'SEP_Estimate__c.SEP_Stream_Assessment_1__c', 'SEP_Estimate__c.SEP_Stream_Assessment_2__c',
    'SEP_Estimate__c.SEP_Stream_Assessment_3__c', 'SEP_Estimate__c.SEP_Stream_Assessment_4__c'
];  
const ASSESMENT_FIELDS = ['SEP_Stream_Assessment__c.Name', 'SEP_Stream_Assessment__c.Function_Points_Sum__c']
const RELATED_FIELDS = ['SEP_Domain2Assesment__c.Domain_Name__c','SEP_Domain2Assesment__c.Id', 'SEP_Domain2Assesment__c.Function_Points_Sum__c'];

export default class SEP_Estimate_Init_Assessment extends LightningElement {
        @api recordId;
       
        @track hasRendered = true;

        @track _name;
        @track _description;

        @track assessID1;
        @track assessID2;
        @track assessID3;
        @track assessID4;

        @track _assessName1;
        @track _assessName2;
        @track _assessName3;
        @track _assessName4;

        @track assessFP1;
        @track assessFP2;
        @track assessFP3;
        @track assessFP4;

        @track assess1Domains = [];
        @track assess2Domains = [];
        @track assess3Domains = [];
        @track assess4Domains = [];

        @track currentExpandedRows;
        gridExpandedRows = [];

        wireData;
        gridColumns;
        @track gridData = [];

        //tmpGridData = [];
        //tmpGridRoot = [];
        //tmpFields = [];

        //used for refresh apex
        @track _getRecordResponse;
        @track _getRecordResponse1;
        @track _getRecordResponse2;
        @track _getRecordResponse3;
        @track _getRecordResponse4;

        @track _getRelatedResponse1;
        @track _getRelatedResponse2;
        @track _getRelatedResponse3;
        @track _getRelatedResponse4;

        logPrefix = 'SEP ';

        @wire(getRecord, { recordId: '$recordId', fields: ESTIMATE_FIELDS })
        wiredEstimate (response) {
            this._getRecordResponse = response;
            let error = response && response.error;
            let data = response && response.data;

            if (data) {
                //console.info(this.logPrefix,"--- DATA in Estimate");

                //get the IDs for the related Assessments
                this.assessID1 = data.fields.SEP_Stream_Assessment_1__c.value;
                this.assessID2 = data.fields.SEP_Stream_Assessment_2__c.value;
                this.assessID3 = data.fields.SEP_Stream_Assessment_3__c.value;
                this.assessID4 = data.fields.SEP_Stream_Assessment_4__c.value;

                this._name = data.fields.Name.value;

            } else if (error) {
                console.info(this.logPrefix,"--- ERROR in Estimate, error");
            }
            
        } 

        // -------------------------- get the name of all assessments

        @wire(getRecord, { recordId: '$assessID1', fields: ASSESMENT_FIELDS })
            wiredAssesment1 (response) {
                this._getRecordResponse1 = response;
                let error = response && response.error;
                let data = response && response.data;
                //console.info(this.logPrefix,"--- Before DATA Assesment", this.assessID1, data, error);
                if (data) {
                    //console.info(this.logPrefix,"--- DATA Assesment");
                    //console.info(this.logPrefix,"--- Asses#1 ",data.fields.Name.value);
                    this._assessName1 = data.fields.Name.value;
                    this.assessFP1 = data.fields.Function_Points_Sum__c.value;
                    //console.info(this.logPrefix,"--- Asses#1 assigned ",this._assessName1);

                    
                    //this.tmpGridData.push(this.tmpGridRoot);
                    this.refresh();
                }
            }
        
        @wire(getRecord, { recordId: '$assessID2', fields: ASSESMENT_FIELDS })
        wiredAssesment2 (response) {
            this._getRecordResponse2 = response;
            let error = response && response.error;
            let data = response && response.data;
            if (data) {
                //console.info(this.logPrefix,"--- Asses#2 ",data.fields.Name.value);
                this._assessName2 = data.fields.Name.value;
                this.assessFP2 = data.fields.Function_Points_Sum__c.value;
                this.refresh();
            }
        }
        @wire(getRecord, { recordId: '$assessID3', fields: ASSESMENT_FIELDS })
        wiredAssesment3 (response) {
            this._getRecordResponse3 = response;
            let error = response && response.error;
            let data = response && response.data;
            if (data) {
                //console.info(this.logPrefix,"--- Asses#3 ",data.fields.Name.value);
                this._assessName3 = data.fields.Name.value;
                this.assessFP3 = data.fields.Function_Points_Sum__c.value;
                this.refresh();
            }
        }

        @wire(getRecord, { recordId: '$assessID4', fields: ASSESMENT_FIELDS })
        wiredAssesment4 (response) {
            this._getRecordResponse4 = response;
            let error = response && response.error;
            let data = response && response.data;
            if (data) {
                //console.info(this.logPrefix,"--- Asses#4 ",data.fields.Name.value);
                this._assessName4 = data.fields.Name.value;
                this.assessFP4 = data.fields.Function_Points_Sum__c.value;
                this.refresh();
            }
        }     
        
        // ---------------------    Get Domains for a given Assessment and construct the grid datat

        @wire(getRelatedListRecords, { parentRecordId: '$assessID1', relatedListId: 'SEP_Domain2Assesments__r', fields: RELATED_FIELDS})
        wiredRelated1 (response) {
            this._getRelatedResponse1 = response;
            let error = response && response.error;
            let data = response && response.data;
            //console.info(this.logPrefix,"--- Before DATA Assesment", this.assessID1, data, error);
            //console.info(this.logPrefix,'in related1');
            if (data) {
                //this.wireData = data;
                //console.info(this.logPrefix,'data related', data);
                //console.info(this.logPrefix,'data related1', JSON.stringify(data));
                let tmpChildren = [];
                this.assess1Domains = [];

                data.records.forEach( obj => {

                    //console.log(this.logPrefix, ' obj is', JSON.stringify( obj ) );
                    let tmpName = obj.fields.Domain_Name__c.value;
                    let tmpID = obj.fields.Id.value;
                    let tmpFP = obj.fields.Function_Points_Sum__c.value;
                    let tmpURL = '/'+tmpID;

                    this.assess1Domains.push({
                        //'assessment': this._assessName1,
                        'domains': tmpURL,
                        'domainName': tmpName,
                        'fp': tmpFP,
                    });
    
                } );

                //console.info(this.logPrefix,'create JSON1', JSON.stringify(this.tmpGridRoot));
                this.refresh();
                //this.tmpFields = data.records.fields;
                //console.info(this.logPrefix,'data related', JSON.stringify(this.tmpFields));

            } else if (error) {
                console.info(this.logPrefix,"--- ERROR  Related List");
                console.info(this.logPrefix,error, 'in related');
            }
        }
                
        @wire(getRelatedListRecords, { parentRecordId: '$assessID2', relatedListId: 'SEP_Domain2Assesments__r', fields: RELATED_FIELDS})
        wiredRelated2 (response) {
            this._getRelatedResponse2 = response;
            let error = response && response.error;
            let data = response && response.data;
            //console.info(this.logPrefix,'data related2');
            if (data) {
                this.assess2Domains = [];
                let tmpChildren = [];
                //console.info(this.logPrefix,'data related2', JSON.stringify(data));
                data.records.forEach( obj => {
                    let tmpName = obj.fields.Domain_Name__c.value;
                    let tmpID = obj.fields.Id.value;
                    let tmpFP = obj.fields.Function_Points_Sum__c.value;
                    let tmpURL = '/'+tmpID;

                    this.assess2Domains.push({
                        //'assessment': this._assessName1,
                        'domains': tmpURL,
                        'domainName': tmpName,
                        'fp': tmpFP,
                    });
    
                } );
                this.refresh();

            } else if (error) {
                console.info(this.logPrefix,"--- ERROR  Related List");
                console.info(this.logPrefix,error, 'in related');
            }
        }

        @wire(getRelatedListRecords, { parentRecordId: '$assessID3', relatedListId: 'SEP_Domain2Assesments__r', fields: RELATED_FIELDS})
        wiredRelated3 (response) {
            //console.info(this.logPrefix,'data related3');
            this._getRelatedResponse3 = response;
            let error = response && response.error;
            let data = response && response.data;

            if (data) {
                //console.info(this.logPrefix,'data related3', JSON.stringify(data));
                this.assess3Domains = [];
                let tmpChildren = [];
                data.records.forEach( obj => {
                    let tmpName = obj.fields.Domain_Name__c.value;
                    let tmpID = obj.fields.Id.value;
                    let tmpFP = obj.fields.Function_Points_Sum__c.value;
                    let tmpURL = '/'+tmpID;

                    this.assess3Domains.push({
                        //'assessment': this._assessName1,
                        'domains': tmpURL,
                        'domainName': tmpName,
                        'fp': tmpFP,
                    });
    
                } );
                this.refresh();

            } else if (error) {
                console.info(this.logPrefix,"--- ERROR  Related List");
                console.info(this.logPrefix,error, 'in related');
            }
        }

        @wire(getRelatedListRecords, { parentRecordId: '$assessID4', relatedListId: 'SEP_Domain2Assesments__r', fields: RELATED_FIELDS})
        wiredRelated4 (response) {
            //console.info(this.logPrefix,'data related4');
            this._getRelatedResponse4 = response;
            let error = response && response.error;
            let data = response && response.data;

            if (data) {
                //console.info(this.logPrefix,'data related4', JSON.stringify(data));
                this.assess4Domains = [];
                let tmpChildren = [];
                data.records.forEach( obj => {
                    let tmpName = obj.fields.Domain_Name__c.value;
                    let tmpID = obj.fields.Id.value;
                    let tmpFP = obj.fields.Function_Points_Sum__c.value;
                    let tmpURL = '/'+tmpID;
                    this.assess4Domains.push({
                        //'assessment': this._assessName1,
                        'domains': tmpURL,
                        'domainName': tmpName,
                        'fp': tmpFP,
                    });
    
                } );
                
                this.refresh();

            } else if (error) {
                console.info(this.logPrefix,"--- ERROR  Related List");
                console.info(this.logPrefix,error, 'in related');
            }
        }

    //------------------------ other methods
    renderedCallback() {

        //console.info(this.logPrefix,'in rendered callback');

        //guarding code inside the renderedCallback using boolean property
        if (this.hasRendered) {
            //this._test = 'set by renderedCallback';
            //console.log('properties ' + this.properties);
            let treegrid = this.template.querySelector('.sep-estimate-treegrid');
            treegrid.expandAll();
            this.hasRendered = false;
        }
    }

    connectedCallback(){
        this._recId = this.recordId;
        console.info(this.logPrefix,this.recordId + ' from connectedCallback', this._recId);
        
    }

    constructGridData() {

        var tmpData = [];
        if ((this._assessName1) && (this.assess1Domains.length)) {
            //console.info(this.logPrefix, 'construct gridData1', this._assessName1, this.assess1Domains.length, JSON.stringify(this.assess1Domains));
            let tmpName = this._assessName1;
            let tmpChild = this.assess1Domains; 
            let tmpFP = this.assessFP1;
            
            
            tmpData.push({
                'assessment': tmpName,
                'domains': "",
                'fp': tmpFP,
                '_children': tmpChild,
            });
            
            console.info(this.logPrefix, 'construct gridData1 after push');
        }
        
        if ((this._assessName2) && (this.assess2Domains.length)) {
            
            let tmpName = this._assessName2;
            let tmpChild = this.assess2Domains; 
            let tmpFP = this.assessFP2;
            tmpData.push({
                'assessment': tmpName,
                'domains': "",
                'fp': tmpFP,
                '_children': tmpChild,
            });

        }
        
        if ((this._assessName3) && (this.assess3Domains.length)) {
            
            let tmpName = this._assessName3;
            let tmpChild = this.assess3Domains; 
            let tmpFP = this.assessFP3;
            tmpData.push({
                'assessment': tmpName,
                'domains': "",
                'fp': tmpFP,
                '_children': tmpChild,
            });

        }
        
        if ((this._assessName4) && (this.assess4Domains.length)) {
            
            let tmpName = this._assessName4;
            let tmpChild = this.assess4Domains; 
            let tmpFP = this.assessFP4;
            tmpData.push({
                'assessment': tmpName,
                'domains': "",
                'fp': tmpFP,
                '_children': tmpChild,
            });

        }
        //console.info(this.logPrefix,'finished constructing grid data ');
        //console.info(this.logPrefix,'constructed grid data is ', tmpData.length, JSON.stringify(tmpData)); 
        return tmpData;
    }

    //don't know if this is the correct way to update the grid data ...
    refresh() {
        //console.info(this.logPrefix,'in  refresh'); 
        refreshApex( this._getRecordResponse);
        refreshApex( this._getRecordResponse1);
        refreshApex( this._getRecordResponse2);
        refreshApex( this._getRecordResponse3);
        refreshApex( this._getRecordResponse4);
        refreshApex( this._getRelatedResponse1);
        refreshApex( this._getRelatedResponse2);
        refreshApex( this._getRelatedResponse3);
        refreshApex( this._getRelatedResponse4);
        //console.info(this.logPrefix,'in  refresh2'); 
        this.gridData = this.constructGridData();
        //console.info(this.logPrefix,'in  refresh3'); 
        this.gridColumns = this.populateColumns();
        //console.info(this.logPrefix,'in  refresh4'); 
        let treegrid = this.template.querySelector('.sep-estimate-treegrid');
        //this.currentExpandedRows = treegrid.getCurrentExpandedRows().toString();
        treegrid.expandAll();
        //console.info(this.logPrefix,'in  refresh5'); 
    }

    // retrieve the list of rows currently marked as expanded
    getCurrentExpandedRows() {
        

        const treegrid = this.template.querySelector('.sep-estimate-treegrid');
        this.currentExpandedRows = treegrid.getCurrentExpandedRows().toString();

        console.info(this.logPrefix,"expanded rows", this.currentExpandedRows);
    }

    gridColumns = this.populateColumns();
    
    populateColumns() {
    var columns = [
        {
            type: 'text',
            fieldName: 'assessment',
            label: 'Scoping Assessment',
            //initialWidth: 300, 
        },
        {
            type: 'url',
            fieldName: 'domains',
            label: 'Domains',
            //initialWidth: 300,
            typeAttributes: {
                label: { fieldName: 'domainName' },
            },
        },
        {
            type: 'number',
            fieldName: 'fp',
            label: 'Function Points'
        },
    ];    
    return columns;
    }


    // ---------- launch flow --------

    renderFlow = false; //when set to true component will render lwc flow component and launch the flow
@track value = '1';

connectedCallback(){
    this._recId = this.recordId;
    console.info(this.recordId + ' from connectedCallback')
}

get options() {
    return [
             { label: 'Stream #1', value: '1' },
             { label: 'Stream #2', value: '2' },
             { label: 'Stream #3', value: '3' },
             { label: 'Stream #4', value: '4' },
           ];
}

handleChange(event) {
        this.value = event.detail.value;
     }

handleClick(event) {
    this.renderFlow = true;
    }

handleStatusChange(event){
    if (event.detail.status === 'FINISHED') {
        //Hide the Flow again
        this.renderFlow = false;
        //refresh whole record page
        //updateRecord( {fields: {Id: this._recId}});
        //window.location.reload();
        this.refresh();
        
        }
    }

    get inputVariables() {
        return [
            {
                // Match with the input variable name declared in the flow.
                name: 'SEP_Stream_number',
                type: 'String',
                value: this.value
            } ,
            {
                // Match with the input variable name declared in the flow.
                name: 'recordId',
                type: 'String',
                value: this._recId
            } 
        ];
    }

}