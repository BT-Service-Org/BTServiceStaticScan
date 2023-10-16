import { LightningElement,track,api,wire } from 'lwc';
import getLearningResourceRecs from '@salesforce/apex/SKillsModalPopupController.getLearningResourceRecs';

import noLRMessage from '@salesforce/label/c.No_LR_Message';
import SKILLS_LOGO from '@salesforce/resourceUrl/Skills360Logo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Learning Resources Name', fieldName: 'lrLink',type:'url' ,sortable: true,
        typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
    },
    { label: 'Duration', fieldName: 'Duration', sortable: true, initialWidth:135,},
    { label: 'Source', fieldName: 'Source', sortable: true, },
    //{ label: 'Link', fieldName: 'Link', type: 'url',sortable: true, },
   
];
export default class SkillsModalPopupComponent extends LightningElement {

    @api isshowmodal;
    @api title;
    @api parentrec;
    @api parentid;
    @track refreshlrRecs;
    @track sortBy;
    @track sortDirection;
    @track defaultsortDirection = 'asc';
    @track showLoading = true;
    @track data = [];
    columns = columns;
    @track showData = false;
    @track isEmpty = false;
    @api openfocusmodal;
    @api boardingrecid;
    
    label = {
        noLRMessage
    };
    skillslogo = SKILLS_LOGO;

    @wire(getLearningResourceRecs,{ parentid: '$parentid' })
    lrRecs(result) {
        //this.showLoading = true;
        this.data = [];
        this.isEmpty = false;
        this.refreshlrRecs = result;
        if (result.data) {
           
            let tempRecords = result.data;
            tempRecords = tempRecords.map( row => {
                return { ...row,Name: row.Learning_Resource__r.Name, Source: row.Learning_Resource__r.Source__c,
                    Duration: row.Learning_Resource__r.Duration__c ,Link: row.Learning_Resource__r.Link__c};
            })
            this.data = tempRecords;
            if(this.data){
               
                this.data.forEach(item => item['lrLink'] = item['Link'] );
            }
                
            console.log('@@@@@'+JSON.stringify( this.data));
            this.error = undefined;
            this.showLoading = false;
            this.showData = true;
            if(this.data.length > 0){
                this.isEmpty = false;
            }else{
                this.isEmpty = true;
                this.noLRlabel = noLRMessage;
            }
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
            this.showLoading = false;
            this.showData = true;
            this.isEmpty = true;
        }else{
            this.isEmpty = true;
            this.noLRlabel = noLRMessage;
        }
        
        
    }
    sortLDT(event) {        
        let fieldName = event.detail.fieldName;
        fieldName = fieldName === 'lrLink' ? 'Name' : fieldName;
        this.sortBy = fieldName;    
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
        this.sortBy = event.detail.fieldName;;
   }  
   sortData(fieldname, direction) {  
  
    try {    
         let parseData = JSON.parse(JSON.stringify(this.data));
         let keyValue = (a) => {
             return a[fieldname];
         };

         let isReverse = direction === this.defaultsortDirection ? 1: -1;
         parseData.sort((x, y) => keyValue(x) > keyValue(y) ? (1 * isReverse) :
                             (keyValue(y) > keyValue(x) ? (-1 * isReverse):0));
         this.data = parseData;
    } catch (errorMsg) {
        console.log ('error occured inside sortData() method.See actual system message <' + errorMsg.message + '>');
    }
 }  
    hideModalBox(){
        this.showLoading = true;
        this.isshowmodal = false;
        this.showData = false;
        this.openfocusmodal = false;
        this.dispatchEvent(new CustomEvent('close'));
        this.showLoading = false;
        this.isEmpty = false;
        this.noLRlabel = '';
    }
    handleSubmit(event){
        this.showLoading = true;
        this.template.querySelector('lightning-record-edit-form').submit();
       
     }
     handleSuccess( event ) { 
        this.showLoading = true;
        const toastEvent = new ShowToastEvent({ 
            title: 'Focus Category Update', 
            message: 'Focus Category updated Successfully', 
            variant: 'success' 
        }); 
        this.dispatchEvent( toastEvent ); 
        this.showLoading = false;
        this.hideModalBox();

    }
    handleOnLoad(event){
        this.showLoading = false;
    }
    handleError(event){
        this.showLoading = false;
    }
}