import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import id from '@salesforce/user/Id';
import getRecordDetials from '@salesforce/apex/GDCMS_NominationScreenController.getRecordDetials';
import getTeamMemberId from '@salesforce/apex/GDCMS_NominationScreenController.getTeamMemberId';
import getTeamMembers from '@salesforce/apex/GDCMS_NominationScreenController.getTeamMembers';

import Engagement_Name from '@salesforce/schema/gdc_ms_Engagement__c.Name';
import Engagement_Title from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_EngagementTitle__c';
import Engagement_Summary from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_EngagementSummary__c';
import Solution_Complexity from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_SolutionComplexity__c';
import Business_Value_Delivered from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_BusinessValueDelivered__c';
import Feedback from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_Feedback__c';
import Company_Logo from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_CompanyLogo__c';
import Complexity from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_Complexity__c';
import Geographies from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_Geographies__c';
import Industry from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_Industry__c';
import Is_Visible_on_Carousel from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_Is_Visible_on_Carousel__c';
import Carousel_Image_Link from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_Carousel_Image_Link__c';
import Display_on_Success_Stories from '@salesforce/schema/gdc_ms_Engagement__c.gdc_ms_DisplayonSuccessStories__c';

import Team_Member from '@salesforce/schema/gdc_ms_Success_Story_Members__c.gdc_ms_Team_Member__c';
import Success_Stories from '@salesforce/schema/gdc_ms_Success_Story_Members__c.gdc_ms_Success_Stories__c';
import Roles from '@salesforce/schema/gdc_ms_Success_Story_Members__c.gdc_ms_Role__c';

const actions = [
    { label: 'View', name: 'show_details' },
    { label: 'Edit', name: 'edit_details' },
];

