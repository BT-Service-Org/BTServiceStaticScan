import { LightningElement } from 'lwc';
import BlankSMERequestedField from '@salesforce/label/c.Blank_SME_Requested_Field';
export default class MethodBannerMessage extends LightningElement {
    label = {
        BlankSMERequestedField
    };

    constructor() {
        super();
        console.log('BlankSMERequestedField --'+this.label.BlankSMERequestedField)
    }
}