import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAssetDetails from '@salesforce/apex/GDC_MS_ReusableAssetsController.getAssetDetails';
import updateAssetMembers from '@salesforce/apex/GDC_MS_ReusableAssetsController.updateAssetMembers';
import getFeedbackRecord from '@salesforce/apex/GDC_MS_ReusableAssetsController.getFeedbackRecord';
import RESUABLE_ASSET_OBJ from '@salesforce/schema/gdc_ms_ReusableAsset__c';
import ASSET_DOMAIN_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_IntendedDomainIndustries__c';
import { NavigationMixin } from 'lightning/navigation';
import isguest from '@salesforce/user/isGuest';
import loggedInUserId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import loggedInUserName from '@salesforce/schema/User.Name';
import { updateRecord } from 'lightning/uiRecordApi';
import dCount from '@salesforce/schema/gdc_ms_ReusableAsset__c.gdc_ms_Download_Count__c';
import ID_FIELD from '@salesforce/schema/gdc_ms_ReusableAsset__c.Id';
import loginMessage from '@salesforce/label/c.gdcms_login_message';
import FORM_FACTOR from '@salesforce/client/formFactor';

import updateDownloadCount from '@salesforce/apex/GDC_MS_ReminderNotifyToAssetDeveloper.updateDownloadCount';
const columns = [
	{ label: 'Role', fieldName: 'gdc_ms_Role__c' },
	{ label: 'Team Member', fieldName: 'gdc_ms_TeamMemberName' },
];

export default class ModalPopupLWC extends NavigationMixin(LightningElement) {
	@api recordId
	isGuestUser = isguest;
	currentUserName;
	currentUserId = loggedInUserId;

	@track isModalOpen = false;
	@track asset;
	@api isReadOnly;
	@track itemList;
	isContentNotLoaded = true;

	@track selectedDomainValues = [];
	domain = ASSET_DOMAIN_FIELD
	domains;
	defaultRecordTypeId;
	isRenderCallbackActionExecuted = false;
	showAssetDetails = true;

	demoLink;
	repositryLink;
	designLink;
	assetName;

	assetRating; feedbackCount; downloadCount;
	feedbackRating;
	feedbackRecordId
	isAssetCompleted

	staticMemberList;
	showTeamMemberTable;
	columns = columns;
	//Getting logged in user details
	@wire(getRecord, { recordId: loggedInUserId, fields: [loggedInUserName] })
	userDetails({ error, data }) {
		if (data) {
			this.currentUserName = data.fields.Name.value;
		} else if (error) {
			this.error = error;
		}
	}

