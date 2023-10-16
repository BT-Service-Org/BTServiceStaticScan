import { LightningElement, track, wire,api} from 'lwc';
import { subscribe, unsubscribe, onError} from 'lightning/empApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadDefaults from '@salesforce/apex/SkillsEntryController.loadDefaults';
import getUserGroupSkills from '@salesforce/apex/SkillsEntryController.getUserGroupSkillsList';
import getAllUserSkillsList from '@salesforce/apex/SkillsEntryController.getAllUserSkillsList';
import getAllSkillsList from '@salesforce/apex/SkillsEntryController.getAllSkillsList';
import getMyTeamSkillsList from '@salesforce/apex/SkillsEntryController.getMyTeamSkillsList';
import getMyDelegatedTeamSkills from '@salesforce/apex/SkillsEntryController.getMyDelegatedTeamSkills';
import updatePAOnboardingRecord from '@salesforce/apex/SkillsEntryController.updatePAOnboardingRecord';
import submitRecords from '@salesforce/apex/SkillsEntryController.submitRecords';
import validateExpertiseRecords from '@salesforce/apex/SkillsEntryController.validateExpertiseRecords';
import deleteRecords from '@salesforce/apex/SkillsEntryController.deleteRecords';
import invokeSkillsBatch from '@salesforce/apex/SkillsEntryController.invokeSkillsBatchJob';
import Id from '@salesforce/user/Id';
import noskillSelected from '@salesforce/label/c.No_Skill_Selected_Str';
import noSelectPromptDesc from '@salesforce/label/c.No_Skill_Selected_Desc';
import skillDeletePromptLabel  from '@salesforce/label/c.Skill_Delete_Prompt_Label';
import skillDeletePromptDesc from '@salesforce/label/c.Skill_Delete_Prompt_Desc';
import deleteSkillSuccessMsg from '@salesforce/label/c.Delete_Skills_Success_Message';

import selectSkillsValidate from '@salesforce/label/c.Skills360_Validate_select';
import validateHeaderLabel  from '@salesforce/label/c.Skills360_Validate_Header';
import validateCountLabel from '@salesforce/label/c.Skills360_Validate_Count';
import validateSkillSuccessMsg from '@salesforce/label/c.Skills360_Validate_Success';
import validateModalMsg from '@salesforce/label/c.Skills360_Validate_Modal_Header';
import defaultModalMsg from '@salesforce/label/c.Skills360_Modal_Header';
import invalidateModalMsg from '@salesforce/label/c.Skills360_Invalidate_Modal_Header';
import noneSkillRating from '@salesforce/label/c.CSG_None_Skill_Rating';

import asplimitmsg from '@salesforce/label/c.Skills_Aspirational_Limit_Msg';
import asphelptext from '@salesforce/label/c.Skills_Aspirational_Help_Text';

import selectSkillsInvalidate from '@salesforce/label/c.Skills360_Invalidate_select';
import InvalidateHeaderLabel  from '@salesforce/label/c.Skills360_InValidate_Header';
import InvalidateCountLabel from '@salesforce/label/c.Skills360_InValidate_Count';
import InvalidateSkillSuccessMsg from '@salesforce/label/c.Skills360_InValidate_Success';
import UpdateSkillsLabel from '@salesforce/label/c.CSG_Update_Skills_Label';
import ConfirmBatchMessage from '@salesforce/label/c.CSG_Confirm_Batch_message_label';
import SkillResultMsg from '@salesforce/label/c.Skill_No_Result_Msg';
import SkillResultSearchMsg from '@salesforce/label/c.Skill_No_Result_Search_Msg';
import skillsMaxMsg from '@salesforce/label/c.Skills360_Limit_100_Msg';
import SkillsLimitMsg from '@salesforce/label/c.Skills_Limit_Msg';
import AspirationalToggleMsg from '@salesforce/label/c.CSG_Aspirational_Toggle_Msg';
import AddSkillsMsg from '@salesforce/label/c.CSG_Add_skills';
import ClickHereMsg from '@salesforce/label/c.CSG_Click_Here';
import SKILLS_bgImage from '@salesforce/resourceUrl/Skills360backgroundImage'
import { getRecord } from 'lightning/uiRecordApi'
import { updateRecord } from "lightning/uiRecordApi";
import SKILLS_CLMNS from '@salesforce/schema/User.Skill360_List_View_Columns__c';
import ID_FIELD from '@salesforce/schema/User.Id';

export default class skillsEditTable extends LightningElement {
    _currentview;
    label = {
        asphelptext,AddSkillsMsg,ClickHereMsg
    };
    @api
    get currentview() {
        return this._currentview;
    }
    set currentview(value) {
        this.setAttribute('currentview', value);
        this._currentview = value;
        this.setshowCheckBox();
        //this.setup();
    }
    
    @api myskillsview;
    @api showmyteam;
    @api findskillview;
    @api currentSubview;
    @api showtablecomp;
    showCheckBox = true;
    userId = Id;
    @track UpdateSkill = UpdateSkillsLabel;
    @track availableGroups = [];
    @track groupOptionValue = 'MySkills';
    @track userSkills = [];
    @track tableLoadingState = false;
    @track progressPctValue = 0;
    @track modalOpen = false;
    @track modalHeaderH2Text = "";
    @track modalBodyH2Text = "";
    @track modalBodyText = "";
    @track modalBodySkillRatingText = false;
    @track channelName = '/event/Skills_Entry_Event__e';
    @track isSubscribeDisabled = false;
    @track isSubmitButtonDisabled = true;
    @track isDeleteButtonDisabled = false;
    @track skillRatingChanged = false;
    @track showConfirmButtonDisabled = false;
    @track isUnsubscribeDisabled = !this.isSubscribeDisabled; 
    @track showContinue = false;
    @track showValidateContinue = false;
    @track skillsListToDelete = [];
    @track isRemoveValidate = false;
    disableValButton = true;
    disableRemoveValButton = true;   
    @track validateClmUpBool ;
    @track validateClmDWBool ;
    sortedDirection;
    @track showTriggerBatchButton = false;
    @track showConfirmBatch = false;
    @track showLRpopup = false;
    @track rowskillId;
    @track searchField = 'All';
    @track searchterm;
    @track onloaduserSkillList = [];
    @track selectedUserRecs = [];
    @track skillsCount = false;
    @track skillNoResultMsg = SkillResultMsg;
    @track SkillResultSearchMsg = SkillResultSearchMsg;
    @track aspirationToggleMsg = AspirationalToggleMsg;
    
    sortedHeader ;
    skillTypeSort = false;
    skillCategorySort =  false;
    skillNameSort =  false;
    expertiseRatingSort =  false;
    expertiseCertifiedSort = false;
    SkillRatingLastUpdateSort = false;
    SkillAspSort = false;
    userSkillRatingOptions ;
    userSkillRatingOptionsNone;
    userinfo = {};
    requiredOptions = [];  
    mySkillsView;
    ratedskillcount = 0;
    
