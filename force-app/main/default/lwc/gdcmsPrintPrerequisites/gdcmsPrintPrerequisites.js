import { LightningElement } from 'lwc';
import PrintBannerMsg from '@salesforce/label/c.gdcmsPrintBannerMsg';

export default class GdcmsPrintPrerequisites extends LightningElement {
    showPrereq = true;
    bannerMessage = PrintBannerMsg;

    closePrereq() {
        this.showPrereq = false;
    }
}