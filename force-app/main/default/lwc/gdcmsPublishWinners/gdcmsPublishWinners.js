import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import publishTheWinners from '@salesforce/apex/GDC_MS_PublishWinnerController.publishTheWinners'

export default class GdcmsPublishWinners extends LightningElement {

    handleClick() {
        publishTheWinners()
        .then(result => {
            if (result === '' ) {
                this.showToast('Success', 'The  winners are published successfully','success');
            } else {
                this.showToast('Error', result, 'error');
            }
        }).catch(error => {
            console.log('Error on callback :::: ' + JSON.stringify(error));
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}