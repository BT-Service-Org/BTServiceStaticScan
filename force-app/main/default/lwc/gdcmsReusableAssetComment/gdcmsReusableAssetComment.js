import { LightningElement, api, track, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import getAllComments from '@salesforce/apex/GDC_MS_AssetCommentController.getAllComments';
import createComment from "@salesforce/apex/GDC_MS_AssetCommentController.createComment";
import updateComment from "@salesforce/apex/GDC_MS_AssetCommentController.updateComment";
import deleteComment from "@salesforce/apex/GDC_MS_AssetCommentController.deleteComment";
import getAssetMembers from "@salesforce/apex/GDC_MS_AssetCommentController.getAssetMembers";
import getRecord from "@salesforce/apex/GDC_MS_AssetCommentController.getRecord";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import hasAdminPermission from '@salesforce/customPermission/GDC_MS_Asset_Admin_Permission';
export default class GdcmsReusableAssetComment extends LightningElement {

    @api recordId;
    @api featureName;
    @api objectApiName;
    isLoading = false;
    /** Edit Mode Fields */
    isEditCommentMode = false;
    editCommentId;
    editCommentSubject;

    hasRendered = false;
    /** Insert Mode Fields */
    commentBody;
    commentInput;
    /** Read Mode Fields */
    @track listAssetComments = [];

    /** Asset Members Fields */
    assetMembers;
    @track selectedAssetMembers = [];
    selectedAssetMember_String;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
       }
    }

    renderedCallback() {
        if (this.hasRendered) return;
        if (this.isCommentFeature) this.getListOfComment();
    }

    get isCommentFeature(){
        return this.featureName === 'Comment Feature' ? true : false;
    }

    getListOfComment() {
        this.isLoading = true;
        getAllComments({ assetId: this.recordId })
            .then((result) => {
                this.listAssetComments = result;
                this.listAssetComments.forEach((item, index) => {
                    item.isCommentAccessToModifyDisabled = item.CreatedById === USER_ID ? false : true;
                });
            })
            .then(() => {
                this.getAssetMembers();
            })
            .catch((error) => {
                this.isLoading = false;
                console.error("error from getListOfComment()->" + JSON.stringify(error));
                this.showToast(`Error Occurred!`, `Please contact your system administrator.`, 'error');
            });
    }

    getAssetMembers() {
        getAssetMembers({ assetId: this.recordId })
            .then((result) => {
                this.assetMembers = result;
            }).then(() => {
                this.hasRendered = true;
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;
                console.error(`Error in getAssetMemebers: ${JSON.stringify(error)}`);
                this.showToast(`Error Occurred!`, `Please contact your system administrator.`, 'error');
            })
    }

    handleBack(){
        window.history.back();
    }

    handleMembersSelections(event) {
        this.selectedAssetMembers = event.detail.value;
        if (this.selectedAssetMembers?.length > 0)
            this.selectedAssetMember_String = this.selectedAssetMembers.toString(',');
    }

    handleCommentInput(event) {

        this.commentBody = event.target.value;
        if (this.commentBody != null && this.commentBody.length > 7)
            this.template.querySelector(
                '[data-id = "postCommentButton"]'
            ).disabled = false;
        else
            this.template.querySelector(
                '[data-id = "postCommentButton"]'
            ).disabled = true;
    }

    //Create Comment Record in Salesforce
    handleCommentPost(event) {

        this.isLoading = true;
        let wrapperObject = {
            commentBody: this.commentBody,
            recipientEmailIds: this.selectedAssetMember_String,
            assetId: this.recordId
        };

        createComment({
            wrapper: wrapperObject
        })
            .then((result) => {
                this.template.querySelector('[data-id="commentBody"]').value = "";
                this.template.querySelector('c-gdcms-combobox-with-search')?.handleRemoveAll();
                this.selectedAssetMember_String = '';
                return result;
            }).then((result) => {
                this.getRecord(result);
            })
            .catch((error) => {
                this.isLoading = false;
                console.error("Error ->" + JSON.stringify(error));
                this.showToast(`Error Occurred!`, `Please contact your system administrator.`, 'error');
            });

    }

    getRecord(commentId) {
        getRecord({ assetId: commentId })
            .then((result) => {
                this.listAssetComments = [result, ...this.listAssetComments];
                let commentListDiv = this.template.querySelector('.comments-list');
                if (commentListDiv)
                    window.setTimeout(() => {
                        commentListDiv.scrollTop = 0;
                    }, 300)
            })
            .then(() => {
                this.showToast(`Your comment has been added.`, ``, 'success');
                this.isLoading = false;
                let listCommentDiv = this.template.querySelector('[data-id="' + commentId + '"]');
                listCommentDiv.style.backgroundColor = '#2e844a'; // Success Green
                window.setTimeout(() => { listCommentDiv.style.backgroundColor = ''; }, 3000)
            })
            .catch((error) => {
                this.isLoading = false;
                console.error("Error ->" + JSON.stringify(error));
                this.showToast(`Error Occurred!`, `Please contact your system administrator.`, 'error');
            })
    }

    editCommentPost(event) {
        this.isEditCommentMode = true;
        this.editCommentId = event.target.dataset.id;
        this.editCommentSubject = event.target.dataset.comment_body;
        window.setTimeout(() => { this.template.querySelector('c-gdcms-base-modal').displayModal(this.isEditCommentMode) }, 300);
    }
    closeModalEdit() {
        this.isEditCommentMode = false;
        this.editCommentSubject = "";
        this.editCommentId = "";
    }

    handleEditCommentSubject(event) {
        this.editCommentSubject = event.target.value;
    }

    editSubmitCommentPost() {
        this.isLoading = true;
        updateComment({
            recordId: this.editCommentId,
            commentBody: this.editCommentSubject
        })
            .then((result) => {
                this.editCommentSubject = "";
                this.editCommentId = "";
                this.getListOfComment();
                this.isEditCommentMode = false;
                this.isLoading = false;
                this.showToast(`Your comment has been updated.`, ``, 'success');
            })
            .catch((error) => {
                this.isLoading = false;
                console.error("Error ->" + JSON.stringify(error));
                this.showToast(`Error Occurred!`, `Please contact your system administrator.`, 'error');
            });
    }

    deleteCommentPost(event) {
        if (confirm("Are you sure you want to delete the comment?")) {
            let deleteCommentId = event.target.dataset.id;
            this.isLoading = true;
            deleteComment({
                recordId: deleteCommentId
            })
                .then((result) => {
                    this.getListOfComment();
                    this.isLoading = false;
                    this.showToast(`Your comment has been deleted.`, ``, 'success');
                })
                .catch((error) => {
                    this.isLoading = false;
                    console.error("Error ->" + JSON.stringify(error));
                    this.showToast(`Error Occurred!`, `Please contact your system administrator.`, 'error');
                });
        }
    }

    showToast(titleText, msgText, variantType) {
        const event = new ShowToastEvent({
            title: titleText,
            message: msgText,
            variant: variantType
        });
        this.dispatchEvent(event);
    }

    get areCommentsAvailable() {
        return this.listAssetComments?.length > 0 ? true : false;
    }

    get isAssetMembersDisabled(){
        return this.assetMembers?.length > 0 ? false : true;
    }

    get isComponentVisible(){
        return hasAdminPermission ? true : false;
    }
}