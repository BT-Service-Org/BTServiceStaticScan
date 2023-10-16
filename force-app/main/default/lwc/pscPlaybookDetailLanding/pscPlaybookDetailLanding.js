import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getPlaybookData from '@salesforce/apex/PSCPlaybookDetailLandingCtrl.getPlaybookData';

export default class PscPlaybookDetailLanding extends LightningElement {
    playbookName;
    @track playbookData = {};
    @track mandatoryStages = [];
    @track optionalStages = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.playbookName = currentPageReference.state?.playbookName;
        }
    }

    @wire(getPlaybookData, { playbookName: '$playbookName' })
    wiredPlayBookData({ error, data }) {

        if (data) {
            if (data !== null && data !== undefined && data.hasOwnProperty('playbookData')) {

                this.playbookData = data;

                if (this.playbookData.stageData.mandatoryStages.length) {
                    this.mandatoryStages = [...this.playbookData.stageData.mandatoryStages];
                    this.mandatoryStages = this.mandatoryStages.map((stage, index) => {
                        return {
                            ...stage,
                            number: index + 1,
                            url: '/ServicesCentral/s/playbook-detail?playbookName=' + encodeURIComponent(this.playbookName) + '&stageName=' + encodeURIComponent(stage.Name)
                        }
                    });
                }

                if (this.playbookData.stageData.optionalStages.length) {
                    this.optionalStages = [...this.playbookData.stageData.optionalStages];
                    this.optionalStages = this.optionalStages.map((stage, index) => {
                        return {
                            ...stage,
                            number: index + 1,
                            url: '/ServicesCentral/s/playbook-detail?playbookName=' + encodeURIComponent(this.playbookName) + '&stageName=' + encodeURIComponent(stage.Name)
                        }
                    })
                }
            }
        }
        if (error) {
            console.log("error", error);
        }

    }

}