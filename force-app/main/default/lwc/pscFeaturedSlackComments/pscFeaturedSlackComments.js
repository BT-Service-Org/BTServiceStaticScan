import { LightningElement, api, track, wire } from 'lwc';
import getFeaturedComments from '@salesforce/apex/PSCFeaturedSlackCommentsCtrl.getFeaturedComments';
import { CurrentPageReference } from 'lightning/navigation';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class PscFeaturedSlackComments extends LightningElement {
    @track commentData = [];
    @track comments = [];
    @api sectionTitle;
    @api columns;
    slack_logo = PSC_IMAGES + '/Logo/slack-logo.png';
    showSpinner = true;
    noRecordsMessage = 'No Featured Comments';
    translate = 0;
    containerElementWidth = 0;
    isPrevBtnDisabled = true;
    isNextBtnDisabled = true;
    initialColumnCount = 0;
    updatedColumnCount = 0;
    hasRendered = false;
    communityPageName = '';
    urlPageName;
    maxCharacterLength = 400;
    isNextDisableButton = false;
    isPrevDisableButton = false;

    start = 0;
    end = 0;
    addCardLength = 0;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlPageName = currentPageReference?.attributes?.name;
            if (currentPageReference.state.hasOwnProperty('name')) {
                this.communityPageName = currentPageReference.state?.name;
            }
        }
    }

    @wire(getFeaturedComments, { communityPageNameStr: '$communityPageName', urlPageName: '$urlPageName' }) getFeaturedComment({ data, error }) {

        this.showSpinner = false;
        if (data) {
            this.comments = data;
            let count = 1;
            this.comments = this.comments.map(comment => {
                return {
                    ...comment,
                    index: count++,
                    slackComment: this.limitTextLength(comment.Slack_Comment__c),
                    isTextLengthExceeded: comment.Slack_Comment__c.length > this.maxCharacterLength ? true : false,
                    commentTime: this.calculateTime(comment.CreatedDate),
                }
            });
            this.refreshImageData(this.start, this.end)
            this.showSpinner = false;
        }
        if (error) {
            this.showSpinner = false;
            console.log('Error', error);
        }

    }

    limitTextLength(text) {
        return text.length > this.maxCharacterLength ? text.slice(0, this.maxCharacterLength) + "..." : text;
    }

    calculateTime(formattedCreatedTime) {
        // Get the current time
        var currentDate = new Date();

        // Comment created time
        var completeCreatedDate = new Date(formattedCreatedTime);

        // Get time in local time zone
        var createdTime = completeCreatedDate.toLocaleString(undefined, {
            hour: 'numeric',
            minute: 'numeric',
            hour12: true
        });

        // Get date in local time zone
        var createdDate = completeCreatedDate.toLocaleDateString(undefined, {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        });

        // Calculate the time difference in milliseconds
        var timeDiff = currentDate - completeCreatedDate;

        // Convert the time difference to seconds, minutes, or hours as needed
        var secondsDiff = Math.floor(timeDiff / 1000);
        var minutesDiff = Math.floor(timeDiff / (1000 * 60));
        var hoursDiff = Math.floor(timeDiff / (1000 * 60 * 60));

        if (hoursDiff >= 48) {
            return 'Commented on ' + createdDate
        } else if (hoursDiff >= 24 && hoursDiff < 48) {
            return 'Yesterday at ' + createdTime
        } else if (hoursDiff < 24 && hoursDiff >= 1) {
            return 'Today at ' + createdTime;
        } else if (hoursDiff < 1 && minutesDiff > 1) {
            return minutesDiff + ' minutes ago';
        } else if (hoursDiff < 1 && minutesDiff == 1) {
            return minutesDiff + ' minute ago';
        } else if (minutesDiff < 1 && secondsDiff < 60) {
            return secondsDiff + ' seconds ago';
        }
    }

    handlePrevious() {
        if ((this.start - this.addCardLength) >= 0) {
            this.start = this.start - this.addCardLength;
        } else {
            this.start = 0;
        }
        this.end = this.start + this.addCardLength;
        this.refreshImageData(this.start, this.end);
        const targetDiv = this.template.querySelector('.target');
        if (targetDiv != null)
            targetDiv.scrollIntoView({ behavior: 'smooth' });
    }

    handleNext() {
        this.start = this.end >= this.comments.length ? this.start : this.end;
        this.end = this.end + this.addCardLength <= this.comments.length ? this.end + this.addCardLength : this.comments.length;
        this.refreshImageData(this.start, this.end);
        const targetDiv = this.template.querySelector('.target');
        if (targetDiv != null)
            targetDiv.scrollIntoView({ behavior: 'smooth' });

    }

    refreshImageData(start, end) {
        this.isNextDisableButton = false;
        this.isPrevDisableButton = false;

        this.commentData = [...this.comments.slice(start, end)];
        if (start == 0) {
            this.isPrevDisableButton = true;
        }
        if (end >= this.comments.length) {
            this.isNextDisableButton = true;
        }

    }

    connectedCallback() {
        switch (FORM_FACTOR) {
            case 'Large':
                this.start = 0;
                this.end = 10;
                this.addCardLength = 10;
                return;
            case 'Medium':
                this.start = 0;
                this.end = 6;
                this.addCardLength = 6;
                return;
            case 'Small':
                this.start = 0;
                this.end = 4;
                this.addCardLength = 4;
                return;
        }
    }
    get getColumnCount() {
        return `column-count:${this.columns}`
    }
    renderedCallback() {
        if (this.urlPageName == 'Community_Home__c') {
            // if (this.template.querySelector('[data-id="feature-slack-title"]')) {
            //     this.template.querySelector('[data-id="feature-slack-title"]').classList.add('title-width');

            // }
            if (this.template.querySelector('[data-id="feature-slack-container"]')) {
                this.template.querySelector('[data-id="feature-slack-container"]').classList.add('container-width');

            }
        }
    }

}