import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getOverallEngagementScopeId from '@salesforce/apex/SEP_QA.getOverallEngagementScopeId';
import getStreamsNdDomain2Assessments from '@salesforce/apex/SEP_QA.getStreamsNdDomain2Assessments';
import ESTIMATE_NAME from '@salesforce/schema/SEP_Estimate__c.Name';
import ESTIMATE_OWNER_ID from '@salesforce/schema/SEP_Estimate__c.OwnerId';
import sepEstimatorAssessmentsModal from 'c/sepEstimatorAssessmentsModal';
import { refreshApex } from '@salesforce/apex';



export default class SepEstimatorAssessmentsContainer extends LightningElement {
    @api recordId;
    @track wiredAssessments = [];
    size = 'medium';
    overallEngScopeId;
    estimateData;
    selStreamAssId = null;
    isInsert = true;

    @wire(getOverallEngagementScopeId)
    wiredOverallEngScopeId({ error, data }) {
        if (data) {
            this.isError = false;
            this.overallEngScopeId = data;
        } else if (error) {
            this.isError = true;
            console.log(this.logPrefix, 'Failed to fetch Overall Engagement Scope Id, ', JSON.stringify(error));
        }
    }

    @wire(getRecord, {recordId: '$recordId', fields: [ESTIMATE_NAME, ESTIMATE_OWNER_ID]})
    wireGetEstimate({data, error}) {
        if(data) {
            this.isError = false;
            this.estimateData = {
                'Id': data.id,
                'Name': data.fields.Name.value,
                'OwnerId': data.fields.OwnerId.value,
            };
        } else {
            this.isError = true;
            console.log(this.logPrefix, 'Failed to fetch Estimate record, ', JSON.stringify(error));
        }
    }

    async handleAssessmentModal() {
        console.log(this.logPrefix, 'Modal open ---');
        const result = await sepEstimatorAssessmentsModal.open({
            size: 'medium',
            overallEngScopeId: this.overallEngScopeId,
            estimateId: this.recordId,
            estimateData: this.estimateData,
            selStreamAssId: null,
            isInsert: true
        });
        refreshApex(this.wiredAssessments);
        console.log(this.logPrefix, 'Modal closed status: ', result);
    }

    @api invoke() {
        this.handleAssessmentModal();
    }

    @wire(getStreamsNdDomain2Assessments, {estimateId: '$recordId'})
    wiredStreamAssessments(response) {
        this.isLoading = true;
        this.wiredAssessments = response;
    }
}