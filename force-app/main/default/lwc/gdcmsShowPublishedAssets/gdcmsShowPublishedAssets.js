import { LightningElement, track, wire } from 'lwc';
import getPublishedAssets from '@salesforce/apex/GDC_MS_ReusableAssetsController.getPublishedAssets';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ASSET_STATUS_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_CloudCompetency__c';
import ASSET_INDUSTRY_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IntendedDomainIndustries__c';
import RESUABLE_ASSET_OBJ from '@salesforce/schema/gdc_ms_ReusableAsset__c';
import SALESFORCE_LOGO_URL from "@salesforce/resourceUrl/GDC_MS_Logo";
import FORM_FACTOR from '@salesforce/client/formFactor';
import dCount from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Download_Count__c';
import ID_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.Id';

import updateDownloadCount from '@salesforce/apex/GDC_MS_ReminderNotifyToAssetDeveloper.updateDownloadCount';



export default class GdcmsShowPublishedAssets extends LightningElement {
   salesforceLogo = SALESFORCE_LOGO_URL;
   isLoading = false;
   isCssLoaded = false;
   hasRendered = false;
   searchText;
   isApplyFilterDisabled = true;
   defaultRecordTypeId;
   assetCloudOptions;
   assetIndustryOptions;
   assetCloudSelectedValue;
   assetIndustrySelectedValue;
   // assetStatusSelectedValue;
   searchText;
   isApplyFilterDisabled = true;
   resultsFound = false;
   isReadOnly = false;
   @track items = [];
   @track filteredData;
   loopAssetId;
   totalFeedbackCount;



