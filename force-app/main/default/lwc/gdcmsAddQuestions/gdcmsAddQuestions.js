import { LightningElement,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUESTION_OBJECT from '@salesforce/schema/gdc_ms_Question__c';
import NAME_FIELD from '@salesforce/schema/gdc_ms_Question__c.gdc_ms_Question__c';
import TYPE_FIELD from '@salesforce/schema/gdc_ms_Question__c.gdc_ms_Type__c';
import OPTIONS_FIELD from '@salesforce/schema/gdc_ms_Question__c.gdc_ms_Options__c';
import REQUIRED_FIELD from '@salesforce/schema/gdc_ms_Question__c.gdc_ms_Required__c';
import CATEGORY_FIELD from '@salesforce/schema/gdc_ms_Question__c.gdc_ms_Category__c';
import ACTIVE_FIELD from '@salesforce/schema/gdc_ms_Question__c.gdc_ms_Is_Active__c';
import ORDER_FIELD from '@salesforce/schema/gdc_ms_Question__c.gdc_ms_Order__c';

import getPicklistOptions from '@salesforce/apex/GDC_MS_AddQuestions.getPicklistValues';
import getQuestions from '@salesforce/apex/GDC_MS_AddQuestions.getQuestions';
import getObject from '@salesforce/apex/GDC_MS_AddQuestions.getObjectName';

const COLS = [
    { label: 'Question', fieldName: 'gdc_ms_Question__c', editable: false },
    { label: 'Order', fieldName: 'gdc_ms_Order__c', editable: true },
    { label: 'Active', fieldName: 'gdc_ms_Is_Active__c', editable: false }
];

export default class AddQuestions extends  NavigationMixin(LightningElement) {
    columns = COLS;

    objectName = '';
    typeValue = '';
    values = '';
    selectedCategory = '';
    activeSectionName = '';

    boolShowValuesField = false;
    boolShowDeleteQuestion = false;
    boolShowSpinner = false;
    boolPreview = false;
    duplicatesFound = false;
    boolSequenceMiss = false;
    boolInvalidOrder = false;
    boolShowAddQuestion = false;
    boolShowEditModal = false;
    boolShowAddModal = false;
    boolShowAddButtononModal = true;
    boolShowOrderingModal = false;
    allValid = false;

    typeOptions = [];
    categoryOptions = [];
    @track editQuestion = {};
    @track lstQuestions = [];
    @track existingQuestions = [];
    @track draftValues = [];

    questionCount = 0;
    //Pagination
    currentPage = 1;
    noOfPages = 1;
    pageSize = 8;
    @track paginatedResult = [];

    connectedCallback(){
        this.getOptions();
    }

    get resultsFound() {
        return this.existingQuestions.length > 0 ? true : false;
    }

    pagination(pageNumber, resultList) {
        let start = this.pageSize * (pageNumber - 1);
        let end = start + this.pageSize;
  
        let tempList = resultList.slice(start, end);
        return tempList;
    }
  
    onPrevious() {
    this.currentPage = this.currentPage > 1 ? this.currentPage - 1 : this.currentPage;
    this.paginatedResult = this.pagination(this.currentPage, this.existingQuestions);
    }
    onNext() {
    this.currentPage = this.currentPage < this.noOfPages ? this.currentPage + 1 : this.currentPage;
    this.paginatedResult = this.pagination(this.currentPage, this.existingQuestions);
    }

    get disableNextButton() {
    return this.currentPage === this.noOfPages ? true : false
    }

    get disablePreviousButton() {
    return this.currentPage === 1 ? true : false
    }

    getOptions() {
        getPicklistOptions()
        .then(result => {
            this.typeOptions = result.typeOptions;
            this.categoryOptions = result.categoryOptions;
        })
        .catch(error => {
            if (error && error.body && error.body.message) {
                this.showToast('Error', error.body.message,'error');
            }
        });
    }

    handleCategoryChange(event) {
        this.boolShowSpinner = true;
        this.lstQuestions.splice(0,this.lstQuestions.length);
        this.currentPage = 1;
        this.selectedCategory = event.detail.value;
        getQuestions({strCategory:this.selectedCategory})
        .then(result => {
            this.existingQuestions = result;
            this.boolShowSpinner = false;

            //pagination
            this.noOfPages = Math.ceil(this.existingQuestions.length / this.pageSize);
            this.paginatedResult = this.pagination(this.currentPage, this.existingQuestions);
            this.getObjectName();
        })
        .catch(error => {
            this.boolShowSpinner = false;
            if (error && error.body && error.body.message) {
                this.showToast('Error', error.body.message,'error');
            }
        });
        this.boolShowAddQuestion = true;
    }

    getObjectName(){
        getObject({strCategory:this.selectedCategory})
        .then(result => {
            this.objectName = result+'__c';
        })
        .catch(error => {
            if (error && error.body && error.body.message) {
                this.showToast('Error', error.body.message,'error');
            }
        });

    }

    handleAddQuestion() {
        this.handleValidity();
        if(this.allValid) {
            this.questionCount++;
            this.boolShowAddModal = true;
            this.boolShowAddButtononModal = true;

            this.lstQuestions.push({number:this.questionCount,sectionName:'Question'+this.questionCount,
                                            question:'',typeValue:'',label:'Question', values:'', required:false});
            setTimeout(()=>this.activeSectionName = 'Question'+this.questionCount,1);
            if(this.lstQuestions.length === 1) {
                this.boolShowDeleteQuestion = false;
            } else {
                this.boolShowDeleteQuestion = true;
                if(this.lstQuestions.length === 5) {
                    this.boolShowAddButtononModal = false;
                }
            }
        } else {
            this.showToast('Error','Required fields missing','error');
        }
        
    }

    closeAddQuestionModal() {
        this.boolShowAddModal = false;
        this.lstQuestions.splice(0,this.lstQuestions.length);
        this.questionCount = 0;
    }

    handleTypeChange(event) {
        let qNo = event.target.name;
        let questionIndex = this.lstQuestions.findIndex(x => x.number === qNo);
        this.lstQuestions[questionIndex].typeValue = event.detail.value;
        if(this.lstQuestions[questionIndex].typeValue === 'Picklist' || this.lstQuestions[questionIndex].typeValue === 'Multi-Select picklist') {
            this.lstQuestions[questionIndex].boolShowValuesField = true;
        } else {
            this.lstQuestions[questionIndex].boolShowValuesField = false;
        }
    }

    handleQuestionChange(event) {
        let qNo = event.target.name;
        let questionIndex = this.lstQuestions.findIndex(x => x.number === qNo);
        this.lstQuestions[questionIndex].question = event.detail.value;
        this.lstQuestions[questionIndex].label = 'Question: '+event.detail.value;
    }

    handleValuesChange(event) {
        let qNo = event.target.name;
        let questionIndex = this.lstQuestions.findIndex(x => x.number === qNo);
        this.lstQuestions[questionIndex].values = event.detail.value;
    }

    handleRequiredChange(event) {
        let qNo = event.target.name;
        let questionIndex = this.lstQuestions.findIndex(x => x.number === qNo);
        this.lstQuestions[questionIndex].required = event.target.checked;
    }

    handleDeleteQuestion(event) {
        let qNo = event.target.dataset.id;
        let questionIndex = this.lstQuestions.findIndex(x => x.number == qNo);
        this.questionCount--;
        this.activeSectionName = '';
        this.lstQuestions.splice(questionIndex,1);
        for(let i=questionIndex; i<this.lstQuestions.length; i++) {
            this.lstQuestions[i].number = this.lstQuestions[i].number -1;
            this.lstQuestions[i].sectionName = 'Question'+ this.lstQuestions[i].number;
        }
        if(this.lstQuestions.length === 1) {
            this.boolShowDeleteQuestion = false;
        }
        if(this.lstQuestions.length <5) {
            this.boolShowAddButtononModal = true;
        }
    }

    handleEditQuestion(event) {
        this.boolShowEditModal = true;
        this.questionId = event.target.dataset.id;
        this.tempIndex = this.existingQuestions.findIndex(x => x.Id === this.questionId);
        this.editQuestion = Object.assign({},this.existingQuestions[this.tempIndex]);
        if(this.editQuestion.gdc_ms_Type__c === 'Picklist' || this.editQuestion.gdc_ms_Type__c === 'Multi-Select picklist') {
            this.boolShowValuesField = true;
        } else {
            this.boolShowValuesField = false;
        }
    }

    handleEditChanges(event) {
        let name = event.target.name
        if(name === 'editQuestionfield') {
            this.editQuestion.gdc_ms_Question__c = event.detail.value;
        } else if(name === 'editRequiredField') {
            this.editQuestion.gdc_ms_Required__c = event.target.checked;
        } else if(name === 'editTypeField') {
            this.editQuestion.gdc_ms_Type__c = event.detail.value;
            this.editQuestion.gdc_ms_Options__c = '';
            if(this.editQuestion.gdc_ms_Type__c === 'Picklist' || this.editQuestion.gdc_ms_Type__c === 'Multi-Select picklist') {
                this.boolShowValuesField = true;
            } else {
                this.boolShowValuesField = false;
            }
        } else if(name === 'editOptionsField') {
            this.editQuestion.gdc_ms_Options__c = event.detail.value;
        } else if(name === 'editActiveField') {
            this.editQuestion.gdc_ms_Is_Active__c = event.target.checked;
        }
    }
    
    handleSave() {
        this.handleValidity();
        if (this.allValid) {
            const fields = this.editQuestion;
            const recordInput = { fields }
            updateRecord(recordInput)
                .then(() => {
                    this.showToast('Success','Question is edited successfully', 'success');
                    this.existingQuestions.splice(this.tempIndex,1,this.editQuestion);
                    let index = this.paginatedResult.findIndex(x => x.Id === this.questionId);
                    this.paginatedResult.splice(index,1,this.editQuestion);
                })
                .catch(error => {
                    if (error && error.body && error.body.message) {
                        this.showToast('Error editing record',error.body.message, 'error');
                    }
                });
            this.boolShowEditModal = false;
        } else {
            this.showToast('Error','Required fields missing','error');
        }
    }

    handleCancel() {
        this.boolShowEditModal = false;
        this.questionId = '';
        this.tempIndex = '';
        this.editQuestion = {};
    }

    handleValidity() {
        //validation for required fields
        this.allValid = [...this.template.querySelectorAll('lightning-input,lightning-combobox,lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
    }


    submitQuestionnaire() {
        this.handleValidity();
        if (this.allValid) {
            this.boolShowAddModal = false;
            this.boolShowSpinner = true;
            let count = 0;
            if(this.existingQuestions.length >0) {
                count = this.existingQuestions.length;
            }
            Promise.all(
                this.lstQuestions.map(ques => {
                    const fields = {};
                    fields[NAME_FIELD.fieldApiName] = ques.question;
                    fields[OPTIONS_FIELD.fieldApiName] = ques.values;
                    fields[TYPE_FIELD.fieldApiName] = ques.typeValue;
                    fields[REQUIRED_FIELD.fieldApiName] = ques.required;
                    fields[CATEGORY_FIELD.fieldApiName] = this.selectedCategory;
                    fields[ACTIVE_FIELD.fieldApiName] = true;
                    fields[ORDER_FIELD.fieldApiName] = ques.number +count;
                    const recordInput = { apiName: QUESTION_OBJECT.objectApiName, fields };
                    return createRecord(recordInput);
                })).then(results => {
                    this.showToast('Success',results.length+' Questions created Successfully','success');
                    let tempArray = JSON.parse(JSON.stringify(this.existingQuestions));
                    for(let item of results) {
                        this.existingQuestions.push({Id:item.id, gdc_ms_Question__c:item.fields['gdc_ms_Question__c'].value, 
                                                        gdc_ms_Required__c:item.fields['gdc_ms_Required__c'].value, gdc_ms_Type__c:item.fields['gdc_ms_Type__c'].value, 
                                                        gdc_ms_Options__c:item.fields['gdc_ms_Options__c'].value, gdc_ms_Is_Active__c:true, gdc_ms_Order__c:item.fields['gdc_ms_Order__c'].value});
                    }
                    //pagination
                    if(this.existingQuestions.length >0 && this.existingQuestions.length <7) {
                        this.noOfPages = 1;
                    }
                    if(tempArray.length%this.pageSize === 0 && tempArray.length!== 0) {
                        this.currentPage = this.noOfPages+1;
                    } else {
                        this.currentPage = this.noOfPages;
                    }
                    this.noOfPages = Math.ceil(this.existingQuestions.length / this.pageSize);
                    this.paginatedResult = this.pagination(this.currentPage, this.existingQuestions);
                    this.lstQuestions.splice(0,this.lstQuestions.length);
                    this.questionCount = 0;
                    this.boolShowSpinner = false;
                }).catch(error => {
                    this.boolShowSpinner = false;
                    if (error && error.body && error.body.message) {
                        this.showToast('Error creating record',error.body.message,'error');
                    }
                });
        } else {
            this.showToast('Error','Required fields missing','error');
        }
        
    }

    handlePreview() {
        this.boolPreview = true;
    }

    handlePreviewCancel() {
        this.boolPreview = false;
    }

    handleRearrange() {
        this.boolShowOrderingModal = true;
    }

    handleOrderCancel() {
        this.boolShowOrderingModal = false;
        this.draftValues = [];
    }

    handleOrderSave(event) {
        this.draftValues = event.detail.draftValues;
        this.checkOrderSequence();
        if(!this.duplicatesFound && !this.boolSequenceMiss && !this.boolInvalidOrder) {
            this.boolShowOrderingModal = false;
            this.boolShowSpinner = true;
            const recordInputs =  this.draftValues.slice().map(draft => {
                const fields = Object.assign({}, draft);
                return { fields };
            });
        
            const promises = recordInputs.map(recordInput => updateRecord(recordInput));
            Promise.all(promises).then(() => {
                
                this.showToast('Success','Order Updated','success');
                for(let item of this.draftValues) {
                    let index = this.existingQuestions.findIndex(x => x.Id === item.Id);
                    this.existingQuestions[index].gdc_ms_Order__c = item.gdc_ms_Order__c;
                }
                this.existingQuestions = [...this.existingQuestions].sort((a, b) => a.gdc_ms_Order__c - b.gdc_ms_Order__c);
                this.paginatedResult = this.pagination(this.currentPage, this.existingQuestions);
                this.boolShowSpinner = false;
                this.draftValues = [];
                this.duplicatesFound = false;
            }).catch(error => {
                this.boolShowSpinner = false;
                if (error && error.body && error.body.message) {
                    this.showToast('Error', error.body.message,'error');
                }
            });
        } else {
            if(this.boolInvalidOrder) {
                this.showToast('Error','Order cannot be blank/zero/Negative','error');
                this.boolInvalidOrder = false;
            }else if(this.duplicatesFound) {
                this.showToast('Error','Duplicate Order found','error');
                this.duplicatesFound = false;
            } else if(this.boolSequenceMiss) {
                this.showToast('Error','Sequence miss/Order starts from 1','error');
                this.boolSequenceMiss = false;
            }
        }
        
    }

    checkOrderSequence() {
        let len = this.draftValues.length;
        this.draftValueIds = [];
        //check if order is blank/zero/negative
        for(let i=0; i<len; i++) {
            if(this.draftValues[i].gdc_ms_Order__c === '' || this.draftValues[i].gdc_ms_Order__c <=0) {
                this.boolInvalidOrder = true;
                break;
            }
            this.draftValueIds.push(this.draftValues[i].Id);
        }

        //check if any duplicates
        if(!this.boolInvalidOrder) {
            for(let i=0; i<len; i++) {
                let j = i+1;
                if(!this.duplicatesFound){
                    for(j;j<len;j++) {
                        if(this.draftValues[i].gdc_ms_Order__c === this.draftValues[j].gdc_ms_Order__c) {
                            this.duplicatesFound = true;
                            break;
                        }
                    }
                }
                if(!this.duplicatesFound) {
                    for(let ques of this.existingQuestions) {
                        if(ques.gdc_ms_Order__c == this.draftValues[i].gdc_ms_Order__c 
                            && ques.Id != this.draftValues[i].Id && !this.draftValueIds.includes(ques.Id)) {
                            this.duplicatesFound = true;
                            break;
                        }
                    }
                }
            }
        }
        
        //check sequence
        if(!this.duplicatesFound && !this.boolSequenceMiss && !this.boolInvalidOrder) {
            let tempArray = JSON.parse(JSON.stringify(this.existingQuestions));
            for(let item of this.draftValues) {
                let index = tempArray.findIndex(x => x.Id === item.Id);
                tempArray[index].gdc_ms_Order__c = item.gdc_ms_Order__c;
            }
            tempArray = [...tempArray].sort((a, b) => a.gdc_ms_Order__c - b.gdc_ms_Order__c);
            for(let i=0; i<tempArray.length-1; i++) {
                let t= Number(tempArray[i].gdc_ms_Order__c);
                let t1= t+1;
                if(tempArray[0].gdc_ms_Order__c != 1 ||(tempArray[i+1].gdc_ms_Order__c != t1 && !this.boolSequenceMiss /*|| tempArray[i].Order__c === ''*/)) {
                    this.boolSequenceMiss = true;
                    break;
                } else if(i===tempArray.length) {
                    break;
                }
            }
        }
    }

    showToast(title,message, type) {
        const event = new ShowToastEvent({
            title: title,
            variant: type,
            message: message,
        });
        this.dispatchEvent(event);
    }
}