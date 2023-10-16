import { LightningElement, api, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import isguest from '@salesforce/user/isGuest';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ASSET_STATUS_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Status__c';
import RESUABLE_ASSET_OBJ from '@salesforce/schema/gdc_ms_ReusableAsset__c';
export default class GdcmsAssetsStatusCard extends NavigationMixin(LightningElement) {
   isReadOnly = false;
   isEditOnly = true;
   @api showFooter = false;
   isGuestUser = isguest;
   assetStatus = [];
   onGoingStatus = [];

   buttonTitle;
   defaultRecordTypeId;
   @api assetData;

   @wire(getObjectInfo, { objectApiName: RESUABLE_ASSET_OBJ })
   objectInfo({ data, error }) {
      if (data) {
         this.defaultRecordTypeId = data.defaultRecordTypeId;
      }
   }

   @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: ASSET_STATUS_FIELD })
   wiredPicklist({ data, error }) {
      if (data) {
         let counter = 1;
         data.values?.forEach(d => {
            let status = {
               "label": d.label,
               "value": d.value,
               "stepNum": counter++
            }
            this.assetStatus = [...this.assetStatus, status];
         });
         this.onGoingStatus = this.onGoingStatus.concat(this.assetStatus[0], this.assetStatus.slice(3));
      } else if (error) {
         console.error(JSON.stringify(error));
      }
   }

   get isAssetStatusAvailable() {
      return this.assetStatus.length > 0 ? true : false;
   }


   get isDesktopDevice() {
      return FORM_FACTOR === "Large" ? true : false;
   }

   get leftSectionCSS() {
      if(this.isDesktopDevice) {
         return "slds-col slds-size_4-of-12";
      } else {
         return "slds-col slds-size_6-of-12";
      }
   }

   get rightSectionCSS() {
      if(this.isDesktopDevice) {
         return "slds-col slds-size_8-of-12";
      } else {
         return "slds-col slds-size_6-of-12";
      }
   }

   get isMobileDevice() {
      return FORM_FACTOR === "Small" ? true : false;
   }

   get isParkedOrRejected() {
      if (this.isAssetStatusAvailable) {
         let curPosition = this.assetStatus.find((status) => status.value === this.assetData.gdc_ms_Status__c);
         curPosition = curPosition.stepNum;
         if (curPosition === 1 || curPosition > 3)
            return false; //Status == Ideation or != Parked/Rejected
         return true; //Status = Parked/Rejected
      }
      return false;
   }

   get isRejected() {
      return this.assetData?.gdc_ms_Status__c === 'Rejected' ? true : false;
   }

   get isParked() {
      return this.assetData?.gdc_ms_Status__c === 'Parked' ? true : false;
   }

   handleEditAction(event) {
      if (this.isMobileDevice) {
         this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
               recordId: this.assetData.Id,
               objectApiName: 'gdc_ms_ReusableAsset__c',
               actionName: 'edit'
            }
         });
      } else {
         this.isEditOnly = false;
      }
   }
   handleViewAction(event) {
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

   closeModal() {
      this.isEditOnly = true;
      this.isReadOnly = false;
   }

}