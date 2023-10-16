import { LightningElement, wire,track, api } from 'lwc';
import PSC_SPSM_IMAGES from '@salesforce/resourceUrl/pscSPSMImages';
import PSC_SPSM_PRODUCT_IMAGES from '@salesforce/resourceUrl/pscSPSMProductImages';
import getAllPlayBookInfo from '@salesforce/apex/PSCPlaybookCtrl.getAllPlayBookInfo';
import playbookHeader from '@salesforce/label/c.Playbook_Header_Text'
import playbookHeaderDescription from '@salesforce/label/c.Playbook_Header_Description'
import pscStageHeader from '@salesforce/label/c.pscStageHeader';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class PscPlaybookHome extends LightningElement {
    label = {
        playbookHeader,
        playbookHeaderDescription,
        pscStageHeader
    }
    @track sowPlaybookType;
    @track sowAndOrderFormPlaybookType;
    @track stages;
    @track sobjectList = [];
    @track sowAndOrderFormPlaybookList = [];
    @api pageName;
    @track pscAllStages = [];
    @api pageHeader;
    @api pageDescription;
    @api contractType;
    @track headerInfo;
    @track headerDescription;
    fallbackImg;
    dividingValue;
    staticResourceUsed;

    connectedCallback()
    {
        this.pageName = this.pageName?this.pageName:'playbooks';
        
        // logic to use different static resources
        if(this.pageName==='productOfferings' || this.pageName==='serviceOfferings'){
            this.staticResourceUsed = PSC_SPSM_PRODUCT_IMAGES;
        }  
        else{
            this.staticResourceUsed = PSC_SPSM_IMAGES;
        }

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

    @wire(getAllPlayBookInfo, { key: '$contractType', pageName:'$pageName' })
    getAllSOWPlayBookInfo({ error, data }) {
        if (data) {
            if (data.sobjectList !== undefined && data.sobjectList.length > 0) {
                if (data.hasOwnProperty('sobjectList') && data.sobjectList.length > 0) {
                    this.playBookData = data;
                    let tileInfo = this.playBookData.hasOwnProperty('playBookResources')?JSON.parse(this.playBookData.playBookResources):[];
                    this.headerInfo = this.playBookData.hasOwnProperty('pageHeader')?this.playBookData.pageHeader:this.pageHeader?this.pageHeader:'';
                    this.fallbackImg = this.playBookData.hasOwnProperty('fallbackTileImg')?(this.staticResourceUsed + this.playBookData.fallbackTileImg):'';
                    this.headerDescription = this.playBookData.hasOwnProperty('pageDescription')?this.playBookData.pageDescription:this.pageDescription?this.pageDescription:'';
                    this.sobjectList = this.processCorrectData(this.playBookData.sobjectList, tileInfo);
                }
            }
        }
        if (error) {
            console.log(JSON.stringify(error));
        }
    }

    processCorrectData(processableArray, metaDataArray) {
        let targetArray = [];
        let found = false;
        processableArray.map((row ,index)=> {
            found = false;
            metaDataArray.map(tile => {
                if (tile.name != null && row.name != null && tile.name.toLowerCase() === row.name.toLowerCase()) {
                    let obj = { Name:row.name, Description__c:row.description, Id:row.id, tileUrl: tile.tileUrl != '' ? this.staticResourceUsed + tile.tileUrl : '', bgUrl: this.getBgImg(index),playbookUrl:row.communityURL}
                    targetArray.push(obj);
                    found = true;
                }
            });
            if (!found) {
                let obj = { Name:row.name, Description__c:row.description, Id:row.id, tileUrl: this.fallbackImg, bgUrl: this.getBgImg(index), playbookUrl:row.communityURL}
                targetArray.push(obj);
            }
        });
        return targetArray;
    }

    get retrievePageHeader()
    {
        return this.pageHeader?this.pageHeader:'';
    }

    get retrievePageDescription()
    {
        return this.pageDescription?this.pageDescription:'';
    }

    getBgImg(ind){
        switch(ind%this.dividingValue) {
            case 1:
                return this.staticResourceUsed + '/images/bg-green.svg'
            case 2:
                return this.staticResourceUsed + '/images/bg-lavender.svg'
            default:
                return this.staticResourceUsed + '/images/bg-blue.svg'
          }
    }

}