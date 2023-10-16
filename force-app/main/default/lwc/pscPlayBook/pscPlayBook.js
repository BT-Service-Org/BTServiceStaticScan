import { LightningElement, api, track, wire } from 'lwc';
import PSC_SPSM_PRODUCT_IMAGES from '@salesforce/resourceUrl/pscSPSMImages';
import getAllPlayBookInfo from '@salesforce/apex/PSCPlaybookCtrl.getAllPlayBookInfo';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class PscPlayBook extends LightningElement {
    playBookData = {};
    @track playBookList = [];
    @track playBookName;
    @api contractType;
    @api pageName;
    // @api maxRecords;


    connectedCallback()
    {
        this.pageName = this.pageName?this.pageName:'playbooks';
        switch (FORM_FACTOR) {
            case 'Large':
                this.dividingValue = 3;
                return;
            case 'Medium':
                this.dividingValue = 2;
                return;
            case 'Small':
                this.dividingValue = 1;
                return;
        }
    }


    @wire(getAllPlayBookInfo, { key: '$contractType', pageName: '$pageName' })
    getAllPlayBookInfo({ error, data }) {
        if (data) {
            if (data.sobjectList !== undefined && data.sobjectList.length > 0) {
                if (data.hasOwnProperty('sobjectList') && data.sobjectList.length > 0) {
                    this.playBookData = data;
                    let tileInfo = JSON.parse(this.playBookData.playBookResources);
                    let found = false;
                    this.playBookData.sobjectList.map((row , index) => {
                        found = false;
                        tileInfo.map(tile => {
                            if (tile.name != null && row.name != null && tile.name.toLowerCase() === row.name.toLowerCase()) {
                                let obj = { Name:row.name, Description__c:row.description, Id:row.id, tileUrl: tile.tileUrl != '' ? PSC_SPSM_PRODUCT_IMAGES + tile.tileUrl : '', bgUrl: this.getBgImg(index),playbookUrl:'/ServicesCentral/s/playbook-landing?playbookName=' + encodeURIComponent(row.name) }
                                this.playBookList.push(obj);
                                found = true;
                            }
                            
                        })
                        if(!found){
                            let obj = { Name:row.name, Description__c:row.description, Id:row.id, tileUrl: '', bgUrl: this.getBgImg(index),playbookUrl:'/ServicesCentral/s/playbook-landing?playbookName=' + encodeURIComponent(row.name) }
                            this.playBookList.push(obj);
                        }
                    });
                }

            }
        }
        
        if (error) {
            console.log(JSON.stringify(error));
        }
    }

    getBgImg(ind){
        switch(ind%this.dividingValue) {
            case 1:
                return PSC_SPSM_PRODUCT_IMAGES + '/images/bg-green.svg'
            case 2:
                return PSC_SPSM_PRODUCT_IMAGES + '/images/bg-lavender.svg'
            default:
                return PSC_SPSM_PRODUCT_IMAGES + '/images/bg-blue.svg'
          }
    }

}