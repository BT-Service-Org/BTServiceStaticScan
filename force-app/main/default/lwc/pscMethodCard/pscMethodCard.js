import { LightningElement, track, api, wire } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import PSC_SPSM_IMAGES from '@salesforce/resourceUrl/pscSPSMImages';
import getMethodCardData from '@salesforce/apex/PSCMethodCardCtrl.getMethodCardData';
import { publish, MessageContext } from 'lightning/messageService';
import METHOD_CARD_COMMUNICATION from '@salesforce/messageChannel/methodCardDataAvailability__c';

export default class PscMethodCard extends LightningElement {
    @api methodIds = [];
    @track methodOwnerShip = [];
    trueImage = PSC_IMAGES + '/Icons/icon-project-type-true.png';
    falseImage = PSC_IMAGES + '/Icons/icon-project-type-false.png';
    noresultImage = PSC_SPSM_IMAGES + '/images/NoResults.png';
    resultFound = true;

    @track methodId;
    @track methodCardData = [];;
    @api showFullDescription;
    methodLink;

    @wire(MessageContext)
    messageContext;

    @wire(getMethodCardData, { key: "$methodIds"})
    fetchRevisionHistoryData({ error, data }) {
        if (data) {
            this.methodCardData = data;
            this.methodOwnerShip = this.methodCardData[0]?.Method_Ownerships_by_Product__r != null ? [...this.methodCardData[0]?.Method_Ownerships_by_Product__r] : [];
            this.resultFound = this.methodCardData.length ? true : false;
            this.publishMessage();

        }
        if (error) {
            console.log("error occured while fetching Method card data", error);
        }

    }

    publishMessage() {
        const payload = { showComponent: this.resultFound }; // or false, depending on your logic
        publish(this.messageContext, METHOD_CARD_COMMUNICATION, payload);
    }

    renderedCallback() {
        if (this.methodOwnerShip.length && this.template.querySelector('.method-title-description ')!=null) {
            this.template.querySelector('.method-title-description ').classList.add('desc');
        }
    }

}