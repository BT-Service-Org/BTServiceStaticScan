import { LightningElement, track, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, notifyRecordUpdateAvailable, getFieldValue  } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';


const RELATED_FIELDS = ['SEP_Capability2Domain__c.Name','SEP_Capability2Domain__c.Id', 'SEP_Capability2Domain__c.SEP_Capability_Name__c', 'SEP_Capability2Domain__c.SEP_Capability_ID__c'];

// related to Header
import Estimate__c from '@salesforce/schema/SEP_Domain2Assesment__c.Estimate__c';
import Name from '@salesforce/schema/SEP_Domain2Assesment__c.Name';
import SEP_Estimate_Name__c from '@salesforce/schema/SEP_Domain2Assesment__c.SEP_Estimate_Name__c';
import Function_Points_Sum__c from '@salesforce/schema/SEP_Domain2Assesment__c.Function_Points_Sum__c';
import getRelatedDomains4SameAssessment  from '@salesforce/apex/SEP_QA.getRelatedDomains4SameAssessment';  //(ID domainid)
import getCompletionProgressData from '@salesforce/apex/SEP_QA.getCompletionProgressData';
// related to body
const DOM_ASSESS_FIELDS = ['SEP_Domain2Assesment__c.Name', 'SEP_Domain2Assesment__c.Estimate__c', 'SEP_Domain2Assesment__c.Function_Points_Sum__c', 'SEP_Domain2Assesment__c.SEP_Estimate_Name__c'];
import getSepQA_Details  from '@salesforce/apex/SEP_QA.getSepQA_Details';
import updateAssessment from '@salesforce/apex/SEP_QA.updateAssessment';
import sepEstimatorAssessmentsConfirmModal from 'c/sepEstimatorAssessmentsConfirmModal';

//related to FP per Domain
const CAPA4DOMAIN = [];
import getCapaFP4Domain  from '@salesforce/apex/SEP_QA.getCapaFP4Domain';

//columns for the Domain Summary Tab
const SummaryCols = [
    {label: 'Capability', type: 'button', 
        typeAttributes: {
            label: { fieldName: 'SEP_Capability_Name__c'},
            variant: 'base'
        },
        fieldName: 'SEP_Capability_Name__c', 
        cellAttributes: {
            class: 'slds-text-link'
        },
    },
    { label: 'Function Points',type: 'text', fieldName: 'Function_Points_Sum__c',
        wrapText: true
    },
    { label: '% Complex',type: 'text', fieldName: 'perComplex',
        wrapText: true
    },
    { label: 'Capability Complexity Rating', fieldName: 'complexityValue', type: 'capabilityComplexityIndicatorTable',initialWidth: 220, typeAttributes: {
        complexityValue: {fieldName: 'complexityValue'}
        }
    },
    
];

export default class SEP_Domain_Assessment_Body extends NavigationMixin(LightningElement) {

    @api recordId;
    @track tabs = [];

    @track data = [];
    @track tabdata;

    @track activeTab = '0';
    activeCapaId = '0';
    activeTabValue = 1;
    activeTabName = 'All';
    maxTab = '1';
    summaryTab= 0;

    //stateful Save button
    isSaving = false;

    // Header 
    @track name = "test";
    @track estimateID;
    @track estimateName;
    @track fp = 0;
    @track _getRecordResponse;

    //fp per capa for domain
    @track _getFP4Capa;
    @track fp4CapaTable = [];

    //related domains for this Stream
    @track domains = [];
    @track _getDomains;
    @track curDomainPos = 0;
    @track maxDomainPos = 1;

    //summary Table Info
    @track summaryData = [];
    summaryCols = SummaryCols;
    // Domain Progress Values
    @track _getCompletionProgress;
    totalQ;
    answeredQ;

    logPrefix = 'SEP --- ';
    // --------------- Conditional Rendering -----------
    get shouldDisplayFunctionPointsPerCapability() {
        return this.activeTabValue === this.summaryTab;
    }
      

