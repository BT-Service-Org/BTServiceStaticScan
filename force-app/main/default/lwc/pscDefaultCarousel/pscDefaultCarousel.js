import { LightningElement, api, wire } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getProductTypeValues from '@salesforce/apex/PSCProductDetailCtrl.getProductTypeValues';
export default class PscDefaultCarousel extends LightningElement {

    bannerImageURL = PSC_IMAGES + '/banner/productBanner.png';
    bannerTitle = '';
    bannerDescription = '';
    bannerButton = '';
    buttonLabel = '';
    buttonUrl = '';
    index = 0;

    carouselData;
    @api keyName = "Service_Central_Carousel";

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

    connectedCallback() {
        this.autoScroll();
    }

    autoScroll() {
        setInterval(() => {
            this.nextBannerHandler();
        }, 100000);

    }

    nextBannerHandler() {
        this.index++;
        this.flag = false;
        if (this.index <= this.carouselData.length - 1) {
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
            this.index = this.carouselData.length - 1;
            this.dataUpdate();
        }
    }

    dataUpdate() {
        this.bannerTitle = this.carouselData[this.index].title;
        this.bannerDescription = this.carouselData[this.index].description;
        this.bannerImageURL = this.carouselData[this.index].bannerURL;
        this.buttonLabel = this.carouselData[this.index].buttonLabel;
        this.buttonUrl = this.carouselData[this.index].action;
    }
}