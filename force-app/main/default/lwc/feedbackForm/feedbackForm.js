import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getProjectAssignment from '@salesforce/apex/FeedbackController.getProjectAssignment';
import createProjFeedback from '@salesforce/apex/FeedbackController.createProjFeedback';
import getResourceSkills from '@salesforce/apex/FeedbackController.getResourceSkills';
import getCandidateRecordId from '@salesforce/apex/FeedbackController.getCandidateRecordId';
//import checkDuplicates from '@salesforce/apex/FeedbackController.checkDuplicates';
//import getPrepopulatedFeedbackSkills from '@salesforce/apex/FeedbackController.getPrepopulatedFeedbackSkills';
import USER_ID from '@salesforce/user/Id';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import PA_Onboarding_Project_Object from '@salesforce/schema/PA_Onboarding_Project__c';
import PA_Onboarding_Candidate_Field from '@salesforce/schema/PA_Onboarding__c.Candidate__c';
import CSG_PROJECT_FEEDBACK_OBJECT from '@salesforce/schema/CSG_Project_Feedback__c';
import ONBOARDING_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.Onboarding__c';
import ASSIGNMENT_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.Assignment__c';
import COMMENT_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.Comments__c';
import FEEDBACK_PULSE_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.Feedback_Pulse__c';
import UNIQUE_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.Unique_Feedback_Id__c';
import FEEDBACK_PROVIDER_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.CSG_Feedback_Provider__c';
import FEEDBACK_TYPE_FIELD from '@salesforce/schema/CSG_Project_Feedback__c.Feedback_Type__c';
 //import FEEDBACK_SKILL_OBJECT from '@salesforce/schema/CSG_ProjectFeedback_Skills__c';
 import CSGPROFILESKILL_OBJECT from '@salesforce/schema/CSGProfileSkill__c';
import FEEDBACKSKILL_FIELD from '@salesforce/schema/CSG_ProjectFeedback_Skills__c.Feedback_Skill__c';
import RATING_FIELD from '@salesforce/schema/CSG_ProjectFeedback_Skills__c.Rating__c';
import CSGFeedback_nullResourceSkills from '@salesforce/label/c.CSGFeedback_nullResourceSkills';
import CSGFeedback_duplicateSkillError from '@salesforce/label/c.CSGFeedback_duplicateSkillError';
import CSGFeedback_noSkillsEnteredError from '@salesforce/label/c.CSGFeedback_noSkillsEnteredError';
import CSGFeedback_successfulSubmission from '@salesforce/label/c.CSGFeedback_successfulSubmission';
import CSGFeedback_duplicateRecordError from '@salesforce/label/c.CSGFeedback_duplicateRecordError';
import CSGFeedback_requiredFieldsMissingError from '@salesforce/label/c.CSGFeedback_requiredFieldsMissingError';
import CSGFeedback_feedbackFormHeader from '@salesforce/label/c.CSGFeedback_feedbackFormHeader';
import CSGFeedback_openModalHeader from '@salesforce/label/c.CSGFeedback_openModalHeader';
import CSGFeedback_cancelButtonLabel from '@salesforce/label/c.CSGFeedback_cancelButtonLabel';
import CSGFeedback_okButtonLabel from '@salesforce/label/c.CSGFeedback_okButtonLabel';
import CSGFeedback_addSkillButton from '@salesforce/label/c.CSGFeedback_addSkillButton';
import CSGFeedback_AssignementInputFieldname from '@salesforce/label/c.CSGFeedback_AssignementInputFieldname';
import CSGFeedback_commentFieldLabel from '@salesforce/label/c.CSGFeedback_commentFieldLabel';
import CSGFeedback_CompetencyColumnLabel from '@salesforce/label/c.CSGFeedback_CompetencyColumnLabel';
import CSGFeedback_OnboardingInputFieldname from '@salesforce/label/c.CSGFeedback_OnboardingInputFieldname';
import CSGFeedback_RatingInputFieldname from '@salesforce/label/c.CSGFeedback_RatingInputFieldname';
import CSGFeedback_TypeColumnLabel from '@salesforce/label/c.CSGFeedback_TypeColumnLabel';
import CSGFeedback_skillColumnLabel from '@salesforce/label/c.CSGFeedback_skillColumnLabel';
import CSGFeedback_saveButtonLabel from '@salesforce/label/c.CSGFeedback_saveButtonLabel';
import CSGFeedback_AddUserSkillsButton from '@salesforce/label/c.CSGFeedback_AddUserSkillsButton';
import CSG_skillButtonHelpText from '@salesforce/label/c.CSG_skillButtonHelpText';
import CSGFeedback_FeebackPulseFieldLabel from '@salesforce/label/c.CSGFeedback_FeebackPulseFieldLabel';
import checkIfUserCanSubmitFeedback from '@salesforce/apex/FeedbackController.checkIfUserCanSubmitFeedback';


