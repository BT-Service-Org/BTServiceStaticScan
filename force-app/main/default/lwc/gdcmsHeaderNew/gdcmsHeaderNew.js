import { LightningElement, track } from 'lwc';

export default class GdcmsHeaderNew extends LightningElement {
    iconName = 'chevronright';
    @track isOpen = false;

    handleClick() {
        this.isOpen = !this.isOpen;
    }
}