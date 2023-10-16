import { LightningElement, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import SUCESS_OBJ from '@salesforce/schema/gdc_ms_Engagement__c';
import getStories from '@salesforce/apex/GDC_MS_DisplaySuccessStoryController.getStories';
import getPicklistValues from '@salesforce/apex/GDC_MS_DisplaySuccessStoryController.getPicklistValues';
import getStoryMembers from '@salesforce/apex/GDC_MS_DisplaySuccessStoryController.getStoryMembers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DefaultImage from '@salesforce/resourceUrl/GDCMSDefaultImage';
import isguest from '@salesforce/user/isGuest';

export default class GdcmsDisplaySucessStory extends LightningElement {

    //pagination
    currentPage = 1;
    noOfPages = 1;
    pageSize = 12;
    paginatedResult = [];
    resultsFound = false;
    isguest = isguest;

    DefaultImage = DefaultImage;
    //filterSection
    get isSmallDevice() {
        return FORM_FACTOR === "Small" ? true : false;
    }
    isApplyFilterDisabled = true;
    objectApiName = SUCESS_OBJ;
    allPicklistValues = [];
    defaultRecordTypeId;
    mainFilterValue;
    filterValue;
    options_FilterValue;
    showMembers = false;
    options_MainFilter = [
        { label: 'Geographies', value: 'gdc_ms_Geographies__c' },
        { label: 'Complexity', value: 'gdc_ms_Complexity__c' },
        { label: 'Industry', value: 'gdc_ms_Industry__c' },
    ];

    //Stories Pannels
    stories;
    allStories;
    filteredStories;
    error;
    clickedButtonLabel;

    summary;
    businessValue;
    solution;
    modalBody;
    storyName;

    open = false;

    members = new Map();
    successStoryMembers = [];

    connectedCallback() {
        getStories()
            .then(result => {
                this.allStories = result;
                this.filteredStories = result;

                if (result.length > 0) {
                    this.resultsFound = true;
                }

                this.noOfPages = Math.ceil(this.filteredStories.length / this.pageSize);
                this.stories = this.pagination(this.currentPage, this.filteredStories);
                console.log('@@this.stories::', this.stories);
            })
            .catch(error => {
                this.error = error;
            });
    }


    handleClick(event) {

        this.clickedButtonLabel = event.target.name;

        this.template.querySelector('c-gdcms-base-modal').displayModal(true);

        [this.summary, this.businessValue, this.solution, this.feedback, this.storyName] =
            [event.currentTarget.dataset.summary, event.currentTarget.dataset.bvalue, event.currentTarget.dataset.solution, event.currentTarget.dataset.feedback, event.currentTarget.dataset.story];

        if (this.clickedButtonLabel == "Engagement Summary") {
            this.modalBody = this.summary;
            this.showMembers = false;
            debugger;
            console.log(this.modalBody);
        }

        if (this.clickedButtonLabel == "Business Value Delivered") {
            this.modalBody = this.businessValue;
            this.showMembers = false;
            debugger;
            console.log(this.modalBody);
        }

        if (this.clickedButtonLabel == "Solution Complexity") {
            this.modalBody = this.solution;
            this.showMembers = false;
            debugger;
            console.log(this.modalBody);
        }

        if (this.clickedButtonLabel == "Feedback") {
            this.modalBody = this.feedback;
            this.showMembers = false;
            debugger;
            console.log(this.modalBody);
        }

        if (this.clickedButtonLabel == "Project Members") {
            this.showMembers = true;
            let storyId = event.currentTarget.dataset.id;
            this.getSuccessStoryMembers(storyId);
        }

        //this.open = true;
    }

    getSuccessStoryMembers(storyId) {

        if (this.members.get(storyId) == undefined) {
            getStoryMembers({ successStoryId: storyId })
                .then(result => {
                    let successMembers = JSON.parse(JSON.stringify(result));
                    successMembers.map(item => {
                        item.gdc_ms_Team_Member__r.Name = item.gdc_ms_Team_Member__r.Name.toLowerCase();
                    });

                    this.members.set(storyId, successMembers);
                    this.successStoryMembers = successMembers;
                })
                .catch(error => {
                    console.log(error);
                })
        }
        else {
            this.successStoryMembers = this.members.get(storyId);
        }

    }

    closeModal() {
        this.open = false;
    }

    /** Additon for Filter Fields - Start **/


    handleChange_MainFilter(event) {
        this.mainFilterValue = event.detail.value;
        getPicklistValues({ fieldString: this.mainFilterValue })
            .then(result => {
                console.log(JSON.stringify(result));
                this.options_FilterValue = result;
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleChange_filter(event) {
        this.filterValue = event.detail.value;
        this.isApplyFilterDisabled = false;
        this.handleApplyFilters();
    }

    resetSearchedResultFilters() {
        this.mainFilterValue = '';
        this.filterValue = '';
        this.options_FilterValue = [];
        this.isApplyFilterDisabled = true;
        this.filteredStories = this.allStories;
        this.currentPage = 1;
        this.noOfPages = Math.ceil(this.filteredStories.length / this.pageSize);
        this.stories = this.pagination(this.currentPage, this.filteredStories);
    }

    handleApplyFilters() {
        let allData = this.allStories;
        let filterType = this.mainFilterValue;
        let filterValue = this.filterValue;

        let fileteredStories = [];
        for (let i = 0; i < allData.length; i++) {
            const element = allData[i];
            if (element.successobj[filterType] === filterValue) {
                fileteredStories.push(element);
            }
        }

        if (fileteredStories.length != undefined && fileteredStories.length > 0) {
            this.filteredStories = fileteredStories;
            this.currentPage = 1;
            this.noOfPages = Math.ceil(this.filteredStories.length / this.pageSize);
            this.stories = this.pagination(this.currentPage, this.filteredStories);
        } else {
            this.showToast('Info', 'No Records found for applied filter.', 'info');
            this.resetSearchedResultFilters();
        }

    }
    //Pagination

    pagination(pageNumber, resultList) {
        let start = this.pageSize * (pageNumber - 1);
        let end = start + this.pageSize;

        let tempList = resultList.slice(start, end);
        return tempList;
    }

    onPrevious() {
        this.currentPage = this.currentPage > 1 ? this.currentPage - 1 : this.currentPage;
        this.stories = this.pagination(this.currentPage, this.filteredStories);
    }
    onNext() {
        this.currentPage = this.currentPage < this.noOfPages ? this.currentPage + 1 : this.currentPage;
        this.stories = this.pagination(this.currentPage, this.filteredStories);
    }

    get disableNextButton() {
        return this.currentPage === this.noOfPages ? true : false
    }

    get disablePreviousButton() {
        return this.currentPage === 1 ? true : false
    }
    /** Additon for Filter Fields - End **/


    showToast(title, messgae, type) {
        const event = new ShowToastEvent({
            title: title,
            message: messgae,
            type: type
        });
        this.dispatchEvent(event);
    }

}