//import CSG_PROJECT_FEEDBACK_FIELD from '@salesforce/schema/CSG_ProjectFeedback_Skills__c.CSG_Project_Feedback__c';


const columns = [ 
     { 
        label: 'Type', 
        fieldName: 'Type',
        type: 'text', 
        sortable: "true"
    }, { 
        label: 'Competency', 
        fieldName: 'Category',
        type: 'text',  
        sortable: "true"
    },{ 
        label: 'Skill', 
        fieldName: 'Name', 
        type: 'text', 
        sortable: "true"
    },
];

export default class CreateDynamicRecord extends NavigationMixin(LightningElement){
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track data = [];
    @track feedbackSkills = []; 
    @track userSkillsList  = [];
    @track feedbackSkillIdslist = [];
    @track feedbackSkillIdsUnSelectedList = [];
    @track selectedSkills  = [];
    @track csgProfileSkill = CSGPROFILESKILL_OBJECT; 
    @track newfeedbackSkills = []; 
    @track index;
    @track modalIndex = 0;
    @track feedbackRec = CSG_PROJECT_FEEDBACK_OBJECT; 
    @track onbProject = PA_Onboarding_Project_Object;
    @track enableAssignment = true;
    @track disableAssignment = false;
    @track Feedback_Skill__c = FEEDBACKSKILL_FIELD;
    @track Rating__c = RATING_FIELD;
    @track Feedback_Pulse__c = FEEDBACK_PULSE_FIELD;
    @track reset = false;
    @track isModalOpen = false;
    @track isModalEmpty = false;
    @track duplicateRec = '';
    userCanSubmitFeedback = true;
    isDuplicateFeedback = false;
    isProactiveFeedback = false;
    showProjectData = false;
    resourceNameLabel = '';
    feedbackRecId='';
    feedbackType = '';
    isProjectFeedback = false;
    projectSelectionRequired = false;
    isGeneralFedback = false;
    radioGroupDisabled = false;
    radioGroupRequired = false;
   //recordPageUrl;

    label = {CSGFeedback_nullResourceSkills,
    CSGFeedback_duplicateSkillError,
    CSGFeedback_noSkillsEnteredError,
    CSGFeedback_successfulSubmission,
    CSGFeedback_duplicateRecordError,
    CSGFeedback_requiredFieldsMissingError,
    CSGFeedback_feedbackFormHeader,
    CSGFeedback_openModalHeader,
    CSGFeedback_cancelButtonLabel,
    CSGFeedback_okButtonLabel,
    CSGFeedback_addSkillButton,
    CSGFeedback_AssignementInputFieldname,
    CSGFeedback_commentFieldLabel,
    CSGFeedback_CompetencyColumnLabel,
    CSGFeedback_OnboardingInputFieldname,
    CSGFeedback_RatingInputFieldname,
    CSGFeedback_TypeColumnLabel,
    CSGFeedback_skillColumnLabel,
    CSGFeedback_saveButtonLabel,
    CSGFeedback_AddUserSkillsButton,
    CSG_skillButtonHelpText,
    CSGFeedback_FeebackPulseFieldLabel
    };

