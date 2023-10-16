import { LightningElement, track, wire, api } from 'lwc';
import getMethodologyVersionData from '@salesforce/apex/PSCRevisionHistoryDataCtrl.getMethodologyVersionData';
import { CurrentPageReference } from 'lightning/navigation';

export default class PscRevisionHistory extends LightningElement {

    @track methodId;
    @track revisionHistoryData = [];
    initialDataLoad = [];
    @track expand = false;
    title;
    showIcon = false;
    @api showHistory=false;
    key='';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.methodNumber = currentPageReference.state?.methodnumber;
            this.methodname = currentPageReference.state?.methodname;
            this.key = (this.methodNumber!==undefined?this.methodNumber:(this.methodname!==undefined?this.methodname:''))
        }
    }
    @wire(getMethodologyVersionData, { key: '$key' })
    fetchRevisionHistoryData({ error, data }) {
        if (data) {
            this.revisionHistoryData = data;
            const revisionHistoryLength =  this.revisionHistoryData.length
            this.title = (revisionHistoryLength && this.revisionHistoryData[0].hasOwnProperty('Method__r')) ? this.revisionHistoryData[0]?.Method__r.Name : '';
            if (revisionHistoryLength > 1) {
                this.showIcon = true;
            }
            this.updateInitialData();
        }

        if (error) {
            console.log("error occured while fetching revision history data", error.message());
        }

    }

    updateInitialData() {
        if (this.revisionHistoryData && this.revisionHistoryData.length > 0) {
            this.initialDataLoad.push(this.revisionHistoryData[0]);
        }
    }

    expandHistory() {
        this.initialDataLoad = this.revisionHistoryData;
        this.expand = true;
    }
    collapseHistory() {
        this.initialDataLoad = this.initialDataLoad.slice(0, 1);
        this.expand = false;
    }
}