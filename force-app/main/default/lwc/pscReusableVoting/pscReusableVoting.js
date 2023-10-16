import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getVoteCount from '@salesforce/apex/PSCReusableVoteCtrl.getVoteCount';
import getUserVote from '@salesforce/apex/PSCReusableVoteCtrl.getUserVote';
import upsertUserVote from '@salesforce/apex/PSCReusableVoteCtrl.upsertUserVote';

export default class PscReusableVoting extends LightningElement {
    isLikeSelected = false;
    isDislikeSelected = false;
    @api recordId;
    @track voteData={};
    voteDataResult;
    userVote;
    userVoteResult;
    showFeedback;
    feedBackLabel='';
    @api parentType//GKC-1355
    @api
    get title(){
        return this.parentType =='Content_Requests__c'?'Do you support this Content Request': 'Was this article helpful?';
    }

    @wire(getVoteCount, { parentId: '$recordId' })
    voteData(result) {
        this.voteDataResult = result;
        if (result.data) {
            if (result.data !== null && result.data !== undefined) {
                this.voteData = result.data;
                this.error = undefined;
            }

        }
        else if (result.error) {
            this.error = result.error;
        }
    }

    @wire(getUserVote, { parentId: '$recordId' })
    userVoteData(result) {
        this.userVoteResult = result;
        if (result.data) {
            if (result.data !== null && result.data !== undefined) {
                this.userVote = result.data;
                this.showFeedback = (this.userVote.userUpVoted === true || this.userVote.userDownVoted === true ?true:false)
                this.error = undefined;
            }
        }
        else if (result.error) {
            this.error = result.error;
        }
    }
    renderedCallback() {
        if (!!this.template.querySelector('[data-id="likeblock"]')) {
            this.template.querySelector('[data-id="likeblock"]').className = this.userVote?.userUpVoted == true ? 'active-button' : 'neutral-button';
            this.template.querySelector('[data-id="dislikeblock"]').className = this.userVote?.userDownVoted == true ? 'active-button' : 'neutral-button';
        }

    }
    handleLikeClick(event) {
        this.enableModal();
        if(event.which=='13' || event.which=='1') {
            if (this.userVote.userUpVoted == false) {
                this.upsertUserVoteUtlity('Up');
                this.feedBackLabel="Tell us more about what you liked in the content?";
                this.openModal();
            }
        }
    }

    handleDislikeClick(event) {
        this.enableModal();
        if(event.which=='13' || event.which=='1') {
            if (this.userVote.userDownVoted == false) {
                this.upsertUserVoteUtlity('Down');
                this.feedBackLabel="Tell us more about what could be improved?"
                this.openModal();
            }
        }

    }

    enableModal() {
        if(!this.userVote.userDownVoted && !this.userVote.userUpVoted) {
            this.openModal();
            
        }
    }
    openModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
    }

    closeModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.hide();
    }

    upsertUserVoteUtlity(type) {
        upsertUserVote({ parentId: this.recordId, voteId: this.userVote?.userVoteId,sentiment:type })
            .then(result => {
                refreshApex(this.voteDataResult);
                refreshApex(this.userVoteResult);
            })
            .catch(error => {
                console.log(error);
            })
    }

    handleFeedbackCreate(){
        this.template.querySelector('c-psc-comments').refreshData();
        this.closeModal();
    }
}