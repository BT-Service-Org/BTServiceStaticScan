import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import GDCMS from '@salesforce/messageChannel/gdcms__c';

export default class GdcmsTeamMemberProfileDownload extends LightningElement {
    displayView = true;
    loaded = true;
    //Changes for Printing PDF - Team Member Profile
    @wire(MessageContext)
		messageContext;

    printPDF() {
        this.displayView = false;
        let payload = {
            pageName : '',
            displayView : false
        }
        publish(this.messageContext, GDCMS, payload);
        this.loaded = false;
        setTimeout(()=>{
            this.loaded = true;
            window.print();
        },3000)

        setTimeout(()=>{
            payload = {
                pageName: '',
                displayView: true
            };

            publish(this.messageContext, GDCMS, payload);
            this.displayView = true;
        },4000)
        //
    }
}