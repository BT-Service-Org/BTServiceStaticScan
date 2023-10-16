import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class adcBenchSurveyModal extends LightningModal {
    @api content;

    handleOkay() {
        this.close('okay');
    }

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.close('okay');
        }
    }
    
}