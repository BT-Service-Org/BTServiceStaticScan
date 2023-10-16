import { LightningElement, api, wire } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import deleteUserFavorite from '@salesforce/apex/PSCFavoriteCtrl.deleteUserFavorite';
import createFavorite from '@salesforce/apex/PSCFavoriteCtrl.createFavorite';
export default class PscFavorite extends LightningElement {
    @api recordId;
    @api title;
    @api favId = undefined;
    heart_blank = PSC_IMAGES + '/Icons/heart_blank.png';
    heart_fill = PSC_IMAGES + '/Icons/heart_fill.png'
    @api fav = false;
    @api favData;

    handleFavoriteButtonClick(event) {
        if (event.which == '13' || event.which == '1') {
            if (this.favId !== null && this.favId !== undefined) {
                deleteUserFavorite({ recId: this.recordId })
                    .then(result => {
                        this.fav = false;
                        if(result.Active__c === false){
                            this.favId = undefined;
                        }
                        
                        this.refreshComponent();
                        const evt = new ShowToastEvent({
                            title: '"' + this.title.slice(0,20)+ '" was removed from your bookmarks.',
                            message: '',
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);

                    })
                    .catch(error => {
                        console.log('delete error->', error);
                    })
            }
            else {
                createFavorite({ recId: this.recordId, name: this.title })
                    .then(result => {
                        this.fav = result.Active__c;
                        this.favId = result.Id;

                        this.refreshComponent();
                        const evt = new ShowToastEvent({
                            title: '"' + this.title.slice(0,20) + '" was added to your bookmarks.',
                            message: '',
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);
                    })
                    .catch(error => {
                        console.log('create error->', error);
                    })
            }
        }
    }

    refreshComponent() {
        const refreshEvt = new CustomEvent("refreshparent");
        this.dispatchEvent(refreshEvt);
    }
}