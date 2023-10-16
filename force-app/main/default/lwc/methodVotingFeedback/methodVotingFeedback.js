import { LightningElement,api,track } from 'lwc';
import createFeedbackRecord from '@salesforce/apex/methodVotingFeedbackController.createFeedbackRecord';
import createVoteRecord from '@salesforce/apex/methodVotingFeedbackController.createVoteRecord';
import existingVoteRecord from '@salesforce/apex/methodVotingFeedbackController.existingVoteRecord';

export default class MethodVotingFeedback extends LightningElement {
    @api recordId;
    valuesrequired=true;
    submitted=false;
    vote;
    showUpvoteButton;
    showDownvoteButton;
    feedbackMessage;
    handleUpvote(){
        this.vote="Upvote";
        console.log(this.vote);
        console.log(this.recordId);
        this.handleVote();
        
    }
    handleDownvote(){
        this.vote="Downvote";
        console.log(this.vote);
        this.handleVote();
        //this.renderedCallback();
    }
    renderedCallback(){}
    handleFeedback(event){
        this.feedbackMessage=event.detail.value;
        if(this.feedbackMessage.length>0){
            this.valuesrequired=false;
        }
        else{
            this.valuesrequired=true;
        }
        console.log(this.feedbackMessage);
    }
    connectedCallback(){
        this.handleExistingVote();

    }
    handleExistingVote(){
        console.log("handlecheck")
        existingVoteRecord({methodRecordId: this.recordId})
        .then((result) => {
            for(let res in result){
                console.log("result"+ result[res].Vote_Type__c);
                if(result[res].Vote_Type__c === "Upvote"){
                    this.showDownvoteButton = true;
                    this.showUpvoteButton = false;
                    console.log("upvote");
                }
                else{
                    this.showUpvoteButton = true;
                    this.showDownvoteButton = false;
                    console.log("downvote");
                }
            }
        })
        .catch((error) => {
        });            
    }

    handleVote(){
        createVoteRecord({methodRecordId: this.recordId,voteType: this.vote })
            .then((result) => {
                this.connectedCallback();

            })
            .catch((error) => {

            });
    }

    handleSubmit(){
        createFeedbackRecord({methodRecordId: this.recordId,feedbackMessage: this.feedbackMessage})
                .then((result) => {
                    this.submitted = true;
                })
                .catch((error) => { 
                    
                });
        }
}