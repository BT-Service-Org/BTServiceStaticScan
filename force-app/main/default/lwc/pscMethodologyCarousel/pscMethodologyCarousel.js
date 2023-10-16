import { LightningElement, track, wire } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getProductTypeValues from '@salesforce/apex/PSCProductDetailCtrl.getProductTypeValues';
import { NavigationMixin } from 'lightning/navigation'; 
import { subscribe, MessageContext } from 'lightning/messageService';
import METHOD_CARD_COMMUNICATION from '@salesforce/messageChannel/methodCardDataAvailability__c';

export default class PscMethodologyCarousel extends NavigationMixin(LightningElement) {
    bannerImageURL = PSC_IMAGES + '/banner/productBanner.png';
    bannerTitle = '';
    bannerDescription = '';
    bannerButton = '';
    buttonLabel = '';
    buttonAction='';
    index = 0;
    showCarousel = true;
    carouselData;
    @track keyName = "Methodology";

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        subscribe(this.messageContext, METHOD_CARD_COMMUNICATION, (message) => {
            this.showCarousel = message.showComponent;
        });
    }

    @wire(getProductTypeValues, { key: "$keyName" })
    productTypeConfig({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null) {
                this.carouselData = JSON.parse(data);
                for (let data of this.carouselData) {
                    data.bannerURL = PSC_IMAGES + data.bannerURL;
                }
            }
            this.dataUpdate();

        }
        if (error) {

        }
    }

    nextBannerHandler() {
        this.index++;
        if (this.index <= this.carouselData.length-1) {
            this.dataUpdate();
        } else {
            this.index = 0;
            this.dataUpdate();
        }
    }
    prevBannerHandler() {
        this.index--;
        if (this.index >= 0) {
            this.dataUpdate();
        } else {
            this.index = this.carouselData.length-1;
            this.dataUpdate();
        }
    }

    dataUpdate() {
        this.bannerTitle = this.carouselData[this.index].title;
        this.bannerDescription = this.carouselData[this.index].description;
        this.bannerImageURL = this.carouselData[this.index].bannerURL;
        this.buttonLabel = this.carouselData[this.index].buttonLabel;
        this.buttonAction = this.carouselData[this.index].action;
    }
}