const columns_trailblazer = [
    { label: 'Nominee', fieldName: 'gdc_ms_Nominee__c' },
    { label: 'Quarter', fieldName: 'gdc_ms_Quarter__c', },
    { label: 'Year', fieldName: 'gdc_ms_Year__c' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

const columns_customer = [
    { label: 'Success Team', fieldName: 'gdc_ms_SuccessTeamName__c' },
    { label: 'Quarter', fieldName: 'gdc_ms_Quarter__c', },
    { label: 'Year', fieldName: 'gdc_ms_Year__c' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class GdcmsNominationsWizardDirectors extends LightningElement {
    @track selectedItem = 'trailblazer_nomination';

    trailblazerRecords = [];
    customerSuccessRecords = [];
    columns_Trailblazer = columns_trailblazer;
    columns_CustomerSuccess = columns_customer;

    trailblazerNomination_readOnly = false;
    trailblazerNomination_Id = '';
    customerSuccessNomination_readOnly = false;
    CustomerSuccessNomination_Id = '';

    UserId = id;
    soqlFilter = 'gdc_ms_Manager__r.gdc_ms_MappedUser__c = ' + "'" + id + "'";

    diableCSS = "";

    trailblazerNomination = false;
    CustomerSuccessNomination = false;
    AchiverNomination = false;

    teamMemberId = '';
    trailblazerNomination_newCreations = false;
    displayTrailblazerTable = false;
    displayCustomerTable = false;
    CustomerSuccess_newCreations = false;

    uploadImage = false;
    addSuccessStories=false;
    addTeamMembers = false;
    objectApiName='gdc_ms_Engagement__c';
    teamMemberObj = 'gdc_ms_Success_Story_Members__c';
    fields = [Engagement_Name,Engagement_Title,Engagement_Summary,Solution_Complexity,Business_Value_Delivered,Feedback,Company_Logo,Complexity,Geographies,Is_Visible_on_Carousel,Industry,Carousel_Image_Link,Display_on_Success_Stories];
    teamMemberFields = [Team_Member,Roles,Success_Stories];

    error;
    teamMemberList ;

   columns = [
        { label: 'Team Member', fieldName: 'gdc_ms_Team_Member__r.Name', type:'text' },
        { label: 'Success Stories', fieldName: 'gdc_ms_Success_Stories__r.Name', type: 'text' },
        { label: 'Role', fieldName: 'gdc_ms_Role__c', type: 'text' },
    ];

    handleReset_Trailblazer() {
        this.displayTrailblazerTable = true;
        this.trailblazerNomination_newCreations = false;
        this.trailblazerNomination_readOnly = false;
    }

    handleReset_Customer() {
        this.displayCustomerTable = true;
        this.CustomerSuccess_newCreations = false;
        this.customerSuccessNomination_readOnly = false;
    }


    handleSelect(event) {
        const selected = event.detail.name;

        if (selected === 'trailblazer_nomination') {
            this.trailblazerNomination = true;
            this.CustomerSuccessNomination = false;
            this.AchiverNomination = false;
        } else if (selected === 'customer_success_team_nomination') {
            this.trailblazerNomination = false;
            this.CustomerSuccessNomination = true;
            this.AchiverNomination = false;
        } else if (selected === 'achiever_nomination') {
            this.trailblazerNomination = false;
            this.CustomerSuccessNomination = false;
            this.AchiverNomination = true;
        }

        this.currentContent = selected;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'show_details':
                this.trailblazerNomination_Id = row.Id;
                this.trailblazerNomination_readOnly = true;
                this.displayTrailblazerTable = false;
                break;
            case 'edit_details':
                this.trailblazerNomination_Id = row.Id;
                this.trailblazerNomination_newCreations = true;
                this.displayTrailblazerTable = false;
                break;
            default:
        }
    }

    handleRowAction_customerSuccess(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const rowDetails = JSON.parse(JSON.stringify(row));
        switch (actionName) {
            case 'show_details':
                this.CustomerSuccessNomination_Id = row.Id;
                this.customerSuccessNomination_readOnly = true;
                this.displayCustomerTable = false;
                break;
            case 'edit_details':
                this.CustomerSuccessNomination_Id = row.Id;
                this.CustomerSuccess_newCreations = true;
                this.displayCustomerTable = false;
                break;
            default:
        }
        this.showDataTable(rowDetails.gdc_ms_SuccessTeamName__r.Id);
    }

    handleNewTrailBlazer() {
        this.displayTrailblazerTable = false;
        this.trailblazerNomination_newCreations = true;
    }

    handleNewCustomerSuccess() {
        this.displayCustomerTable = false;
        this.CustomerSuccess_newCreations = true;

    }

    async connectedCallback() {
        this.getRecords();
        this.displayTrailblazerTable = true;
        this.displayCustomerTable = true;
        const recordDetails = await getTeamMemberId();
        console.log('User Id Team Id   :::: ' + recordDetails);
        if (recordDetails != undefined) {
            this.teamMemberId = recordDetails;
        }
    }

    getRecords() {
        getRecordDetials()
            .then(result => {
                if (result !== undefined && result.length > 0) {
                    result.forEach(element => {
                        if (element.gdc_ms_AwardCategory__c === 'Trailblazer Award') {
                            console.log(element);
                            if (element.gdc_ms_Nominee__c && element.gdc_ms_Nominee__r.Name) {
                                element.gdc_ms_Nominee__c = element.gdc_ms_Nominee__r.Name;
                            }
                            this.trailblazerRecords.push(element);
                        } else if (element.gdc_ms_AwardCategory__c === 'Customer Success Team Award') {
                            this.showDataTable(element.gdc_ms_SuccessTeamName__c);
                            if (element.gdc_ms_SuccessTeamName__c && element.gdc_ms_SuccessTeamName__r.Name) {
                                element.gdc_ms_SuccessTeamName__c = element.gdc_ms_SuccessTeamName__r.Name;
                            }
                            this.customerSuccessRecords.push(element);
                        }
                    });

                    if (this.trailblazerRecords && this.trailblazerRecords.length > 0) {
                        this.displayTrailblazerTable = true;
                    }

                    if (this.customerSuccessRecords && this.customerSuccessRecords.length > 0) {
                        this.displayCustomerTable = true;
                    }
                } else {
                    console.log(error);
                    this.showToast('Error', 'The Nominations are not yet started. Please wait for the further communicnation.', 'error');
                    this.diableCSS = "disabledScreen";
                }
            }).catch(error => {
                console.log('Error on callback :::: ' + error);
            });
    }
    enableEdit_Trailblazer() {
        this.trailblazerNomination_newCreations = true;
        this.trailblazerNomination_readOnly = false;
    }
    enableEdit_Customer() {
        this.CustomerSuccess_newCreations = true;
        this.customerSuccessNomination_readOnly = false;
    }

    handleSuccess_Trailblazer(event) {
        this.trailblazerNomination_newCreations = false;
        this.trailblazerNomination_Id = event.detail.id;
        this.trailblazerNomination_readOnly = true;
        this.displayToast('trailblazer');
    }
    async handleBackTrailBlazer() {
        window.location.reload();
    }

    handleSuccess_CustomerSuccess(event) {
        this.CustomerSuccess_newCreations = false;
        this.CustomerSuccessNomination_Id = event.detail.id;
        this.customerSuccessNomination_readOnly = true;
        this.displayToast('customer');
    }

    handleSuccess_Achievers(event) {
        this.displayToast('achievers');
        let baseurl = window.location.origin + '/gdcIndia/s/rewards-and-recognition-';
        window.location = baseurl;
    }

    displayToast(type) {
        if ((type == 'trailblazer' && this.trailblazerNomination_Id) || (type == 'customer' && this.CustomerSuccessNomination_Id)) {
            this.showToast('Success', 'The record has been Updated...!', 'success');
        } else if (type) {
            this.showToast('Success', 'The record has been Created...!', 'success');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    handleUploadImagePopup(event) {
        this.uploadImage = !this.uploadImage;
        event.stopPropagation();
    }
    handleSuccessStories(){
        this.addSuccessStories = !this.addSuccessStories;
    }
    handleAddTeamMembers(){
        this.addTeamMembers = !this.addTeamMembers;
    }
    handleCreateSuccessStories(event){
        this.addSuccessStories = !this.addSuccessStories;
        this.showDataTable(event.detail.id);
        this.showToast('Success', 'The success story has been Created...!', 'success');
    }
    handleAddSuccessStoryMembers(event){
        this.addTeamMembers = !this.addTeamMembers;
        this.showDataTable(event.detail.fields.gdc_ms_Success_Stories__c.value);
        this.showToast('Success', 'The success story has been Created...!', 'success');
    }
    handleSubmit(event){
        const successStory = JSON.parse(JSON.stringify(event.detail.fields));
        this.showDataTable(successStory.gdc_ms_SuccessTeamName__c);
    }
    showDataTable( successStoryRecId){
        getTeamMembers({ successStoryId: successStoryRecId })
            .then((data) => {
                //this.teamMemberList = data;
                this.teamMemberList =  data.map(record => Object.assign(
                      { "gdc_ms_Success_Stories__r.Name": record.gdc_ms_Success_Stories__r.Name, "gdc_ms_Team_Member__r.Name": record.gdc_ms_Team_Member__r.Name},record
                      ));
            })
            .catch((error) => {
                this.error = error;
            });
    }
}