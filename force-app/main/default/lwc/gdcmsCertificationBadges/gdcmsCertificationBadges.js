/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used for displaying at most 12 certificates in the gdcmsTeamMemberQuickDetails and gdcmsTeamMemberProfile component.
 ****************************/

import { LightningElement,api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import GDCMS from '@salesforce/messageChannel/gdcms__c';

export default class GdcmsCertificationBadges extends LightningElement {

    showMore = true;
    labelShowMore = "Show All";
    certs = [];
    @api listOfCerts; 
    @api title;
    @api showMoreAsModal = false

    allCerts = [];

    displayView = true;
    get showButton(){
        return this.listOfCerts && this.listOfCerts.length > 12
    }

    renderedCallback(){
        var hover = this.template.querySelector('[data-id="badges"]')
        if(this.showMoreAsModal && hover){
            hover.classList.add('hover-effect');
        }
    }

    @api
    updateCerts(certs){
        this.listOfCerts = JSON.parse(JSON.stringify(certs));
        let listOfCerts = this.listOfCerts;
        this.allCerts = listOfCerts;
        this.certs = JSON.parse(JSON.stringify(listOfCerts.length <=12 ? listOfCerts : listOfCerts.slice(0,12)));
    }

    handleShowMore(){        
        let listOfCerts = this.listOfCerts;
        if(this.showMoreAsModal){
            this.template.querySelector('c-gdcms-base-modal').displayModal(true);
            setTimeout(()=> this.template.querySelector('c-gdcms-certificates-body').updateCerts(this.listOfCerts), 1E2);
            return;
        }
        this.certs = JSON.parse(JSON.stringify(this.showMore ? listOfCerts : (listOfCerts.length <=12 ? listOfCerts : listOfCerts.slice(0,12))));
        this.labelShowMore = this.showMore ? 'Hide' : 'Show All' ;
        this.showMore = !this.showMore;  
    }

    get certTitle(){
        return `${this.title}'s Certifications`;
    }

    handleClose(){
        this.showMore = false;
    }

    connectedCallback() {
		if (!this.subscription) {
			this.subscribeToMessageChannel();
		}
	}

    @wire(MessageContext)
	messageContext;

	subscribeToMessageChannel() {
		this.subscription = subscribe(
			this.messageContext,
			GDCMS,
			(message) => this.handleMessage(message)
		);
	}

	handleMessage(message) {
		//Handling Hide and unhide of Header from Print Profile
		let disp = message.displayView;
		if (disp == false) {
			this.displayView = false;
			return;
		}
		else {
			this.displayView = true;
			return;
		}
	}

}