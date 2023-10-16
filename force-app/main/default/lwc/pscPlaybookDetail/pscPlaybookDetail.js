import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getPlaybookData from '@salesforce/apex/PSCPlaybookDetailCtrl.getPlaybookData';
export default class PscPlaybookDetail extends LightningElement {
    playbookName;
    stageName;
    playbookData;
    outcomeData = [];
    activeSectionMessage = '';
    expand = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.playbookName = currentPageReference.state?.playbookName;
            this.stageName = currentPageReference.state?.stageName;
        }
    }

    @wire(getPlaybookData, { playbookName: '$playbookName', stageName: '$stageName' })
    wiredPlayBookData({ error, data }) {
        if (data) {
            if (data !== null && data !== undefined && data.hasOwnProperty('playbook')) {
                this.playbookData = data;
                if (data.stageOutcomes.length) {
                    this.outcomeData = [...data.stageOutcomes];
                    this.outcomeData = this.outcomeData.map(data => {
                        if (data.hasOwnProperty('Stage_Method_Outcome__r') && data.Stage_Method_Outcome__r.length) {
                            return {
                                ...data,
                                label: (data.hasOwnProperty('Order__c') && data.Order__c ? data.Order__c + ". " : '') + data.Outcome__r?.Title__c,
                                methods: data.Stage_Method_Outcome__r.map(result => {
                                    if (result.hasOwnProperty('Method_Outcome__r') && result.Method_Outcome__r.hasOwnProperty('Method__r')) {
                                        return {
                                            ...result,
                                            navUrl: '/ServicesCentral/s/method?methodnumber=' + result.Method_Outcome__r.Method__r?.Method_Number__c
                                        }
                                    }
                                })
                            }
                        } else {
                            return {
                                ...data,
                                label: (data.hasOwnProperty('Order__c') && data.Order__c ? data.Order__c + ". " : '') + data.Outcome__r?.Title__c
                            }
                        }
                    });
                }
            }
        }
        if (error) {
            console.log("error", error);
        }
    }
    renderedCallback() {
        if (this.template.querySelector('.slds-is-open')) {
            const section = this.template.querySelector('section')?.classList;
        }

    }
    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }
    handleSetActiveSectionC() {
        const accordion = this.template.querySelector('.example-accordion');

    }

}