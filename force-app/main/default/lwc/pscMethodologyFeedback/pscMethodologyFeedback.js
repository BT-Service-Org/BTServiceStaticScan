import { LightningElement,api } from 'lwc';

export default class PscMethodologyFeedback extends LightningElement {
    @api header;
    @api helpText;
    @api slackUrl;
    @api buttonName;
}