import { LightningElement } from 'lwc';

export default class GdcmsVision extends LightningElement {
    areDetailsVisible = false;
    toggle (event)
    {
        this.areDetailsVisible = !this.areDetailsVisible;
    }
}