    // --------------- Header --------------------------
    @wire(getRecord, { recordId:'$recordId', fields: DOM_ASSESS_FIELDS})
    loadFields(response){
        this._getRecordResponse = response;
        let error = response && response.error;
        let data = response && response.data;
        if(error){
            console.info(this.logPrefix,"No data Dom2Asses Name ");
        }else if(data){

            /*
            this.name = data.fields.Name.value;
            this.estimateID = data.fields.Estimate__c.value;
            this.fp = data.fields.Function_Points_Sum__c.value;
            */

            this.name = getFieldValue(data, Name);
            this.estimateID = getFieldValue(data, Estimate__c);
            this.fp = getFieldValue(data, Function_Points_Sum__c);
            this.estimateName = getFieldValue(data,SEP_Estimate_Name__c );

            console.info(this.logPrefix,"record id ", this.recordId);
            console.info(this.logPrefix,"Estimate Name ", this.estimateName);
        }
    }
    
    refreshWire() {
        console.info(this.logPrefix,'refresh wire');
        refreshApex(this._getRecordResponse);
        refreshApex(this._getFP4Capa);
        refreshApex(this._getCompletionProgress);
    }

    get domainName() {
        return this.name;
    }

    get functionPoints() {
        return this.fp;
    }

    get estimateURL() {
        return '/' + this.estimateID;
    }

    // ---------------- Data Handling Body ---------------

    // get the list of related domains
    @wire(getRelatedListRecords, { parentRecordId: '$recordId', relatedListId: 'SEP_Capability2Domains__r', fields: RELATED_FIELDS})
    wiredRelated ({error,data}) {
        
        if (data) {
            this.wireData = data;

            let i = 1;
            // add an all records tab
            this.tabs.push({
                id: '0',
                name: 'All',
                //capaid: `${capaID}`,
                key:`${i}`,
                value: '0',
                
            });
            i++;
            this.summaryTab++

            //iterate over related list items and store in tabs
            data.records.forEach( obj => {

                let tmpName = obj.fields.SEP_Capability_Name__c.value;
                let tmpID = obj.fields.Id.value;
                let capaID = obj.fields.SEP_Capability_ID__c.value;

                this.tabs.push({
                    id: `${tmpID}`,
                    name: `${tmpName}`,
                    //capaid: `${capaID}`,
                    key:`${i}`,
                    value:`${capaID}`,
                });
                
                
                i++;
                this.summaryTab++
            } );

            this.tabs.push({
                id: '0',
                name: 'Function Point Summary',
                key:`${i}`,
                value: `${i}`,
                
            });
            this.summaryTab++

            this.maxTab = i.toString();
         

        } else if (error) {
            console.info(this.logPrefix,"--- ERROR  Related List");
            console.info(this.logPrefix,error, 'in related');
        }
    }

    //get all QA records for this assessment
    @wire(getSepQA_Details, { assessid: '$recordId'})
    wiredQA_Details ({error,data}) {
        console.info(this.logPrefix,"--- wired qa");
        if (data && data.length > 0) {
            this.data = data;
            // First time only display the parent questions
            let cloneData = JSON.parse(JSON.stringify(this.data));
            let prevQuestion = cloneData[0].SEP_Question_Answer__c;
            let prevQuestionAnswer = cloneData[0].Selected_Answer__c;
            // If parent question answer is selected and that has dependent question than also display those question else hide
            cloneData = cloneData.filter(e => {
                if(
                    e.Parent_Question__c == undefined || e.Parent_Question__c == ''
                ) {
                    prevQuestion = e.SEP_Question_Answer__c;
                    prevQuestionAnswer = e.Selected_Answer__c;
                    e['isVisible'] = true;
                } else if (
                    e.Parent_Question__c == prevQuestion && e.Dependent_Answer__c == prevQuestionAnswer
                ) {
                    e['isVisible'] = true;
                } else {
                    e['isVisible'] = false;
                }
                return true;
            });
            this.data = cloneData;
            this.changeTabData();
        } else if (error) {
            console.info(this.logPrefix,"--- ERROR in wiredQA, error");
        }
    }
        
    @wire(getCompletionProgressData, { assessid: '$recordId'})
    domainCompletionProgressData(response) {
        this._getCompletionProgress = response;
        let error = response && response.error;
        let data = response && response.data;
        if (error) {
            console.info(this.logPrefix, "No Completion Data Found");
        } else if (data) {
            this.answeredQ = data[0];
            this.totalQ = data[1];
            this.updateDomainProgressIndicator();
        }
    }

