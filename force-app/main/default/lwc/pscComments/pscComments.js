import { LightningElement, wire, api } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import getCommentData from '@salesforce/apex/PSCCommentsCtrl.getCommentData';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';

import ARTICLE_FEEDBACK_OBJECT from '@salesforce/schema/Article_Feedback__c';
import FEEDBACK_FIELD from '@salesforce/schema/Article_Feedback__c.Feedback__c';
import KNOWLEDGE_FIELD from '@salesforce/schema/Article_Feedback__c.Knowledge__c';
import STATUS_FIELD from '@salesforce/schema/Article_Feedback__c.Status__c';
import REUSABLE_ASSET_FIELD from '@salesforce/schema/Article_Feedback__c.Reusable_Asset__c';
import PARENT_FEEDBACK_FIELD from '@salesforce/schema/Article_Feedback__c.Parent_Feedback__c';
import RECORD_TYPE_ID_FIELD from '@salesforce/schema/Article_Feedback__c.RecordTypeId';
import PSC_PAGE_FIELD from '@salesforce/schema/Article_Feedback__c.PSC_Page__c';//GKC-1355
import CONTENT_REQUEST from '@salesforce/schema/Article_Feedback__c.Content_Requests__c';//GKC-1254

export default class PscComments extends LightningElement {
    @api parentDetailRecId = null;
    parentFeedbackId = null;
    @api parentType;
    @api userUpVoted;
    @api userDownVoted;
    @api recordId;
    feedbackLabel ="Post your comment"
    likeImage = PSC_IMAGES + '/images/upvote.png';
    dislikeImage = PSC_IMAGES + '/images/downvote.png';

    commentDataRefresh;
    commentData = [];
    reply;
    currentParentRecord;


    @wire(getCommentData, { parentDetailRecId: '$parentDetailRecId', parentFeedbackId: '$parentFeedbackId' })
    commentData(result) {
        this.commentDataRefresh = result;
        if (result.data) {
            if (result.data !== null && result.data !== undefined) {
                this.commentData = result.data;
                this.commentData = this.commentData.map(feedback => {
                    return {
                        ...feedback,
                        feedbackType: feedback.Sentiment__c ? 'Suggestion' : 'Comment',
                        upVote: feedback.Sentiment__c == "Up",
                        downVote: feedback.Sentiment__c == "Down",
                        feedbackTime: this.calculateTime(feedback.CreatedDate),
                        commentReplySection: feedback.Article_Feedbacks__r? feedback.Article_Feedbacks__r.map(reply => {
                            return {
                                ...reply,
                                replyTime : this.calculateTime(reply.CreatedDate)
                            }
                        }) : []
                    }
                })
                this.error = undefined;
            }

        }
        else if (result.error) {
            console.log('result.error->', result.error);
            this.error = result.error;
        }
    }

    @wire(getObjectInfo, { objectApiName: ARTICLE_FEEDBACK_OBJECT })
    objectInfo;

    handleReplyChange(event) {
        this.reply = event.target.value;
    }

    handleReplyClick(event) {
        this.reply = undefined;
        this.commentData = this.commentData.map(row => {
            return {
                ...row,
                showReplyBox: (row.Id === event.currentTarget.dataset.id ? true : false)
            };
        })
    }

    calculateTime(formattedCreatedTime) {
        // Get the current time
        var currentDate = new Date();

        // Article created time
        var completeCreatedDate = new Date(formattedCreatedTime);

        // Get time in local time zone
        var createdTime = completeCreatedDate.toLocaleString(undefined, {
            hour: "numeric",
            minute: "numeric",
            hour12: true
        });

        // Get date in local time zone
        var createdDate = completeCreatedDate.toLocaleDateString(undefined, {
            year: "numeric",
            month: "2-digit",
            day: "2-digit"
        });


        // Calculate the time difference in milliseconds
        var timeDiff = currentDate - completeCreatedDate;

        // Convert the time difference to seconds, minutes, or hours as needed
        var secondsDiff = Math.floor(timeDiff / 1000);
        var minutesDiff = Math.floor(timeDiff / (1000 * 60));
        var hoursDiff = Math.floor(timeDiff / (1000 * 60 * 60));

        if (hoursDiff >= 48) {
            return "Commented on " + createdDate
        } else if (hoursDiff >= 24 && hoursDiff < 48) {
            return "Yesterday at " + createdTime
        } else if (hoursDiff < 24 && hoursDiff >= 1) {
            return "Today at " + createdTime;
        } else if (hoursDiff < 1) {
            return minutesDiff + " minutes ago";
        }
    }

    handleReplySubmit(event) {
        let recTypeId;
        if (this.objectInfo.data) {
            const recTyps = this.objectInfo.data.recordTypeInfos;
            recTypeId = Object.keys(recTyps).find(recTyp => recTyps[recTyp].name === 'Feedback');
        }
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.feedback-text');

        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            return;
        }
        const fields = {};
        fields[FEEDBACK_FIELD.fieldApiName] = this.reply;
        if (this.parentType === 'Knowledge__kav') {
            fields[KNOWLEDGE_FIELD.fieldApiName] = this.parentDetailRecId;
        }
        else if (this.parentType === 'Reusable_Asset__c') {
            fields[REUSABLE_ASSET_FIELD.fieldApiName] = this.parentDetailRecId;
        }
        //GKC-1355
        else if (this.parentType === 'PSC_Page__c') {
            fields[PSC_PAGE_FIELD.fieldApiName] = this.parentDetailRecId;
        }
        //GKC-1254
        else if (this.parentType === 'Content_Requests__c') {
            fields[CONTENT_REQUEST.fieldApiName] = this.parentDetailRecId;
        }
        fields[STATUS_FIELD.fieldApiName] = 'New';
        fields[RECORD_TYPE_ID_FIELD.fieldApiName] = recTypeId;
        fields[PARENT_FEEDBACK_FIELD.fieldApiName] = event.currentTarget.dataset.id;
        const recordInput = { apiName: ARTICLE_FEEDBACK_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(result => {
                this.reply = '';
                this.refreshData();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Reply posted successfully',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                console.log('error->', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
    handleFeedbackCreate() {
        this.refreshData();
        this.template.querySelector('c-psc-comments').refreshData();

    }

    @api
    refreshData() {
        refreshApex(this.commentDataRefresh);
    }
}