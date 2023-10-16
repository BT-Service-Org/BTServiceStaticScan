import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';

export default class PscHelp extends NavigationMixin(LightningElement) {
    slack_logo= PSC_IMAGES + '/Logo/slack-logo.png';
    @api header;
    @api helpText;
    @api slackUrl;
    @api buttonName;
    NavigateToSlack(event) {
        if(event.keyCode=='13' || event.keyCode==undefined) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
            attributes: {
                url: `${this.slackUrl}`
            }
            });
        }
        
    }
}