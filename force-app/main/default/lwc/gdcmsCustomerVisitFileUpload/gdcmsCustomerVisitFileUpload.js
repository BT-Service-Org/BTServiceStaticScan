import { LightningElement, api } from 'lwc';
import saveDocument from '@salesforce/apex/GDC_MS_CustomerVisitHandleUpload.saveDocument'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const MAX_FILE_SIZE = 2500000;

export default class GdcmsCustomerVisitFileUpload extends LightningElement {

    @api recordId;

    fileName = '';
    filesUploaded = [];

    selectedValue = 'Customer Logo';

    get options() {
        return [
            { label: 'Customer Logo', value: 'Customer Logo' },
            { label: 'Photo of Visitor', value: 'Photo of Visitor' },
            { label: 'Photo of SF Partner', value: 'Photo of SF Partner' },
        ];
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
    }

    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg'];
    }

    get uploader() {
        return (this.fileName === '');
    }

    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            console.log('filess, ', this.filesUploaded, this.fileName);
        }
    }

    saveFile(){
        var fileCon = this.filesUploaded[0];
        if (fileCon.size > MAX_FILE_SIZE) {
            let message = 'File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + fileCon.size;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Something went wrong',
                message: message,
                variant: 'error'
            }));
            return;
        }
        var reader = new FileReader();
        var self = this;
        reader.onload = function() {
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.upload(fileCon, fileContents);
        };
        reader.readAsDataURL(fileCon);
        
    }

    upload(file, fileContents){
        this.uploadChunk(file, fileContents)//, fromPos, toPos, ''); 
    }

    uploadChunk(file, fileContents){//, fromPos, toPos, attachId){
        var chunk = fileContents//.substring(fromPos, toPos);
        
        saveDocument({ 
            parentId: this.recordId,
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            fieldName: this.selectedValue,
        })
        .then(result => {
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'File Upload Success',
                variant: 'success'
            }));
            this.fileName = '';
            this.dispatchEvent(new CustomEvent('close'));
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Something went wrong',
                message: error.body.message,
                variant: 'error'
            }));
            return;
        })
        .finally(()=>{
            
        })
    }

}