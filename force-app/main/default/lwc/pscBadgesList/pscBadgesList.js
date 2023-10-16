import { LightningElement, api } from 'lwc';
export default class PscBadgesList extends LightningElement {
    badgeKey = 'myBadges'

    @api showModalBox() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
    }

    closeModal() {
        const modal = this.template.querySelector('c-psc-modal');
        modal.hide();
    }
}