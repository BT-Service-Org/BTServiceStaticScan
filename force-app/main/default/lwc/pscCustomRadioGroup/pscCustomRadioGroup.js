import { api, LightningElement, track, wire } from 'lwc';
import { getPicklistValues} from 'lightning/uiObjectInfoApi';
import writing_new_artefact_options_field from '@salesforce/schema/Feedback_for_Method__c.Writing_New_Artefact_Options__c';

export default class PscCustomRadioGroup extends LightningElement {

    @api recordTypeId;
    @api field;
    @api fieldApiName;
    @track options = [];
    otherInputRequired = false;
    otherInputDisabled = true;


    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: writing_new_artefact_options_field})
    getPicklistOptions({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null && Object.keys(data).length > 0) {
                const picklistData = JSON.parse(JSON.stringify(data));
                if(picklistData && picklistData.values.length > 0){
                    this.options = picklistData.values.map((option, index)=>{
                        return{
                            ...option,
                            otherInput: option.label === 'Other',
                        }
                    });
                    this.dispatchEvent(new CustomEvent('selected', {
                        detail: {
                            radioInput: null,
                            textInput: null,
                            fieldName: this.field.fieldName,
                            otherInputFieldName: this.field.otherFieldName,
                            valid: false
                        } 
                    }));
                }
            }
        }
        if (error) {
            console.log("error =>", error);
        }
    }

    @api
    showRequireError(){
        this.template.querySelector('input[type=radio]').reportValidity();
    }

    handleOtherInput(event){
        const otherInputText = event.detail.value;
        const value = this.template.querySelector('input[type=radio]:checked').value || null;
        this.dispatchEvent(new CustomEvent('selected', {
            detail: {
                radioInput: value,
                textInput: otherInputText,
                fieldName: this.field.fieldName,
                otherInputFieldName: this.field.otherFieldName,
                valid: !!otherInputText
            } 
        }));
    }

    radioChange(event){
        const value = event?.target?.value;
        if(value !== 'Other'){
            this.otherInputDisabled = true;
            this.otherInputRequired = false;
            const otherInputText = this.template.querySelector('lightning-input[data-id="otherInput"]');
            otherInputText.setCustomValidity('');
            otherInputText.reportValidity();
            this.dispatchEvent(new CustomEvent('selected', {
                detail: {
                    radioInput: value,
                    textInput: null,
                    fieldName: this.field.fieldName,
                    otherInputFieldName: this.field.otherFieldName,
                    valid: true
                } 
            }));
        }else if(value === 'Other'){
            this.otherInputDisabled = false;
            this.otherInputRequired = true;
            const otherInputText = this.template.querySelector('lightning-input[data-id="otherInput"]')?.value
            this.dispatchEvent(new CustomEvent('selected', {
                detail: {
                    radioInput: value,
                    textInput: otherInputText,
                    fieldName: this.field.fieldName,
                    otherInputFieldName: this.field.otherFieldName,
                    valid: !!otherInputText
                } 
            }));
        }
    }
}