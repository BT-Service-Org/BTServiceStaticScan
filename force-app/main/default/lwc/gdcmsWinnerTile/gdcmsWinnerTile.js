import { LightningElement,api } from 'lwc';
import DefaultImage from '@salesforce/resourceUrl/GDCMSDefaultImage';
export default class GdcmsWinnerTile extends LightningElement {
    @api winner;
    name ;
    groupleader ;
    quarter;
    photoUrl;
    achieverAward = false;
    trailblazerAward = false;
    teamAward =false;

    connectedCallback(){
        //console.log('winnerlist '+this.winner.gdc_ms_AwardCategory__c+' '+this.winner.gdc_ms_Nominee__r.Name);
        if(this.winner.gdc_ms_AwardCategory__c == 'Achievers Award'){
            this.achieverAward = true;
            this.name = this.winner.gdc_ms_Nominee__r.Name;
            this.photoUrl = this.winner.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c!=undefined?this.winner.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c:DefaultImage;
        }
        if(this.winner.gdc_ms_AwardCategory__c == 'Trailblazer Award'){
            this.trailblazerAward = true;
            this.name = this.winner.gdc_ms_Nominee__r.Name;
            this.photoUrl = this.winner.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c!=undefined?this.winner.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c:DefaultImage;
        }
        if(this.winner.gdc_ms_AwardCategory__c == 'Customer Success Team Award'){
            this.teamAward = true;
            if (this.winner.gdc_ms_SuccessTeamName__c !== undefined) {
                this.name = this.winner.gdc_ms_SuccessTeamName__r.Name;
                this.photoUrl = this.winner.gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c!=undefined?this.winner.gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c:DefaultImage;
            } else if (this.winner.gdc_ms_Nominee__c !== undefined) {
                this.name = this.winner.gdc_ms_Nominee__r.Name;
                this.photoUrl = this.winner.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c!=undefined?this.winner.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c:DefaultImage;
            }
        }


        if (this.winner.GDC_MS_GroupLeader__c) {
            this.groupleader = this.winner.GDC_MS_GroupLeader__c;
        }

        if (this.winner.gdc_ms_Quarter__c) {
            this.quarter = this.winner.gdc_ms_Quarter__c;
        }
    }

    handleChecked(event){
        let checkBoxFieldValue = event.target.checked;
        console.log('check '+checkBoxFieldValue)
        let recordId = event.target.dataset.id;
        console.log('check '+recordId)
           // this.checkedBoxesIds.push(recordId);
        if(checkBoxFieldValue){
           const selectedCheckbox = new CustomEvent('selectedwinner', { detail: recordId });
           this.dispatchEvent(selectedCheckbox);
        }
        if(!checkBoxFieldValue){
            const selectedCheckbox = new CustomEvent('diselectedwinner', { detail: recordId });
           this.dispatchEvent(selectedCheckbox);
        }
    }
}