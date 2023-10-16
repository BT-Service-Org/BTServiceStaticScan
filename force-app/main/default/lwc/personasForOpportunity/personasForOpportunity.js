import { LightningElement,api,wire} from 'lwc';
import getPersonaForOpportunity from '@salesforce/apex/GetPersonasForOpportunity.getPersonasForOpportunity';

import {
    subscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import refreshPersonas from '@salesforce/messageChannel/RefreshPersonas__c';


import { NavigationMixin } from 'lightning/navigation';

export default class PersonasForOpportunity extends NavigationMixin(LightningElement){

    @api recordId;
    @api interviews;
    @api scopingCount;
    @api reportId;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.getRecords();  
        // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                refreshPersonas,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        this.getRecords();
    }
    getRecords(){
        getPersonaForOpportunity({opptyId:this.recordId})
            .then(result => {
                let returnedInterviews = new Array();
                for(let i=0;i<result.length;i++){
                    returnedInterviews.push({
                        "id":result[i].Id,
                        "assessmentSummary":result[i].Assessment__r.Summary__c,
                        "domainName":result[i].Domain__c,
                        "assessmentId":result[i].Assessment__c,
                        "personaId":result[i].Persona__c,
                        "link":`/lightning/n/Scopingv2?c__assessmentId=${result[i].Assessment__c}&c__personaId=${result[i].Persona__c}&c__interviewId=${result[i].Id}`
                    });
    
                }

                this.interviews = returnedInterviews;
                this.title =`Scoping Assessment ( ${this.interviews.length} )`;
                this.reportLink = `/lightning/r/Report/${this.reportId}/view?fv0=${this.recordId}`;
            })
            .catch(error => {
                console.log(error);
            });
    }

    refreshClicked(event){
        this.getRecords();
    }
    navigateToPersona(event){

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Scopingv2',  
            },
            // query string parameters
            state: {
                "c__assessmentId": event.target.dataset.assessment,
                "c__personaId": event.target.dataset.persona,
                "c__interviewId": event.target.dataset.record
            }
        });
    }

}