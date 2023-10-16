import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import getActiveDomains from '@salesforce/apex/SEP_QA.getActiveDomains';
import createStreamAssessment from '@salesforce/apex/SEP_QA.createStreamAssessment';

export default class SepEstimatorAssessmentsModal extends LightningModal {
    @api estimateId;
    @api estimateData;
    @api overallEngScopeId;
    @api selStreamAssDomains;
    @api selStreamAssId;
    @api isInsert;
    @api recordId;
    @track gridData;
    errorMsg;
    successMsg;
    isLoading = false;
    showForm = true;
    isError = false;
    @api streamAssessmentName;
    @track selectedRows = [];
    @track preSelectedRows;
    preSelectedDomainIds;
    logPrefix = 'SEP --- ';
    columns = [
        { label: 'Domain', fieldName: 'Name', sortable: "true" },
    ];
    @track isChecked = true;
    sortBy;
    sortDirection;

    get disabledStreamInput() {
        return !this.isInsert;
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.gridData));
        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });
        this.gridData = parseData;

    }

    generateInitAssessmentsData() {
        this.isLoading = true;
        getActiveDomains().then(result => {
            console.log('getActiveDomains result:', result);
            // Prepare the data for the tree grid
            let treeData = this.prepareTreeData(result);
            console.log('treeData:', treeData);
            this.gridData = treeData;
            // Pre select the 'Overall Engagement Scope' row
            this.preSelectedDomainIds = [this.overallEngScopeId];
            // Add selected Assessment domains to the preSelectedRows
            if(!this.isEmpty(this.selStreamAssDomains)) {
                this.preSelectedDomainIds.push(...this.selStreamAssDomains.keys());
            }
            this.preSelectedRows = this.preSelectedDomainIds;
            this.isLoading = false;
        }).catch(error => {
            console.error('Error in getActiveDomains:', error);
            this.isLoading = false;
            this.showForm = false;
            this.errorMsg = 'Failed to load Active Domains, ' + JSON.stringify(error);
        });
    }
        
    prepareTreeData(domains) {
        let treeData = [];
        let map = new Map();
    
        // First pass: create a map and add root nodes to treeData
        domains.forEach(domain => {
            // Create a new object for the domain
            let domainObj = { ...domain };
            map.set(domain.Id, domainObj);
            if (!domain.Parent_Domain__c) {
                treeData.push(domainObj);
            }
        });
    
        // Second pass: add child nodes to their parent node
        domains.forEach(domain => {
            if (domain.Parent_Domain__c) {
                let parent = map.get(domain.Parent_Domain__c);
                if (parent) {
                    if (!parent._children) {
                        parent._children = [];
                    }
                    // Create a new object for the domain
                    let domainObj = { ...domain };
                    parent._children.push(domainObj);
                }
            }
        });
    
        return treeData;
    }
    
    

    connectedCallback() {
        this.generateInitAssessmentsData();
    }

    handleRowSelection(event) {
        console.log(this.logPrefix, 'Handle row selection ---');
        this.selectedRows = event.detail.selectedRows;
        // Add DomainIds to the Datatable preSelectedRows
        let selRowIds = new Set(this.preSelectedDomainIds);
        this.selectedRows.forEach(e => {
            selRowIds.add(e.Id);
        });
        this.preSelectedRows = Array.from(selRowIds);
    }

    handleCloseAlert() {
        this.errorMsg = false;
    }

    handleStreamNameChange(event) {
        this.streamAssessmentName = event.target.value;
    }

    isEmpty(str) {
        return (str === '' || str === undefined);
    }

    handleSave() {
        console.log(this.logPrefix, 'Handle save selections ---');
        let userSelectedRows = this.selectedRows;
        if(!this.isEmpty(this.selStreamAssDomains)) {
            userSelectedRows = this.selectedRows.filter(e => !this.selStreamAssDomains.has(e.Id));
        }
        console.log(JSON.parse(JSON.stringify(userSelectedRows)));
        if(this.isEmpty(this.streamAssessmentName)) {
            this.errorMsg = 'Please enter Stream Assessment name!';
            return;
        }
        if(userSelectedRows.length <= 1) {
            this.errorMsg = 'Please select at least one domain to continue!';
            return;
        }
        const assessment = {};
        assessment['streamName'] = this.streamAssessmentName;
        assessment['overallEngScopeId'] = this.overallEngScopeId;
        assessment['selStreamAssId'] = this.selStreamAssId;
        console.log(this.logPrefix, 'Assessment --');
        console.log(assessment);
        this.errorMsg = this.showForm = false;
        this.isLoading = true;
        createStreamAssessment({assessment: assessment, estimate: this.estimateData, selDomains: userSelectedRows, isInsert: this.isInsert}).then(response => {
            let jsonResponse = JSON.parse(response);
            console.log(this.logPrefix, 'Assessment response --');
            console.log(jsonResponse);
            this.isLoading = false;
            this.showForm = false;
            this.isError = jsonResponse.isError;
            if(jsonResponse.isError) {
                this.errorMsg = jsonResponse.message;
            } else {
                this.gridData = this.selDomains = [];
                this.streamAssessmentName = this.estimateData = '';
                this.successMsg = jsonResponse.message
            }
        }).catch(error => {
            this.isLoading = false;
            this.showForm = false;
            this.isError = true;
            this.errorMsg = 'Failed to create Assessment records, ' + JSON.stringify(error);
        });
    }

    handleUpdate() {
        console.log(this.logPrefix, 'Handle update selections ---');
        this.handleSave();
    }

    handleCancel() {
        this.close('okay');
    }
}