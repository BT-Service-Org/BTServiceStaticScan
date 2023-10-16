import { LightningElement, wire, track, api } from 'lwc';
import getContainerData from '@salesforce/apex/PSCArticlesContainerController.getContainerData';
import { CurrentPageReference } from 'lightning/navigation';

export default class PscRecentQuestionsCommunity extends LightningElement {
    @track featureContent = [];
    @track displayFeatureContent = [];
    @track pageName = '';
    @api maxNoOfResults;
    isNextDisableButton = false;
    isPrevDisableButton = false;
    showDefaultMessage =  false;
    start = 0;
    end = 3;
    detailPageUrl;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.key = currentPageReference.state?.name;
        }
    }

    getPageData() {
        getContainerData({ name: 'Recent Questions', maxNoOfResults: parseInt(this.maxNoOfResults), key: this.key })
            .then(result => {
                this.records = result.tileData;
                this.showDefaultMessage = !this.records.length;
                this.error = undefined;
                this.records.sort((a, b) => a.recordLastUpdateDate && b.recordLastUpdateDate ? new Date(b.recordLastUpdateDate) - new Date(a.recordLastUpdateDate) : '');
                this.pageName = this.records[0].resourceType;
                this.refreshImageData(this.start, this.end);
                let sourceName = result?.additionaldata1;
                this.detailPageUrl = "/ServicesCentral/s/global-search/%40uri#sort=relevancy&f:@gkcsource=" + sourceName + "&f:@community_name=" + "[" + this.pageName + "]";
            })
            .catch(error => {
                console.error('error->', error);
            });


    }

    connectedCallback() {
        this.getPageData();

    }

    refreshImageData(start, end) {

        this.isNextDisableButton = false;
        this.isPrevDisableButton = false;

        this.displayFeatureContent = [...this.records.slice(start, end)];
        if (start == 0) {
            this.isPrevDisableButton = true;
        }
        if (end >= this.records.length) {
            this.isNextDisableButton = true;
        }

    }

    prev() {

        if ((this.start - 3) >= 0) {
            this.start = this.start - 3;
        } else {
            this.start = 0;
        }

        this.end = this.start + 3 <= this.records.length ? this.start + 3 : this.records.length;

        this.refreshImageData(this.start, this.end);
    }



    next() {
        this.start = this.end >= this.records.length ? this.start : this.end;
        this.end = this.end + 3 <= this.records.length ? this.end + 3 : this.records.length;

        (this.start, this.end);
        this.refreshImageData(this.start, this.end);
    }
}