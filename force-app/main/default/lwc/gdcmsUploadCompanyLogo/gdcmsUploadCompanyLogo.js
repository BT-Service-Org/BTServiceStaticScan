import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class GdcmsUploadCompanyLogo extends NavigationMixin(LightningElement) {
    @api recordId;
    file;

    // renderedCallback() {
    //     this.template.querySelector('c-gdcms-base-modal').displayModal(true);
    // }

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