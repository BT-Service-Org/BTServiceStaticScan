import { LightningElement , api} from 'lwc';

export default class PscModal extends LightningElement {
    showModal = false;
    hasHeaderString = false;
    _headerPrivate;
    @api showFooter = false;
    @api modalType;
    @api
    set header(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    get header() {
        return this._headerPrivate;
    }

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        this.dispatchEvent(new CustomEvent('closedialog'));
        this.hide();
    }

    handleSlotTaglineChange() {
        this.showElement('p');
    }

    handleSlotFooterChange() {
        this.showElement('footer');
    }

    showElement(htmlTag) {
        this.template.querySelector(htmlTag)?.classList?.remove('modal-hidden');
    }

    renderedCallback() {
        if (this.modalType =='add_tags') {
            this.template.querySelector('.slds-modal__container')!= null ? this.template.querySelector('.slds-modal__container').classList.add('addtag_modal') : ''
        }
    }
}