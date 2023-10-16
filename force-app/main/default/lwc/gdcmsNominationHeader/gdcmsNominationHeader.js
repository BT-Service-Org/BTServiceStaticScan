import { LightningElement, track , api} from 'lwc';
import getCurrentQuarter from '@salesforce/apex/GDCMS_NominationScreenController.getCurrentQuarter';
import gdcmsRewardsAndRecognitionLink from '@salesforce/label/c.gdcmsRewardsAndRecognitionLink';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GdcmsNominationHeader extends LightningElement {
    @api display = false;
    @track dates = {};

    label_gdcmsRewardsAndRecognitionLink = gdcmsRewardsAndRecognitionLink;

    async connectedCallback() {
        const recordDetails = await getCurrentQuarter();
        console.log('recordDetails   :::: ' + recordDetails);
        if (recordDetails != undefined) {
            this.dates = recordDetails;
        } else {
            this.showToast('Error', 'The Nominations are not yet started. Please wait for the further communicnation.', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get gdc_ms_QuarterStartDate__c() {
        if (this.dates) {
            return this.dates.gdc_ms_QuarterStartDate__c;
        } else {
            return '';
        }
    }

    get gdc_ms_Quarter__c() {
        if (this.dates) {
            return this.dates.gdc_ms_Quarter__c;
        } else {
            return '';
        }
    }

    get gdc_ms_QuarterEndDate__c() {
        if (this.dates) {
            return this.dates.gdc_ms_QuarterEndDate__c;
        } else {
            return '';
        }
    }

    get displayHeader() {
        if (this.display && this.display === 'false') {
            return false;
        } else {
            return true;
        }
    }
}