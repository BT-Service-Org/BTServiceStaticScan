import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'gdc_ms_Nomination__c.Name', 'gdc_ms_Nomination__c.gdc_ms_AwardCategory__c'
];

export default class GdcmsRewardsRecognitionView extends LightningElement {
    @api recordId;
    activeSections = ['A','B'];
    isTrailblazers = false;
    isCustomerScussess = false;
    isAchieversAward = false;
    accLabel = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    savedRecordIdWire({ data, error }) {
        if (data !== undefined) {
            this.setAwardCategory(data.fields.gdc_ms_AwardCategory__c.value);
        }
    }

    async setAwardCategory(data) {
        switch (data) {
            case 'Trailblazer Award':
                await this.resertUI();
                this.isTrailblazers = true;
                this.accLabel = 'Trailblazer Award';
                 break;

            case 'Customer Success Team Award':
                await this.resertUI();
                this.isCustomerScussess = true;
                this.accLabel = 'Customer Success Team Award';
                break;

            case 'Achievers Award':
                await this.resertUI();
                this.isAchieversAward = true;
                this.accLabel = 'Achievers Award';
                break;
            default:
                break;
        }
    }

    async resertUI() {
        this.isTrailblazers = false;
        this.isCustomerScussess = false;
        this.isAchieversAward = false;
    }
}