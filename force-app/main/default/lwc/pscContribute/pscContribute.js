import { LightningElement, track, wire } from 'lwc';
import getDependentPicklistValues from '@salesforce/apex/PSCContributeCtrl.getDependentPicklistValues';
import getTagName from '@salesforce/apex/PSCContributeCtrl.getTagName';
import getContributeData from '@salesforce/apex/PSCContributeCtrl.getContributeData';
import deleteContentDocument from '@salesforce/apex/PSCContributionService.deleteContentDocument';
import getKnowlegdeRecordType from '@salesforce/apex/PSCContributeCtrl.getKnowlegdeRecordType';
import updateContributeData from '@salesforce/apex/PSCContributeCtrl.updateContributeData';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import pscContributeAutoPublishResouces from '@salesforce/label/c.PSC_Contribute_Auto_Publish_Resouces';
import pscContributeErrorMessage from '@salesforce/label/c.PSC_Contribute_Error_Message';
import pscContributeSuccessMessage from '@salesforce/label/c.PSC_Contribute_Success_Message';
import pscContributeSubmitForReview from '@salesforce/label/c.PSC_Contribute_Submit_For_Review_Label';
import pscContributeSubmitForReviewFlowApiName from '@salesforce/label/c.PSC_Contribute_Submit_For_Review_Flow_Api_Name';
import pscContributeSuccessPageHeader from '@salesforce/label/c.PSC_Contribute_Success_Page_Header';
import pscContributeSuccessRAPageHeader from '@salesforce/label/c.PSC_Contribute_Success_Page_Header_RA';
import pscContributeSuccessPageBody from '@salesforce/label/c.PSC_Contribute_Success_Page_Body';
import pscContributeSuccessRAPageBody from '@salesforce/label/c.PSC_Contribute_Success_Page_Body_For_RA';
import pscContributeSuccessPageBodyPublished from '@salesforce/label/c.PSC_Contribute_Success_Page_Body_For_Published';
import pscContributeSuccessPageButtonLabel from '@salesforce/label/c.PSC_Contribute_Success_Page_Button';
import pscContributeSuccessPageButtonPublishedLabel from '@salesforce/label/c.PSC_Contribute_Success_Page_Button_For_Published';
import pscContributeSuccessRAPageButtonPublishedLabel from '@salesforce/label/c.PSC_Contribute_Success_Page_Button_For_Published_RA';
import pscContributeSubmitButtonLabel from '@salesforce/label/c.PSC_Contribute_Submit_Button_Label';
import pscContributeSaveButtonLabel from '@salesforce/label/c.PSC_Contribute_Save_Button_Label';
import pscContributeSubmitForReviewHelpText from '@salesforce/label/c.PSC_Contribute_Submit_For_Review_Helptext';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ASSET_LOCATION from '@salesforce/schema/Article_Link__c.Asset_Location__c';
import ASSET_LINK from '@salesforce/schema/Article_Link__c';
import { createRecord, getFieldValue } from 'lightning/uiRecordApi';
import ARTICLE_TAG from '@salesforce/schema/Article_Tags__c';
import TAG_OBJECT from '@salesforce/schema/Tag__c';
import NAME_FIELD from '@salesforce/schema/Tag__c.Name';

export default class PscContribute extends NavigationMixin(LightningElement) {
    value = '';
    orignalPicklistData;
    @track industryData;
    @track productData;
    @track roleData;
    @track show1Page = true;
    @track reusableAssetPageOne = false;
    renderFlow = false;
    flowApiName;
    submitForReview = false;
    submitForRAReview=false;
    @track flowInputVariables;
    assetTypeValue;
    resourceTypeValue;
    selectedIndustries = [];
    selectedProducts = [];
    selectedRoles = [];
    selectedUsers = [];
    @track articleLinksToInsert = [];
    @track articleTagsToInsert = [];
    recordTypeId = '';
    knowledgeArticle = '';
    reusableAssetId;
    showSpinner = false;
    assetLocationOptions;
    @track autoPublishResouces = pscContributeAutoPublishResouces.split(',') || [];
    @track contentDocumentIds = [];
    showSuccessPage = false;
    isReusableAsset = false;
    showButtons = false;
    orgBaseUrl = '';
    urlName = '';
    articleButtonLabel = pscContributeSuccessPageButtonLabel;
    articleRAButtonLabel = pscContributeSuccessRAPageButtonPublishedLabel;
    successPageBody = pscContributeSuccessPageBody;
    reusableSuccessPageBody = pscContributeSuccessRAPageBody;
    submitForReviewHelpText = pscContributeSubmitForReviewHelpText;
    contributeImageURL = PSC_IMAGES + '/banner/Contribute_banner.png';
    pscContributeSubmitForReviewLabel = pscContributeSubmitForReview;
    pscContributeSubmitForReviewFlowApiNameLabel = pscContributeSubmitForReviewFlowApiName;
    pscContributeSuccessPageHeaderLabel = pscContributeSuccessPageHeader;
    pscContributeSuccessRAPageHeaderLabel = pscContributeSuccessRAPageHeader;
    @track Article_Link__c = {};
    @track Article_Tags__c = {};
    assetLoc;
    tagText;
    userGuideUrl = "https://docs.google.com/document/d/17tLNH38iSaALpPk5gK5QvHCOiov4RET29uZsN18xdvY/edit"

