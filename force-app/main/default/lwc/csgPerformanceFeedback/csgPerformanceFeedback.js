import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';

import SALESORCE_SMART_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Salesforce_Smart__c';
import SALESORCE_SMART_RATING_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Salesforce_Smart_Rating__c';

import GET_IT_DONE_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Get_It_Done__c';
import GET_IT_DONE_RATING_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Get_It_Done_Rating__c';

import WIN_AS_TEAM_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Win_as_a_Team__c';
import WIN_AS_TEAM_RATING_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Win_as_a_Team_Rating__c';

import MOTIVATE_CHAMPION_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Motivate_Champion__c';
import MOTIVATE_CHAMPION_RATING_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Motivate_Champion_Rating__c';

import COURAGEOUS_COMMUNICATOR_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Courageous_Communicator__c';
import COURAGEOUS_COMMUNICATOR_RATING_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Courageous_Communicator_Rating__c';

import JUDGEMENT_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Judgement__c';
import DRIVE_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Drive__c';
import INFLUENCE_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Influence__c';

import COMMENT_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.Comments__c';
import RELATIONSHIP_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_PF_Relationship__c';
import CSG_USER_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.Onboarding__c'; //Onboarding__c

import STATUS_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_Feedback_Request_Status__c';
import FEEDBACK_PROVIDER_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_Feedback_Provider__c';

import saveFeedback from '@salesforce/apex/FeedbackController.saveFeedback';
import getDefaultRecordTypeId from '@salesforce/apex/FeedbackController.getEFDefaultRecordTypeId';

export default class CsgPerformanceFeedback extends NavigationMixin(LightningElement) {
    activeSections = ['GF','GC','JDI', 'R'];
    userId = Id;
    error;
    salesforceSmartField = SALESORCE_SMART_FIELD;
    salesforceSmartRatingField = SALESORCE_SMART_RATING_FIELD;
    getITDoneField = GET_IT_DONE_FIELD;
    getITDoneRatingField = GET_IT_DONE_RATING_FIELD;
    winAsTeamField = WIN_AS_TEAM_FIELD;
    winAsTeamRatingField = WIN_AS_TEAM_RATING_FIELD;
    motivateChampionField = MOTIVATE_CHAMPION_FIELD;
    motivateChampionratingField = MOTIVATE_CHAMPION_RATING_FIELD;
    courageuousField = COURAGEOUS_COMMUNICATOR_FIELD;
    courageuousRatingField = COURAGEOUS_COMMUNICATOR_RATING_FIELD;
    judgementField = JUDGEMENT_FIELD;
    driveField = DRIVE_FIELD;
    influenceField = INFLUENCE_FIELD;
    commentField = COMMENT_FIELD;
    relationshipField = RELATIONSHIP_FIELD;
    csgUserField = CSG_USER_FIELD;

    fields = [SALESORCE_SMART_FIELD, SALESORCE_SMART_RATING_FIELD, 
        GET_IT_DONE_FIELD, GET_IT_DONE_RATING_FIELD, 
        WIN_AS_TEAM_FIELD, WIN_AS_TEAM_RATING_FIELD,
        MOTIVATE_CHAMPION_FIELD, MOTIVATE_CHAMPION_RATING_FIELD,
        COURAGEOUS_COMMUNICATOR_FIELD, COURAGEOUS_COMMUNICATOR_RATING_FIELD,
        JUDGEMENT_FIELD, DRIVE_FIELD, INFLUENCE_FIELD, COMMENT_FIELD, 
        RELATIONSHIP_FIELD, CSG_USER_FIELD, STATUS_FIELD, FEEDBACK_PROVIDER_FIELD
    ];

    smartRatingValue = '';
    getITDoneRatingValue = '';
    winAsTeamRatingValue = '';
    motivateChampionRatingValue = '';
    courageuousRatingValue = '';
    feedbackRecord;
    
    @wire(CurrentPageReference)
    currPageRef;
    
    get recordIdFromState() {
        return this.currPageRef && this.currPageRef.state.c__recordId;
    }

    @wire(getRecord, { recordId: "$recordIdFromState", fields: "$fields" })
    feedbackRecord;

    recordTypeId;
    connectedCallback() {
        getDefaultRecordTypeId().then(id => {
            this.recordTypeId = id;
        });
    }

    get isFeedbackProvider() {
        return getFieldValue(this.feedbackRecord.data, FEEDBACK_PROVIDER_FIELD) === this.userId;
    }

    get feedbackProvider() {
        return getFieldValue(this.feedbackRecord.data, FEEDBACK_PROVIDER_FIELD);
    }

    get lockRecord() {
        return getFieldValue(this.feedbackRecord.data, STATUS_FIELD) === 'Completed';
    }

    get csgUser() {
        return getFieldValue(this.feedbackRecord.data, CSG_USER_FIELD);
    }

    get relationship() {
        return getFieldValue(this.feedbackRecord.data, RELATIONSHIP_FIELD);
    }

    get comment() {
        return getFieldValue(this.feedbackRecord.data, COMMENT_FIELD);
    }

    get salesforceSmart() {
        return getFieldValue(this.feedbackRecord.data, SALESORCE_SMART_FIELD);
    }

