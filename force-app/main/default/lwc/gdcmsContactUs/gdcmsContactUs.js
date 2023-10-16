import { LightningElement, api } from 'lwc';
import sendEmailMessage from '@salesforce/apex/GDC_MS_ContactUsController.sendEmailMessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PROJECT_NAME from '@salesforce/schema/gdc_ms_Feedback__c.gdc_ms_ProjectName__c';
import ASSET_TITLE from '@salesforce/schema/gdc_ms_Feedback__c.gdc_ms_AssetTitle__c';
import USAGE_RATING from '@salesforce/schema/gdc_ms_Feedback__c.gdc_ms_AssetUsageRating__c';
import ASSET_SUGGESTION from '@salesforce/schema/gdc_ms_Feedback__c.gdc_ms_AssetSuggestion__c';
import TEAM_MEMBER from '@salesforce/schema/gdc_ms_Feedback__c.gdc_ms_TeamMember__c';

const OPTIONS = [
    { label: 'Question', value: 'Question' },
    { label: 'Issue', value: 'Issue' }
    // { label: 'Feedback', value: 'Feedback' },
]
export default class GdcmsContactUs extends LightningElement {

    firstName;
    emailAddress;
    descrption;
    @api showForm;
    showErrorMessage;
    showSuccessMessage;
    options = OPTIONS;
    queryType = 'Question';

    handleClick(event) {

        const allValid = [
            ...this.template.querySelectorAll('.inputComp'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(allValid) {
            sendEmailMessage({ firstName: this.firstName, emailAddress: this.emailAddress, description: this.descrption, queryType : this.queryType })
        .then(result => {
            console.log('RESULT ',JSON.stringify(result));
            //this.showForm1 = false;
            this.showSuccessMessage = true;
            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Your request has been submitted successfully!!',
                variant: 'success',
            });
            this.dispatchEvent(evt);
            setTimeout(() => {
                this.dispatchEvent(new CustomEvent('closepanel'));
            }, 0);
        })
        .catch(error => {
            console.log('ERROR ',error);
            this.showErrorToast('Error', 'Please contact your administrator, Error Details: ' + error.body.message + '.', 'error');
            
            setTimeout(() => {
                this.dispatchEvent(new CustomEvent('closepanel'));
            }, 3000);
        })
        }
        
    }

    closePanel() {
        this.dispatchEvent(new CustomEvent('closepanel'));
    }

    handleChange(event) {
        this.queryType = event.detail.value;
        
    }

    changeFirstName(event) {
        this.firstName = event.detail.value;
    }

    changeEmailAddress(event) {
        this.emailAddress = event.detail.value;
    }

    changeDesc(event) {
        this.descrption = event.detail.value;
    }

    //Asset feedback
    objectApiName = 'gdc_ms_Feedback__c';
    fields = [TEAM_MEMBER, ASSET_TITLE, PROJECT_NAME, USAGE_RATING, ASSET_SUGGESTION];


    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Your feedback has been submitted successfully!!',
            variant: 'success',
        });
        this.dispatchEvent(evt);

        setTimeout(() => {
            this.dispatchEvent(new CustomEvent('closepanel'));
        }, 0);
    }

    get headline() {
        return this.showForm1 ? 'Asset Feedback' : 'Contact Us';
    }

    get svgUrl () {
        return this.showForm1 ? '/_slds/icons/standard-sprite/svg/symbols.svg#feedback' : '/_slds/icons/standard-sprite/svg/symbols.svg#call' ;
    }

    get showForm1() {
        return location.href.indexOf('asset') >= 0;
    }

    handleError(event) {
        console.log('asset and feedback error message++' + event.detail);
        if(event.detail && event.detail.message && event.detail.message.indexOf('The requested resource does not exist') > -1) {
            this.handleSuccess(event);
        }
        else {
            this.showErrorMessage = true;
            this.showErrorToast('Error', 'Please contact your administrator, Error Details: '+ event.detail.message + '.', 'error');
        }
        

    }
    showErrorToast(titile, message, variant) {
        const evt = new ShowToastEvent({
            title: titile,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }


}