    anyvalidatedRecs = false;
    anyInvalidRecs = false;
    recordsSubmitted = 0;
    recordsSelected = 0
    messageReceivedTracker = 0;
    recordFailTracker = 0;
    recordSuccessTracker = 0;
    subscription = {};
        
    @wire(CurrentPageReference)
    pageRef;
    activityIdsForTracker =[];
    @track validateMap = {};
    useridSet = [];
    @track onloadAllSubordinates = [];
    @track servicesOrgUserIds = [];
    listViewDisabled = false;
    
    _selected = [];
    modalBodyTableFields = false;
    modalBodyFocusFields = false;
    displayTypeFld = false;
    displayCatFld = false;
    displaySNameFld = false;
    displayAspFld = false;
    displaySkillRatingFld = false;
    displaySLastUpdateFld = false;
    displayEVFld = false;
    aspSkillStr;
    focusStr;
    searchFieldOptions =[];
    
    @wire(getRecord, { recordId: Id, fields: [SKILLS_CLMNS]}) 
    userDetails({error, data}) {
        this.requiredOptions = ["Type","Category","SkillName","SkillRating"];
        if (data) {
            if(data.fields.Skill360_List_View_Columns__c.value){
                this._selected = JSON.parse(data.fields.Skill360_List_View_Columns__c.value);
                //this._selected = data.fields.Skill360_List_View_Columns__c.value;
                console.log(data.fields.Skill360_List_View_Columns__c+'In get record'+this._selected);
                console.dir(data.fields.Skill360_List_View_Columns__c);
                this.setClmnsVisibility(this._selected);
                console.dir(this.searchFieldOptions+'search list');
            }else{
                this._selected = JSON.parse('["Type","Category","SkillName","SkillRating","Aspirational","ExpertiseValidated"]');
                this.searchFieldOptions = [{ label: 'All', value: 'All'},
                                           {
                                               label: 'Type',
                                                   value: 'skillType'
                                                       },
                                           {
                                               label: 'Category',
                                                   value: 'skillCategory'
                                                       },
                                           {label: 'Skill Name',
                                               value: 'skillName'
                                                   }
                                           ,
                                           {
                                               label: 'Skill Rating',
                                                   value: 'expertiseRating'
                                                       }
                                           
                                          ];
                this.displayTypeFld = true;
                this.displayCatFld = true;
                this.displaySNameFld = true;
                this.displayAspFld = true;
                this.displaySkillRatingFld = true;
                this.displayEVFld = true;
                //this.displaySLastUpdateFld = true;
            }
            
        } else if (error) {
            this.error = error ;
        }
    }
    setClmnsVisibility(clmns){
        console.log('clmns'+clmns);
        const items = [{ label: 'All', value: 'All'}];
        for(let i = 0; i < clmns.length; i++) {
            console.log('clmns'+clmns[i]);
            
            switch(clmns[i]) { 
                case 'Type':
                items.push({
                    label: 'Type',
                        value: 'skillType'
                            });
                this.displayTypeFld = true;
                break;
                case 'Category':
                items.push({
                    label: 'Category',
                        value: 'skillCategory'
                            });
                this.displayCatFld = true;
                break;
                case 'SkillName':
                items.push({label: 'Skill Name',
                    value: 'skillName'
                        });
                this.displaySNameFld = true;
                break;
                case 'Aspirational':
                this.displayAspFld = true;
                break; 
                case 'SkillRating':
                items.push({
                    label: 'Skill Rating',
                        value: 'expertiseRating'
                            });
                this.displaySkillRatingFld = true;
                break;    
                case 'SkillRatingLastUpdate':
                this.displaySLastUpdateFld = true;
                break;   
                case 'ExpertiseValidated':
                this.displayEVFld = true;
                break;     
            }
            this.searchFieldOptions = items;
        }
    }
    @api
    updateSkillTaxonomyModal(){
        this.modalHeaderH2Text = UpdateSkillsLabel;
        this.modalBodyH2Text = '';
        this.modalBodyText =  ConfirmBatchMessage ;
        this.modalBodySkillRatingText = false;
        this.showContinue = false;
        this.showValidateContinue = false;
        this.showConfirmBatch = true;
        this.showConfirmButtonDisabled = false;
        this.modalOpen = true;
    }
    
    //This is to trigger Batch class "CSG_SkillsTaxonomySyncBatch" on click of confirm button
    invokeSkillsBatchJS(){
        this.tableLoadingState = false;
        invokeSkillsBatch({})
            .then(result => {
                console.log('success');
                this.showValidateContinue = false;
                this.showContinue = false;
                this.modalOpen = false;
                this.isRemoveValidate = false;
                this.showConfirmBatch = false;
                this.showConfirmButtonDisabled = false;
                this.userSkillsByGroup(this.groupOptionValue);
                this.tableLoadingState = true;
            })
            .catch((error) => {
                console.log(error);
                this.tableLoadingState = true;
            }) 
            }
    
