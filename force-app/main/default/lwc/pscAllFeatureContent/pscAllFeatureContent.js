import { LightningElement, wire, track } from 'lwc';
import getAllFeatureContent from '@salesforce/apex/PSCPageViewService.getAllFeatureContent';
import PSC_ASSETS from '@salesforce/resourceUrl/pscAssets';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class PscAllFeatureContent extends LightningElement {


    // cardsContainer='';
    // @track translateXValue = 0;
    @track allFeatureContent = [];
    @track displayFeatureContent = [];
    start;
    end;
    incrementValue = 3;
    isNextDisableButton = false;
    isPrevDisableButton = false;
    fallbackImageUrl = PSC_ASSETS + '/profile_banner/dark-blue.png'
    hidePreviousbtn = true;
    hideNextbtn = true;
    logoImage = PSC_IMAGES + '/Icons/communities.png'



    @wire(getAllFeatureContent) getAllFeatureContent({ data, error }) {
        if (data) {
            this.allFeatureContent = data.map(obj => {
                return {
                    ...obj,
                    imageUrl__c: obj.imageUrl__c ? obj.imageUrl__c : this.fallbackImageUrl,
                    bgUrl: obj.imageUrl__c ? `background-image:url("${obj.imageUrl__c}");background-size: 100% 100%;background-repeat: no-repeat;border-radius:8px;filter: grayscale(25%);` : `background-image:url("${this.fallbackImageUrl}");background-size: 100% 100%;background-repeat: no-repeat;border-radius:8px;filter: grayscale(25%);`
                }
            });
        }
        if (this.allFeatureContent.length) {
            this.refreshImageData(this.start, this.end);
        }

    }

    refreshImageData(start, end) {
        this.isNextDisableButton = false;
        this.isPrevDisableButton = false;

        this.displayFeatureContent = this.allFeatureContent.slice(start, end);

        if (start == 0) {
            this.isPrevDisableButton = true;
        }
        if (end >= this.displayFeatureContent.length) {
            this.isNextDisableButton = true;
        }
        if (this.start <= 0) {

            if (this.template.querySelector('[data-id="prev"]')) {
                this.template.querySelector('[data-id="prev"]').classList.add('disable');
            }
        } else if (this.template.querySelector('[data-id="prev"]')) {
            this.template.querySelector('[data-id="prev"]').classList.remove('disable')
        }

        if (this.end >= this.allFeatureContent.length) {
            if (this.template.querySelector('[data-id="next"]')) {
                this.template.querySelector('[data-id="next"]').classList.add('disable')
            }
        } else if (this.template.querySelector('[data-id="next"]')) {
            this.template.querySelector('[data-id="next"]').classList.remove('disable')
        }


        this.hidePreviousbtn = this.start <= 0;
        this.hideNextbtn = this.end >= this.allFeatureContent.length;

    }

    prevBannerHandler() {
        if ((this.start - this.incrementValue) >= 0) {
            this.start = this.start - this.incrementValue;
        } else {
            this.start = 0;
        }
        this.end = this.start + this.incrementValue;
        this.refreshImageData(this.start, this.end);

    }

    nextBannerHandler() {
        this.start = this.end >= this.allFeatureContent.length ? this.start : this.end;
        this.end = this.end + this.incrementValue <= this.allFeatureContent.length ? this.end + this.incrementValue : this.allFeatureContent.length;
        this.refreshImageData(this.start, this.end);
    }

    get getLogo() {
        return `background-image:url("${this.logoImage}");`
    }


    connectedCallback() {

        switch (FORM_FACTOR) {
            case 'Large':
                this.start = 0;
                this.end = 3;
                this.refreshImageData(this.start, this.end);
                return;
            case 'Medium':
                this.start = 0;
                this.end = 2;
                this.incrementValue = 2;
                this.refreshImageData(this.start, this.end);
                return;
            case 'Small':
                this.start = 0;
                this.end = 1;
                this.incrementValue = 1;
                this.refreshImageData(this.start, this.end);
                return;
        }

    }
}