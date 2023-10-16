import { LightningElement,api } from 'lwc';
import DefaultImage from '@salesforce/resourceUrl/GDCMSDefaultImage';
export default class GdcmsNominationTile extends LightningElement {
    name ;
    groupleader ;
    quarter;
    photoUrl;
    achieverAward = false;
    trailblazerAward = false;
    teamAward =false;

    @api nomination;
    connectedCallback(){
        //console.log('NominationList '+this.nomination.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c+' '+this.nomination.gdc_ms_Nominee__r.Name);
        if(this.nomination.gdc_ms_AwardCategory__c == 'Achievers Award'){
            this.achieverAward = true;
            this.name = this.nomination.gdc_ms_Nominee__r.Name;
            this.photoUrl = this.nomination.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c!=undefined?this.nomination.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c:DefaultImage;
        }
        if(this.nomination.gdc_ms_AwardCategory__c == 'Trailblazer Award'){
            this.trailblazerAward = true;
            this.name = this.nomination.gdc_ms_Nominee__r.Name;
            this.photoUrl = this.nomination.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c!=undefined?this.nomination.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c:DefaultImage;
        }
        if(this.nomination.gdc_ms_AwardCategory__c == 'Customer Success Team Award'){
            this.teamAward = true;
            if (this.nomination.gdc_ms_SuccessTeamName__c !== undefined) {
                this.name = this.nomination.gdc_ms_SuccessTeamName__r.Name;
                this.photoUrl = this.nomination.gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c!=undefined?this.nomination.gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c:DefaultImage;
            } else if (this.nomination.gdc_ms_Nominee__c !== undefined) {
                this.name = this.nomination.gdc_ms_Nominee__r.Name;
                this.photoUrl = this.nomination.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c!=undefined?this.nomination.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c:DefaultImage;
            }

        }
        if (this.nomination.GDC_MS_GroupLeader__c) {
            this.groupleader = this.nomination.GDC_MS_GroupLeader__c;
        }

        if (this.nomination.gdc_ms_Quarter__c) {
            this.quarter = this.nomination.gdc_ms_Quarter__c;
        }



    }


    handleChecked(event){
        let checkBoxFieldValue = event.target.checked;
        console.log('check '+checkBoxFieldValue)
        let recordId = event.target.dataset.id;
        console.log('check '+recordId)
        if(checkBoxFieldValue){
            const selectedCheckbox = new CustomEvent('selected', { detail: recordId });
            this.dispatchEvent(selectedCheckbox);
        }
        if(!checkBoxFieldValue){
            const selectedCheckbox = new CustomEvent('diselected', { detail: recordId });
            this.dispatchEvent(selectedCheckbox);
        }
    }
}