    // select/unselect rows which are preset on DOM
    allSelected(event) {
        let disable;
        this.anyvalidatedRecs = false;
        this.anyInvalidRecs = false;
        
        let selectedRows = this.template.querySelectorAll('lightning-input[data-class="selectedcheckbox"]');
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
                if(!this.anyvalidatedRecs){
                    this.anyvalidatedRecs = (selectedRows[i].getAttribute('data-validated') === 'true');
                }
                if(!this.anyInvalidRecs){
                    this.anyInvalidRecs  = (selectedRows[i].getAttribute('data-validated') === 'false');
                }
                
            }
            this.updateactivityIdsForTracker(selectedRows[i].checked,selectedRows[i].getAttribute('data-id'));
        } 
        if(this.activityIdsForTracker.length > 0 ){
            if(this.anyInvalidRecs ){
                this.disableValButton = false;
            }
            else{
                this.disableValButton = true;
            }
            if(this.anyvalidatedRecs){
                this.disableRemoveValButton = false;
            }else{
                this.disableRemoveValButton = true;
            }
            
        }else{
            this.disableRemoveValButton = true;
            this.disableValButton = true;
        }
    }
    
    //Hold id of selected records & Modify Select All header checkbox if any changes made on the rows
    changeSelectAll(event) {        
        let check = event.target.checked;
        let dataid = event.target.dataset.id;
        this.updateactivityIdsForTracker(check,dataid);
        //update select all checkbox
        this.updateSelectAll();
        
        if(check == true){
            if(event.target.dataset.validated === 'true'){
                this.disableRemoveValButton = false;
            }else if(event.target.dataset.validated === 'false'){
                console.log('here validate');
                this.disableValButton = false;
                
                
            }
            
            
        }else{
            this.checkForOtherValidInvalid();
        }
        
    }
    
    //This function add/removes selected elements on UI
    updateactivityIdsForTracker(check,dataid){
        let foundIndex = this.activityIdsForTracker.indexOf(dataid);
        if(check && foundIndex === -1){
            this.activityIdsForTracker.push(dataid);
        }
        else if(!check && foundIndex !== -1){
            this.activityIdsForTracker.splice(foundIndex,1);
        }
        
        //Enable disable delete button
        if(this.activityIdsForTracker.length>0){
            this.isDeleteButtonDisabled = false;
        }
        else{
            this.isDeleteButtonDisabled = true;
        }
    }
    
    
    updateSelectAll(){
        var checkboxVal = this.template.querySelector('input[data-id="cb1"]');
        if(checkboxVal){
            if(this.userSkills.length == 0 || this.activityIdsForTracker.length == 0){
                //No skills present
                checkboxVal.checked = false;
            }if(this.userSkills.length == this.activityIdsForTracker.length){
                //Selected skills match with total skills list
                checkboxVal.indeterminate = false;
                checkboxVal.checked = true;
            }else if(this.activityIdsForTracker != null && this.activityIdsForTracker.length > 0){
                //Selected skills doesnt match with total skills list
                checkboxVal.indeterminate = true;
            }  
            else{ //all skills un checked
                console.log('in else ');
                checkboxVal.indeterminate = false;
                checkboxVal.checked = false;
            } 
        }
    }
    
    
    
    // Handles subscription to event channel, will only iterate count if PE creator == logged in user
    // only way to currently 'filter' channel
    handleSubscribe(isDelete) {
        console.log('  handleSubscribe  : ' );
        const that = this;
        // Callback invoked whenever a new event message is received
        const messageCallback = function(response) {
            const payload = response.data.payload;
            
            if(payload.CreatedById === that.userId){
                console.log('New message received: ', JSON.stringify(response));
                console.log('total count of recordsSubmitted: ', that.recordsSubmitted);
                that.messageReceivedTracker++;
                console.log('total count records processed: ', that.messageReceivedTracker);
                if(payload.Save_Response_Id__c !== 'fail'){
                    that.recordSuccessTracker++;
                } else {
                    if(payload.Response_Message__c && payload.Response_Message__c.includes(SkillsLimitMsg)){
                        payload.Response_Message__c = skillsMaxMsg;
                    }
                    
                    
                    that.showFailureToast('A Skill and Expertise record failed to update',payload.Response_Message__c,'sticky');
                    that.recordFailTracker++;
                }
                if(that.messageReceivedTracker === that.recordsSubmitted){
                    that.handleUnsubscribe();
                    that.userSkillsByGroup(that.groupOptionValue);
                    if(that.recordsSelected > 0){
                        that.showSuccessToast('submitSkill');
                    }else if(that.recordSuccessTracker > 0){
                        that.showSuccessToast('submit');
                    }
                    //now that we're complete udpate the PA Onboarding Record
                    updatePAOnboardingRecord({userSet: null});
                    that.messageReceivedTracker = 0;
                    that.recordSuccessTracker = 0;
                    that.recordFailTracker = 0;
                }
            }
        };
            
            // Invoke subscribe method of empApi. Pass reference to messageCallback
            subscribe(this.channelName, -1, messageCallback).then(response => {
                // Response contains the subscription information on successful subscribe call
                console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
                this.subscription = response;
                
            });
    }
    
    handleUnsubscribe() {
        
        
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            this.recordsSubmitted = 0;
            this.recordsSelected = 0;
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }
    
    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }
    
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
    
    closeModal(){
        this.showValidateContinue = false;
        this.showContinue = false;
        this.modalOpen = false;
        this.isRemoveValidate = false;
        this.showConfirmBatch = false;
        this.modalBodyTableFields = false;
    }
    
    openSkillRatingDescriptionModal(){
        this.modalHeaderH2Text = 'Skill Rating Definitions';
        this.modalBodyH2Text = '';
        this.modalBodyText = '';
        this.modalBodySkillRatingText = true;
        this.modalOpen = true;
        this.showConfirmButtonDisabled = false;
    }
    
    openNoSkillsSelectedModal(){
        this.modalHeaderH2Text = 'No Skills Selected';
        this.modalBodyH2Text = 'Please select or change a Skill Rating.';
        this.modalBodyText = '';
        this.modalBodySkillRatingText = false;
        this.modalOpen = true;
        this.showConfirmButtonDisabled = true;
    }
    
    openNoSkillsDeletedModal(hText,bText,showContinue){
        this.modalHeaderH2Text = hText;//'No Skills Selected';
        this.modalBodyH2Text = bText;//'Please select a Skill.';
        this.modalBodyText = '';
        this.modalBodySkillRatingText = false;
        this.showConfirmButtonDisabled = false;
        this.showContinue = showContinue;
        this.modalOpen = true;
        this.showValidateContinue = false;
        
    }
    
    openValidateModal(hText,bText,showContinue){
        this.modalHeaderH2Text = hText;
        this.modalBodyH2Text = bText;
        this.modalBodyText = '';
        this.modalBodySkillRatingText = false;
        this.showConfirmButtonDisabled = false;
        this.showValidateContinue = showContinue;
        this.modalOpen = true;
        this.showContinue = false;    
    }
    
    
    showSuccessToast(operation) {
        var tmsg;
        //Set the default message
        let titleMsg = defaultModalMsg;
        switch(operation) { 
            case 'delete':
            tmsg = deleteSkillSuccessMsg ;
            tmsg = tmsg.replace("subCount", this.recordsSubmitted);
            tmsg = tmsg.replace("sucCount", this.recordSuccessTracker);
            break;
            case 'validate':
            tmsg = validateSkillSuccessMsg ;
            tmsg = tmsg.replace("subCount", this.recordsSubmitted);
            tmsg = tmsg.replace("sucCount", this.recordSuccessTracker);
            titleMsg = validateModalMsg;
            break;
            case 'invalidate':
            tmsg = InvalidateSkillSuccessMsg ;
            tmsg = tmsg.replace("subCount", this.recordsSubmitted);
            tmsg = tmsg.replace("sucCount", this.recordSuccessTracker);
            titleMsg = invalidateModalMsg;
            break;
            case 'submit':
            tmsg = this.recordSuccessTracker + ' of ' + this.recordsSubmitted + ' Skills and Expertise records have been updated';
            break; 
            case 'submitSkill':
            tmsg = this.recordsSelected + ' of ' + this.recordsSelected + ' Skills and Expertise records have been updated';
            break;       
        }
        const event = new ShowToastEvent({
            title: titleMsg,
                message: tmsg,//this.recordSuccessTracker + ' of ' + this.recordsSubmitted + ' Skills and Expertise records have been updated',
                    variant: 'success',
                        mode: 'dismissable'
                            });
        this.dispatchEvent(event);
        this.showContinue = false;
    }
    
    showConfirmSkillsSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success',
                message:'Your Skills and Expertise records have been confirmed',
                    variant: 'success',
                        mode: 'dismissable'
                            });
        this.dispatchEvent(event);
    }
    
    showFailureToast(failureTotle,failureMessage,mode) {
        const event = new ShowToastEvent({
            title: failureTotle,//'A Skill and Expertise record failed to update',
                message: failureMessage,
                    variant: 'error',
                        mode: mode//'sticky'
                            });
        this.dispatchEvent(event);
    }
    
    //creating UUID in order to build object in controller
    createUUID() {
        var dt = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c === 'x' ? r :(r&0x3|0x8)).toString(16);
        });
        return uuid;
    }
    
    handleChange(event){
        event.target.dataset.change = true;
        console.log(event.target.dataset.index+'?'+this.userSkills[event.target.dataset.index].expertiseRating);
        
        //this.calculateProgressPctValue();
        //let ratingValue = event.target.value;
        //let recordId = event.target.dataset.id;
        if(event.target.dataset.name == 'expertiseRating'){
            this.userSkills[event.target.dataset.index].expertiseRating = event.target.value;
        }else if(event.target.dataset.name == 'aspirationalskill'){
            this.userSkills[event.target.dataset.index].aspirationSkill = event.target.checked;
        }
        console.log(this.userSkills[event.target.dataset.index].aspirationSkill+'???'+this.userSkills[event.target.dataset.index].expertiseRating );
        
        if(this.tableLoadingState){ 
            this.skillRatingChanged = true;
        }
    }
    
    
    handleGroupChange(event){
        this.groupOptionValue = event.detail.value;
        this.tableLoadingState = false;
        this.resetSortHeaders();
        this.userSkillsByGroup(this.groupOptionValue);
    }
    
    changeListView(event){
        if(event){
            event?.preventDefault();
        }
        const selectedEvent = new CustomEvent("changeview", {
            detail: 'AllSkills' });
        
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);  
    }
    
    
    //Added to allow users to validate they have no skills to update, but were compliant in reviewing
    confirmSkills(){
        //updates onboarding record with date/time
        updatePAOnboardingRecord({userSet: null});
        //close out modal
        this.closeModal();
        if(this.userSkills?.length > 0 ){
            //show them recording was successful
            this.showConfirmSkillsSuccessToast();
            
        }
        this.changeListView(); 
        
    }
    
    //grabs skills by group value
    userSkillsByGroup(groupValue,searchTermVal){
        
        console.log(groupValue+'&&&');
        switch (groupValue){
             case 'All Skills':
            getAllSkillsList({}).then(res =>{
                    this.sortSkills(res);
                    this.onloaduserSkillList = this.userSkills;
                    this.tableLoadingState = true;
                    this.isDeleteButtonDisabled = true;
                    if(this.userSkills.length === 0){
                        this.modalHeaderH2Text = 'Welcome to the CSG Skills App';
                        this.modalBodyH2Text = 'It looks like you haven\'t assigned yourself any skills.';
                        this.modalBodyText = 'Choose a Group or Role from the dropdown in the app to get started!';
                        this.modalBodySkillRatingText = false;
                        this.showConfirmButtonDisabled = true; 
                        this.showContinue = false;
                        this.modalOpen = true;
                        this.isSubmitButtonDisabled = true;
                    }
                    this.listViewDisabled = false;
                    this.searchterm = '';
                    this.searchField = 'All';
                    this.clearSelections();
                    this.fetchAspSkills(this.onloaduserSkillList);
                    this.ratedskillcount = this.userSkills.length;
                })
                .catch(error => {
                    this.error = error;
                    this.tableLoadingState = true;
                    this.isSubmitButtonDisabled = false;
                });
            break;
            case 'MySkills':
            getAllUserSkillsList({userId: this.userId}).then(results => {
                    this.sortSkills(results); 
                    this.onloaduserSkillList = this.userSkills;
                    this.tableLoadingState = true;
                    this.isDeleteButtonDisabled = true;
                    if(this.userSkills.length === 0){
                        this.modalHeaderH2Text = 'Welcome to the CSG Skills App';
                        this.modalBodyH2Text = 'It looks like you haven\'t assigned yourself any skills.';
                        this.modalBodyText = 'Choose a Group or Role from the dropdown in the app to get started!';
                        this.modalBodySkillRatingText = false;
                        this.showConfirmButtonDisabled = true; 
                        this.showContinue = false;
                        this.modalOpen = true;
                        this.isSubmitButtonDisabled = true;
                    }
                    this.listViewDisabled = false;
                    this.searchterm = '';
                    this.searchField = 'All';
                    this.clearSelections();
                    this.fetchAspSkills(this.onloaduserSkillList);
                    this.ratedskillcount = this.userSkills.length;
                })
                .catch(error => {
                    this.error = error;
                    this.tableLoadingState = true;
                    this.isSubmitButtonDisabled = false;
                });
            break;
            
            case 'MyTeamSkills':
            getMyTeamSkillsList().then(resultList => {
                    this.sortSkills(resultList);
                    this.tableLoadingState = true;
                    this.isSubmitButtonDisabled = false;
                    this.onloadAllSubordinates = this.userSkills;
                    this.onloaduserSkillList = this.userSkills;
                    //Collect subordinates ids fro user multiselect
                    this.servicesOrgUserIds = [];
                    this.userSkills.forEach(skill =>{
                        this.servicesOrgUserIds.push(skill.userId);
                    });
                    //clear the selected users
                    const objChild = this.template.querySelector('c-lwc-multi-lookup');
                    objChild.clearSelected();
                    this.clearSelections();
                    if(this.userSkills.length == 0){
                        this.isSubmitButtonDisabled = true;
                        
                    }
                    this.disableValButton = true;
                    this.disableRemoveValButton = true;
                    this.listViewDisabled = false;
                    this.searchterm = '';
                    this.searchField = 'All';
                    
                    
                })
                .catch(error => {
                    this.error = error;
                    this.tableLoadingState = true;
                    this.isSubmitButtonDisabled = false;
                });
            break;
            case 'DelegatedTeamSkills':
            getMyDelegatedTeamSkills().then(result => {
                    this.sortSkills(result);
                    this.tableLoadingState = true;
                    this.isSubmitButtonDisabled = false;
                    this.onloadAllSubordinates = this.userSkills;
                    this.onloaduserSkillList = this.userSkills;
                    this.servicesOrgUserIds = [];
                    //Collect subordinates ids fro user multiselect
                    this.userSkills.forEach(skill =>{
                        this.servicesOrgUserIds.push(skill.userId);
                    });
                    //clear the selected users
                    const objChild = this.template.querySelector('c-lwc-multi-lookup');
                    objChild.clearSelected();
                    this.clearSelections();
                    if(this.userSkills.length == 0){
                        this.isSubmitButtonDisabled = true;
                        
                    }
                    this.disableValButton = true;
                    this.disableRemoveValButton = true;
                    this.listViewDisabled = false;
                    this.searchterm = '';
                    this.searchField = 'All';
                    
                })
                .catch(error => {
                    this.error = error;
                    this.tableLoadingState = true;
                    this.isSubmitButtonDisabled = false;
                });
            break;
            default:
            getUserGroupSkills({userId: this.userId, groupName: groupValue})
                .then(result => {
                    this.sortSkills(result);
                    this.onloaduserSkillList = this.userSkills;
                    this.tableLoadingState = true;
                    this.listViewDisabled = false;
                    this.searchterm = '';
                    this.searchField = 'All';
                    if(this.userSkills.length == 0){
                        this.isSubmitButtonDisabled = true;
                    }
                    else{
                        this.isSubmitButtonDisabled = false;
                    }
                    console.dir(this.userSkills.length+'$$$$$$$$'+this.userSkills);
                    
                })
                .catch(error => {
                    this.error = error;
                    this.tableLoadingState = true;
                    this.isSubmitButtonDisabled = false;
                    this.searchterm = '';
                    this.searchField = 'All';
                });
        }
        if(this.userSkills){
            this.skillsCount = true;
        }
        else{
            this.skillsCount = false;
        }
    }
    
    sortSkills(result){
        this.userSkills = result.slice()
                                    .sort((a, b) => {
                                        const userNameA = a.userName;
                                        const userNameB = b.userName;
                                        var isUnameNull = true;
                                        
                                        if(a.userName || b.userName ){
                                            isUnameNull = false;
                                        }
                                        
                                        const skillNameA = a.skillName?.toLowerCase();
                                        const skillNameB = b.skillName?.toLowerCase();
                                        const skillCategoryA = a.skillCategory?.toLowerCase();
                                        const skillCategoryB = b.skillCategory?.toLowerCase();
                                        const skillTypeA = a.skillType?.toLowerCase();
                                        const skillTypeB = b.skillType?.toLowerCase();
                   
                                if ((isUnameNull || userNameA?.localeCompare(userNameB) === 0 )  ) {
                                        if (skillTypeA?.localeCompare(skillTypeB) === 0) {
                                            if (skillCategoryA?.localeCompare(skillCategoryB) === 0) {
                                                return skillNameA?.localeCompare(skillNameB);
                                            } else {
                                                return skillCategoryA?.localeCompare(skillCategoryB);
                                            }

                                        } else {
                                                return skillTypeA?.localeCompare(skillTypeB);
                                        }
                                }
                                else {
                                    return userNameA?.localeCompare(userNameB);
                                }
                    });
    }
    
    
    handleselectedUsers(event){
        try {
            this.selectedUserRecs = event.detail.selRecords;
            console.log(JSON.stringify(this.selectedUserRecs));
            this.filterRecs(this.searchterm,this.searchField);
            
        }catch(err) {
            console.log('error occured'+err.message);
        }
        this.validateClmUpBool = false;
        this.validateClmDWBool = false;
        this.sortedDirection = null;
    }
    
    
    renderedCallback() {
        //On change to results, render the selected rows as checked
        if(this.groupOptionValue && (this.groupOptionValue == 'My Team Skills'||this.groupOptionValue == 'Delegated Team Skills')){
            this.uncheckAndCheckselected();
        }
    }
    
    uncheckAndCheckselected(){
        let selectedRows = this.template.querySelectorAll('lightning-input[data-class="selectedcheckbox"]');
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                let found = this.activityIdsForTracker.find(element => element === selectedRows[i].getAttribute('data-id'));
                if(found){
                    selectedRows[i].checked = true;
                }else{
                    selectedRows[i].checked = false;
                }
            }
        }
        this.updateSelectAll();
    }
    
    
    calculateProgressPctValue(){
        let userSkillLength = this.userSkills.length;
        let userSkillsNACount = 0;
        for(var userSkill of this.userSkills){
            if(userSkill.Expertise_Rating__c > 0){
                userSkillsNACount++;
            }
        } 
        this.progressPctValue = (userSkillsNACount/userSkillLength)*100;
    }
    
    
    get disableSelectAllButton(){
        return !(this.userSkills  && this.userSkills.length);
    }
    
    get userSkillOptions() {
        
        return this.userSkillRatingOptionsNone;
    }
    
    get userSkillOptionsExisting() {
        
        return  this.userSkillRatingOptions ;
    }
    //DEFAULT TO NOT SET
    async connectedCallback() {
        console.log();
        let initialGroupValue = this.pageRef.state.c__groupName;
        console.log(this.pageRef);
        console.log('this.groupOptionValue..'+this.groupOptionValue+' '+this.findskillview );
        
        if(!this.findskillview  ){
            if( typeof initialGroupValue === 'undefined' && this.currentview == 'MySkills'){
                initialGroupValue = "MySkills";
                this.groupOptionValue = "MySkills";
            }
        }
        else{
            initialGroupValue = "All Skills";
            this.groupOptionValue = "All Skills";
        }
        
        
        //get the groups first
        loadDefaults()
            .then(result => {
                this.availableGroups = result.csgGrps;
                //set the group value
                this.groupOptionValue = initialGroupValue;
                this.showTriggerBatchButton = result.batchButtonEnabled;  
                this.userSkillRatingOptions = result.picklistWrapperList;
                this.userSkillRatingOptionsNone = result.picklistWrapperListNone;
                this.userinfo = result.userinfo;
                
            })
            .catch(error => {
                this.error = error;
            });
        this.userSkillsByGroup(initialGroupValue);
        
        
        
    }
    
    
    setshowCheckBox(){
        console.log(this.currentview+'current view%%%5');
        if(this.currentview == 'MySkills' || this.currentview == 'TeamSkills' ){// )
            this.showCheckBox = true;
        }else{
            this.showCheckBox = false;
        }
        
    }
    
    //The below condition is to display "No Results found - Search in All Skills link"
    get showSearchMsg(){
        if( !this.skillsCount  && (this._currentview === 'MySkills')){
            return true;
        }
        else{
            return false;
        }
    }
    
    //The below condition is to display "No Results found"
    get showAllSkillsSearchMsg(){
        if( !this.skillsCount  && (this._currentview == 'AllSkills' || this._currentview == 'TeamSkills')){// )
            return true;
        }
        else{
            return false;
        }
    }
    
    get showSubmitbutton(){
        return (!this.skillRatingChanged );
    }
    
    get showOkbutton(){
        return (!this.showValidateContinue && !this.showContinue && !this.showConfirmBatch  );
    }
 
    get showCancelbutton(){
        return (this.showValidateContinue || this.showContinue || this.showConfirmBatch );
        
    }
    
    deleteSkills() { 
        
        let selectedRows = this.template.querySelectorAll('lightning-input[data-class="selectedcheckbox"]');
        
        this.skillsListToDelete = [];
        // based on selected row getting values of the contact
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].checked && selectedRows[i].type === 'checkbox' && selectedRows[i].dataset.id != undefined) {
                
                this.skillsListToDelete.push(selectedRows[i].dataset.id);
            }
        }
        //capturing the count of skills selected for displaying the toast message
        this.recordsSubmitted = this.skillsListToDelete.length;
        if(this.skillsListToDelete.length == 0){
            //Display a modal with message "No Skills selected"
            this.openNoSkillsDeletedModal(noskillSelected,noSelectPromptDesc,false);
        }
        else{
            var PromptDesc = skillDeletePromptDesc.replace("&n",this.skillsListToDelete.length);
            this.openNoSkillsDeletedModal(skillDeletePromptLabel,PromptDesc,true);
        } 
    }
    
    
    validateSkills(event){
        //Clear selections 
        var buttonName = event.target.dataset.name;
        console.log(buttonName);
        this.validateMap = {};
            this.useridSet = [];
        let validateCount = 0;
        let rvalidateCount = 0;
        this.isRemoveValidate = false;
        let selectedRows = this.template.querySelectorAll('lightning-input[data-class="selectedcheckbox"]');
        for(let i = 0; i < selectedRows.length; i++) {
            console.log(selectedRows[i].getAttribute('data-validated'));
            let isValidated = (selectedRows[i].getAttribute('data-validated') === 'true');
            if(selectedRows[i].checked){
                if(!isValidated){
                    validateCount++;
                }else if(isValidated){
                    console.log(isValidated+'<<'+rvalidateCount);
                    rvalidateCount++;
                }
                //Collect userids for updating onboarding records
                this.useridSet.push(selectedRows[i].getAttribute('data-userid'));
                this.validateMap[selectedRows[i].getAttribute('data-id')] = selectedRows[i].checked;
            }
            
        }
        console.log(validateCount);
        
        if(buttonName =='Remove_Validate'){
            this.isRemoveValidate = true;
            this.recordsSubmitted = rvalidateCount;
            console.log(rvalidateCount+'>>');
            if(rvalidateCount == 0){
                this.openValidateModal(noskillSelected,selectSkillsInvalidate,false);
            }
            else{
                var PromptDesc = InvalidateCountLabel.replace("&n",rvalidateCount);
                this.openValidateModal(InvalidateHeaderLabel,PromptDesc,true);
            }
        }else{
            this.recordsSubmitted = validateCount;
            //Open Modals
            if(validateCount== 0){
                this.openValidateModal(noskillSelected,selectSkillsValidate,false);
            }
            else{
                var PromptDesc = validateCountLabel.replace("&n",validateCount);
                this.openValidateModal(validateHeaderLabel,PromptDesc,true);
            } 
        }
        
    }
    
    confirmSkillvalidate(){
        
        this.modalOpen = false;
        this.tableLoadingState = false;
        this.isSubmitButtonDisabled = true;
        this.disableValButton = true;
        this.disableRemoveValButton = true;
        var res = {};
            this.listViewDisabled = true;
        validateExpertiseRecords({recordsMap : this.validateMap,isRemoveValidate : this.isRemoveValidate})
            .then(result => {
                res =  JSON.parse(result);
                if(res.Success != null){
                    this.recordSuccessTracker = res.Success;
                    if(this.isRemoveValidate){
                        this.showSuccessToast('invalidate');
                    }
                    else{
                        this.showSuccessToast('validate');
                    }
                    //clear the selected users
                    const objChild = this.template.querySelector('c-lwc-multi-lookup');
                    objChild.clearSelected();
                    this.userSkillsByGroup(this.groupOptionValue);
                    this.clearSelections();
                    if(this.isRemoveValidate == true){
                        updatePAOnboardingRecord({userSet: null});
                    }else{
                        updatePAOnboardingRecord({userSet: this.useridSet});
                    }
                    
                    
                }
                else{
                    this.showFailureToast('Error',res.Error,'sticky');
                    this.userSkillsByGroup(this.groupOptionValue);
                }
                this.listViewDisabled = false;
            })
            .catch(error => { 
                console.log("error"+error);
                this.error = error; 
                this.tableLoadingState = true;
            });
    }
    
    
    confirmSkillDelete(){
        this.modalOpen = false;
        this.tableLoadingState = false;
        this.isSubmitButtonDisabled = true;
        this.listViewDisabled = true;
        
        
        console.log('calling delete skill ');
        var res = {};
            //invoke an Apex method to delete Skills from External object
            deleteRecords({ skillRecsToDelete: this.skillsListToDelete })
            .then(result => {
                
                res =  JSON.parse(result);
                console.log(res.Success+''+res.Error);
                if(res.Success != null){
                    console.log(res.Success);
                    this.recordSuccessTracker = res.Success;
                    
                    this.showSuccessToast('delete');
                    this.userSkillsByGroup(this.groupOptionValue);
                    this.clearSelections();
                    //now that we're complete udpate the PA Onboarding Record
                    updatePAOnboardingRecord({userSet: null});
                }
                else{
                    this.showFailureToast('Error',res.Error,'sticky');
                    this.userSkillsByGroup(this.groupOptionValue);
                }
            })
            .catch((error) => {
                console.log(error);
                this.tableLoadingState = true;
                
            }) 
            }
    
    clearSelections(){
        this.activityIdsForTracker = [];
        this.updateSelectAll();
        this.skillRatingChanged = false;
        this.isSubmitButtonDisabled = true;
        this.validateClmUpBool = false;
        this.validateClmDWBool = false;
        this.sortedDirection = null;
        this.showConfirmBatch =false;
        this.resetSortHeaders();
        this.recordSuccessTracker = 0;
    } 
    
    submit() {
        let allRecords = []; 
        let hasError = false;
        
        if(this.checkAspirationCount() == 'countError'){
            return;
        }
        
        allRecords.push(this.retrieveRecords());
        
        //start empApi listener on submit
        if(this.recordsSubmitted > 0){
            this.userSkills.forEach(skill =>{
                
                if(skill.aspirationSkill === true
                   && (skill.expertiseRating == undefined|| skill.expertiseRating == ''|| skill.expertiseRating == ' ')
                  ){
                      hasError = true;
                      
                  }
                
            });
            if(hasError){
                this.showFailureToast('Error','Aspirational skills are only applicable for skills with a rating of 1-3. Please adjust your selection accordingly.','dismissable');
                return;
            }
            this.tableLoadingState = false;
            this.isSubmitButtonDisabled = true;
            this.isDeleteButtonDisabled = true;
            this.disableValButton = true;
            this.disableRemoveValButton = true;
            this.listViewDisabled = true;
            this.handleSubscribe(false);
            submitRecords({ records: allRecords })
                .then(() => {
                    console.log('External job submitted');
                    this.clearSelections();
                })
                .catch((error) => {
                    console.log(error);
                    this.tableLoadingState = true;
                })
                } else {
                    this.openNoSkillsSelectedModal();
                }
    }
    
    checkAspirationCount(){
        let selectedRows = this.template.querySelectorAll('lightning-input[data-name="aspirationalskill"]');
        let aspCount = 0;
        for(let i = 0; i < selectedRows.length; i++) {
            console.log(selectedRows[i].checked+'MMMMM');
            if(selectedRows[i].checked){
                aspCount++;
            }
            console.log(selectedRows[i].getAttribute('data-rating'));
            
        }
        
        if(aspCount > 10){
            this.showFailureToast('Error',asplimitmsg,'dismissable');
            return 'countError';
            
        }
        
    }
    retrieveRecords() {	
        let rows = Array.from(this.template.querySelectorAll("tr.inputRows"));	
        let updatedRecs = {}
        let aspRows = {}
        let isaspChanged = false;
        
        let records = rows.map(row => {	
            let cells = Array.from(row.querySelectorAll("lightning-combobox[data-change='true']"));	
            let aspcells1 = Array.from(row.querySelectorAll("lightning-input[data-change='true']"));
            console.log(aspcells1+'logggg');
            if(aspcells1 != null && aspcells1.length>0){
                isaspChanged = true;    
            }
            return cells.reduce( (record, cell) => {	
                if(cell.dataset.id === ''){	
                    record.id = this.createUUID();	
                } else {	
                    record.id = cell.dataset.id;	
                }	
                record.ProfileSkill_c__c = cell.dataset.skill;	
                record.User_c__c = cell.dataset.user;	
                record.Expertise_Rating__c = cell.value;	
                //record.aspirationskillvalue = cell.dataset.aspiration;
                updatedRecs[record.id] = record;
                console.log(cell.dataset.aspiration+''+updatedRecs[record.id].Expertise_Rating__c);
                return record;	
            }, {})	
                
                
                }); 
        console.log(isaspChanged+'?????');        
        if(isaspChanged == true){
            let resultrecords = rows.map(row => { 
                
                let aspcells = Array.from(row.querySelectorAll("lightning-input[data-change='true']"));
                
                return aspcells.reduce( (record, cell) => { 
                    
                    if(cell.dataset.id === ''){ 
                        record.id = this.createUUID();  
                    } else {    
                        record.id = cell.dataset.id;    
                    } 
                    console.log(record.id+'>>>'+updatedRecs[record.id]); 
                    if(updatedRecs[record.id] == null || updatedRecs[record.id] == undefined){  
                        updatedRecs[record.id] = record;
                        aspRows[record.id] = record;
                        
                        record.ProfileSkill_c__c = cell.dataset.skill;  
                        record.User_c__c = cell.dataset.user;   
                        record.aspirationSkill = cell.checked;  
                        
                        return record; 
                    } 
                    else{
                        record = updatedRecs[record.id];
                        console.log('asp value'+cell.checked);
                        record.aspirationSkill = cell.checked;
                        aspRows[record.id] = record;
                        return record; 
                    }
                    
                }, {})  
                    
                    
                    });
            
            let filteredRecords = resultrecords.filter(value => Object.keys(value).length !== 0);
            let finalRecords = filteredRecords;
            let filteredRecords1 = records.filter(value => Object.keys(value).length !== 0);
            filteredRecords1.forEach(selUser =>{
                console.log(aspRows[selUser.id]+'map rec'+selUser.id);
                if(aspRows[selUser.id] == null || aspRows[selUser.id] == undefined){
                    
                    console.log('map rec1'+selUser.id);
                    finalRecords.push(selUser);
                }
            });	
            filteredRecords = filteredRecords.filter(obj => {
                return obj.Expertise_Rating__c != noneSkillRating;
            });
            this.recordsSubmitted = filteredRecords.length;
            return filteredRecords; 
        }
        let filteredRecords = records.filter(value => Object.keys(value).length !== 0);	
        filteredRecords = filteredRecords.filter(obj => {
            return obj.Expertise_Rating__c != noneSkillRating;
        });
        this.recordsSubmitted = filteredRecords.length;
        return filteredRecords;	
    }	
    
    sleeper(ms) {
        return function(x) {
            return new Promise(resolve => setTimeout(() => resolve(x), ms));
        };
            }
    
    checkForOtherValidInvalid(){
        this.anyInvalidRecs = false;
        this.anyvalidatedRecs = false;
        let selectedRows = this.template.querySelectorAll('lightning-input[data-class="selectedcheckbox"]');
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox' && selectedRows[i].checked  == true) {
                
                if(!this.anyvalidatedRecs){
                    this.anyvalidatedRecs = (selectedRows[i].getAttribute('data-validated') === 'true');
                }
                if(!this.anyInvalidRecs){
                    this.anyInvalidRecs  = (selectedRows[i].getAttribute('data-validated') === 'false');
                }
                
            }
        } 
        if(this.activityIdsForTracker.length > 0 ){
            console.log(this.anyInvalidRecs+'invalid');
            if(this.anyInvalidRecs == true){
                this.disableValButton = false;
            }else{
                this.disableValButton = true;
            }
            if(this.anyvalidatedRecs == true){
                this.disableRemoveValButton = false;
            }else{
                this.disableRemoveValButton = true;
            }
            
        }else{
            this.disableRemoveValButton = true;
            this.disableValButton = true;
        }        
    }
    
    sorttableData(event) {
        
        let colName = event ? event.target.name : undefined;
        if(colName){
            this.validateClmUpBool = false;
            this.validateClmDWBool = false;
            this.sortedHeader = colName;
            this.sortedDirection = ( this.sortedDirection === 'asc' ? 'desc' : 'asc' );
            let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
            if ( this.sortedDirection == 'asc' ){
                this.validateClmUpBool = true;
            }
            else{
                this.validateClmDWBool = true;
            }
            this.resetSortHeaders();
            switch (colName ) {
                case 'skillType':
                this.skillTypeSort =  true; 
                break;
                case 'skillCategory':
                this.skillCategorySort =  true;
                break;
                case 'skillName':
                this.skillNameSort =  true;
                break;
                case 'expertiseRating':
                this.expertiseRatingSort =  true;
                break;
                case 'expertiseCertified':
                this.expertiseCertifiedSort =  true;
                break;
                case 'skilllastupdate':
                this.SkillRatingLastUpdateSort =  true;
                break;
                case 'aspirationSkill':
                this.SkillAspSort =  true;
                break;
                
                default:
                this.skillTypeSort =  true; 
            }
            
            let table = JSON.parse(JSON.stringify(this.userSkills));
            
            console.log(JSON.stringify(event.currentTarget));
            table.sort((a,b) => 
                       {
                           console.log(a[ colName ]+'^^^^^'+colName);
                           if(colName == 'expertiseCertified' || colName == 'aspirationSkill'){  
                               
                               
                               return a[ colName ] == b[ colName ] ? 1 : ( a[ colName ] < b[ colName ] ? 1 * isReverse : -1 * isReverse);
                                   
                                   }
                           if(colName == 'skilllastupdate'){
                               if((a[ colName ] == '') || (a[ colName ] == undefined ) &&(a[ colName ] == b[ colName ])){
                                   return 1;
                               }
                               else if((a[ colName ] == '') || (a[ colName ] == undefined )){
                                   return 1 * isReverse;
                               }
                               else if(b[ colName ] =='' || b[ colName ] == undefined){
                                   return -1 * isReverse;
                               }
                               else{
                                   var da = new Date(a[ colName ]);
                                   var db = new Date(b[ colName ]);  
                                   if(da == db){
                                       return 1;
                                   }else{
                                       return (da > db) ? 1 * isReverse : -1 * isReverse;
                                   }
                               }
                               
                           }else  {  
                               //Check if the comparing value is blank
                               if(!a[ colName ]){
                                   return 1 * isReverse;
                                   
                               }
                               //Check if the compareTo value is blank
                               else if(!b[ colName ]){
                                   return -1 * isReverse;
                               }
                               else{
                                   //Check if a > b
                                   if(a[ colName ].toLowerCase()  > b[ colName ].toLowerCase() ) {
                                       return 1 * isReverse;
                                   }
                                   //Check if a < b
                                   else if(a[ colName ].toLowerCase() < b[ colName ].toLowerCase()){
                                       return -1 * isReverse;
                                   } 
                               }
                               return 0;
                           }
                       }
                      );
            this.userSkills = table;
        }
    }  
    
    resetSortHeaders(){
        this.skillTypeSort = false;
        this.skillCategorySort =  false;
        this.skillNameSort =  false;
        this.expertiseRatingSort =  false;
        this.expertiseCertifiedSort =  false;
        this.SkillRatingLastUpdateSort = false;
        this.SkillAspSort = false;
    }
    
    navigateToSkillRelatedListView(event) {
        this.rowskillId =  event.target.name;
        console.log(event.target.name+''+this.rowskillId);
        this.showLRpopup = true;
        
    }
    handleModalClosed(){
        this.showLRpopup = false;
        this.rowskillId = '';
    }
    filterListView(event){
        this.searchterm = event.target.value;
        console.log(this.searchField+'--'+this.searchterm);
        this.filterRecs(this.searchterm,this.searchField);
        //.filter( r => !this.filterAccountSizeValue || r.EO_Account_Size__c == this.filterAccountSizeValue);
    }
    filterRecs(searchterm,searchField){
        let results = [];
        if(searchterm != '' && searchterm != null){
            if(searchField == 'All'){
                results = this.onloaduserSkillList
                    .filter( r => ( r.skillName != null && this.displaySNameFld && r.skillName.toLowerCase().includes(searchterm.toLowerCase()) )|| ( r.expertiseRating != null && this.displaySkillRatingFld && r.expertiseRating.toLowerCase().includes(searchterm.toLowerCase())) 
                            || ( r.skillType != null && this.displayTypeFld && r.skillType.toLowerCase().includes(searchterm.toLowerCase())) ||  ( r.skillCategory != null && this.displayCatFld && r.skillCategory.toLowerCase().includes(searchterm.toLowerCase())));
                
            }else{
                let key1 = searchField;
                let value1 = searchterm.toLowerCase();
                results = this.onloaduserSkillList
                    .filter(function(e) {
                        return e[key1] != null && e[key1].toLowerCase().includes(value1);
                    });
                
            }
            this.userSkills = results;  
            if(this.selectedUserRecs != undefined && this.selectedUserRecs.length >0){
                console.log('here inside'+this.selectedUserRecs);
                let userresults = [];
                this.selectedUserRecs.forEach(selUser =>{
                    let found = results.filter(element => element.userId === selUser.recId);
                    userresults.push(...found);
                });
                this.userSkills = userresults;  
            }
        }else{
            
            if(this.selectedUserRecs != undefined && this.selectedUserRecs.length >0){
                let userresults = [];
                this.selectedUserRecs.forEach(selUser =>{
                    let found = this.onloaduserSkillList.filter(element => element.userId === selUser.recId);
                    userresults.push(...found);
                });
                this.userSkills = userresults;  
            }else{
                this.userSkills = this.onloaduserSkillList;
            }
        }
        
        if(this.userSkills && this.userSkills.length > 0){
            this.skillsCount = true;
        }
        else{
            this.skillsCount = false;
        }
        this.validateClmUpBool = false;
        this.validateClmDWBool = false;
    }
    handlefilterChange(event){
        
        this.searchField = event.target.value;
        console.log(this.searchField);
        this.filterRecs(this.searchterm,this.searchField);
    }
    
    get remainingSkillCount() {
        return (100 - this.userSkills.length);
    }
    get backgroundStyle() {
        return `position: relative; height: 46vh; background-position: center;background-size: cover;background-repeat: no-repeat;background-image:url(${SKILLS_bgImage})`;
    }
    
    get options() {
        return [
            { label: 'Type', value: 'Type' },
            { label: 'Category', value: 'Category' },
            { label: 'Skill Name', value: 'SkillName' },
            { label: 'Aspirational', value: 'Aspirational' },
            { label: 'Skill Rating', value: 'SkillRating' },
            { label: 'Skill Rating Last Update', value: 'SkillRatingLastUpdate' },
            { label: 'Validated', value: 'ExpertiseValidated' },
        ];
    }
    get selected() {
        return this._selected.length ? this._selected : 'none';
    }
    
    handleChange1(e) {
        this._selected = e.detail.value;
        console.log(this._selected+'___sel');
    }
    saveFieldSelection(){
        this.tableLoadingState = false;
        this.modalOpen = false;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.userId;
        fields[SKILLS_CLMNS.fieldApiName] = JSON.stringify(this._selected);
        const recordInput = {fields};
            
        updateRecord(recordInput).then((record) => {
            this.modalOpen = false;
            this.modalBodyTableFields = false;
            this.tableLoadingState = true;
            this.displayTypeFld = false;
            this.displayCatFld = false;
            this.displaySNameFld = false;
            this.displayAspFld = false;
            this.displaySkillRatingFld = false;
            this.displaySLastUpdateFld = false;
            this.displayEVFld = false;
            this.setClmnsVisibility(this._selected);
            console.log(record);
        });
        //updateRecord(recordInput);
    }
    handleFieldSelection(event){
        this.modalHeaderH2Text = '';
        this.modalBodyH2Text = '';
        this.modalBodyText = '';
        this.modalBodySkillRatingText = false;
        this.modalOpen = true;
        this.showConfirmButtonDisabled = false;
        this.showValidateContinue = false;
        this.modalBodyTableFields = true;
    }
    fetchAspSkills(skillsList){
        this.aspSkillStr = '';
        for(let i = 0; i < skillsList.length; i++) {
            if(skillsList[i].aspirationSkill){
                this.aspSkillStr = this.aspSkillStr + skillsList[i].skillName+', ';
            }
        }
        this.aspSkillStr = this.aspSkillStr.slice(0, -2) ;
        const selectedEvent = new CustomEvent("aspvaluechange", {
            detail: this.aspSkillStr });
        
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        
    }
    
    
    @api
    handleCSGGrpChange(groupOptionValue){
        console.log(groupOptionValue);
        this.groupOptionValue = groupOptionValue;
        this.tableLoadingState = false
        this.userSkillsByGroup(groupOptionValue,null);
        this.setshowCheckBox();
        
        
    }
}