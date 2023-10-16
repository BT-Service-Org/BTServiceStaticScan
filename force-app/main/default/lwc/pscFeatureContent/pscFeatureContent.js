import { LightningElement, wire, track, api } from 'lwc';
import getFeatureContent from '@salesforce/apex/PSCPageViewService.getFeatureContent';
import { CurrentPageReference } from 'lightning/navigation';
import PSC_ASSET from '@salesforce/resourceUrl/pscAssets';
export default class PscFeatureContent extends LightningElement {

    @track featureContent = [];
    @track displayFeatureContent = [];
    @track pageName = '';
    @api maxResultCount;
    @api hideFooter = false;
    fallbackImage = PSC_ASSET + '/profile_banner/FCDefaultImage.png'
    start = 0;
    end = 3;
    detailPageUrl;
    features_class;
    isNextDisableButton = false;
    isPrevDisableButton = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.pageName = currentPageReference.state?.name;
            this.detailPageUrl = '/ServicesCentral/s/all-featured-content?name=' + this.pageName;
        }
    }

    connectedCallback() {
        this.features_class = this.hideFooter ? 'features-full-container' : 'features';
    }

    @wire(getFeatureContent, { key: '$pageName', resultCount: '$maxResultCount' }) getPageSections({ data, error }) {
        if (data) {
            this.featureContent = data.map(section => {

                return {
                    ...section,
                    size: section.Section_Width__c == '25%' ? '3' : section.Section_Width__c == '33%' ? '4' : section.Section_Width__c == '50%' ? '6' : section.Section_Width__c == '75%' ? '9' : '12',
                    contentFont: section.Section_Width__c == '25%' ? 'contentfont25' : section.Section_Width__c == '33%' ? 'contentfont50' : section.Section_Width__c == '50%' ? 'contentfont50' : section.Section_Width__c == '75%' ? 'contentfont75' : 'contentfont100',
                }

            });
            this.refreshImageData(this.start, this.end);
        } else if (error) {
            console.log(error);
        }
    }
    refreshImageData(start, end) {

        this.isNextDisableButton = false;
        this.isPrevDisableButton = false;

        if (!this.hideFooter) {
            this.displayFeatureContent = [...this.featureContent.slice(start, end)]
        }
        else {
            this.displayFeatureContent = this.featureContent;
        }
        if (start == 0) {
            this.isPrevDisableButton = true;
        }
        if (end >= this.featureContent.length) {
            this.isNextDisableButton = true;
        }


    }
    prev() {
        if ((this.start - 3) >= 0) {
            this.start = this.start - 3;
        } else {
            this.start = 0;
        }
        this.end = this.start + 3;
        this.refreshImageData(this.start, this.end);
    }

    next() {
        this.start = this.end >= this.featureContent.length ? this.start : this.end;
        this.end = this.end + 3 <= this.featureContent.length ? this.end + 3 : this.featureContent.length;
        this.refreshImageData(this.start, this.end);
    }

}