    // get all related domains to this one sharing same assessment id. For handling of buttons in header
    @wire(getRelatedDomains4SameAssessment, {domainid: '$recordId'})
    wiredGetDomains(response) {
        this._getDomains = response;
        let error = response && response.error;
        let data = response && response.data;
        if(error){
            console.info(this.logPrefix,"error in getting domains ", JSON.stringify(error));
        }else if(data){
            let i = 0;
            
            //iterate over result and add position id
            data.forEach( obj => {
                i++;
                
                let tmpName = obj.Name;
                let tmpID = obj.Id;

                this.domains.push({
                    id: `${tmpID}`,
                    name: `${tmpName}`,
                    key:`${i}`,
                });
                //find the current position in the array
                if (tmpID == this.recordId) {
                    this.curDomainPos = i;
                }
            } );
            this.maxDomainPos = i;
           console.info(this.logPrefix,"releated domains ", JSON.stringify(this.domains), this.maxDomainPos);
        }
    }    


    async performUpdate() {
        // avoid reentry
        if (!this.isSaving) {

            this.isSaving = !this.isSaving;

            /* Reduce data for update */
            /* ID, SEP_Capability_ID__c, SEP_Query__c, SEP_Answer_1__c, SEP_Answer_2__c, SEP_Answer_3__c, SEP_Answer_4__c, SEP_Answer_5__c, 
            Selected_Answer__c, Parent_Question__c, Dependent_Answer__c, isVisible */
            let reducedData = this.data.map((
                {
                    SEP_Capability_ID__c, SEP_Query__c, SEP_Answer_1__c, SEP_Answer_2__c, SEP_Answer_3__c, 
                    SEP_Answer_4__c, SEP_Answer_5__c, Parent_Question__c, Dependent_Answer__c, isVisible, ...rest
                }
            ) => rest);
            //update using Apex
            console.info(this.logPrefix,"--- try to update using apex....");
            updateAssessment({assessid: this.recordId, records: reducedData} )
                .then((result) => {
                    console.info(this.logPrefix,"--- updated using apex....");
                    this.isSaving = !this.isSaving;
                    this.refreshWire();
                    
                })
                .catch((error) => {
                    console.info(this.logPrefix,"--- error while updated using apex....", JSON.stringify(error));
                    this.isSaving = !this.isSaving;
                    let errorMsg = 'Unexpected error';

                    if (error.body.message && error.body.message.includes('INSUFFICIENT_ACCESS_OR_READONLY')) {
                        errorMsg = 'INSUFFICIENT_ACCESS_OR_READONLY';
                    } else if (error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].statusCode === 'INSUFFICIENT_ACCESS_OR_READONLY') {
                        errorMsg = 'INSUFFICIENT_ACCESS_OR_READONLY';
                    }else if (error.body.message && error.body.message.includes('STRING_TOO_LONG')) {
                        errorMsg = 'Notes cannot be longer than 255 characters.';
                    }

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating assessment',
                            message: errorMsg,
                            variant: 'error',
                        }),
                    );
                });    
                
        } else {
            console.info(this.logPrefix,"--- currently saving....", error);
        }
    }

    // data handling for capa function points for given domain
    fp4capaCol = [
        { label: 'Capability', type: 'button', 
            typeAttributes: {
                label: { fieldName: 'SEP_Capability_Name__c'},
                variant: 'base'
            },
            fieldName: 'SEP_Capability_Name__c', 
            cellAttributes: {
                class: 'slds-text-link'
            },
        },
        { label: 'Function Points',type: 'text', fieldName: 'Function_Points_Sum__c',
            wrapText: true},
    ];

    //get all Fp per Domains for this assessment
    @wire(getCapaFP4Domain, { assessid: '$recordId'})
    wiredCapaFP4Domain (response) {
        this._getFP4Capa = response;
        let error = response && response.error;
        let data = response && response.data;
        if(error){
            console.info(this.logPrefix,"CapaFP4Domain ");
        }else if(data){
           this.fp4CapaTable = data;
           this.fp4CapaTable = this.fp4CapaTable.map((row, index) => ({ ...row, key: index }));

           this.summaryData = this.fp4CapaTable.map(ele=>({...ele, perComplex: (ele.Function_Point_Consumption__c !== undefined ? JSON.stringify(ele.Function_Point_Consumption__c)+' %' : undefined), complexityValue: ele.Function_Point_Consumption__c})); // to add complexity value for the indicator!
        }
    } 

    // ----------- define columns for QA datatable
    columns = this.populateColumns(); 

    populateColumns(){
        var columns = [
            { label: 'Question',type: 'text', fieldName: 'SEP_Query__c', wrapText: true},
            { 
                label: 'Not Applicable', fieldName: 'SEP_Answer_0__c', type: 'clickablecolorcell', 
                typeAttributes: { 
                    cellcontent: {fieldName: 'SEP_Answer_0__c'},cellcolumn: {col: 0},
                    cellselected: {fieldName: 'Selected_Answer__c'},cellquestionid: {fieldName: 'Id'}
                },
                hideDefaultActions: "true"
            },
            { 
                label: 'Answer #1', fieldName: 'SEP_Answer_1__c',wrapText: true, type: 'clickablecolorcell', 
                typeAttributes: { 
                    cellcontent: {fieldName: 'SEP_Answer_1__c'},cellcolumn: {col: 1},
                    cellselected: {fieldName: 'Selected_Answer__c'},cellquestionid: {fieldName: 'Id'},
                    cellquestionanswerid: {fieldName: 'SEP_Question_Answer__c'}
                }
            },

            { 
                label: 'Answer #2', fieldName: 'SEP_Answer_2__c',wrapText: true, type: 'clickablecolorcell', 
                typeAttributes: { 
                    cellcontent: {fieldName: 'SEP_Answer_2__c'},cellcolumn: {col: 2},
                    cellselected: {fieldName: 'Selected_Answer__c'},cellquestionid: {fieldName: 'Id'},
                    cellquestionanswerid: {fieldName: 'SEP_Question_Answer__c'}
                }
            },

            { 
                label: 'Answer #3', fieldName: 'SEP_Answer_3__c',wrapText: true, type: 'clickablecolorcell', 
                typeAttributes: { 
                    cellcontent: {fieldName: 'SEP_Answer_3__c'},cellcolumn: {col: 3},
                    cellselected: {fieldName: 'Selected_Answer__c'},cellquestionid: {fieldName: 'Id'},
                    cellquestionanswerid: {fieldName: 'SEP_Question_Answer__c'}
                }
            },

            { 
                label: 'Answer #4', fieldName: 'SEP_Answer_4__c',wrapText: true, type: 'clickablecolorcell', 
                typeAttributes: { 
                    cellcontent: {fieldName: 'SEP_Answer_4__c'},cellcolumn: {col: 4},
                    cellselected: {fieldName: 'Selected_Answer__c'},cellquestionid: {fieldName: 'Id'},
                    cellquestionanswerid: {fieldName: 'SEP_Question_Answer__c'}
                }
            },

            { 
                label: 'Answer #5', fieldName: 'SEP_Answer_5__c',wrapText: true, type: 'clickablecolorcell', 
                typeAttributes: { 
                    cellcontent: {fieldName: 'SEP_Answer_5__c'},cellcolumn: {col: 5},
                    cellselected: {fieldName: 'Selected_Answer__c'},cellquestionid: {fieldName: 'Id'},
                    cellquestionanswerid: {fieldName: 'SEP_Question_Answer__c'}
                }
            },

            { 
                label: 'Notes', fieldName: 'Question_Note__c',wrapText: true, type: 'text', editable: true
            }
    
        ];
        return columns;
    }
    
    // ------------  Event Handling -------------------------
    handleSummaryTableCapabilityClick(event) {
        console.log('key');
        console.log(JSON.parse(JSON.stringify(event.detail.row)));
        console.log(event.detail.row.key)
        this.goToPage(event.detail.row.key, true);
    }

    // ------ handle tab switch event - change data source for table?
    handleActive(event) {
        const tab = event.target;
        const capaid = event.target.value;
        this.activeTabName = event.target.label;
        console.info(this.logPrefix,'>>Tab ', capaid, ' is now active');
        console.info(this.logPrefix,'>>Tab ',event.target.label, ' is now active');
        console.info(this.logPrefix,'>>Tab ',event.target.value, ' is now active');
        //console.info(this.logPrefix,'Event: ', JSON.stringify(event.target));

        //ensure that activeTabValue always have the correct value (for buttons)
        let tmp = this.tabs.find(tmp => tmp.value === capaid);
        console.info(this.logPrefix, JSON.stringify(tmp));
        this.activeTabValue =  Number(tmp.key);
        console.info(this.logPrefix,'>>Tab ', capaid, ' is now active at ', this.activeTabValue);
        this.activeCapaId = capaid;

        //if we have data filter for respective tab
        this.changeTabData();
        
    }

    changeTabData() {
        //if we have data filter for respective tab
        if (this.data) {
            if (this.activeCapaId == '0') { // tab ALL
                this.tabdata = this.data.filter( element => element['isVisible'] == true);;
            } else {
                this.tabdata = this.data.filter( element => element.SEP_Capability_ID__c == this.activeCapaId && element['isVisible'] == true);
            }
        }
    }

    handleHeaderAction(event) {
        const actionName = event.detail.action.name;
        const colDef = event.detail.columnDefinition;
        
        if (actionName === 'select_all') {
            const columns = this.columns;
            var idx = columns.findIndex(column => column.label === colDef.label);
    
            // Check if all rows in the active tab are currently selected
            const allSelected = this.tabdata.every(row => row.Selected_Answer__c === idx);
    
            this.data = this.data.map(row => {
                if (this.activeCapaId == '0' || row.SEP_Capability_ID__c == this.activeCapaId) {
                    return {...row, Selected_Answer__c: allSelected ? 0 : idx}; // Deselect all if all are selected, else select all
                } else {
                    return row;
                }
            });
        
            this.changeTabData();
        }
    }

    handleSaveButtonClick(event) {
        console.info(this.logPrefix,'button event');
        this.saveData();
        this.lastSaved = Date.now();
    }

    saveData() {
        //todo - implement save logic
        
        this.performUpdate();
        this.lastSaved = Date.now();
    }

    updateDomainProgressIndicator() {
        const progressRing = this.template.querySelector('c-sep-assessment-completion-progress');
        if (progressRing) {
          progressRing.updateProgress(this.answeredQ, this.totalQ);
        }
    }

    updateSelectedCell(id, columnIndex) {
        console.info(this.logPrefix,'in updSelCell', id, columnIndex);
        let cloneData = JSON.parse(JSON.stringify(this.data));
        cloneData.some((row, index) => {
            if (row.Id === id) {
                console.info(this.logPrefix, 'try to update', JSON.stringify(row), 'with ', columnIndex );
                // If selected answer cell value is undefined or empty than remove the property to deselect the answer else populate the answer
                if(columnIndex == undefined || columnIndex == '') {
                    cloneData[index]['Selected_Answer__c'] = null;  
                } else {
                    row.Selected_Answer__c = columnIndex;
                }
                console.info(this.logPrefix, 'after update');
                return true;
            }
            return false; 
        });
        this.data = cloneData;
        this.changeTabData();
    }

    updateWithDependentQuestions(questionAnswerId, colIndex) {
        let cloneData = JSON.parse(JSON.stringify(this.data));
        // Check if the seleted question has dependent question in the data and 
        // show/ hide all the dependent question based on the parent question answer dependency
        cloneData = cloneData.filter(e => {
            if(questionAnswerId == e.Parent_Question__c) {
                e['isVisible'] = (colIndex == e.Dependent_Answer__c) ? true : false;
                // Deselect the dependent question answer
                e['Selected_Answer__c'] = null;
            }
            return true;
        });
        this.data = cloneData;
    }

    updateChangedCell(id, content) {
        console.info(this.logPrefix,'in updSelCell', id, content);

        //we need to clone data...
        let cloneData = JSON.parse(JSON.stringify(this.data));

        cloneData.some((row, index) => {
            if (row.Id === id) {
                console.info(this.logPrefix, 'try to update', JSON.stringify(row), 'with ', content);
                row.Question_Note__c = content;
                console.info(this.logPrefix, 'after update');
                return true;
            }
            return false;
        });

        this.data = cloneData;
        this.changeTabData();

    }

    updateAllQuestionAsNotApplicable() {
        console.info(this.logPrefix,'Upadte all question as Not Applicable');
        let cloneData = JSON.parse(JSON.stringify(this.data));
        let uniqueCapabilities = new Set();
        // Find all the unique capabilities from the visible records in the grid
        this.tabdata.forEach(record => {
            uniqueCapabilities.add(record.SEP_Capability_ID__c);
        });
        // Update the the Selected_Answer__c field only for the visible records
        cloneData.forEach(record => {
            if(uniqueCapabilities.has(record.SEP_Capability_ID__c)) {
                record.Selected_Answer__c = 0;
            }
        });
        this.data = cloneData;
        this.changeTabData();
    }

    getColumnIndex(fieldName) {
        const columns = this.columns;
        for (let i = 0; i < columns.length; i++) {
            if (columns[i].fieldName === fieldName) {
                return i;
            }
        }
        return -1;
    }

    // event for clickable color cell
    handleCellClicked(event) {
        const current_col = event.detail.column;
        const current_questionid = event.detail.questionid;
        const current_questionanswerid = event.detail.questionanswerid;
        // If selected question and answer has dependent question than populate those question
        this.updateWithDependentQuestions(current_questionanswerid, current_col);
        this.updateSelectedCell(current_questionid, current_col);
    }

    handleCellChange(event) {
        const updatedFields = event.detail.draftValues;
        updatedFields.forEach(updatedItem => {
            const content = updatedItem.Question_Note__c;
            const current_questionid = updatedItem.Id;
            this.updateChangedCell(current_questionid, content);
        });

    }

    cellClicked(event) {
        const cellattribute = event.detail;
    
        const fieldName = event.detail.fieldName;
        const rowIndex = event.detail.rowIndex;
        const columnIndex = this.getColumnIndex(fieldName);

    }

    // Button Handling
    goBack() {
        this.goToPage(this.activeTabValue--, false);
    }
    goNext(){
        this.goToPage(this.activeTabValue++, false);
    }
    async goSkip(){
        let alertText = 'Your responses are about to be set to \'Not Applicable\' for ' + this.tabdata.length + ' question(s). Click confirm in order to proceed.';
        const confirmResult = await sepEstimatorAssessmentsConfirmModal.open({
            size: 'small',
            modalTitle: this.domainName + ': ' + this.activeTabName,
            modalMessage: alertText
        });
        console.log(confirmResult);
        if(confirmResult == 'confirm') {
            this.updateAllQuestionAsNotApplicable();
            this.goToPage(this.activeTabValue++, false);
        }
    }

    goToPage(pageNum, isNavThroughLink) {
        this.activeTabValue = isNavThroughLink ? pageNum + 2 : this.activeTabValue;
        const tmp = this.tabs.find(tmp => tmp.key === this.activeTabValue.toString());
        this.activeTab = tmp.value;
    }

    get bDisableBackBtn(){
        return this.activeTabValue == 1 ? true : false;
    }
    get bDisableNextBtn(){
        return this.activeTabValue == this.maxTab ? true : false;
    }

    nextDomain() {
        this.saveData();
        this.curDomainPos++;
        let tmp = this.domains.find(tmp => tmp.key === this.curDomainPos.toString());
        console.info(this.logPrefix, 'next Domain', JSON.stringify(tmp), tmp.id);


        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: tmp.id,
                actionName: 'view'
            }
        });
    }

    previousDomain() {
        this.saveData();
        this.curDomainPos--;
        let tmp = this.domains.find(tmp => tmp.key === this.curDomainPos.toString());
        console.info(this.logPrefix, 'previous Domain', JSON.stringify(tmp), tmp.id);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: tmp.id,
                actionName: 'view'
            }
        });
    }

    get bDisablePrevDomainBtn(){
        return this.curDomainPos == 1 ? true : false;
    }
    get bDisableNextDomainBtn(){
        return this.curDomainPos == this.maxDomainPos ? true : false;
    }



    //Callbacks

    renderedCallback() {
        /*
        var el = this.template.querySelectorAll('*');
        console.info(this.logPrefix,'Render Callback', el);
        console.info(this.logPrefix,'-->', JSON.stringify(el));
        */
    }
    timer; 

    connectedCallback() {
        console.info(this.logPrefix,'connected Callback');
        /* Auto save causes issues, to be fixed!
        this.timer = setInterval(() => {
          this.saveData();
        }, 180000);
        */
      }
      
      
    disconnectedCallback() {
        console.info(this.logPrefix,'connected Callback');
        //clearInterval(timer);
    }

    // helpers eg timezone

    ampm = false;
    @track lastSaved = Date.now();

    get timeZone() {
        return Intl.DateTimeFormat().resolvedOptions().timeZone;
    }
}