import { LightningElement,api } from 'lwc';

export default class CustomRichTextField extends LightningElement {
    @api value ;
    @api fieldLabel ; //1.1 Description

    constructor() {
        super();
        console.log(this.value)
        console.log(this.fieldLabel)
    }

    handleChange(event) {
        this.value = event.target.value;
    }
}