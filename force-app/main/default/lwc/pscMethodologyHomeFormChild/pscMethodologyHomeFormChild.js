import { LightningElement, api,track } from 'lwc';

export default class PscMethodologyHomeFormChild extends LightningElement {
    @api formTitle;
    @api recordsToDisplay;
    @api formData = [];
    partialData=[];
    completeData=[];
    @track engagementData = [];
    showCompleteData=false;

    connectedCallback() {
        
        for (let i = 0; i < this.formData.length; i++) {
            this.completeData.push({ title: this.formData[i].title, allListTitle: this.formData[i].linkTitle, allListLink: this.formData[i].allPageLink, methodologyChildList: [] });
            this.partialData.push({ title: this.formData[i].title, allListTitle: this.formData[i].linkTitle, allListLink: this.formData[i].allPageLink, methodologyChildList: [] });
            for (let j = 0; j < this.formData[i].methodologyChildList.length; j++) {
                this.completeData[i].methodologyChildList.push(this.formData[i].methodologyChildList[j]);
                if (j < this.recordsToDisplay) {
                    this.partialData[i].methodologyChildList.push(this.formData[i].methodologyChildList[j]);
                }
                else {
                    continue;
                }
            }

        }
        this.engagementData=this.partialData;
        
    }

    showEngagementData() {
        this.showCompleteData=!this.showCompleteData;
        this.engagementData=[];
        if(this.showCompleteData) {
            
            this.engagementData = this.completeData;
        } else {
            this.engagementData=this.partialData;
        }

    }

}