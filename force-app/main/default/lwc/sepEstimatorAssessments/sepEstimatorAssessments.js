import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ESTIMATE_NAME from '@salesforce/schema/SEP_Estimate__c.Name';
import ESTIMATE_OWNER_ID from '@salesforce/schema/SEP_Estimate__c.OwnerId';
import getOverallEngagementScopeId from '@salesforce/apex/SEP_QA.getOverallEngagementScopeId';
import getStreamsNdDomain2Assessments from '@salesforce/apex/SEP_QA.getStreamsNdDomain2Assessments';
import sepEstimatorAssessmentsModal from 'c/sepEstimatorAssessmentsModal';
import sepEstimatorAssessmentsDomainsArchiveModal from 'c/sepEstimatorAssessmentsDomainsArchiveModal';
import { refreshApex } from '@salesforce/apex';

export default class SepEstimatorAssessments extends LightningElement {
    @api recordId;
    estimateData;
    overallEngScopeId;
    isLoading = false;
    isError = false;
    @track hideNonFsTable = true;
    columns = [
        { label: 'Work Streams', fieldName: 'work_streams', type: 'text' },
        { label: 'Functional Points', fieldName: 'functional_points', type: 'text' },
        { label: 'Complexity Progress', fieldName: 'complexity_progress', type: 'text' },
        { label: 'Completion Progress', fieldName: 'completion_progress', type: 'text' },
        { type: 'button', typeAttributes: { label: 'Button', name: 'button', variant: 'base' } }
    ];
    @track gridData;
    @track wiredAssessments = [];
    @track overallEngScopeData = [];
    gridExpandIcon = 'utility:chevronright';
    logPrefix = 'SEP --- ';

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

    @wire(getStreamsNdDomain2Assessments, {estimateId: '$recordId'})
    wiredStreamAssessments(response) {
        this.isLoading = true;
        this.wiredAssessments = response;
        let data = response.data;
        let error = response.error;
        if(data) {
            let wStreams = new Map();
            data.forEach(e => {
                let record = e.record;
                let functionPoints = (record.Function_Points_Sum__c === undefined || record.Function_Points_Sum__c === null) ? 0 : record.Function_Points_Sum__c;
                let complexityPoints = (record.Function_Point_Consumption__c === undefined || record.Function_Point_Consumption__c === null) ? 0 : record.Function_Point_Consumption__c;
                let totalfunctionPoints = (record.Total_of_Possible_Function_Points__c === undefined || record.Total_of_Possible_Function_Points__c === null) ? 0 : record.Total_of_Possible_Function_Points__c;
                

                if(wStreams.has(record.SEP_Stream_Assessment__c)) {
                    let getStream = wStreams.get(record.SEP_Stream_Assessment__c);
                    getStream['streamAssessment']['functionPoints'] += functionPoints;
                    let addDomainAssessment = {
                        'id': record.Id,
                        'name': record.Name,
                        'domainId': record.SEP_Domain__c,
                        'complexityPoints': complexityPoints,
                        'functionPoints': functionPoints,
                        'totalfunctionPoints': totalfunctionPoints,
                        'allQSize': e.allQSize,
                        'answeredQSize': e.answeredQSize
                    };
                    getStream['domainAssessment'].push(addDomainAssessment);
                } else {
                    let assessments = {
                        'streamAssessment': {
                            'id': record.SEP_Stream_Assessment__c,
                            'name': record.SEP_Stream_Assessment__r.Name,
                            'functionPoints': functionPoints,
                            'allQSize': e.allQSize,
                            'answeredQSize': e.answeredQSize
                        },
                        'domainAssessment': [
                            {
                                'id': record.Id,
                                'name': record.SEP_Domain__r.Name,
                                'domainId': record.SEP_Domain__c,
                                'functionPoints': functionPoints,
                                'totalfunctionPoints': totalfunctionPoints,
                                'complexityPoints': complexityPoints,
                                'allQSize': e.allQSize,
                                'answeredQSize': e.answeredQSize
                            }
                        ]
                    };
                    wStreams.set(record.SEP_Stream_Assessment__c, assessments);
                }
            });
            console.log(this.logPrefix, 'Assessments ---');
            console.log(wStreams);
            this.generateGridData(wStreams);
            if(wStreams.size > 0){this.hideNonFsTable = false;}
        } else if (data == null) {
            this.gridData = [];
            this.isLoading = this.isError = false;
            console.log(this.logPrefix, 'Assessment records not found for the Estimate Id: ' + this.recordId);
        } else {
            this.gridData = [];
            this.isLoading = false;
            this.isError = true;
            console.log(this.logPrefix, 'Failed to fetch Assessment records, ', JSON.stringify(error));
        }
    }   