    assetUrl;
    isDealSizeArticle = false;
    tags_modal = false;
    link_modal = false;
    errorFound = false;
    errorMsg = '';
    articleTagRecTypeId = '';
    targetAudienceHelpText = "Use this search field to find applicable roles for your Target Audience. Your options are Account Management, Design, Engagement Delivery, Solution Consulting, Strategy, Technical Consulting, or Human-Centered Change"


    @wire(getDependentPicklistValues, {})
    wiredPicklistData(data, error) {
        if (data) {
            if (data !== null && data.data !== undefined) {
                this.orignalPicklistData = data.data;
            }
        }
        else if (error) {
            console.log(error);
        }
    }

    @wire(getContributeData)
    wiredContributeData(data, error) {
        if (data) {
            if (data !== null && data.data !== undefined) {
                this.industryData = data.data[0];
                this.productData = data.data[1];
                this.roleData = data.data[2];
            }
        }
        else if (error) {
            console.log(error);
        }
    }


    // Article Tag RecId
    @wire(getObjectInfo, { objectApiName: ARTICLE_TAG })
    wiredArticleTagData({ data, error }) {
        if (data) {
            const recTyps = data.recordTypeInfos;
            this.articleTagRecTypeId = Object.keys(recTyps).find(recTyp => recTyps[recTyp].name === 'Tag Relationship');
        }
        else if (error) {
            console.error(error);
        }
    }

    @wire(getKnowlegdeRecordType)
    getKnowlegdeRecordType(data, error) {
        if (data && data.data) {
            this.recordTypeId = data.data;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: ASSET_LINK })
    assetLinkMetadata;

    @wire(getPicklistValues, { recordTypeId: '$assetLinkMetadata.data.defaultRecordTypeId', fieldApiName: ASSET_LOCATION })
    WiredStatusPicklist({ error, data }) {
        if (data) {
            let options = [];
            for (var i = 0; i < data.values.length; i++) {
                options.push({ label: data.values[i].label, value: data.values[i].value });
            }
            this.assetLocationOptions = options;
        }
        if (error) {
            console.log(error);
        }
    }

    get submitButtonLabel() {
        return this.submitForReview ? pscContributeSubmitButtonLabel : pscContributeSaveButtonLabel;
    }

    get isNextButtonDisabled() {
        return !(this.resourceTypeValue && this.assetTypeValue);
    }

    handleLoad() {
        this.showSpinner = false;
        this.showButtons = true;
    }

    async handle1stPageNext() {
        if (this.resourceTypeValue && this.assetTypeValue) {
            this.show1Page = !this.show1Page;
            this.showSpinner = !this.show1Page;
            this.isReusableAsset = this.resourceTypeValue == 'Reusable Assets' ? true : false;
            this.isDealSizeArticle = this.assetTypeValue == 'Customer Stories' || this.assetTypeValue == 'Project Deliverables - Pre-Sales' ? true : false;
            this.reusableAssetPageOne = this.isReusableAsset;
            this.selectedProducts = [];
            if (this.contentDocumentIds && this.contentDocumentIds.length > 0) {
                await this.removeContentDocument();
            }
            this.handleReset();
        }
        this.navigateToTop();
    }

    handleAssetTypeSelect(event) {
        this.assetTypeValue = event.target.value;
        this.resourceTypeValue = event.target.dataset.key;
        this.isReusableAsset = this.resourceTypeValue == 'Reusable Assets' ? true : false;
        this.reusableAssetPageOne = true;
    }

    handleIndustriesChange(event) {
        this.selectedIndustries = [...event.detail.selRecords];
    }

    handleProductChange(event) {
        this.selectedProducts = [...event.detail.selRecords]
    }