    get feedbackTypeOptions () {
        return [
            {label: 'Project Related Feedback', value: 'projFeedback'},
            {label: 'General Skills Related Feedback', value: 'genFeedback'},

        ];
    }
    
    @api recordId;

    fields = [FEEDBACKSKILL_FIELD, RATING_FIELD];   
     
    @wire (CurrentPageReference)
        currentPageReference;

    setFeedbackType(event) {
        const selectedOption = event.detail.value;
        console.log('Option selected with value: ' + selectedOption);
        this.feedbackType = selectedOption;
        if(selectedOption === 'projFeedback'){
            this.isProjectFeedback = true;
            this.isGeneralFedback = false;
            this.projectSelectionRequired = true;
        }
        else {
            this.isProjectFeedback = false;
            this.isGeneralFedback = true;
            this.projectSelectionRequired = false;
        }
    }

    @wire(getRecord, {recordId: '$feedbackRecId', fields: [FEEDBACK_TYPE_FIELD, ONBOARDING_FIELD, UNIQUE_FIELD]})
    wiredFeedbackRecord({error, data}) {
        if( error ){
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        }
        else if ( data ) {
            if(getFieldValue(data, FEEDBACK_TYPE_FIELD) === "Project Related Feedback") {
                this.feedbackType = 'projFeedback';
                this.isProjectFeedback = true;
                this.isGeneralFedback = false;
            }
            else {
                this.feedbackType = 'genFeedback';
                this.isProjectFeedback = false;
                this.isGeneralFedback = true;
            }
            this.radioGroupDisabled = true;            
            this.feedbackRec.Onboarding__c = getFieldValue(data, ONBOARDING_FIELD);
            this.feedbackRec.Unique_Feedback_Id__c = getFieldValue(data, UNIQUE_FIELD);
            //console.log("feedback type: " + getFieldValue(data, FEEDBACK_TYPE_FIELD));
        }
    }
    connectedCallback(currentPageReference) {
    //this.currentPageReference = currentPageReference;

        console.log("user id: " + USER_ID);
        if (this.currentPageReference.state.prjAssign__recordId || this.currentPageReference.state.orgAssign__recordId ){
            this.modalClass = 'slds-modal slds-fade-in-open';
            this.modalBackdropClass = 'slds-backdrop slds-backdrop_open';
            this.isModalOpen = true;

        } else {
            this.isModalOpen = false;

        }
        console.log('****** Feedback Record ID: ' + this.feedbackRecId);
        if(this.currentPageReference.state.c__recId) {
            this.feedbackRecId = this.currentPageReference.state.c__recId;
            console.log('****** Feedback Record ID: ' + this.feedbackRecId);
            if(getFieldValue(this.wiredFeedbackRecord.data, FEEDBACK_TYPE_FIELD) === "General Feedback") {
                console.log("connected callback ==== general feedback, so not getting project assignment")
                return;
            }
        }
               
        getProjectAssignment({assignedProjId: this.currentPageReference.state.prjAssign__recordId, orgAssignId: this.currentPageReference.state.orgAssign__recordId})
            
            .then(result => {
                this.onbProject = result;
                console.log("this.onbProject: " + JSON.stringify(this.onbProject, null, 2));
                if(this.currentPageReference.state.prjAssign__recordId || this.currentPageReference.state.orgAssign__recordId){
                    this.enableAssignment = false;
                    this.disableAssignment = true;
                    this.isProactiveFeedback = false;
                    this.showProjectData = true;
                    this.feedbackType = 'projFeedback';
                    this.radioGroupDisabled = true;
                    this.isProjectFeedback = true;
                }
                else {
                    this.isProactiveFeedback = true;
                    this.feedbackType = '';
                    this.radioGroupDisabled = false;
                    this.isProjectFeedback = false;
                }              
                this.feedbackRec.Onboarding__c = this.onbProject.PA_Onboarding__c;
                this.feedbackRec.Assignment__c = this.onbProject.Id;
                this.feedbackRec.Unique_Feedback_Id__c =  this.feedbackRec.Assignment__c + '-' + this.feedbackRec.Onboarding__c + '-' + USER_ID;
                this.resourceNameLabel = this.onbProject.PA_Onboarding__r.Candidate__r.Name;
                console.log("this.feedbackRec: " + JSON.stringify(this.feedbackRec, null, 2));
                this.checkIfCurrentUserIsFeedbackProvider(this.feedbackRecId);                
                //this.duplicateFeedbackCheck(this.feedbackRec.Unique_Feedback_Id__c);                          
            })
            .catch(error => {
                this.error = error;
            }); 
    }