    generateGridData(wStreams) {
        let tempData = [];
        worAsLoop: for (let e of wStreams.values()) {
          let streamAssessment = e.streamAssessment;
          let allQSize = streamAssessment.allQSize;
          let answeredQSize = streamAssessment.answeredQSize;
          let worAsCompletionProgress = allQSize > 0 ? Math.round((answeredQSize / allQSize) * 100) : 0;
      
          let worAsRecord = {
            id: streamAssessment.id,
            work_streams: streamAssessment.name,
            functional_points: streamAssessment.functionPoints,
            allQSize,
            answeredQSize,
            displayChild: false,
            gridExpandIcon: 'utility:chevronright',
            _children: []
          };
      
          let childCompletionProgressSum = 0;
          let childComplexityProgressSum = 0;
          let childTotalPossibleFuctionPointsSum = 0;
      
          for (let r of e.domainAssessment) {
            let domAsCompletionProgress = r.allQSize > 0 ? Math.round((r.answeredQSize / r.allQSize) * 100) : 0;
            childCompletionProgressSum += domAsCompletionProgress;

            childComplexityProgressSum += r.complexityPoints;
            childTotalPossibleFuctionPointsSum += r.totalfunctionPoints;

            let domAsRecord = {
              id: r.id,
              domainId: r.domainId,
              work_streams: r.name,
              functional_points: r.functionPoints,
              total_functional_points: r.totalfunctionPoints,
              allQSize: r.allQSize,
              answeredQSize: r.answeredQSize,
              answeredQ: r.answeredQSize,
              totalQ: r.allQSize,
              d2a_link: '/' + r.id,
              completion_progress: domAsCompletionProgress,
              complexity_Points: r.complexityPoints

            };
      
            if(r['domainId'] == this.overallEngScopeId) {
                this.overallEngScopeData = domAsRecord;
                continue worAsLoop;
            }
            worAsRecord._children.push(domAsRecord);
          }
      
          let averageChildCompletionProgress = 0;
          let averageChildComplexityProgress = 0;
          let averageChildTotalPossibleFunctionPoints = 0;

          if (worAsRecord._children.length > 0) {
            averageChildCompletionProgress = Math.round(childCompletionProgressSum / worAsRecord._children.length);

            averageChildComplexityProgress = Math.round(childComplexityProgressSum / worAsRecord._children.length);;
            
            averageChildTotalPossibleFunctionPoints =  Math.round(childTotalPossibleFuctionPointsSum / worAsRecord._children.length);;
            

          }
      
          worAsRecord.completion_progress = `${averageChildCompletionProgress}`;
          worAsRecord.complexity_progress = `${averageChildComplexityProgress}`;
          //worAsRecord.TotalPossibleFunctionPoints_progress = `${averageChildTotalPossibleFunctionPoints}`;
          worAsRecord.TotalPossibleFunctionPoints_progress = `${childTotalPossibleFuctionPointsSum}`;
          tempData.push(worAsRecord);
        }
        tempData.forEach(ele=>{
            const points = (ele.functional_points / ele.TotalPossibleFunctionPoints_progress) *100;
            ele.complexity_Points = (points !== undefined && !isNaN(points) ) ? points : 0;
        })
      
        console.log(this.logPrefix, 'Assessment grid data ---');
        console.log(tempData);
      
        this.gridData = tempData;
        this.isLoading = false;
        this.isError = false;
    }
    
    async toggleChildRow(event) {
        const recordId = event.currentTarget.dataset.recordid;
    
        this.gridData.forEach(record => {
            if (record.id === recordId) {
                record.displayChild = !record.displayChild;
                record.gridExpandIcon = record.gridExpandIcon === 'utility:chevronright' ? 'utility:chevrondown' : 'utility:chevronright';
                
                if (record.displayChild) {
                    record._children.forEach(child => {
                        child.answeredQ = child.answeredQSize;
                        child.totalQ = child.allQSize;
                    });
                }
            }
        });
    
        await this.nextTick();
    
        this.updateProgressForChildRecords();
    }
    