   get isSmallDevice() {
      return FORM_FACTOR === "Small" ? true : false;
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
         this.assetCloudOptions = data.values
      } else if (error) {
         console.error(JSON.stringify(error));
      }
   }
   @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: ASSET_INDUSTRY_FIELD })
   wiredIndustryPicklist({ data, error }) {
      if (data) {
         this.assetIndustryOptions = data.values
      } else if (error) {
         console.error(JSON.stringify(error));
      }
   }
   _wiredMarketData;
   @wire(getPublishedAssets)
   wireAsset(wireResult) {
      const { data, error } = wireResult;
      this._wiredMarketData = wireResult;
      if (data?.length > 0) {
         this.items = data;
         this.filteredData = [...this.items];
         /* this.filteredData.forEach((asset) => {
            //check visibility of the button group.
            let temp = Object.assign({}, asset);

            if (temp.gdc_ms_DesignLink__c || temp.gdc_ms_DemoLink__c || temp.gdc_ms_RepositoryLink__c)
               temp.areLinksAvailable = true;
            else
               temp.areLinksAvailable = false;
            
            asset = temp;
         }) */

         this.resultsFound = true;
      }
      else if (error) {
         console.error(JSON.stringify(error));
      }
   }


   handleDemoClick(event) {
      window.open(event.currentTarget.dataset.demolink)
   }
   handleDesignClick(event) {
      window.open(event.currentTarget.dataset.designlink)
   }
   handleRepositoryClick(event) {
      let assetCount = 0;
      let repolink = event.currentTarget.dataset.reposlink;
      if (event.currentTarget.dataset.assetcount == 'undefined' || event.currentTarget.dataset.assetcount == '') {
         assetCount = 1;
      }
      else {
         assetCount = Number(event.currentTarget.dataset.assetcount) + 1;
      }
      const fields = {};
      //fields.Id = event.target.dataset.assetid;
      //fields.gdc_ms_Download_Count__c = assetCount;
      fields[ID_FIELD.fieldApiName] = event.currentTarget.dataset.assetid;
      fields[dCount.fieldApiName] = assetCount;

      const recordInput = { fields };
      // recordInput.fields = fields;
//       updateRecord(recordInput)
//          .then((record) => {
//             window.open(repolink);
//          })
//          .catch(error => {
//             console.error(JSON.stringify(error));
//          });
           updateDownloadCount({
            assetID : event.currentTarget.dataset.assetid
         }).then(result=>{
            window.open(repolink);
         })
         .catch(error => {
            console.error(JSON.stringify(error));
         });
   }

   handleOpenAsset(event) {
      this.loopAssetId = event.currentTarget.dataset.assetid;
      if (this.isMobileDevice) {
         this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
               recordId: this.assetData.Id,
               objectApiName: 'gdc_ms_ReusableAsset__c',
               actionName: 'view'
            }
         });
      } else {
         this.isReadOnly = true;
      }
   }

   initiateSearchOnEnter(event) {
      if (event.code == 'Enter' && this.searchText != undefined) {
         this.handleApplyFilters();
      }
   }

   handleSearch(event) {
      this.searchText = event.target.value;
      if (this.searchText != undefined)
         this.isApplyFilterDisabled = false;
   }
   handleApplyFilters() {
      this.isLoading = true;
      
      this.filteredData = [...this.items];
      if (this.searchText != undefined) {
         let tempData = [];
         this.filteredData?.forEach((asset) => {
            if (asset.gdc_ms_Title__c?.toLowerCase().includes(this.searchText.toLowerCase()) ||
               asset.gdc_ms_Proposed_ByName?.toLowerCase().includes(this.searchText.toLowerCase())) {
               let isContains = tempData.find(e => e.Id === asset.Id);
               if (!isContains)
                  tempData.push(asset);
            }
         })
         this.filteredData = [...tempData]
      }
      if (this.assetCloudSelectedValue != undefined) {
         let tempData = [];
         this.filteredData?.forEach((asset) => {
            if (asset.gdc_ms_CloudCompetency__c?.toLowerCase() === this.assetCloudSelectedValue.toLowerCase()) {
               let isContains = tempData.find(e => e.Id === asset.Id);
               if (!isContains)
                  tempData.push(asset);
            }
         })
         this.filteredData = [...tempData]
      }
      if (this.assetIndustrySelectedValue != undefined) {
         let tempData = [];
         this.filteredData?.forEach((asset) => {
            let industryDomain = asset?.gdc_ms_IntendedDomainIndustries__c?.split(';');
            if (industryDomain && industryDomain.find(e => e.toLowerCase() === this.assetIndustrySelectedValue.toLowerCase())) {
               let isContains = tempData.find(e => e.Id === asset.Id);
               if (!isContains)
                  tempData.push(asset);
            }
         })
         this.filteredData = [...tempData]
      }
      if (this.filteredData.length <= 0) {
         this.resultsFound = false;
      } else {
         this.resultsFound = true;
      }
      this.isLoading = false;
   }

   resetSearchedResultFilters() {
      // this.assetStatusSelectedValue = null;
      this.assetCloudSelectedValue = null;
      this.assetIndustrySelectedValue = null;
      this.searchText = null;
      this.filteredData = [...this.items];
      this.isApplyFilterDisabled = true;
      this.resultsFound = true;
   }
   handleCloudChange(event) {
      this.assetCloudSelectedValue = event.detail.value;
      if (this.assetCloudSelectedValue != undefined)
         this.isApplyFilterDisabled = false;
      this.handleApplyFilters();
   }
   handleIndustryChange(event) {
      this.assetIndustrySelectedValue = event.detail.value;
      if (this.assetIndustrySelectedValue != undefined)
         this.isApplyFilterDisabled = false;
      this.handleApplyFilters();
   }
   // On hover of icons, position the tooltip
   top;
   handleButtonHover(event) {
      this.top = event.offsetY;
      button = event;
   }

   get styleOnHover() {
      return `position: absolute;bottom: ${this.top + 30}px;margin: 1em;`;
   }
   handleViewAction(event, isButtonMenu) {
      this.loopAssetId = isButtonMenu ? event.target.dataset.assetid : event.target.dataset.key;
      if (this.isMobileDevice) {
         this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
               recordId: this.assetData.Id,
               objectApiName: 'gdc_ms_ReusableAsset__c',
               actionName: 'view'
            }
         });
      } else {
         this.isReadOnly = true;
      }
   }
   closeModal(event) {
      this.isReadOnly = false;
      this.totalFeedbackCount = event.detail.totalFeedbackCount;
      //this.template.querySelector('[data-id = ' + event.detail.assetId + ']').value = event.detail.assetRating;
      let star = this.template.querySelector(`c-gdcms-five-star-rating[data-id="${event.detail.assetId}"]`);
      // star.classList.toggle('slds-hide');
      star.value = event.detail.assetRating;
      star.totalFeedbackCount = event.detail.totalFeedbackCount;
      star.initializeRating();
      // star.classList.toggle('slds-hide');
   }

   handleOnselectMenu(event) {
      this.selectedItemValue = event.detail.value;
      if (this.selectedItemValue === 'designDocument') {
         this.handleDesignClick(event);
      } else if (this.selectedItemValue === 'assetDemo') {
         this.handleDemoClick(event);
      } else if (this.selectedItemValue === 'repositoryLink') {
         this.handleRepositoryClick(event);
      } else if (this.selectedItemValue === 'openAsset') {
         this.handleViewAction(event, true);
      }

   }
   handleRatingChanged(event) {
      // console.log('value' + event.detail);
   }

   toggleCardMenu(event) {
      const assetId = event.currentTarget.dataset.assetid;
      if(assetId) {
         event.stopPropagation();
         event.currentTarget.classList.toggle('slds-is-open');
      }

      let cardMenuItems = this.template.querySelectorAll('.slds-is-open');
      for(let i = 0; i < cardMenuItems.length; i++) {
         if(!assetId || cardMenuItems[i].dataset.assetid !== assetId) {
            cardMenuItems[i].classList.remove('slds-is-open');
         }
      }
   }
}