import { LightningElement, wire, track, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getQuestion from '@salesforce/apex/GDC_MS_QuestionAnswerFormController.getQuestions';
import getQuesAns from '@salesforce/apex/GDC_MS_QuestionAnswerFormController.getQuestionAnswers';
import createIntakeRecords from '@salesforce/apex/GDC_MS_QuestionAnswerFormController.createRecords'
import questionLabel from '@salesforce/label/c.gdcms_question_label';
import info from '@salesforce/label/c.gdcms_WorkIntake_Modal_Statement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import listViewId from '@salesforce/apex/GDC_MS_QuestionAnswerFormController.getListViewId';

export default class QuestionAnswerForm extends NavigationMixin(LightningElement) {
    @api boolShowPreview;
    @api objectName;
    @track formName;
    @track questions = [];
    @track quesAns = [];
    @track value = '';
    @track pageNumber = 1;
    @track recordSize = '10';
    @track totalRecords;
    @track totalPages;
    @track records;
    @track showSubmitButton = false;
    @track engagementName;
    @track parentRecordId;

    @api questionAns;
    @api isEditMode;
    workIntakeFormId;
    @api recordId;

    LABELS = {
        info
    };
    connectedCallback() {
        if (this.recordId) {
            this.isEditMode = true;
            this.workIntakeFormId = this.recordId;
        }
        this.getQuestionAnswers();
    }

    @wire(getObjectInfo, { objectApiName: '$objectName' }) objectInfo({ data, error }) {
        if (data) {
            this.formName = data.label;
        }
        if (error) {
            this.showToast('Error', 'Something went wrong', 'error');
        }
    };

    createQuestionMap() {
        var data = JSON.parse(JSON.stringify(this.questionAns));
        this.workIntakeFormId = data[0]?.gdc_ms_Work_Intake_Form__c;
        let map1 = [];
        data.forEach(element => {
            let a = {
                key: element.gdc_ms_Question__c,
                value: element
            }
            map1.push(a);
        });
    }

    getQuestionAnswers() {
        if (this.isEditMode === true) {
            getQuesAns({ recordId: this.recordId })
                .then(data => {
                    this.engagementName = data?.Name;
                    this.createRowsQuestionAns(data?.Question_Answers__r);
                }).catch(error => {
                    this.showToast('Something went wrong,Please contact your administrator', error?.body?.message, 'error');
                    this.handleListViewNavigation();
                    this.dispatchEvent(new CustomEvent('close'));
                });
        } else {
            getQuestion({ objectName: this.objectName })
                .then(data => {
                    this.createRowsQuestionAns(data);
                })
                .catch(error => {

                });
        }
    }

    createRowsQuestionAns(data) {
        if (data.length > 0) {
            let strData = JSON.parse(JSON.stringify(data));
            strData.map((row, index) => {
                row.value = row?.gdc_ms_Answer__c === undefined ? '' : row?.gdc_ms_Answer__c;
                row.comments = row?.gdc_ms_Comments__c === undefined ? '' : row?.gdc_ms_Comments__c;
                row.questionAnswerId = this.isEditMode === true ? row.Id : '';
                row.questionId = this.isEditMode === true ? row.gdc_ms_Question__r.Id : row.Id;
                row.queNo = index + 1;
                row.required = row.gdc_ms_Required__c;
                row.gdc_ms_Type__c = row.gdc_ms_Type__c === undefined ? row.gdc_ms_Question__r.gdc_ms_Type__c : row.gdc_ms_Type__c;

                if (!(row?.gdc_ms_Options__c === undefined && row?.gdc_ms_Question__r?.gdc_ms_Options__c === undefined)) {
                    row.gdc_ms_Options__c = row.gdc_ms_Options__c === undefined ? row.gdc_ms_Question__r.gdc_ms_Options__c : row.gdc_ms_Options__c;
                }
                delete row.Required__c;

                this.quesAns.push({ label: row.questionId, value: row.value, comments: row.comments, questionAnswerId: row.questionAnswerId });
                // Handling picklist and multi-select picklist type questions
                if (row?.gdc_ms_Options__c != undefined) {
                    if (row.gdc_ms_Type__c === 'Picklist') {
                        row.picklist = true;
                    }
                    else if (row.gdc_ms_Type__c === 'Multi-Select picklist') {
                        row.multipicklist = true;
                    }

                    row.options = [];
                    row.gdc_ms_Options__c.split(';').forEach(function (k, i) {
                        const combooption = {
                            label: k.replace('\r', ''),
                            value: k.replace('\r', '')
                        };
                        row.options = [...row.options, combooption];
                    });
                    delete row.Options__c;
                }

                // Handling text type questions
                if (row.gdc_ms_Type__c === 'Text') {
                    row.textarea = true;
                }

                // Handling Checkbox type questions
                if (row.gdc_ms_Type__c === 'Checkbox') {
                    row.checkbox = true;
                    row.checked = false;
                }

                // Handling Number type questions
                if (row.gdc_ms_Type__c === 'Number') {
                    row.Number = true;
                }

                // Handling Date type questions
                if (row.gdc_ms_Type__c === 'Date') {
                    row.Date = true;
                }

                row.questionName = row.queNo + '. ' + this.getQuestionName(row);
            });
            //console.log('@@JSON.parse(JSON.stringify(strData))::', JSON.parse(JSON.stringify(strData)));
            //console.log('##this.quesAns ' + JSON.stringify(this.quesAns));
            this.records = JSON.parse(JSON.stringify(strData));
            var uiRecords = [];

            for (var i = 0; i < Number(this.recordSize); i++) {
                if (strData[i])
                    uiRecords.push(strData[i]);
            }

            this.totalRecords = data.length;
            this.totalPages = Math.ceil((data.length) / Number(this.recordSize));

            this.questions = JSON.parse(JSON.stringify(uiRecords));
            if (this.pageNumber === this.totalPages) {
                if (this.boolShowPreview) {
                    this.showSubmitButton = false;
                } else {
                    this.showSubmitButton = true;
                }
            }
        } else {
            this.showToast('Error', 'There are no Questions', 'error');
            this.handleListViewNavigation();
            this.dispatchEvent(new CustomEvent('close'));
        }
    }

    handleNavigation(event) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        if (!isValid) {
            return;
        }
        let buttonName = event.target.label;
        if (buttonName == 'Next') {
            this.pageNumber = this.pageNumber >= this.totalPages ? this.totalPages : this.pageNumber + 1;
        } else if (buttonName == 'Previous') {
            this.pageNumber = this.pageNumber > 1 ? this.pageNumber - 1 : 1;
        }
        this.processRecords();
    }

    processRecords() {
        var uiRecords = [];
        var startLoop = ((this.pageNumber - 1) * Number(this.recordSize));
        var endLoop = (this.pageNumber * Number(this.recordSize) >= this.totalRecords) ? this.totalRecords : this.pageNumber * Number(this.recordSize);


        for (var i = startLoop; i < endLoop; i++) {
            uiRecords.push(JSON.parse(JSON.stringify(this.records[i])));
        }

        this.questions = JSON.parse(JSON.stringify(uiRecords));

        if (this.pageNumber === this.totalPages && !this.boolShowPreview) {
            this.showSubmitButton = true;
        }
        else {
            this.showSubmitButton = false;

        }
    }

    get disablePreviousButtons() {
        if (this.pageNumber == 1)
            return true;
    }

    get disableNextButtons() {
        if (this.pageNumber == this.totalPages)
            return true;
    }

    handleChange(event) {
        let queNo = event.currentTarget.dataset.index;
        //console.log('@@handleChange '+queNo+' '+event.currentTarget.dataset.Id, JSON.stringify(event.target.key));
        if (event.target.name === 'checkbox') {
            if (event.target.checked) {
                this.quesAns[queNo - 1].value = 'true';
                this.records[queNo - 1].checked = event.target.checked;
            }
            else {
                this.quesAns[queNo - 1].value = '';
                this.records[queNo - 1].checked = false;
            }
        } else if (event.target.name === 'multiselect') {
            let mutiselectArray = [];
            mutiselectArray = JSON.parse(JSON.stringify(event.target.value));
            this.quesAns[queNo - 1].value = mutiselectArray.join(';');
            this.records[queNo - 1].value = mutiselectArray.join(';');
        } else {
            let questionName = this.getQuestionName(this.records[queNo - 1]);
            if (questionName == questionLabel) {
                this.engagementName = event.target.value;
            }
            this.quesAns[queNo - 1].value = event.target.value;
            this.records[queNo - 1].value = event.target.value;
        }
    }

    handleComment(event) {
        let queNo = event.currentTarget.dataset.index;
        this.quesAns[queNo - 1].comments = event.target.value;
        this.records[queNo - 1].comments = event.target.value;
    }

    handleSubmit(event) {

        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');

        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            return;
        }
        let recordValues = [];
        let recordData = JSON.stringify(this.quesAns);

        JSON.parse(recordData).forEach(element => {
            if (element.value != '') {
                recordValues.push(element.value);
            }
        });

        if (recordValues.length == 0) {
            this.showToast('You have not answered any question', '', 'error');
            this.showSubmittedForm = false;
            return;
        }

        this.records = recordData;
        createIntakeRecords({ records: this.records, engagementName: this.engagementName, workIntakeFormId: this.workIntakeFormId })
            .then((result) => {
                this.parentRecordId = result;
                this.navigateToRecordPage(this.parentRecordId);

                this.dispatchEvent(new CustomEvent());
            })
            .catch((error) => {
                this.showToast('Error', error.body.message);
                this.dispatchEvent(new CustomEvent('close'));
                //this.showToast('Error', 'Error occured in creating the record', error.message);
            })
    }

    navigateToRecordPage(parentId) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: parentId,
                actionName: 'view'
            }
        });
        //location.reload();
    }

    handleListViewNavigation() {
        // Navigate to the object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.objectName,
                actionName: 'list'
            },
            state: {
                filterName: listViewId
            }
        });
    }

    showToast(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    getQuestionName(row) {
        if (this.isEditMode === true) {
            return row.gdc_ms_Question__r?.gdc_ms_Question__c;
        } else {
            return row.gdc_ms_Question__c;
        }
    }

   
}