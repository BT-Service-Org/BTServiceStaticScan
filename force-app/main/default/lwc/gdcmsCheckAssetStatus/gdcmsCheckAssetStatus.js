import { LightningElement, track, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getNonPublishedAssets from '@salesforce/apex/GDC_MS_ReusableAssetsController.getNonPublishedAssets';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ASSET_STATUS_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Status__c';
import RESUABLE_ASSET_OBJ from '@salesforce/schema/gdc_ms_ReusableAsset__c';
import SUBMITTED_BY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Proposed_By__c';
import ASSET_TITLE_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Title__c';
import ASSET_DESC_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Description__c';
import ASSET_CLOUDCMPTY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_CloudCompetency__c';
import ASSET_DOMAIN_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IntendedDomainIndustries__c';
import ASSET_IDEACLASS_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IdeaClassification__c';
import ASSET_PRBLMSLVD_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_ProblemSolvedByThisAsset__c';
import ASSET_BENEFIT_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Benefits__c';
import ASSET_ISDESGNREADY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IsDesignReady__c';
const columns = [
   {
      "label": "Name",
      "fieldName": "gdc_ms_Title__c",
      "type": "text",
      "wrapText": true
   },
   {
      "label": "Proposed By",
      "fieldName": "gdc_ms_Proposed_ByName",
      "type": "text"
   },
   {
      "label": "Cloud Competency",
      "fieldName": "gdc_ms_CloudCompetency__c",
      "type": "text",
      "wrapText": true
   },
   {
      "label": "Intended Domain/Industries",
      "fieldName": "gdc_ms_IntendedDomainIndustries__c",
      "type": "text",
      "wrapText": true
   },
   {
      "label": "Idea Classification",
      "fieldName": "gdc_ms_IdeaClassification__c",
      "type": "text",
      "wrapText": true
   },
   {
      "label": "Status",
      "fieldName": "gdc_ms_Status__c",
      "type": "text"
   },
   {
      "label": "",
      "fieldName": "actionType",
      "type": "button-icon",
      "fixedWidth": 50,
      "typeAttributes": {
         "iconName": "utility:edit",
         "variant": "bare",
         "title": "Edit",
         "name": "Edit"
      },
      "cellAttributes": {
         "alignment": "center"
      }
   },
   {
      "label": "",
      "fieldName": "actionType",
      "type": "button-icon",
      "fixedWidth": 50,
      "typeAttributes": {
         "iconName": "utility:preview",
         "variant": "bare",
         "title": "View",
         "name": "View"
      },
      "cellAttributes": {
         "alignment": "center"
      }
   }
];

export default class GdcmsCheckAssetStatus extends LightningElement {

   isLoading = false;
   columns = columns;
   isCssLoaded = false;
   hasRendered = false;
   isModalOpen = false;
   assetStatusOptions = [];
   assetStatusSelectedValue;
   searchText;
   isApplyFilterDisabled = true;
   modelDetails = {};
   defaultRecordTypeId;
   myValue;
   objectApiName = RESUABLE_ASSET_OBJ;
   fields = { SUBMITTED_BY_FIELD, ASSET_TITLE_FIELD, ASSET_DESC_FIELD, ASSET_CLOUDCMPTY_FIELD, ASSET_DOMAIN_FIELD, ASSET_IDEACLASS_FIELD, ASSET_PRBLMSLVD_FIELD, ASSET_BENEFIT_FIELD, ASSET_ISDESGNREADY_FIELD }
   isModalOpen_Create = false;

   recordsCount = 100;
   recordsOffset = 0;

   pageNumberList = [];
   sectionSize = 3;
   currentSection = 0;

   get isSmallDevice() {
      return FORM_FACTOR === "Small" ? true : false;
   }
   handleCreate() {
      this.isModalOpen_Create = true;
   }
   closeModalCreate() {
      this.isModalOpen_Create = false;
   }


   @wire(getObjectInfo, { objectApiName: RESUABLE_ASSET_OBJ })
   objectInfo({ data, error }) {
      if (data) {
         this.defaultRecordTypeId = data.defaultRecordTypeId;
      }
   }

   @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: ASSET_STATUS_FIELD })
   wiredPicklist({ data, error }) {
      if (data) {
         data.values?.forEach(d => {
            if (d.value !== "Delivered")
               this.assetStatusOptions = [...this.assetStatusOptions, d];
         })
      } else if (error) {
         console.error(JSON.stringify(error));
      }
   }

   @track data = [];
   filteredData = [];

   renderedCallback() {
      if (!this.hasRendered) {
         this.getAllAssets();
      };

   }

   getAllAssets() {
      this.isLoading = true;
      getNonPublishedAssets()
         .then((result) => {
            result?.forEach((asset) => {
               asset.gdc_ms_Proposed_ByName = asset.gdc_ms_Proposed_By__r?.Name;
               asset.gdc_ms_Proposed_By_User = asset.gdc_ms_Proposed_By_User__r?.Name;
               asset.gdc_ms_IntendedDomainIndustries__c = asset.gdc_ms_IntendedDomainIndustries__c?.replaceAll(';', ' ');
               asset.gdc_ms_IdeaClassification__c = asset.gdc_ms_IdeaClassification__c?.replaceAll(';', ' ');
            })
            return result;
         }).then((result) => {
            this.data = result;
            this.filteredData = [...this.data];
            this.hasRendered = true;
            this.isLoading = false;

            // Update Records count and offset
            this.recordsOffset += this.recordsCount;

            //pagination
            this.noOfPages = Math.ceil(this.data.length / this.pageSize);
            // console.log('no of pages: ', this.noOfPages);
            this.setPageList();
            this.paginatedResult = this.pagination(this.currentPage, this.data);

         }).catch((error) => {
            console.error(`Error occurred in getAllAssets`);
            console.error(JSON.stringify(error));
         })
   }

   handleSearch(event) {
      this.searchText = event.target.value;
      if (this.searchText != undefined)
         this.isApplyFilterDisabled = false;
   }

   get resultsFound() {
      return this.filteredData.length > 0 ? true : false;
   }

   handleRowAction(event) {
      this.template.querySelector('c-gdcms-base-modal').displayModal(this.isModalOpen);
   }
   handleClose() {
      this.isModalOpen = false;
      this.dispatchEvent(new CustomEvent('close'));
   }


   handleStatusChange(event) {
      this.assetStatusSelectedValue = event.detail.value;
      if (this.assetStatusSelectedValue != undefined)
         this.isApplyFilterDisabled = false;
      this.handleApplyFilters();
   }
   handleApplyFilters() {
      this.isLoading = true;
      this.filteredData = [...this.data]
      if (this.searchText != undefined) {  //1 filter value : Text field
         let tempData = [];
         this.filteredData.forEach((asset) => {
            if (asset.gdc_ms_Title__c?.toLowerCase().includes(this.searchText.toLowerCase()) ||
               asset.gdc_ms_Proposed_ByName?.toLowerCase().includes(this.searchText.toLowerCase())) {
               let isContains = tempData.find(e => e.Id === asset.Id);
               if (!isContains)
                  tempData.push(asset);
            }
         })
         this.filteredData = [...tempData]
      }
      if (this.assetStatusSelectedValue != undefined) { //1 filter value : Status Field
         let tempData = [];
         this.filteredData.forEach((asset) => {
            if (asset.gdc_ms_Status__c?.toLowerCase() === this.assetStatusSelectedValue.toLowerCase()) {
               let isContains = tempData.find(e => e.Id === asset.Id);
               if (!isContains)
                  tempData.push(asset);
            }
         })
         this.filteredData = [...tempData]
      }

      //pagination
      this.currentPage = 1;
      this.currentSection = 0;
      this.noOfPages = Math.ceil(this.filteredData.length / this.pageSize);
      this.setPageList();
      this.paginatedResult = this.pagination(this.currentPage, this.filteredData);
      this.isLoading = false;
   }

   resetSearchedResultFilters() {
      this.assetStatusSelectedValue = null;
      this.searchText = null;
      this.filteredData = [...this.data];
      this.isApplyFilterDisabled = true;

      //pagination
      this.currentPage = 1;
      this.currentSection = 0;
      this.noOfPages = Math.ceil(this.filteredData.length / this.pageSize);
      this.setPageList();
      this.paginatedResult = this.pagination(this.currentPage, this.filteredData);

   }


   onScroll() {
      let mydiv = this.template.querySelector('.assets-list')
      if (mydiv.scrollTop >= mydiv.scrollHeight * 0.8) {
         this.getAllAssets(this.recordsCount, this.recordsOffset);
      }

   }

   //Pagination

   currentPage = 1;
   noOfPages = 1;
   pageSize = 10;
   paginatedResult = [];

   pagination(pageNumber, resultList) {
      let start = this.pageSize * (pageNumber - 1);
      let end = start + this.pageSize;

      let tempList = resultList.slice(start, end);
      return tempList;
   }

   onPrevious() {
      // this.currentPage = this.currentPage > 1 ? this.currentPage - 1 : this.currentPage;
      this.currentSection -= 1;
      this.setPageList();
      // this.paginatedResult = this.pagination(this.currentPage, this.filteredData);
   }
   onNext() {
      // this.currentPage = this.currentPage < this.noOfPages ? this.currentPage + 1 : this.currentPage;
      this.currentSection += 1;
      this.setPageList();
      // this.paginatedResult = this.pagination(this.currentPage, this.filteredData);
   }

   get disableNextButton() {
      return (this.currentSection * this.sectionSize) + this.sectionSize >= this.noOfPages ? true : false
   }

   get disablePreviousButton() {
      return this.currentSection === 0 ? true : false
   }

   initiateSearchOnEnter(event) {
      if (event.code == 'Enter' && this.searchText != undefined) {
         this.handleApplyFilters();
      }
   }

   setPageList() {
      this.pageNumberList = [];
      for(let i = this.currentSection * this.sectionSize; (i < (this.currentSection * this.sectionSize) + this.sectionSize) && i < this.noOfPages; i++) {
         this.pageNumberList.push({
            pageNumber: i + 1,
            style: this.currentPage == i + 1 ? 'slds-badge slds-badge_lightest pageNumberSelected pageNumber' : 'slds-badge slds-badge_lightest pageNumber'
         })
      }
   }

   pageNumberHandler(event) {
      this.currentPage = event.currentTarget.dataset.pagenumber;
      for(let page of this.pageNumberList) {
         page.style = this.currentPage == page.pageNumber ? 'slds-badge slds-badge_lightest pageNumberSelected pageNumber' : 'slds-badge slds-badge_lightest pageNumber'
      }
      this.paginatedResult = this.pagination(this.currentPage, this.filteredData);
   }

}