import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
import METHOD_CARD_COMMUNICATION from '@salesforce/messageChannel/methodCardDataAvailability__c';
import getTableOfContentsValues from '@salesforce/apex/PSCMethodDetailCtrl.getTableOfContentsValues';
import getMethodId from '@salesforce/apex/PSCMethodDetailCtrl.getMethodId';

export default class PscMethodDetail extends LightningElement {
    methodContentData = [];
    methodNumber;
    recId;
    showContent=false;
    key ='';


    @wire(MessageContext)
    messageContext;
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.methodNumber = currentPageReference.state?.methodnumber;
            this.methodname = currentPageReference.state?.methodname;
            this.key = (this.methodNumber!==undefined?this.methodNumber:(this.methodname!==undefined?this.methodname:''))
        }
    }


    @wire(getMethodId, { key: "$key" })
    wiredMethodId({ error, data }) {
        if (data) {

            if (data !== undefined && data !== null) {
                this.recId = data;
            }
        }
        if (error) {
            console.log("Error", error);
        }
    }

    @wire(getTableOfContentsValues, { key: "Method_Table_of_Contents" })
    methodDataConfig({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null) {
                this.methodContentData = [...JSON.parse(data)];
            }
        }
        if (error) {
            console.log("Error", error);
        }
    }

    connectedCallback() {
        subscribe(this.messageContext, METHOD_CARD_COMMUNICATION, (message) => {
            this.showContent = message.showComponent;
            console.log('message in method detail->',message);
        });
    }
}