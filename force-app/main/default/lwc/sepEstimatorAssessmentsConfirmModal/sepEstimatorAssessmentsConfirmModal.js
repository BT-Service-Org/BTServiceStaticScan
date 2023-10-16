import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class SepEstimatorAssessmentsConfirmModal extends LightningModal {
    @api modalTitle;
    @api modalMessage;

    handleCancel() {
        this.close('cancel');
    }

    handleConfirm() {
        this.close('confirm');
    }
}