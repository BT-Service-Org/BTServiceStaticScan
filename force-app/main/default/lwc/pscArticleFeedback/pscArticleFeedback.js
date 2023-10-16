import { LightningElement, api , wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ARTICLE_FEEDBACK_OBJECT from '@salesforce/schema/Article_Feedback__c';
import FEEDBACK_FIELD from '@salesforce/schema/Article_Feedback__c.Feedback__c';
import KNOWLEDGE_FIELD from '@salesforce/schema/Article_Feedback__c.Knowledge__c';
import SENTIMENT_FIELD from '@salesforce/schema/Article_Feedback__c.Sentiment__c';
import STATUS_FIELD from '@salesforce/schema/Article_Feedback__c.Status__c';
import REUSABLE_ASSET_FIELD from '@salesforce/schema/Article_Feedback__c.Reusable_Asset__c';
import RECORD_TYPE_ID_FIELD from '@salesforce/schema/Article_Feedback__c.RecordTypeId';
import PSC_PAGE_FIELD from '@salesforce/schema/Article_Feedback__c.PSC_Page__c';//GKC-1355
import CONTENT_REQUEST from '@salesforce/schema/Article_Feedback__c.Content_Requests__c';//GKC-1254
export default class PscArticleFeedback extends LightningElement {
    feedback;
    @api parentId;
    @api userUpVoted;
    @api userDownVoted;
    @api parentType;
    @api feedbackType;
    @api feedbackLabel='';
    isRequired = true;
    articleType='';
    validationMessage='';
    showSpinner = false;

    @wire(getObjectInfo, { objectApiName: ARTICLE_FEEDBACK_OBJECT })
    objectInfo;

    handleSubmit() {
        this.showSpinner=true;
        let recTypeId;
        if ( this.objectInfo.data ) {
            const recTyps = this.objectInfo.data.recordTypeInfos;
            recTypeId =  Object.keys( recTyps ).find( recTyp => recTyps[ recTyp ].name === 'Feedback' );
        }
        let userVote = (this.userUpVoted === true ? 'Up' : (this.userDownVoted === true ? 'Down' : undefined));
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.feedback-text');

        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            this.showSpinner=false;
            return;
        }
        if (userVote !== undefined || this.feedbackType=='Comment') {
            const fields = {};
            fields[FEEDBACK_FIELD.fieldApiName] = this.feedback;
            if(this.parentType==='Knowledge__kav'){
                fields[KNOWLEDGE_FIELD.fieldApiName] = this.parentId;
            }
            else if(this.parentType==='Reusable_Asset__c'){
                fields[REUSABLE_ASSET_FIELD.fieldApiName] = this.parentId;
            }
            //GKC-1355
            else if(this.parentType==='PSC_Page__c'){
                fields[PSC_PAGE_FIELD.fieldApiName] = this.parentId;
            }
            //GKC-1254
            else if(this.parentType=='Content_Requests__c'){
                fields[CONTENT_REQUEST.fieldApiName] = this.parentId;
            }
            if(this.feedbackType=="Suggestion") {
                fields[SENTIMENT_FIELD.fieldApiName] = userVote;
            }
            fields[SENTIMENT_FIELD.fieldApiName] = userVote;
            fields[STATUS_FIELD.fieldApiName] = 'New';
            fields[RECORD_TYPE_ID_FIELD.fieldApiName] = recTypeId;
            
            const recordInput = { apiName: ARTICLE_FEEDBACK_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(result => {
                    this.feedback = '';
                    let ev = new CustomEvent('feedbacksuccess', {});
                    this.dispatchEvent(ev); 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Article Feedback created',
                            variant: 'success',
                        }),
                    );
                    this.showSpinner=false;
                })
                .catch(error => {
                    console.log('error->',error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                    this.showSpinner=false;
                });
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Please vote before providing feedback',
                    message: '',
                    variant: 'warning',
                }),
            );
            this.showSpinner=false;
        }
    }
    handleSubmitWithoutFeedback() {
        this.dispatchEvent(new CustomEvent('cancelaction'));
    }

    handleFeedbackChange(event) {
        this.feedback = event.target.value;
    }

    renderedCallback() {
        
        if(this.feedbackType == "Suggestion") {
            this.isRequired=false;
        } else {
            this.isRequired=true
        }
    }

    connectedCallback() {
        this.articleType = this.parentType == "Knowledge__kav" ? "article" : this.parentType =="Reusable_Asset__c" ? "asset": "content";
        this.validationMessage = this.feedbackType == "Suggestion" ? "Kindly provide your feedback." : "Please input your comment"
    }
}