    updateProgressForChildRecords() {
        const progressRings = this.template.querySelectorAll('c-sep-assessment-completion-progress');
    
        progressRings.forEach(progressRing => {
            const ringRecordId = progressRing.dataset.recordid;
            const childRecord = this.findChildRecordById(ringRecordId);
    
            if (childRecord) {
                progressRing.updateProgress(childRecord.answeredQ, childRecord.totalQ);
            }
        });
    }
    
    findChildRecordById(recordId) {
        for (let record of this.gridData) {
            if (record.displayChild) {
                const childRecord = record._children.find(child => child.id === recordId);
                if (childRecord) {
                    return childRecord;
                }
            }
        }
    
        return null;
    }    
    
    toggleChildRow(event) {
        const recordId = event.currentTarget.dataset.recordid;
        this.gridData.map(record => {
            if (record['id'] == recordId) {
                record['displayChild'] = record['displayChild'] ? false : true;
                record['gridExpandIcon'] = record['gridExpandIcon'] == 'utility:chevronright' ? 'utility:chevrondown' : 'utility:chevronright';
            }
            return record;
        });
    }

    recalculateAnsweredAndTotalQ() {
        this.answeredQ = 0;
        this.totalQ = 0;
        console.log('grid data');
        console.log(this.gridData);
    
        this.gridData.forEach(record => {
            console.log('record');
            console.log(record);
            if(record.displayChild) {
                record._children.forEach(child => {
                    // Make sure to replace 'answeredQSize' and 'allQSize' with the actual properties in your dataset
                    this.answeredQ += child.answeredQSize;
                    this.totalQ += child.allQSize;
                });
            }
        });
    }

    nextTick() {
        return new Promise((resolve) => {
            setTimeout(resolve, 0);
        });
    }

    async handleAssessmentModal() {
        console.log(this.logPrefix, 'Modal open ---');
        const result = await sepEstimatorAssessmentsModal.open({
            size: 'small',
            overallEngScopeId: this.overallEngScopeId,
            estimateId: this.recordId,
            estimateData: this.estimateData,
            selStreamAssId: null,
            isInsert: true
        });
        refreshApex(this.wiredAssessments);
        console.log(this.logPrefix, 'Modal closed status: ', result);
    }

    async handleAddNewDomain(event) {
        const selStreamAssId = event.target.value;
        const selStreamName = event.target.dataset.streamName;
        let streamAssDomains = new Map();
        for(let e of this.gridData) {
            if(e['id'] == selStreamAssId) {
                e['_children'].forEach(r => {
                    streamAssDomains.set(r['domainId'], r['work_streams']);
                });
                break;
            }
        }
        console.log(this.logPrefix, 'Modal open to add new domain ---');
        const result = await sepEstimatorAssessmentsModal.open({
            size: 'small',
            overallEngScopeId: this.overallEngScopeId,
            estimateId: this.recordId,
            estimateData: this.estimateData,
            selStreamAssDomains: streamAssDomains,
            streamAssessmentName: selStreamName,
            selStreamAssId: selStreamAssId,
            isInsert: false
        });
        refreshApex(this.wiredAssessments);
        console.log(this.logPrefix, 'Modal closed status: ', result);
    }

    async handleArchiveDomain(event) {
        console.log(this.logPrefix, 'Archive Domain Modal open ---');
        const selStreamAssId = event.target.value;
        const selStreamName = event.target.dataset.streamName;
        console.log('selStreamAssId: ' + selStreamAssId);
        const result = await sepEstimatorAssessmentsDomainsArchiveModal.open({
            size: 'small',
            estimateId: this.recordId,
            streamAssessmentName: selStreamName,
            selStreamAssId: selStreamAssId,
            isArchive: true
        });
        refreshApex(this.wiredAssessments);
        console.log(this.logPrefix, 'Archive Domain Modal closed status: ', result);
    }

    async handleRestoreDomain(event) {
        console.log(this.logPrefix, 'Restore Archive Domain Modal open ---');
        const selStreamAssId = event.target.value;
        const selStreamName = event.target.dataset.streamName;
        console.log('selStreamAssId: ' + selStreamAssId);
        const result = await sepEstimatorAssessmentsDomainsArchiveModal.open({
            size: 'small',
            estimateId: this.recordId,
            streamAssessmentName: selStreamName,
            selStreamAssId: selStreamAssId,
            isArchive: false
        });
        refreshApex(this.wiredAssessments);
        console.log(this.logPrefix, 'Restore Archive Domain Modal closed status: ', result);
    }

}