	@wire(getObjectInfo, { objectApiName: RESUABLE_ASSET_OBJ })
	objectInfo({ data, error }) {
		if (data) {
			this.defaultRecordTypeId = data.defaultRecordTypeId;
		} else if (error) {
			this.handleError(error);
		}
	}
	@wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: ASSET_DOMAIN_FIELD })
	wiredPicklistDomain({ data, error }) {
		if (data) {
			this.domains = data.values
		} else if (error) {
			this.handleError(error);
		}
	}
	handleDomainsSelections(event) {
		this.selectedDomainValues = event.detail.value;
	}

	handleSave(event) {
		const fields = event.detail.fields;
		this.template.querySelector('lightning-record-edit-form').submit(fields);
		updateAssetMembers({ assetTeamMembers: this.itemList })
			.then(result => {
				this.showToast(`Success!!`, result, `success`);
				this.dispatchEvent(new CustomEvent('close'));
			})
			.catch(error => {
				console.error('ERROR ', error);
				this.showToast(`Error!!`, error, `error`);
			});
	}

	loadData() {
		getAssetDetails({ assetId: this.recordId })
			.then((data) => {
				this.asset = data;
				this.itemList = this.asset?.Asset_Members__r ? JSON.parse(JSON.stringify(this.asset.Asset_Members__r)) : null;
				this.error = undefined;
				this.template.querySelector("c-gdcms-base-modal").displayModal(true);
				this.isContentNotLoaded = false;
				this.isRenderCallbackActionExecuted = true;
				this.demoLink = this.asset.gdc_ms_DemoLink__c;
				this.repositryLink = this.asset.gdc_ms_RepositoryLink__c;
				this.designLink = this.asset.gdc_ms_DesignLink__c;
				this.assetRating = this.asset.gdc_ms_Asset_Rating__c;
				this.feedbackCount = this.asset.gdc_ms_Feedback_Count__c;
				this.downloadCount = this.asset.gdc_ms_Download_Count__c;
				this.isAssetCompleted = this.asset.gdc_ms_Status__c == 'Delivered' ? true : false;
				this.assetName = this.asset.gdc_ms_Title__c;
				this.makeAssetMembersList();
				//return true;
			})
			.catch((error) => {
				this.error = error;
				this.asset = undefined;
				//return false;
			});
	}

	renderedCallback() {
		if (this.isRenderCallbackActionExecuted) {
			return;
		}
		this.loadData();

	}



	getTeamMembers(event) {
		this.itemList = JSON.stringify(event.detail);
		if (this.asset) {
			this.asset.Asset_Members__r = this.itemList;
		}
	}

	openModal() {
		this.template.querySelector('c-gdcms-base-modal').displayModal(true);
	}
	closeModal() {
		this.dispatchEvent(new CustomEvent('close', {
			detail: {
				assetRating: this.assetRating, assetId: this.recordId, totalFeedbackCount: this.feedbackCount
			}
		}));
	}
	submitDetails() {
		// to close modal set isModalOpen tarck value as false
		this.isModalOpen = false;
	}

	get showAddDel() {
		return this.recordId;
	}

	showToast(titleText, msgText, variantType) {
		const event = new ShowToastEvent({
			title: titleText,
			message: msgText,
			variant: variantType
		});
		this.dispatchEvent(event);
	}
	handleError(event) {
		console.error('onerror', JSON.stringify(event))
		this.showToast(`Error Occurred!`, `Please contact your system administrator.`, `error`);
	}

	handleComments(event) {
		if (this.isGuestUser) {
			this.salesforceLogin();
		} else {
			//let url = 'https://gdcdev-dreamportal.cs198.force.com/gdc/s/detail/'+this.recordId;
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: this.recordId,
					objectApiName: 'gdc_ms_ReusableAsset__c',
					actionName: 'view'
				}
			});
		}
	}

	get headline() {
		return this.showAssetDetails ? 'Reusable Asset Details' : 'Asset Feedback';
	}

	provideFeedback(event) {
		if (this.isGuestUser) {
			this.salesforceLogin();
		} else {
			this.showAssetDetails = false;
			this.populateFeedback();
		}
	}

	salesforceLogin() {
		// console.log('url=' + window.location.href);
		let obj = {};
		obj.action = "navigate";
		obj.url = window.location.href;
		obj.isModalBox = true;
		obj.recordId = this.recordId;
		sessionStorage.clear();
		//sessionStorage.setItem('asseturl', window.location.href);
		sessionStorage.setItem('gdcMicrosite', JSON.stringify(obj));
		// console.log('Current page ' + this.CurrentPageReference);
		const event = new ShowToastEvent({
			title: 'Alert! Login Required',
			variant: 'warning',
			message: loginMessage + ' {0}',
			messageData: [
				{
					url: '/login',
					label: 'LOGIN'
				},
			],
			mode: 'Sticky'
		});
		this.dispatchEvent(event);
	}

	populateFeedback() {
		if (this.currentUserId === undefined || this.currentUserId === null ||
			this.recordId === undefined || this.recordId === null) {
			return;
		}
		getFeedbackRecord({ userId: this.currentUserId, assetId: this.recordId })
			.then(data => {
				if (data != null) {
					this.feedbackRecordId = data.Id;
					this.feedbackRating = data.gdc_ms_AssetUsageRating__c;
					// console.log('feedbackRating', this.feedbackRating);
				}
			})
			.catch(error => {
				console.error('ERROR Getting Feedback', JSON.stringify(error));
			});
	}

	showDetails(event) {
		this.showAssetDetails = true;
	}

	submitFeedbackForm(event) {
		event.preventDefault();
		const fields = event.detail.fields;
		fields.gdc_ms_AssetUsageRating__c = String(this.feedbackRating);
		fields.gdc_ms_AssetTitle__c = this.recordId;
		if (this.currentUserId) {
			fields.gdc_ms_Logged_In_User__c = loggedInUserId;
		}
		// console.log('fields ' + JSON.stringify(fields) + ' ' + this.feedbackRating);
		if (this.feedbackRating === undefined || this.feedbackRating === 0 ||
			this.feedbackRating == "undefined") {
			this.showErrorMessage = true;
			const evt = new ShowToastEvent({
				title: 'Error',
				message: 'Please fill rating!!',
				variant: 'error',
			});
			this.dispatchEvent(evt);
		} else if (this.feedbackRating <= 3 && this.feedbackSuggestion === undefined) {
			const evt = new ShowToastEvent({
				title: 'Error',
				message: 'Suggestion is Mandatory for rating equal or less than 3',
				variant: 'error',
			});
			this.dispatchEvent(evt);
		}
		else {
			this.template.querySelector('lightning-record-edit-form').submit(fields);
		}
	}

	handleSuccess(event) {
		if (this.feedbackRating === undefined || this.feedbackRating === 0 ||
			this.feedbackRating == "undefined") {
			this.showErrorMessage = true;
			const evt = new ShowToastEvent({
				title: 'Error',
				message: 'Please fill rating!!',
				variant: 'error',
			});
			this.dispatchEvent(evt);
			return;
		}
		const evt = new ShowToastEvent({
			title: 'Success',
			message: 'Your feedback has been submitted successfully!!',
			variant: 'success',
		});
		this.dispatchEvent(evt);

		setTimeout(() => {
			this.dispatchEvent(new CustomEvent('closepanel'));
		}, 0);

		this.loadData();

		window.setTimeout(() => {
			this.showAssetDetails = true;
		}, 800);

		// let myPromise = new Promise(function(myResolve, myReject) {
		//  	let res = 	this.loadData();
		// 	 if(res)
		// 		myResolve();
		//      else
		// 	 	myReject();

		//   });

		//   myPromise()
		//   .then(()=>{this.showAssetDetails = true;})
		//   .catch(()=>{console.log('Error--')})

	}

	handleError(event) {
		// console.log('asset and feedback error message++' + JSON.stringify(event.detail));
		if (event.detail && event.detail.message && event.detail.message.indexOf('The requested resource does not exist') > -1) {
			this.handleSuccess(event);
		}
		else {
			this.showErrorMessage = true;
			this.showErrorToast('Error', 'Please contact your administrator, Error Details: ' + event.detail.message + '.', 'error');
		}
	}

	navigateToDemo(event) {
		this.navigateToWeb(this.demoLink);
	}
	navigateToRepositry(event) {
		// console.log('asset count value modal popup -' + this.downloadCount + this.recordId);
		let assetCount = 0;
		if (this.downloadCount == 'undefined' || this.downloadCount == '') {
			assetCount = 1;
		}
		else {
			assetCount = Number(this.downloadCount) + 1;
		}
		const fields = {};

		fields[ID_FIELD.fieldApiName] = this.recordId;
		fields[dCount.fieldApiName] = assetCount;

		const recordInput = { fields };
		// recordInput.fields = fields;
// 		updateRecord(recordInput)
// 			.then((record) => {
// 				// console.log('Success ' + record);
// 				this.navigateToWeb(this.repositryLink);
// 			})
// 			.catch(error => {
// 				this.salesforceLogin();
// 			});
		
		updateDownloadCount({
				assetID : this.recordId
			 }).then(result=>{
				this.navigateToWeb(this.repositryLink);
			 })
			 .catch(error => {
				console.error(JSON.stringify(error));
			 });



		//this.navigateToWeb(this.repositryLink);
	}
	navigateToDesign(event) {
		this.navigateToWeb(this.designLink);
	}
	navigateToWeb(externalUrl) {
		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url: externalUrl
			}
		})
	}

	handleRatingChanged(event) {
		this.feedbackRating = event.detail.rating;
	}

	getSuggestion(event) {
		this.feedbackSuggestion = event.detail.value;
	}

	makeAssetMembersList(){
		if (this.isReadOnly && this.itemList != undefined && this.itemList != null) {
			let preparedArr = [];
			this.itemList.forEach(record => {
				let preparedRec = {};
				preparedRec.Id = record.Id;
				preparedRec.gdc_ms_Role__c = record.gdc_ms_Role__c;
				preparedRec.gdc_ms_TeamMemberName = record.gdc_ms_TeamMember__r.Name;
				preparedArr.push(preparedRec);
			});
			this.staticMemberList = preparedArr;
			this.showTeamMemberTable = this.isReadOnly && this.staticMemberList?.length > 0 ? true : false;
		}
	}

	get layoutCSS(){
        return  FORM_FACTOR ===  'Small'  ? 'layoutCssMob' : 'layoutCssDesk';
    }
}