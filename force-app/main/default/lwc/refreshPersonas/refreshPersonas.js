import { LightningElement,wire } from 'lwc';
import {
    publish,
    MessageContext
} from 'lightning/messageService';
import refreshPersonas from '@salesforce/messageChannel/RefreshPersonas__c';

export default class RefreshPersonas extends LightningElement {

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        console.log('connectedCallback..')
        const payload = {};
        publish(this.messageContext, refreshPersonas, payload);
        console.log('event published...')
    }


    sendEvent(event){
        const payload = {};
        publish(this.messageContext, refreshPersonas, payload);

    }

}