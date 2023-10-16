import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PscCopyUrl extends LightningElement {

    copyUrl(event) {
        if (event.which == '13' || event.which == '1') {
            let input = document.createElement("input");
            input.value = window.location.href;
            document.body.appendChild(input);
            const evt = new ShowToastEvent({
                title: "Link to article successfully copied",
                message: '',
                variant: 'success',
            });
            input.select();
            document.execCommand("copy");
            this.dispatchEvent(evt);
            input.remove();
        }
    }

}