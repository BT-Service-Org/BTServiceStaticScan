import { LightningElement, wire } from 'lwc';
import adcBenchSurveyModal from 'c/adcBenchSurveyModal';
import { CurrentPageReference } from 'lightning/navigation';

import USER_ID from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STAFFING_STATUS_FIELD from '@salesforce/schema/User.Staffing_Status__c';

import showBenchBtn from '@salesforce/customPermission/ADC_BenchMgnt_showBenchButton';
import { NavigationMixin } from "lightning/navigation";

export default class AdcBenchSurveyButton extends NavigationMixin(LightningElement)  {
    isButtonDisabled = false;
    urlId = '';

    @wire(getRecord, { recordId: USER_ID, fields: [STAFFING_STATUS_FIELD] })
    user;
    
    get staffingStatus() {
        return getFieldValue(this.user.data, STAFFING_STATUS_FIELD);
    }

    get showBenchBtn(){
        return showBenchBtn;
    }

    async handleClick() {
        const result = await adcBenchSurveyModal.open({
            size: 'small',
            description: 'Modal with the ADC On Bench Survey',
        });
        
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
            this.urlId = currentPageReference.attributes.recordId;

            if(this.user.data) {
                if(this.urlId !== USER_ID || this.staffingStatus !== "On Bench") {
                    this.isButtonDisabled = true;
                }
            }     
        }
    }
        
}