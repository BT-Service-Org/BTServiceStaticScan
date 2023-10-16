import { LightningElement, api, wire, track } from 'lwc';
import REUSABLE_ASSET from '@salesforce/schema/Reusable_Asset__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTagName from '@salesforce/apex/PSCContributeCtrl.getTagName';
import NAME_FIELD from '@salesforce/schema/Tag__c.Name';
import TAG_OBJECT from '@salesforce/schema/Tag__c';
import ARTICLE_TAG from '@salesforce/schema/Article_Tags__c';
import { createRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import updateContributeRAData from '@salesforce/apex/PSCContributeCtrl.updateContributeRAData';
import pscContributeSubmitForReviewRA from '@salesforce/label/c.PSC_Contribute_Submit_For_Review_RA_Label';
import pscContributeSubmitForReviewRAHelpText from '@salesforce/label/c.PSC_Contribute_Submit_For_Review_RA_Helptext';
import pscContributeSuccessMessage from '@salesforce/label/c.PSC_Contribute_Success_Message';
export default class PscReusableContributeFlow extends LightningElement {
    @api industryData;
    @api productData;
    @api roleData;
    @track contentDocumentIds = [];
    @track articleTagsToInsert = [];
    @api targetAudienceHelpText;
    tagText;
    tags_modal=false;
    articleTagRecTypeId = '';
    errorMsg = '';
    errorFound = false;
    selectedIndustries = [];
    selectedProducts = [];
    selectedRoles = [];
    @api reusableAssetPageOne;
    @track reusableAssetPageTwo = false;
    submitForRAReview = false;
    reusableAssetRecTypeId = '';
    reusableAssetId;
    @api assetTypeValue;
    @api resourceTypeValue;
    @api showSpinner;
    showButtons = false;
    pscContributeSubmitForReviewRALabel = pscContributeSubmitForReviewRA;
    submitForReviewRAHelpText = pscContributeSubmitForReviewRAHelpText;


    @wire(getObjectInfo, { objectApiName: REUSABLE_ASSET })
    objectInfo(data, error) {
        if (data && data.data) {
            const recTyps = data.data.recordTypeInfos;
            this.reusableAssetRecTypeId = Object.keys(recTyps).find(recTyp => recTyps[recTyp].name === 'Existing Asset');
        } else if (error) {
            console.log(error);
        }
    }

     //Article Tag RecId
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

    handleLoad() {
        this.showSpinner = false;
        this.showButtons = true;
    }
    handleReusableAssetSuccess(event) {
        this.reusableAssetId = event.detail.id;
        this.showSpinner = false;
        this.reusableAssetPageOne = false;
        this.reusableAssetPageTwo = true;
        const topNavigate = new CustomEvent('navtop', {
            detail: ''
        });
        // Fire the custom event
        this.dispatchEvent(topNavigate);
    }
    handleReusableAssetSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        let fields = event.detail.fields;
        fields['Asset_Type__c'] = this.assetTypeValue;
        fields['Resource_Type__c'] = this.resourceTypeValue;
        fields['Status__c'] = 'Draft';
        this.showSpinner = true;

        this.template.querySelector('lightning-record-edit-form').submit(fields);
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

    navigateToTop() {
        const navigateToTop = this.template.querySelector('[data-id="target"]');
        navigateToTop.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
    }

    reusableFirstPrevious() {
        this.showSpinner = true;
        if (this.reusableAssetId !== undefined && this.reusableAssetId != null) {
            deleteRecord(this.reusableAssetId)
                .then(() => {
                    this.showSpinner = false;
                    this.reusableAssetPageOne = false;
                    this.reusableAssetPageTwo = false;
                    this.show1Page = true;
                    const pageChangeEvent = new CustomEvent('pagechange', {
                        detail: this.show1Page
                    });
                    // Fire the custom event
                    this.dispatchEvent(pageChangeEvent);


                })
                .catch(error => {
                    console.log('error->', error);
                });
        }
        else {
            this.showSpinner = false;
            this.reusableAssetPageOne = false;
            this.reusableAssetPageTwo = false;
            this.show1Page = true;
            const pageChangeEvent = new CustomEvent('pagechange', {
                detail: this.show1Page
            });
            // Fire the custom event
            this.dispatchEvent(pageChangeEvent);
        }

        const topNavigate = new CustomEvent('navtop', {
            detail: ''
        });
        // Fire the custom event
        this.dispatchEvent(topNavigate);

    }
    handleIndustriesChange(event) {
        this.selectedIndustries = [...event.detail.selRecords];
    }

    handleProductChange(event) {
        this.selectedProducts = [...event.detail.selRecords];
    }

    handleRoleChange(event) {
        this.selectedRoles = [...event.detail.selRecords]
    }

    async handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        if (uploadedFiles) {
            this.contentDocumentIds.push(...uploadedFiles.map(item => item.documentId));
        }
    }

    handleReusableAssetFinalNext(event) {
        this.showSpinner = true;
        let selectedRAProductIds = this.selectedProducts.map((product) => product.Id);
        let selectedRAIndustries = this.selectedIndustries.map(industry => industry.Id);
        let selectedRoleIds = this.selectedRoles.map((role) => role.Id);

        updateContributeRAData({
            reusableAssetId: this.reusableAssetId,
            isAutoPublish: this.submitForRAReview,
            productIdString: JSON.stringify(selectedRAProductIds),
            industryIdString: JSON.stringify(selectedRAIndustries),
            contentIdString: JSON.stringify(this.contentDocumentIds),
            roleIdString: JSON.stringify(selectedRoleIds),
            articleTags: this.articleTagsToInsert
        })
            .then(result => {
                this.showSpinner = false;
                this.orgBaseUrl = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: pscContributeSuccessMessage,
                        variant: 'success'
                    })
                );
                this.showSuccessPage = true;
                const data = { showsuccess: this.showSuccessPage,submitForRAReview: this.submitForRAReview,reusableassetid: this.reusableAssetId, orgbaseurl: this.orgBaseUrl }
                const SuccessPage = new CustomEvent('successpage', {
                    detail: data
                });
                // Fire the custom event
                this.dispatchEvent(SuccessPage);
                const topNavigate = new CustomEvent('navtop', {
                    detail: ''
                });
                // Fire the custom event
                this.dispatchEvent(topNavigate);
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('error => ', error);
            })
    }
    reusableSecondPrevious() {
        this.reusableAssetPageOne = true;
        this.reusableAssetPageTwo = false;
        const topNavigate = new CustomEvent('navtop', {
            detail: ''
        });
        // Fire the custom event
        this.dispatchEvent(topNavigate);

    }
    handleSubmitRAReview(event) {
        this.submitForRAReview = event.detail.checked;
    }

    get submitButtonLabel() {
        return this.submitForRAReview ? 'Submit' : 'Publish';
    }

    openAddTagsModal() {
        this.tags_modal = true;
        this.openModal();
    }

    openModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
    }

    closeModal() {
        this.tagText = '';
        const modal = this.template.querySelector('c-psc-modal');
        modal.hide();
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