    get salesforceSmartRating() {
        if(this.smartRatingValue == '') {
            this.smartRatingValue = getFieldValue(this.feedbackRecord.data, SALESORCE_SMART_RATING_FIELD);
        }
        return getFieldValue(this.feedbackRecord.data, SALESORCE_SMART_RATING_FIELD);
    }

    get itDone() {
        return getFieldValue(this.feedbackRecord.data, GET_IT_DONE_FIELD);
    }

    get itDoneRating() {
        if(this.getITDoneRatingValue == '') {
            this.getITDoneRatingValue = getFieldValue(this.feedbackRecord.data, GET_IT_DONE_RATING_FIELD);
        }
        return getFieldValue(this.feedbackRecord.data, GET_IT_DONE_RATING_FIELD);
    }

    get winAsTeam() {
        return getFieldValue(this.feedbackRecord.data, WIN_AS_TEAM_FIELD);
    }

    get winAsTeamRating() {
        if(this.winAsTeamRatingValue == '') {
            this.winAsTeamRatingValue = getFieldValue(this.feedbackRecord.data, WIN_AS_TEAM_RATING_FIELD);
        }
        return getFieldValue(this.feedbackRecord.data, WIN_AS_TEAM_RATING_FIELD);
    }

    get motivateChampion() {
        return getFieldValue(this.feedbackRecord.data, MOTIVATE_CHAMPION_FIELD);
    }

    get motivateChampionRating() {
        if(this.motivateChampionRatingValue == '') {
            this.motivateChampionRatingValue = getFieldValue(this.feedbackRecord.data, MOTIVATE_CHAMPION_RATING_FIELD);
        }
        return getFieldValue(this.feedbackRecord.data, MOTIVATE_CHAMPION_RATING_FIELD);
    }

    get courageuous() {
        return getFieldValue(this.feedbackRecord.data, COURAGEOUS_COMMUNICATOR_FIELD);
    }

    get courageuousRating() {
        if(this.courageuousRatingValue == '') {
            this.courageuousRatingValue = getFieldValue(this.feedbackRecord.data, COURAGEOUS_COMMUNICATOR_RATING_FIELD);
        }
        return getFieldValue(this.feedbackRecord.data, COURAGEOUS_COMMUNICATOR_RATING_FIELD);
    }

    get judgement() {
        return getFieldValue(this.feedbackRecord.data, JUDGEMENT_FIELD);
    }

    get drive() {
        return getFieldValue(this.feedbackRecord.data, DRIVE_FIELD);
    }

    get influence() {
        return getFieldValue(this.feedbackRecord.data, INFLUENCE_FIELD);
    }

    get smartRequired() {
        return this.smartRatingValue !== 'NA - Unable To Assess';
    }

    handleSmartRatingChange(event) {
        this.smartRatingValue = event.detail.value;
    }

    get gidRequired() {
        return this.getITDoneRatingValue !== 'NA - Unable To Assess';
    }

    handleGIDRatingChange(event) {
        this.getITDoneRatingValue = event.detail.value;
    }

    get winRequired() {
        return this.winAsTeamRatingValue !== 'NA - Unable To Assess';
    }

    handleWinRatingChange(event) {
        this.winAsTeamRatingValue = event.detail.value;
    }

    get motivateRequired() {
        return this.motivateChampionRatingValue !== 'NA - Unable To Assess';
    }

    handleMotivateRatingChange(event) {
        this.motivateChampionRatingValue = event.detail.value;
    }

    get courageuousRequired() {
        return this.courageuousRatingValue !== 'NA - Unable To Assess';
    }

    handleCourageousRatingChange(event) {
        this.courageuousRatingValue = event.detail.value;
    }
    /*

    salesforceSmartRequired = false;
    getITDoneRequired = false;
    winAsTeamRequired = false;
    motivateChampionRequired = false;
    courageuousRequired = false;

    handleSmartChange(event) {
        this.salesforceSmartRequired = !event.detail.value.startsWith('NA');    
    }

    handleITDoneChange(event) {
        this.getITDoneRequired = !event.detail.value.startsWith('NA');    
    }

    handleWinAsTeamChange(event) {
        this.winAsTeamRequired = !event.detail.value.startsWith('NA');    
    }

    handleMotivateChampionChange(event) {
        this.motivateChampionRequired = !event.detail.value.startsWith('NA');    
    }

    handleCourageuousChange(event) {
        this.courageuousRequired = !event.detail.value.startsWith('NA');    
    }
    */

    handleSubmit(event) {
        event.preventDefault();
        let isError = this.template.querySelector(".slds-has-error");

        if (!isError) {
            let recordId = this.recordIdFromState;
            saveFeedback({ engagementFeedback: event.detail.fields, recordId: recordId }).then(recordId => {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: '',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: recordId,
                        objectApiName: 'CSG_Project_Feedback__c',
                        actionName: 'view'
                    }
                });
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            });
        }
        
    }

    redirectToRecord(event){
        let recordId = this.recordIdFromState;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'CSG_Project_Feedback__c',
                actionName: 'view'
            }
        });
     }
}