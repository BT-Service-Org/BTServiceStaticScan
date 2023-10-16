import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { refreshApex } from '@salesforce/apex';

import Estimate__c from '@salesforce/schema/SEP_Domain2Assesment__c.Estimate__c';
import Name from '@salesforce/schema/SEP_Domain2Assesment__c.Name';
import Function_Points_Sum__c from '@salesforce/schema/SEP_Domain2Assesment__c.Function_Points_Sum__c';

const DOM_ASSESS_FIELDS = ['SEP_Domain2Assesment__c.Name', 'SEP_Domain2Assesment__c.Estimate__c', 'SEP_Domain2Assesment__c.Function_Points_Sum__c'];

export default class SEP_Domain_Assessment_Header extends LightningElement {

    @api recordId;
    @track name = "test";
    @track estimateID;
    @track fp = 0;

    logPrefix = 'SEP --- ';

    @track _getRecordResponse;

    @wire(getRecord, { recordId:'$recordId', fields: DOM_ASSESS_FIELDS})
    loadFields(response){
        this._getRecordResponse = response;
        let error = response && response.error;
        let data = response && response.data;
        if(error){
            console.info(this.logPrefix,"No data Dom2Asses Name ");
        }else if(data){

            /*
            this.name = data.fields.Name.value;
            this.estimateID = data.fields.Estimate__c.value;
            this.fp = data.fields.Function_Points_Sum__c.value;
            */

            this.name = getFieldValue(data, Name);
            this.estimateID = getFieldValue(data, Estimate__c);
            this.fp = getFieldValue(data, Function_Points_Sum__c);
            
            //console.info(this.logPrefix,"Domain Name ", this.name);

        }
    }
    refreshWire() {
        console.info(this.logPrefix,'refresh wire');
        refreshApex(this._getRecordResponse);
    }

    get domainName() {
        return this.name;
    }

    get functionPoints() {
        return this.fp;
    }

    get estimateURL() {
        return '/' + this.estimateID;
    }

    timer; 

    connectedCallback() {
        console.info(this.logPrefix,'connected Callback asses header');
        /*
        this.timer = setInterval(() => {
          this.refreshWire();
        }, 10000);
        */
      }
      
      
    disconnectedCallback() {
        console.info(this.logPrefix,'diconnected Callback Asses header');
        //clearInterval(timer);
    }

}