import { LightningElement, wire, track, api } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import GDCMS from '@salesforce/messageChannel/gdcms__c';
import FORM_FACTOR from '@salesforce/client/formFactor';
import footerText from '@salesforce/label/c.gdcms_footerText';
import FOOTER_IMAGE_URL from '@salesforce/resourceUrl/GDC_MS_Footer_Image';

export default class GdcmsFooter extends LightningElement {

	@api ContentId;
	footerImage;
	showForm = true;
	showContactUsUtilityDocker = false;
	footerText = footerText;
	displayView = true;

	@track mapOfFooterLinks = [];

	handleContactUs(event) {
		event.preventDefault();
		if (!this.showContactUsUtilityDocker) {
			this.showContactUsUtilityDocker = true;
		}
	}

	get bgImage() {
		return `background:url(${FOOTER_IMAGE_URL}) center center /cover; width: 100%; height:100%; border : 1px solid #D4D4D4`;
	}
	closePanel() {
		this.showContactUsUtilityDocker = false;
	}

	onFormSubmit(event) {
		event.preventDefault();
		const fields = event.detail.fields;
	}

	get isDesktop() {
		return FORM_FACTOR === 'Large'
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