/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used for updating the skills details for a particular team member.
 ****************************/

 import { LightningElement, wire, api } from 'lwc';
 import { NavigationMixin } from 'lightning/navigation';
 import Id from '@salesforce/user/Id';
 import getTeamMemberSkillSet from '@salesforce/apex/GDC_MS_SkillsUpdateFormController.getTeamMemberSkillSet';
 import salesforceCerti from '@salesforce/schema/gdc_ms_TeamMember__c.gdc_ms_SalesforceCertifications__c';
 import skillsHighlights from '@salesforce/schema/gdc_ms_TeamMember__c.gdc_ms_SkillHighlights__c';
 import summary from '@salesforce/schema/gdc_ms_TeamMember__c.gdc_ms_Summary__c';
 import verticalExpertise from '@salesforce/schema/gdc_ms_TeamMember__c.gdc_ms_VerticalExpertise__c';
 import customerCredentials from '@salesforce/schema/gdc_ms_TeamMember__c.gdc_ms_Customer_Credentials__c'; //Adwait
 import Team_Member from '@salesforce/schema/gdc_ms_TeamMember__c';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import MyBioErrorMsg from '@salesforce/label/c.gdcmsMyBioErrorMsg';

 export default class GdcmsSkillsUpdateForm extends NavigationMixin(LightningElement) {


     userId = Id;
     teamMemberName;
     @api sC = salesforceCerti;
     @api summ = summary;
     @api vE = verticalExpertise;
     @api sH = skillsHighlights;
     @api cC = customerCredentials;

     // Flexipage provides recordId and objectApiName
     @api recordId;
     @api file;
     @api objectApiName = Team_Member;
     loaded = false;
     @wire(getTeamMemberSkillSet, { userId: '$userId' })
     skillset({ data, error }) {
         if (data) {
             console.log(data);
             error = undefined;
             this.recordId = data.teamMemberId;
             this.teamMemberName = data.teamMemberName;
             this.loaded = true;
         }
         if (error) {
             this.loaded = true;
             console.log(error);
         }

     }

     get teamMemberName() {
         return this.teamMemberName;
     }

     get message() {
         if (this.loaded) {
             if (this.teamMemberName) return `Hello ${this.teamMemberName}, please help us keep your bio updated.`;
             //else return 'Hi, It looks like you’re not a part of GDC. Please drop an email to csg-gdc-microsite-feedback@salesforce.com in case you are a part of GDC and still seeing this message.'
             else return MyBioErrorMsg;
         }
         else return '';
     }

     handleSuccess() {
         const evt = new ShowToastEvent({
             title: 'Update Successfull',
             message: 'Your Bio has been updated. Thank You.',
             variant: 'success',
         });
         this.dispatchEvent(evt);
     }
 }