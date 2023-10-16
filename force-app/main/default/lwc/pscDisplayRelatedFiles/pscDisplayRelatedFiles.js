import { LightningElement, api, wire } from 'lwc';
import getContentDocumentIDs from '@salesforce/apex/PSCDisplayRelatedFilesCtrl.getContentDocumentIDs';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
export default class PscDisplayRelatedFiles extends LightningElement {
    @api parentId;
    error;
    fileData;
    showAttachments=true;
    IconUrl = PSC_IMAGES + '/Icons/';

    @wire(getContentDocumentIDs, { parentId: '$parentId' })
    voteData(data, error) {
        if (data) {
            if (data !== null && data.data !== undefined) {
                this.fileData = data.data;
                this.showAttachments = !!this.fileData.length;
                this.fileData = this.fileData.map(file => {
                    return {
                        ...file,
                        fileIconUrl: this.IconUrl + file.fileIconName + '_60.png'
                    };
                })
                
            }

        }
        else if (error) {
            this.error = error;
        }
    }


}