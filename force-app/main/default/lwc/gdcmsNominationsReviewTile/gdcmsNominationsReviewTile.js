import { LightningElement, api, track } from 'lwc';
import DefaultImage from '@salesforce/resourceUrl/GDCMSDefaultImage';
import getNominations from '@salesforce/apex/GDC_MS_NominationController.getNominationsRecords';
import getWinners from '@salesforce/apex/GDC_MS_NominationController.getWinners';
import updateWinner from '@salesforce/apex/GDC_MS_NominationController.updateWinner';
import removeWinner from '@salesforce/apex/GDC_MS_NominationController.removeWinner';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GdcmsNominationsReviewTile extends LightningElement {

    @api awardType = '';
    @api currentTabName = 'false';

    @track records = [];

    display = false;
    showDetails = false;
    selectedRecord = {};

    activeSections =['A', 'B', 'C'];
    selectedWinners = [];

    //Trailblazer Award
    //Customer Success Team Award
    //Achievers Award
    connectedCallback() {
        if (this.awardType && this.currentTabName) {
            this.showNominations(this.awardType,this.currentTabName);
        }
    }

    showNominations(awardTypeVar,currentTabNameVar){
        getNominations({ awardType: awardTypeVar, currentTabName: currentTabNameVar })
        .then(result => {
            console.log(JSON.stringify(result));
            if (result) {
                if (awardTypeVar === 'Customer Success Team Award') {
                    for (let i = 0; i < result.length; i++) {
                        if (result[i].gdc_ms_SuccessTeamName__c) {
                            result[i].gdc_ms_Nominee__c = result[i].gdc_ms_SuccessTeamName__r.Name;
                            result[i].imageUrl = result[i].gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c !=undefined ? result[i].gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c : DefaultImage;
                        }
                    }
                } else {
                    for (let i = 0; i < result.length; i++) {
                        if (result[i].gdc_ms_Nominee__c) {
                            result[i].gdc_ms_Nominee__c = result[i].gdc_ms_Nominee__r.Name;
                            result[i].gdc_ms_Designation__c = result[i].gdc_ms_Nominee__r.gdc_ms_Designation__c != undefined ? result[i].gdc_ms_Nominee__r.gdc_ms_Designation__c : '';
                            result[i].imageUrl = result[i].gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c !=undefined ? result[i].gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c : DefaultImage;
                        }
                    }
                }
                this.records = result;
                console.log('Rec -->>' + JSON.stringify(this.records));
            }
        }).catch(error => {
            console.log(error);
        })
    }

    handleClick(event) {
        console.log(event.target.name);

        if (this.records && this.records.length > 0) {
            let data = this.records.filter(record => record.Id === event.target.name);
            console.log(JSON.stringify(data));
            this.selectedRecord = data[0];
            this.showDetails = true;
        }
    }


    handleClose() {
        this.showDetails = false;
        this.selectedRecord = {};
    }

    get isTrailBlazerAward() {
        if (this.awardType === 'Trailblazer Award') {
            return true;
        } else {
            return false;
        }
    }

    get isCustomerSuccess() {
        if (this.awardType === 'Customer Success Team Award') {
            return true;
        } else {
            return false;
        }
    }

    get isAchiever() {
        if (this.awardType === 'Achievers Award') {
            return true;
        } else {
            return false;
        }
    }

    get isWinnerTab() {
        if (this.currentTabName === 'false') {
            return false;
        } else {
            return true;
        }
    }
    selectedTiles(event){
        if(event.target.checked === true){
            var selectedWinnerRecId = event.target.name;
            this.selectedWinners = [...this.selectedWinners, selectedWinnerRecId];
        }
        else if(event.target.checked === false && this.selectedWinners.includes(event.target.name)){
            var filteredList = this.selectedWinners.filter( winnerList => {
                return winnerList !== event.target.name;
              });
            this.selectedWinners = filteredList;
        }
    }
    saveWinners(){
        updateWinner({ recordIds: this.selectedWinners })
        .then((result) => {
            this.showToast('Success', 'The winner(s) has been updated...!', 'success');
            this.showNominations(this.awardType,this.currentTabName);
            this.handleResetCheckbox();
        })
        .catch((error) => {
            this.error = error;
        });
    }
    removeWinners(){
        removeWinner({ recordIds: this.selectedWinners })
        .then((result) => {
            this.showToast('Success', 'The winner(s) has been updated...!', 'success');
            this.showNominations(this.awardType,this.currentTabName);
            this.handleResetCheckbox();
        })
        .catch((error) => {
            this.error = error;
            console.log('this.error' + this.error);
        });
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    handleResetCheckbox(){
        this.template.querySelectorAll('lightning-input[data-id="chkbox"]').forEach(element => {
          element.checked = false;
        });
      }
}