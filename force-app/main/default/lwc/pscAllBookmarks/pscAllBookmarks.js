import { LightningElement, track, api } from 'lwc';
import getPSCBookmarkedArticles from '@salesforce/apex/PSCAllBookmarksCtrl.getPSCBookmarkedArticles';
import getPSCArticles from '@salesforce/apex/PSCArticlesContainerController.getPSCArticles';

export default class PscAllBookmarks extends LightningElement {
    @track records;
    @api containerTitle;
    @api pageTitle;
    @api maxResultPerPage;
    @api noResultLabel;
    @api showFavorite;
    @track dataNotFound;
    error;
    recordsToDisplay;
    totalPages = 0;
    @track currentPage = 1;
    pageNumberToDisplay = [];
    startPageNumber;
    endPageNumber;
    showPreviousButton = true;
    showNextButton = true;
    showPagination = true;

    connectedCallback() {
        if(this.containerTitle == 'My Bookmarks') {
            this.getBookmarksData();
        } else {
            this.getAllData();
        }
        
    }
    renderedCallback() {
        this.showPagination = this.totalPages > 1;
        if (this.showPagination) {
            this.setPageActive(this.currentPage);
        }
    }

    getBookmarksData() {
        getPSCBookmarkedArticles({ name: this.containerTitle })
            .then(result => {
                this.records = result.tileData;
                this.error = undefined;
                let totalNoOfRecords = this.records.length;
                if (totalNoOfRecords === 0) {
                    this.dataNotFound = true;
                }
                this.totalPages = totalNoOfRecords % this.maxResultPerPage == 0 ? totalNoOfRecords / this.maxResultPerPage : Math.floor(totalNoOfRecords / this.maxResultPerPage) + 1;
                this.recordsToDisplay = this.records.slice(0, parseInt(this.maxResultPerPage));
                this.SetPaginationTiles();
                this.hideNavigationButtons();
            })
            .catch(error => {
                console.error('error->', error);
            })
    }

    getAllData() {

        getPSCArticles({ name: this.containerTitle, maxNoOfResults: parseInt(this.maxResultPerPage) })
            .then(result => {
                this.records = result.tileData;
                this.error = undefined;
                this.records.sort((a, b) => a.recordLastUpdateDate && b.recordLastUpdateDate ? new Date(b.recordLastUpdateDate) - new Date(a.recordLastUpdateDate): '');
                let totalNoOfRecords = this.records.length;
                if (totalNoOfRecords === 0) {
                    this.dataNotFound = true;
                }
                this.totalPages = totalNoOfRecords % this.maxResultPerPage == 0 ? totalNoOfRecords / this.maxResultPerPage : Math.floor(totalNoOfRecords / this.maxResultPerPage) + 1;

    
                this.recordsToDisplay = this.records.slice(0, parseInt(this.maxResultPerPage));
                this.SetPaginationTiles();
                this.hideNavigationButtons();
            })
            .catch(error => {
                console.error('error->', error);
            })
    }

    nextHandler() {

        if ((this.currentPage < this.totalPages) && this.currentPage !== this.totalPages) {

            //increase currentPage by 1
            this.currentPage = this.currentPage + 1;

            this.setPageActive(this.currentPage);
            this.SetPaginationTiles(this.currentPage);

            this.displayRecordPerPage(this.currentPage);
            this.hideNavigationButtons();
        }
    }

    previousHandler() {

        if (this.currentPage > 1) {
            //decrease currentPage by 1
            this.currentPage = this.currentPage - 1;
            this.setPageActive(this.currentPage);
            this.SetPaginationTiles(this.currentPage);
            this.displayRecordPerPage(this.currentPage);
            this.hideNavigationButtons();
        }
    }

    hideNavigationButtons() {
        this.showPreviousButton = !(this.currentPage == 1);
        this.showNextButton = !(this.currentPage >= this.totalPages);
    }

    displayRecordPerPage(currentPage) {
        this.startingRecord = ((currentPage - 1) * this.maxResultPerPage);
        this.endingRecord = (this.maxResultPerPage * currentPage);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;
        this.recordsToDisplay = this.records.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

    SetPaginationTiles(currentPage = 1) {
        this.pageNumberToDisplay = [];
        this.startPageNumber = currentPage - 2 > 0 ? currentPage - 2 : 1;
        this.endPageNumber = currentPage + 2 > this.totalPages ? this.totalPages : currentPage + 2;

        for (let i = this.startPageNumber; i <= this.endPageNumber; i++) {
            this.pageNumberToDisplay.push(i);
        }
    }

    handlePageTileClick(event) {
        this.currentPage = Number(event.target.dataset.page);
        this.setPageActive(this.currentPage);
        this.displayRecordPerPage(this.currentPage);
        this.SetPaginationTiles(this.currentPage);
        this.hideNavigationButtons();
    }
    setPageActive(currentPage) {
        const elements = this.template.querySelectorAll('.Page-item');
        const index = this.pageNumberToDisplay.indexOf(currentPage);
        if (elements.length) {
            elements.forEach(el => {
                el.classList.remove('Page-active');

            });
            elements[index].classList.add('Page-active');
        }

    }

    handleRefresh() {
        this.getBookmarksData();
    }
}