    handleRoleChange(event) {
        this.selectedRoles = [...event.detail.selRecords]
    }

    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        let fields = event.detail.fields;
        this.urlName = encodeURIComponent(fields['Title']).trim().replace(/[_.!~*'%-()]/g, '');
        fields['UrlName'] = this.urlName;
        fields['Asset_Type__c'] = this.assetTypeValue;
        fields['Resource_Type__c'] = this.resourceTypeValue;
        this.showSpinner = true;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSubmitReview(event) {
        this.submitForReview = event.detail.checked;
    }

    async removeContentDocument() {
        if (this.contentDocumentIds && this.contentDocumentIds.length > 0) {
            try {
                await deleteContentDocument({ contentIdString: JSON.stringify(this.contentDocumentIds) });
                this.contentDocumentIds = [];
            } catch (error) {
                console.log('error =>', error);
            }
        }
    }

    async handleSuccess(event) {
        try {
            this.knowledgeArticle = event.detail.id;
            let selectedProductIds = this.selectedProducts.map((product) => product.Id);
            let selectedRoleIds = this.selectedRoles.map((role) => role.Id);
            let selectedIndustryIds = this.selectedIndustries.map(industry=>industry.Id);
            this.orgBaseUrl = await updateContributeData({
                knowledgeId: this.knowledgeArticle,
                isAutoPublish: this.submitForReview,
                productIdString: JSON.stringify(selectedProductIds),
                industryIdString: JSON.stringify(selectedIndustryIds),
                contentIdString: JSON.stringify(this.contentDocumentIds),
                roleIdString: JSON.stringify(selectedRoleIds),
                acticleLinks: this.articleLinksToInsert,
                articleTags: this.articleTagsToInsert

            });
            if (this.submitForReview) {
                this.launchSubmitFlow();
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: pscContributeSuccessMessage,
                        variant: 'success'
                    })
                );
                this.articleButtonLabel = this.submitForReview ? pscContributeSuccessPageButtonLabel : pscContributeSuccessPageButtonPublishedLabel;
                this.successPageBody = this.submitForReview ? pscContributeSuccessPageBody : pscContributeSuccessPageBodyPublished;
                this.showSuccessPage = true;
                this.navigateToTop();
            }
        } catch (error) {
            console.log('error => ', error);
        }
        this.showSpinner = false;
    }

    launchSubmitFlow() {
        if (!this.knowledgeArticle) {
            return;
        }
        this.renderFlow = false;
        this.flowApiName = this.pscContributeSubmitForReviewFlowApiNameLabel;
        this.flowInputVariables = [{
            name: "recordId",
            type: "String",
            value: this.knowledgeArticle
        }, {
            name: "varRedirectToRecordPage",
            type: "Boolean",
            value: false
        }
        ];
        this.renderFlow = true;
    }

    handleFlowStatusChange(event) {
        if (event.detail.status.includes("FINISHED")) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: pscContributeSuccessMessage,
                    variant: 'success'
                })
            );
            this.showSuccessPage = true;
            this.navigateToTop();
        }
        this.renderFlow = false;
    }

    navigateToTop() {
        const navigateToTop = this.template.querySelector('[data-id="target"]');
        navigateToTop.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
    }

    async handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        if (uploadedFiles) {
            this.contentDocumentIds.push(...uploadedFiles.map(item => item.documentId));
        }
    }

    handleReset() {
        let comboBox = this.template.querySelector('lightning-checkbox-group[data-id="industry"]');
        this.selectedIndustries = [];
        if (comboBox) {
            comboBox.value = null;
            comboBox.setCustomValidity('');
            comboBox.reportValidity();
        }
        let sumbitCheckBox = this.template.querySelector('lightning-input[data-id="submitForReview"]');
        if (sumbitCheckBox) {
            sumbitCheckBox.value = null;
        }
    }

    handleError(event) {
        event.preventDefault();
        event.stopImmediatePropagation();
        let errorMessage = event.detail.detail;
        let [fieldError] = Object.values(event.detail.output.fieldErrors);

        if (fieldError && fieldError.length > 0 &&
            fieldError[0].errorCode === 'DUPLICATE_VALUE' &&
            fieldError[0].field === 'UrlName' && fieldError[0].message == errorMessage) {
            errorMessage = pscContributeErrorMessage;
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            }));
        this.showSpinner = false;
    }

    navigateToKnowledgeListView() {
        if (this.isReusableAsset) {
            if (!this.submitForRAReview) {
                window.location.href = '/ServicesCentral/s/reusable-asset?recordId=' + this.reusableAssetId;
            } else {
                const urlLink = this.orgBaseUrl + '/lightning/r/Reusable_Asset__c/' + this.reusableAssetId + '/view';
                window.open(urlLink, '_blank');
            }
        } else {
            if (!this.submitForReview) {
                window.location.href = '/ServicesCentral/s/article/' + encodeURIComponent(this.urlName);
            } else if (this.orgBaseUrl) {
                const urlLink = this.orgBaseUrl + '/lightning/o/Knowledge__kav/list?filterName=My_Knowledge_Articles';
                window.open(urlLink, '_blank');
            }
        }
    }

    closeModal() {
        this.clearModalData();
        const modal = this.template.querySelector('c-psc-modal');
        modal.hide();
    }

    openAddLinksModal() {
        this.link_modal = true;
        this.tags_modal = false;
        this.openModal();
    }
    openAddTagsModal() {
        this.link_modal = false;
        this.tags_modal = true;
        this.openModal();
    }

    openModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
    }

    handleAddLinksSubmit(event) {
        let isValid = true;
        let linkLoc = this.template.querySelectorAll('.link-location');
        let linkText = this.template.querySelectorAll('.link-text');
        let linkUrl = this.template.querySelectorAll('.link-url');

        linkLoc.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        linkText.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        linkUrl.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            return;
        }
        this.Article_Link__c = {};
        this.Article_Link__c.Asset_Location__c = this.assetLoc;
        this.Article_Link__c.Link_Text__c = this.tagText;
        this.Article_Link__c.Link_Url__c = this.assetUrl;
        if (this.Article_Link__c) {
            this.articleLinksToInsert.push(this.Article_Link__c);
        }
        this.closeModal();
    }

    handleAssetLocationChange(event) {
        this.assetLoc = event.detail.value;
    }

    removeRecord(event) {
        const tags = [];
        this.articleTagsToInsert.map(element => {
            if (element.Name != event.target.name) {
                tags.push(element);
            }

        });
        this.articleTagsToInsert = [...tags];
    }

    handleLinkTextChange(event) {
        this.tagText = event.target.value;
    }

    handleLinkUrlChange(event) {
        this.assetUrl = event.target.value;
    }

    clearModalData() {
        this.assetLoc = '';
        this.assetUrl = '';
        this.tagText = '';
    }

    SuccessPage(event) {
        this.showSuccessPage = event.detail.showsuccess;
        this.reusableAssetId = event.detail.reusableassetid;
        this.submitForRAReview = event.detail.submitForRAReview;
        this.orgBaseUrl = event.detail.orgbaseurl;
    }

    updatePageStatus(event) {
        this.show1Page = event.detail
    }

    handleAddTagsSubmit(event) {
        // code for existing tag
        let fields = event.detail.fields;
        this.errorFound = false;

        if ((fields['Tag__c'] === undefined || fields['Tag__c'] === null || fields['Tag__c'] == '') && !this.tagText) {
            this.errorMsg = 'Please input a tag in either of the provided input boxes.';
            this.errorFound = true;
            return;
        }
        else if (fields['Tag__c'] != undefined && fields['Tag__c'] != null && fields['Tag__c'] != '' && this.tagText) {
            this.errorMsg = 'Please input a tag into one of the provided input boxes.';
            this.errorFound = true;
            return;
        }
        else if ((fields['Tag__c'] != undefined || fields['Tag__c'] != null || fields['Tag__c'] != '') && !this.tagText) {
            let tagName;
            let canAdd = true;
            getTagName({ tagId: fields['Tag__c'] }).then(result => {
                tagName = result;
                this.Article_Tags__c = {};
                this.Article_Tags__c.Tag__c = fields['Tag__c'];
                this.Article_Tags__c.Name = tagName;
                if (this.articleTagsToInsert) {
                    this.articleTagsToInsert.forEach(el => {
                        if (el.Name == tagName) {
                            canAdd = false;
                        }
                    })
                }

                if (this.Article_Tags__c && canAdd) {
                    this.articleTagsToInsert.push(this.Article_Tags__c);
                }

                if (!canAdd) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: tagName + 'Already added',
                            variant: 'error'
                        })
                    );
                }
                this.closeModal();
            })

        }
        else if ((fields['Tag__c'] == undefined || fields['Tag__c'] == null || fields['Tag__c'] == '') && this.tagText) {
            fields = {};
            fields[NAME_FIELD.fieldApiName] = this.tagText;
            const recordInput = { apiName: TAG_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(result => {
                    this.Article_Tags__c = {};
                    this.Article_Tags__c.Tag__c = result.id;
                    this.Article_Tags__c.Name = this.tagText;
                    if (this.Article_Tags__c) {
                        this.articleTagsToInsert.push(this.Article_Tags__c);
                    }
                    this.closeModal();
                })
                .catch(error => {
                    if (error.body.output.fieldErrors.Name[0].errorCode == 'FIELD_CUSTOM_VALIDATION_EXCEPTION') {
                        this.errorFound = true;
                        this.errorMsg = error.body.output.fieldErrors.Name[0].message;

                    } else {
                        this.errorFound = true;
                        this.errorMsg = 'Some error occurred.Please try again with different tag';
                    }
                    console.error('error in parent tag->', error);
                });
        }
    }

    handleTagChange(event) {
        this.tagText = event.target.value;
    }

}