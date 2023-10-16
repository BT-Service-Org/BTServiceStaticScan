import { LightningElement, api, track, wire } from 'lwc';
import getQuesAns from '@salesforce/apex/GDC_MS_QuestionAnswerFormController.getQuestionAnswers';
import info from '@salesforce/label/c.gdcms_Statement_on_WorkIntake_Detail';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class GdcmsWorkIntakeForm extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;
    @track formName;
    @track questionAnswerRecords = [];
    @track engagementName;
    @track error;
    @track isModalOpen = false;
    @track comment = '';
    @track createdByUser = '';
    @api isEditMode;
    @api editButtonActive=false;

    @track isModalOpen = false;
    queAnswersRecords;

    LABELS = {
        info
    };

    @wire(getObjectInfo, { objectApiName: '$objectApiName' }) objectInfo({ data, error }) {
        if (data) {
            this.formName = data.label;
        }
        if (error) {
            this.showToast('Error', 'Something went wrong', 'error');
        }
    };

    connectedCallback() {
        getQuesAns({ recordId: this.recordId })
            .then(result => {
                this.createdByUser = result.CreatedBy.FirstName + ' ' + result.CreatedBy.LastName;
                let queAnsRecords = JSON.parse(JSON.stringify(result.Question_Answers__r));
                this.queAnswersRecords = queAnsRecords;
                queAnsRecords.map((row, index) => {
                    if (row.gdc_ms_Question__r.gdc_ms_Type__c === 'Checkbox') {
                        if (row.gdc_ms_Answer__c == 'true') {
                            row.checkbox = true;
                            row.Comments = row.gdc_ms_Comments__c;
                            row.question = row.gdc_ms_Question__r.gdc_ms_Question__c;
                            row.answer = true;
                        }
                        else {
                            row.checkbox = true;
                            row.Comments = row.gdc_ms_Comments__c;
                            row.question = row.gdc_ms_Question__r.gdc_ms_Question__c;
                            row.answer = false;
                        }
                    }

                    else {
                        row.text = true;
                        row.question = row.gdc_ms_Question__r.gdc_ms_Question__c;
                        row.answer = row.gdc_ms_Answer__c;
                        row.Comments = row.gdc_ms_Comments__c;
                    }
                });

                this.questionAnswerRecords = JSON.parse(JSON.stringify(queAnsRecords));
                this.isEditMode = true;
                
                if (result.Name != this.recordId.slice(0, -3)) {
                    this.engagementName = ' - ' + result.Name;
                }
                else {
                    this.engagementName = '';
                }

                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.questionAnswerRecords = undefined;
            });

    }

    handleClick(event) {
        let index = event.currentTarget.dataset.index;
        this.comment = this.questionAnswerRecords[index].Comments;
        this.isModalOpen = true;
    }

    closeModalBox() {
        this.isModalOpen = false;
    }

    enableEdit() {
        this.editButtonActive = true;
        this.openModal();
    }

    //modal popup methods start
    
    openModal() {
		this.template.querySelector('c-gdcms-base-modal').displayModal(true);
	}
	closeModal() {
		this.dispatchEvent(new CustomEvent('close'));
	}
    //model popup methods end
}