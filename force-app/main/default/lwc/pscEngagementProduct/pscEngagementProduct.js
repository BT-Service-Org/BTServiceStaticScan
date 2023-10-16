import { LightningElement, wire, track, api } from 'lwc';
import PSC_SPSM_PRODUCT_IMAGES from '@salesforce/resourceUrl/pscSPSMProductImages';
import PSC_SPSM_IMAGES from '@salesforce/resourceUrl/pscSPSMImages';
import { CurrentPageReference } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getProductdata from '@salesforce/apex/PSCEngagementProductCtrl.getProductData';
import { subscribe, MessageContext } from 'lightning/messageService';
import METHOD_CARD_COMMUNICATION from '@salesforce/messageChannel/methodCardDataAvailability__c';

export default class PscEngagementProductYN extends LightningElement {
    @api engagementCardTitle;
    @api productRecordType;
    @api footerTrueTitle;
    @api footerFalseTitle;
    @api footerWarningTitle;
    @api largeScreenValue;
    fullProductData = [];
    trueProductData = [];;
    falseProductData = [];
    maybeProductData = [];
    engagementProductData = [];
    recordsToDisplay;
    methodNumber;
    methodname;
    key;
    staticResourceUsed;
    fallbackImage;
    showEngagementCard=false;

    trueImage = PSC_SPSM_PRODUCT_IMAGES + '/images/icon-project-type-true.png';
    falseImage = PSC_SPSM_PRODUCT_IMAGES + '/images/icon-project-type-false.png';
    alertImage = PSC_SPSM_PRODUCT_IMAGES + '/images/icon-warning.png';


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.methodNumber = currentPageReference.state?.methodnumber;
            this.methodname = currentPageReference.state?.methodname;
            this.key = (this.methodNumber!==undefined?this.methodNumber:(this.methodname!==undefined?this.methodname:''))
        }
    }
    

    @wire(MessageContext)
    messageContext;

    @wire(getProductdata, { key: '$key', recordTypeName: '$productRecordType', title: '$engagementCardTitle', statImgPath: PSC_SPSM_PRODUCT_IMAGES })
    fetchEngagementProductData({ error, data }) {
        if (data) {

            if (data !== null && data !== undefined) {
                let imgPathData;
                this.fullProductData = data;

                if (data.hasOwnProperty('imagePathData')) {
                    imgPathData = JSON.parse(this.fullProductData.imagePathData);
                }

                if (this.fullProductData.hasOwnProperty('trueValues') && this.fullProductData.trueValues !== undefined) {
                    this.trueProductData = this.fullProductData.trueValues.map(row => {
                        return {
                            ...row,
                            trueValue: true,
                            prodImg: this.staticResourceUsed + this.getImgPath(imgPathData, row.productName)
                        }
                    });
                }
                if (this.fullProductData.hasOwnProperty('maybeValues') && this.fullProductData.maybeValues !== undefined) {
                    this.maybeProductData = this.fullProductData.maybeValues.map(row => {
                        return {
                            ...row,
                            maybeValue: true,
                            prodImg: this.staticResourceUsed + this.getImgPath(imgPathData, row.productName)
                        }
                    });
                }
                if (this.fullProductData.hasOwnProperty('falseValues') && this.fullProductData.falseValues !== undefined) {
                    this.falseProductData = this.fullProductData.falseValues.map(row => {
                        return {
                            ...row,
                            falseValue: true,
                            prodImg: this.staticResourceUsed + this.getImgPath(imgPathData, row.productName)
                        }
                    });
                }
                this.fullProductData = [...this.trueProductData, ...this.maybeProductData, ...this.falseProductData];

                this.updateEngagementData();
            }
            else if (error) {
                console.log("Error fetching Engagement Product data", error);
            }
        }
    }

    updateEngagementData() {
        this.engagementProductData = [];
        if (this.fullProductData.length > this.recordsToDisplay) {
            this.showIcon = true;
            for (let i = 0; i < this.recordsToDisplay; i++) {
                this.engagementProductData.push(this.fullProductData[i]);
            }

        } else {
            this.engagementProductData = this.fullProductData;
        }
        if (this.template.querySelector('.engagement-products')) {
            this.template.querySelector('.engagement-products').classList.add('limited-product');

        }
    }

    getImgPath(imgPathData, rowName) {
        for (let x of imgPathData) {
            if (x.name !== undefined && x.name.toLowerCase() === rowName.toLowerCase()) {
                return x.tileUrl;
            }
        }
        return this.fallbackImage;
    }
    expandHistory() {

        this.engagementProductData = [];
        this.expand = true;
        this.engagementProductData = this.fullProductData;
        if (!this.engagementProductData.length % this.recordsToDisplay <= 1) {
            this.template.querySelector('.engagement-products').classList.remove('limited-product');
        }
    }
    collapseHistory() {
        this.updateEngagementData();
        this.expand = false;

    }
    connectedCallback() {
        subscribe(this.messageContext, METHOD_CARD_COMMUNICATION, (message) => {
            this.showEngagementCard = message.showComponent;
        });

        // logic to use different static resources
        if (this.engagementCardTitle === 'Industries') {
            this.fallbackImage = '/industry/Other.png';
            this.staticResourceUsed = PSC_SPSM_IMAGES;
        }
        else {
            this.fallbackImage = '/product/commerce.png';
            this.staticResourceUsed = PSC_SPSM_PRODUCT_IMAGES;
        }


        switch (FORM_FACTOR) {
            case 'Large':
                this.recordsToDisplay = this.largeScreenValue;
                return;
            case 'Medium':
                this.recordsToDisplay = 4;
                return;
            case 'Small':
                this.recordsToDisplay = 3;
                return;
        }
    }
}