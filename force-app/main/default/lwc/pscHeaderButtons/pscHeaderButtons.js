import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 

export default class PSCHeaderButtons extends NavigationMixin(LightningElement)  {
    contributeUrl='/ServicesCentral/s/contribute';
    NavigateToContribute() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
        attributes: {
            url: `${this.contributeUrl}`
        }
        });
    }

    requestContentModal() {
        const modal = this.template.querySelector('c-psc-request-content-modal');
        modal.showModalBox();
    }
}