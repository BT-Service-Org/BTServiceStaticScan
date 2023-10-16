import LightningModal from 'lightning/modal';
export default class CreateNewRole extends LightningModal {
    handleSuccess(event){
        this.close(event.detail);
     }
     handleError(event){
        this.close(event.detail);
     }
}