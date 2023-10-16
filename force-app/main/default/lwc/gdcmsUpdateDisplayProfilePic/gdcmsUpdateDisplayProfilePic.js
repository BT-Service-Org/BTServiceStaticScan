import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class GdcmsUpdateDisplayProfilePic extends NavigationMixin(LightningElement) {

    @api recordId;
    file;

    updateProfilePic(){        
        this.template.querySelector('c-gdcms-base-modal').displayModal(true);
    }

    filePreview(event) {
        // Naviagation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                recordIds: this.file.documentId,
            }
        })
        
        this.handleClose();
        
    }

    handleClose(){
        setTimeout(()=> {
            this.template.querySelector('c-gdcms-base-modal').displayModal(false);
        }, 100);
    }
}