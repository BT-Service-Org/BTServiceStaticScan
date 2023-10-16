import { LightningElement, track, wire } from 'lwc';
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

const PLACEHOLDER_TEXT = {
    DriveGDCGoalsAsPerVision: 'Anurag worked on the HDFC POC and contributed immensely on winning the Services deal. He continued the success and lead E2E delivery from GDC with a fantastic CSAT from Customer.',
    TeamPlayerRecognisedMentor: 'Anurag who is a TC was able to mentor and train the new joiners in the project on various core capabilities(Integration, Data Migration, E2E functionality). He was also able to lead the entire scrum team in the absence of project lead and execute sprint goals in a smooth manner.Deserves great credit for the work he has done, notably setting up the CI / CD process and building the technical frameworks - laying a strong foundation for the development work that followed.',
    MeasurableContributionToGDC: '- Was a leader on the initiative, driving execution within the team and with the larger GDC team, ensuring successful outcomes were met \n - Were key pillars for the success of the initiative and cannot imagine anyone else in this role due to their creativity, resourcefulness and being able to get it done',
    DemonstrateWinAsTeamCharacteristic_Team: 'Arkansas team has delivered an implementation worthy of being a Salesforce success story.The key differentiators for our continued success throughout this engagement have been leading with a transformation mindset using OOTB and close alignment between Sales and Services teams. We presented as One Salesforce team and trusted advisors. This allowed us to build trust with the client and create a sense of shared ownership early on leading to high performance and high satisfaction. Kudos to the entire GDC team on the success!',
    CustomerAppreciationHighCSATScore: 'Outstanding CSAT 5/5 rating for the *GDC Greenthumb team.* Greenthumb was an account where a prior implementation had gone wrong and left an unhappy customer. The GDC Greenthumb not only reversed and implemented the right way to ensure Customer Success! It was well led by TA, and complemented by STC and our ATC (Futureforce).\n"In words of the *Customer Product Owner* “Fantastic professional service at all stages, again Akash and his remote team where absolutely fantastic, Adil also kept us well informed of everything. Thanks again for all of your time and effort."',
    ProjectComplexityValueDelivered: 'Dixons was one of first Multi-cloud implementation in EMEA with SFCC, SOM, SFMC, SFSC, Identity Cloud .Phase 1 included 2 Brand sites rollout (uhchearing.com (http://uhchearing.com/) & AARP).',
    CustomerGeoFeedback: 'Vijay is Technically strong for his years of experience. He has picked up some complex integrations, document generation and implemented it end to end. Helped migrate and enhance frameworks. Ensures he demoes all the features and seeks immediate feedback.\nBrought incredible experience and diplomacy to the project, he shared solutions which we hadn’t thought about and ran with POC’s to support these solutions and ensured we were all take on the journey with him!',
    PersonalAchievements: 'Vijay is on-track on his Integration Architect journey, and also a mentor other Consultant on Integration Journey. He is one of the Subject Matter Experts in Lightning Web Components and additionally completed 60 hours of VTO, including two PRO Bono projects.',
    DemonstrateWinAsTeamCharacteristic_Ind: 'As Salesforce Quote says “It takes an entire village to get this level execution in Bajaj. With stringent timelines & cross collaboration with Tableau & function team , it wasn’t not an easy task.The key differentiators for our continued success throughout this engagement have been leading with a transformation mindset using OOTB and close alignment between Sales and Services teams. We presented as One Salesforce team and trusted advisors.'
}


export default class GdcmsNominationsWizard extends LightningElement {
    @track selectedItem = 'trailblazer_nomination';

    trailblazerNomination_readOnly = false;
    trailblazerNomination_Id = '';
    customerSuccessNomination_readOnly = false;
    CustomerSuccessNomination_Id = '';

    UserId = id;
    soqlFilter = 'gdc_ms_Manager__r.gdc_ms_MappedUser__c = ' + "'" + id + "'";

    placeholderText = PLACEHOLDER_TEXT;

    diableCSS = "";

    trailblazerNomination = false;
    CustomerSuccessNomination = false;
    AchiverNomination = false;

    teamMemberId = '';
    uploadImage = false;
    addSuccessStories=false;
    addTeamMembers = false;
    objectApiName='gdc_ms_Engagement__c';
    teamMemberObj = 'gdc_ms_Success_Story_Members__c';
    fields = [Engagement_Name,Engagement_Title,Engagement_Summary,Solution_Complexity,Business_Value_Delivered,Feedback,Company_Logo,Complexity,Geographies,Is_Visible_on_Carousel,Industry,Carousel_Image_Link,Display_on_Success_Stories];
    teamMemberFields = [Team_Member,Roles,Success_Stories];
    successStoriesRecordId = null;
    error;
    teamMemberList ;
   columns = [
        { label: 'Team Member', fieldName: 'gdc_ms_Team_Member__r.Name', type:'text' },
        { label: 'Success Stories', fieldName: 'gdc_ms_Success_Stories__r.Name', type: 'text' },
        { label: 'Role', fieldName: 'gdc_ms_Role__c', type: 'text' },
    ];

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

    async connectedCallback() {
        getRecordDetials()
            .then(result => {
                if (result !== undefined && result.length > 0) {
                    result.forEach(element => {
                        if (element.gdc_ms_AwardCategory__c === 'Trailblazer Award') {
                            this.trailblazerNomination_Id = element.Id;
                            this.trailblazerNomination_readOnly = true;
                        } else if (element.gdc_ms_AwardCategory__c === 'Customer Success Team Award') {
                            this.CustomerSuccessNomination_Id = element.Id;
                            this.customerSuccessNomination_readOnly = true;
                            this.showDataTable(element.gdc_ms_SuccessTeamName__c);
                        }
                    });
                } else {
                    console.log(error);
                    this.showToast('Error', 'The Nominations are not yet started. Please wait for the further communicnation.', 'error');
                    this.diableCSS = "disabledScreen";
                }
            }).catch(error => {
                console.log('Error on callback :::: ' + error);
            });



        const recordDetails = await getTeamMemberId();
        console.log('User Id Team Id   :::: ' + recordDetails);
        if (recordDetails != undefined) {
            this.teamMemberId = recordDetails;
        }
    }

    enableEdit_Trailblazer() {
        this.trailblazerNomination_readOnly = false;
    }
    enableEdit_Customer() {
        this.customerSuccessNomination_readOnly = false;
    }

    handleSuccess_Trailblazer(event) {
        this.trailblazerNomination_Id = event.detail.id;
        this.trailblazerNomination_readOnly = true;
        this.displayToast('trailblazer');
    }

    handleSuccess_CustomerSuccess(event) {
        this.CustomerSuccessNomination_Id = event.detail.id;
        this.customerSuccessNomination_readOnly = true;
        this.displayToast('customer');
    }
    handleSubmit(event){
        const successStory = JSON.parse(JSON.stringify(event.detail.fields));
        this.showDataTable(successStory.gdc_ms_SuccessTeamName__c);
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
        event.stopPropagation()
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
        this.showToast('Success', 'The team member has been added...!', 'success');
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