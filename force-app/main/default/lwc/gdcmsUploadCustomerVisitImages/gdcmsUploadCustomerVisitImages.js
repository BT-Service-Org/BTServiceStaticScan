import { LightningElement, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class GdcmsUploadCustomerVisitImages extends NavigationMixin(LightningElement) {
    @api recordId;
    @api showCancel;
    file;

    @track displayCancel;

    // renderedCallback() {
    //     this.template.querySelector('c-gdcms-base-modal').displayModal(true);
    // }

    renderedCallback() {
        debugger;
        if (this.showCancel && this.showCancel == "false") {
            this.displayCancel = false;
        } else {
            this.displayCancel = true;
        }
    }

    filePreview(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: this.file.documentId,
            }
        })
        this.handleClose();
    }

    handleClose() {
        setTimeout(()=> {
            this.dispatchEvent(new CloseActionScreenEvent());
        }, 10000);
    }

    handleCloseWindow(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}