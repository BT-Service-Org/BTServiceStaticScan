import { LightningElement, api, track } from 'lwc';
export default class CustomFileUploadLWC extends LightningElement {
    @track allFiles = [];
    @api FiledocumentIds = [];
    bufferIds = [];
    @track hasUploaded = false;

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    /**This is to get already uploaded Files from sessionstorage on click of back button in flow screen */
    connectedCallback() {
        if(this.FiledocumentIds?.length > 0) {
            this.bufferIds = this.FiledocumentIds.map((x) => x); 
            var oldFiles = JSON.parse(sessionStorage.getItem('uploadedFiles'));
            this.allFiles = oldFiles !== null ? oldFiles : [];
            this.hasUploaded = this.allFiles.length > 0 ? true : false;
        }else {
            /**Clearing the session storage that we use to store the deliverables and roles- FLOW: Create_Method */
            var oldFiles = sessionStorage.getItem('uploadedFiles')
            if( oldFiles !== undefined || oldFiles !== null) sessionStorage.removeItem('uploadedFiles');
        }
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        
        uploadedFiles.forEach(ele =>{
            const fileEle = {};
            fileEle.documentId = ele.documentId;
            fileEle.name = ele.name;
            this.allFiles.push(fileEle);
            if ( this.bufferIds.length > 0 ) {
                this.bufferIds.push(ele.documentId);
                this.FiledocumentIds = this.bufferIds;
            }else {
                this.FiledocumentIds.push(ele.documentId);
            }
        });
        if( this.allFiles.length > 0 ) {
            this.hasUploaded = true;
            /**adding data to sessionstorage to render already uploaded Files on click on back button in Flow screen */
            sessionStorage.setItem('uploadedFiles', JSON.stringify(this.allFiles));
        }
    }
}