    get enableAssignment() {
        return this.enableAssignment;
    }
    get disableAssignment() {
        return this.disableAssignment;
    }
    get isRadioGroupRequired() {
        return this.isProactiveFeedback;
    }

    get disableOnboarindSelection() {
        return this.currentPageReference.state.c__recId ? true : false;
    }
    openModal(){
        if(this.userSkillsList && this.userSkillsList.length <1 ) {
            this.isModalOpen = false;
            this.isModalEmpty = true;
            return;
        }
        this.isModalOpen = true;
        this.modalClass = 'slds-modal slds-fade-in-open';
        this.modalBackdropClass = 'slds-backdrop slds-backdrop_open';
       // alert('fdbkSkillIds' + this.feedbackSkillIdslist );
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
        }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.userSkillsList));
        // Return the value stored in the field
        let keyValue = (a) => {
        return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? -1: 1;
        // sorting data
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }
    

    handleCloseModal() {
        this.isModalOpen = false;
        this.modalClass = 'slds-modal ';
        this.modalBackdropClass = 'slds-backdrop ';
        this.isModalEmpty = false;
    }
    handleModalRowClick(event){
       
        var k = event.target.getAttribute('data-id');
        for(let v=0; v<this.userSkillsList.length; v++){
            if(v == k)
            {
                if(this.userSkillsList[v].Selected === true){
                    this.userSkillsList[v].Selected = false;
                    this.userSkillsList[v].StyleColor = '';
                    this.feedbackSkillIdsUnSelectedList.push(this.userSkillsList[v].Id);
                }
                else{
                    this.userSkillsList[v].Selected = true;
                    this.userSkillsList[v].StyleColor = 'selected-row';
                    
                }
                break;
            }
        }
        
    }

    sortRecs( event ) {

        let colName = event.target.name;
        console.log( 'Column Name is ' + colName );
        if ( this.sortBy === colName ) {
            this.sortedDirection = ( this.sortedDirection === 'asc' ? 'desc' : 'asc' );
        }
        else {
            this.sortedDirection = 'asc';
        }

        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        this.sortBy = colName;

        // sort the data
        this.userSkillsList = JSON.parse( JSON.stringify( this.userSkillsList ) ).sort( ( a, b ) => {
            a = a[ colName ] ? a[ colName ].toLowerCase() : ''; // Handle null values
            b = b[ colName ] ? b[ colName ].toLowerCase() : '';
            return a > b ? 1 * isReverse : -1 * isReverse;
        });;

    }

    handleSubmitModal() {
        this.isModalOpen = false;

        for(let i=0; i<this.userSkillsList.length; i++){
            if(this.userSkillsList[i].Selected === true && (this.feedbackSkillIdslist.length< 1 || !this.feedbackSkillIdslist.includes(this.userSkillsList[i].Id)))
            {
                this.index++;
                    this.feedbackSkills.push ({
                        sobjectType: 'CSG_ProjectFeedback_Skills__c',
                        Feedback_Skill__c: this.userSkillsList[i].Id,
                        Rating__c : '',
                        disabledSkill : 'true',
                    });
                    this.feedbackSkillIdslist.push(this.userSkillsList[i].Id);
                
            }
            else if(this.feedbackSkillIdsUnSelectedList.length > 0 && this.feedbackSkillIdslist.includes(this.feedbackSkillIdsUnSelectedList[i])) {
                for(let j=0; j<this.feedbackSkills.length; j++){
                let deleteIndex = this.feedbackSkills.indexOf(this.feedbackSkillIdsUnSelectedList[i]);
                this.feedbackSkillIdslist = this.feedbackSkillIdslist.splice(deleteIndex,0);
                this.feedbackSkills = this.feedbackSkills.splice(deleteIndex,0);
                }
            } 
            
           
        }
        this.feedbackSkillIdsUnSelectedList.splice(0, this.feedbackSkillIdsUnSelectedList.length);

    }


    addSkill(){
        this.index++;
        this.feedbackSkills.push ({
            sobjectType: 'CSG_ProjectFeedback_Skills__c',
            Feedback_Skill__c: '',
            Rating__c : '',
        });
    }
    
    removeSkill(event) {
        var i = event.target.getAttribute('data-id');
       // var index = this.index;
        if (this.feedbackSkills.length >0) {
            this.feedbackSkills.splice(i, 1);
        }
    }
    
    handleOnboardingChange(event) {
        this.feedbackRec.Onboarding__c = event.target.value;

        getCandidateRecordId({onboardingRecordId: this.feedbackRec.Onboarding__c})
        .then( result => {
            console.log("handleOnboardingChange -- getRecord -- result: " + JSON.stringify(result, null, 2));
            getResourceSkills({ candidateId: result})
                    .then(result => {
                        // alert('H'+this.onbProject.PA_Onboarding__r.CSG_Role_Community__c);
                        console.log("handleOnboardingChange --- result: " + JSON.stringify(result, null, 2));
                        if(this.isProactiveFeedback) {
                            refreshApex(this.result);
                        }
                        for(let i=0; i<result.length; i++){
                            
                            this.userSkillsList.push({
                                sobjectType: 'CSG_Group_Skill__c',
                                Id : result[i].CSGProfileSkill__r.Id,
                                Name: result[i].CSGProfileSkill__r.Name,
                                Type : result[i].CSGProfileSkill__r.Type__c,
                                Category : result[i].CSGProfileSkill__r.Category__c,
                                Selected : false,
                                StyleColor : ''
                            });
                            this.modalIndex++;
                            if(this.isProactiveFeedback) {
                                getRecordNotifyChange(this.userSkillsList);
                            }                                                        
                        }
                        
                        this.data = this.userSkillsList;
                        if (this.userSkillsList.length > 1){
                            this.data = this.userSkillsList;
                            this.modalClass = 'slds-modal slds-fade-in-open';
                            this.modalBackdropClass = 'slds-backdrop slds-backdrop_open';
                            this.isModalOpen = true;
                
                        } else {
                            this.isModalOpen = false;
                            this.isModalEmpty = true;
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    });
        }

        )
        .catch (error => {
            console.log("handleOnboardingChange -- gerRecord -- error: " + JSON.stringify(error, null, 2));
        });
        
    }

    handleAssignmentChange(event) {
        console.log("handleAssignmentChange called in JS");
        if(!event.target.value) {
            this.resetForm();
            return; // don't continue to fetch assignment details and resource skills since there is no assignment selected yet.
        }
        this.feedbackRec.Assignment__c = event.target.value; 
        //this.isModalOpen = this.feedbackRec.Assignment__c;
        this.isProactiveFeedback = true;
        getProjectAssignment({assignedProjId: this.feedbackRec.Assignment__c})
                .then(result => {
                    this.onbProject = result;
                    console.log("this.onbProject: " + JSON.stringify(this.onbProject, null, 2));
                    this.showProjectData = true;                  
                    this.feedbackRec.Onboarding__c = this.onbProject.PA_Onboarding__c;
                    this.feedbackRec.Unique_Feedback_Id__c =  this.feedbackRec.Assignment__c + '-' + this.feedbackRec.Onboarding__c + '-' + USER_ID;
                    this.resourceNameLabel = this.onbProject.PA_Onboarding__r.Candidate__r.Name;
                   //alert("Unique Keyyyyyyy Line 137: " + this.feedbackRec.Unique_Feedback_Id__c);
                   this.checkIfCurrentUserIsFeedbackProvider(this.feedbackRecId); 
                   //this.duplicateFeedbackCheck(this.feedbackRec.Unique_Feedback_Id__c);
                })
                .catch(error => {
                    this.error = error;
                    this.showProjectData = false;
                });
                //alert('New Assignment chosen  '+this.feedbackRec.Assignment__c);
    }

    handleCommentsChange(event) {
        this.feedbackRec.Comments__c = event.target.value;
    }
    handleFeedbackPulseChange(event) {
        this.feedbackRec.Feedback_Pulse__c = event.target.value;
    }

    handleSkillChange(event) {
        var skillDuplicate = false;
        for(let j=0; j<this.feedbackSkills.length; j++){
            if(this.feedbackSkills[j].Feedback_Skill__c === event.target.value)
            {
                skillDuplicate = true;
                break;
            }
        }
        if(skillDuplicate === false)
        {
        var i = event.target.getAttribute('data-id');
        this.feedbackSkills[i].Feedback_Skill__c = event.target.value;
        }
        else
        {
            var i = event.target.getAttribute('data-id');
            const inputFields = this.template.querySelectorAll(
                'lightning-input-field'
            );
            if (inputFields) {
                inputFields.forEach(field => {
                    if(i === field.getAttribute('data-id')){
                        field.reset();
                    }
                });
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Duplicate Skill',
                    message: this.label.CSGFeedback_duplicateSkillError,
                    variant: 'error',
                    mode: 'dismissable'
                }),
            );
        }
    }

    handleRatingChange(event) {
        var i = event.target.getAttribute('data-id');
        this.feedbackSkills[i].Rating__c = event.target.value;
    }
    
    handleCancel(event) {
        this.feedbackRec.Assignment__c = '' ;
        this.feedbackRec.Onboarding__c = '' ; 
        this.feedbackRec.Comments__c = '';
        this.feedbackRec.Unique_Feedback_Id__c = '';
        this.onbProject = '';
        this.reset = true;
        this.feedbackSkills.splice(0, this.feedbackSkills.length);
    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'CSG_Project_Feedback__c',
                actionName: 'home'
            },
        });
    }

    handleSave(event){
        var i = this.feedbackSkills.length;
        if( i < 1 || i === null )
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.CSGFeedback_noSkillsEnteredError,
                    variant: 'error',
                }),
            );
        }
        else
        {
            let tempFeedbackType = this.feedbackType === 'projFeedback' ? 'Project Related Feedback' : 'General Feedback';
            let newProjectFeedback = { [ONBOARDING_FIELD.fieldApiName] : this.feedbackRec.Onboarding__c ,
                                       [ASSIGNMENT_FIELD.fieldApiName] : this.feedbackRec.Assignment__c,
                                       [COMMENT_FIELD.fieldApiName] : this.feedbackRec.Comments__c,
                                       [UNIQUE_FIELD.fieldApiName] : this.feedbackRec.Unique_Feedback_Id__c,
                                       [FEEDBACK_PULSE_FIELD.fieldApiName] : this.feedbackRec.Feedback_Pulse__c,
                                       [FEEDBACK_TYPE_FIELD.fieldApiName] : tempFeedbackType
                                    };
            createProjFeedback({prjFeedbackObj : newProjectFeedback, listFeedbackSkills : this.feedbackSkills})
                .then((resp)=>{
                    this.recordId = resp.Id; //this will auto call wireMethod/
                    if (this.recordId )
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: this.label.CSGFeedback_successfulSubmission,
                            variant: 'success',
                        }),
                    );
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: 'CSG_Project_Feedback__c',
                            actionName: 'view'
                        },
                    });
                    this.feedbackRec.Assignment__c = '' ;
                    this.feedbackRec.Onboarding__c = '' ; 
                    this.feedbackRec.Comments__c = '';
                    this.onbProject = '';
                    this.reset = true;
                    this.feedbackSkills.splice(0, this.feedbackSkills.length);
                    
                }).catch((err) => {
                    this.error = err;
                   
                    console.log ("this.error: " + JSON.stringify(this.error, null, 2));
                    let message = '';
                    if(err.body.message) { //generic error messages
                        message = err.body.message;
                    }
                    
                    if(err.body.fieldErrors) { // field leve errors, usually means validatino ruled was triggered.
                        for (const [key, value] of Object.entries(err.body.fieldErrors)) {
                            console.log(`${key}: ${value}`);
                            message += value[0] ? value[0].message + "\n" : "";
                          }
                    }
                    
                    if(err.body.pageErrors) { // page level errors, usually means required field validation failed.
                        for (const [key, value] of Object.entries(err.body.pageErrors)) {
                            console.log(`${key}: ${value}`);
                            message += value[0] ? value[0].message + "\n" : "";
                          }
                    }
                    this.template.querySelectorAll('lightning-input-field').forEach(element => {
                        element.reportValidity();
                    });
                
                       this.dispatchEvent(
                        new ShowToastEvent({
                        title: this.label.CSGFeedback_requiredFieldsMissingError,
                        message: message,
                        variant: 'error',
                        }),
                        ); 
                    
                });
        }
    }

    /*
      function to check for duplicate feedback. A feedback is considered a duplicate if there is already a record in the system with the same unique id. The unique ID is a combination of:
      - Assignment ID (Project Record)
      - Onboarding ID (Onboarding Record identifying the resource)
      - Feedback provider user record ID
    */
    /* duplicateFeedbackCheck(uniqueId) {
        console.log("duplicate check");
        console.log("dublicate check: this.userCanSubmitFeedback: " + this.userCanSubmitFeedback);

        checkDuplicates({recordCheck : uniqueId})	
        .then((resp)=>{	
        //this.isModalOpen = false;	
            this.duplicateRec = resp;	
            if (this.duplicateRec !== null){
                this.isDuplicateFeedback = true;	
            }
            else {
                this.isDuplicateFeedback = false;
                getResourceSkills({ candidateId: this.onbProject.PA_Onboarding__r.Candidate__c})
                    .then(result => {
                        // alert('H'+this.onbProject.PA_Onboarding__r.CSG_Role_Community__c);
                        if(this.isProactiveFeedback) {
                            refreshApex(this.result);
                        }
                        for(let i=0; i<result.length; i++){
                            
                            this.userSkillsList.push({
                                sobjectType: 'CSG_Group_Skill__c',
                                Id : result[i].CSGProfileSkill__r.Id,
                                Name: result[i].CSGProfileSkill__r.Name,
                                Type : result[i].CSGProfileSkill__r.Type__c,
                                Category : result[i].CSGProfileSkill__r.Category__c,
                                Selected : false,
                                StyleColor : ''
                            });
                            this.modalIndex++;
                            if(this.isProactiveFeedback) {
                                getRecordNotifyChange(this.userSkillsList);
                            }                                                        
                        }
                        
                        this.data = this.userSkillsList;
                        if (this.userSkillsList.length > 1){
                            this.data = this.userSkillsList;
                            this.modalClass = 'slds-modal slds-fade-in-open';
                            this.modalBackdropClass = 'slds-backdrop slds-backdrop_open';
                            this.isModalOpen = true;
                
                        } else {
                            this.isModalOpen = false;
                            this.isModalEmpty = true;
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    });
            }
        }).catch((err) => {	
            this.error = err;	
        });
    } */

    /*
      Function to check whether the currently logged in user is the feedback provider. If it is not, we need to show a modal that they can't provide feedback.
      On modal dismission, they will be taken to a blank form so they can submit proactive feedback.
    */

    checkIfCurrentUserIsFeedbackProvider(uniqueId) {
        console.log('checkIfUserCanSubmitFeedback');
        console.log('uniqueId: ' + uniqueId);
        console.log('USER_ID: ' + USER_ID);

        checkIfUserCanSubmitFeedback( {recId: uniqueId, currUserID: USER_ID} )
        .then( result => {
            if(result === 'COMPLETED') {
                this.userCanSubmitFeedback = true;
                this.isDuplicateFeedback = true;
            }
            else if (result === 'NO_RESULTS') {
                this.userCanSubmitFeedback = false;
                this.isDuplicateFeedback = false;
            }
            else if (result === 'SAME_USER') {
                this.userCanSubmitFeedback = true;
                this.isDuplicateFeedback = false;
            }
            else if (result === 'DIFFERENT_USER') {
                this.userCanSubmitFeedback = false;
                this.isDuplicateFeedback = false;
            }
            else {
                this.userCanSubmitFeedback = false;
                this.isDuplicateFeedback = false;
            }

            if(this.userCanSubmitFeedback && !this.isDuplicateFeedback) {
                getResourceSkills({ candidateId: this.onbProject.PA_Onboarding__r.Candidate__c})
                    .then(result => {
                        // alert('H'+this.onbProject.PA_Onboarding__r.CSG_Role_Community__c);
                        if(this.isProactiveFeedback) {
                            refreshApex(this.result);
                        }
                        for(let i=0; i<result.length; i++){
                            
                            this.userSkillsList.push({
                                sobjectType: 'CSG_Group_Skill__c',
                                Id : result[i].CSGProfileSkill__r.Id,
                                Name: result[i].CSGProfileSkill__r.Name,
                                Type : result[i].CSGProfileSkill__r.Type__c,
                                Category : result[i].CSGProfileSkill__r.Category__c,
                                Selected : false,
                                StyleColor : ''
                            });
                            this.modalIndex++;
                            if(this.isProactiveFeedback) {
                                getRecordNotifyChange(this.userSkillsList);
                            }                                                        
                        }
                        
                        this.data = this.userSkillsList;
                        if (this.userSkillsList.length > 1){
                            this.data = this.userSkillsList;
                            this.modalClass = 'slds-modal slds-fade-in-open';
                            this.modalBackdropClass = 'slds-backdrop slds-backdrop_open';
                            this.isModalOpen = true;
                
                        } else {
                            this.isModalOpen = false;
                            this.isModalEmpty = true;
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    });
            }
            console.log('user can submit feedback: ' + this.userCanSubmitFeedback);
            console.log('typeof this.userCanSubmitFeedback: ' + typeof this.userCanSubmitFeedback);
        })
        .catch(error => {
            this.error = error;
            console.log("error in user check: " + JSON.stringify(error, null, 2));
        });

    }

    handleDuplicateFeedbackModalCloseButton(event){
        
        this.resetForm();
        this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'CSG_Project_Feedback_Form'
                }
        }, true);
   
    }

    handleDuplicateFeedbackModalOkButton(event){
        // navigate the user to the duplicate record.
        this[NavigationMixin.Navigate]({	
            type: 'standard__recordPage',	
            attributes: {	
                recordId: this.feedbackRecId,	
                objectApiName: 'CSG_Project_Feedback__c',	
                actionName: 'view'	
            },	
        });	
    }

    resetForm(){
        this.enableAssignment = true;
        this.disableAssignment = false;
        this.feedbackRec.Assignment__c = '' ;
        this.feedbackRec.Onboarding__c = '' ; 
        this.feedbackRec.Comments__c = '';
        this.feedbackRec.Unique_Feedback_Id__c = '';
        this.feedbackRec.Feedback_Pulse__c = 'Green';
        this.onbProject = '';
        this.reset = true;
        this.feedbackSkills.splice(0, this.feedbackSkills.length);
        this.isDuplicateFeedback = false;
        this.showProjectData = false;
        this.userCanSubmitFeedback = true;
        this.isModalOpen = false;
    }

            
}