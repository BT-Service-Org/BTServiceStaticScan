import { LightningElement, track, api } from 'lwc';
import getPSCArticles from '@salesforce/apex/PSCArticlesContainerController.getPSCArticles';
import { NavigationMixin } from 'lightning/navigation';
export default class PSCArticlesContainer extends NavigationMixin(LightningElement) {
    @track records;
    @api containerTitle;
    @api maxNoOfResults;
    @api noResultLabel;
    @api showFavorite;
    @api showFooterFromMeta;
    @api showAllPageAPIName;
    @track dataNotFound;
    showFooter;
    error;
    favoritesAllData;
    favFound = false;
    recordsToDisplay;

    connectedCallback() {
        this.getPageData();
    }

    getPageData() {
        getPSCArticles({ name: this.containerTitle, maxNoOfResults: parseInt(this.maxNoOfResults) })
            .then(result => {
                this.records = result.tileData;
                this.error = undefined;
                this.records.sort((a, b) => a.recordLastUpdateDate && b.recordLastUpdateDate ? new Date(b.recordLastUpdateDate) - new Date(a.recordLastUpdateDate): '');
                let totalNoOfRecords = this.records.length;
                if (totalNoOfRecords === 0) {
                    this.dataNotFound = true;
                }
                if (totalNoOfRecords > parseInt(this.maxNoOfResults)) {
                    this.showFooter = true;
                }
                else {
                    this.showFooter = false;
                }
                this.recordsToDisplay = this.records.slice(0, parseInt(this.maxNoOfResults));
            })
            .catch(error => {
                console.error('error->', error);
            })
    }

    handleRefresh() {
        this.getPageData();
    }

    handlViewAllNavigation(event) {
        if (event.which == '13' || event.which == '1') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: this.showAllPageAPIName
                }
            });
        }
    }
}