import LightningModal from 'lightning/modal';
export default class CreateNewActivity extends LightningModal {
    handleSuccess(event){
        this.close(event.detail);
     }
     handleError(event){
        this.close(event.detail);
     }
}