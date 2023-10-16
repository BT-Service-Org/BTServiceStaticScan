import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import id from '@salesforce/user/Id';
import saveNominationRecord from '@salesforce/apex/GDCMS_NominationScreenController.saveNominationRecord';
import getRecordAchevierDetials from '@salesforce/apex/GDCMS_NominationScreenController.getRecordAchevierDetials'


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

export default class GdcmsNominationScreen extends LightningElement {
    @api recordId;
    isEdit = false;

    UserId = id;
    soqlFilter = 'gdc_ms_Manager__r.gdc_ms_MappedUser__c = ' + "'" + id + "'";

    placeholderText = PLACEHOLDER_TEXT;

    achiverAward = {};
    nominee = '';
    nomineeId = '';
    recordsData = [];


    savedRecordId;


    connectedCallback() {
        if (this.recordId !== undefined) {
            console.log('Record ID ::::: ' + this.recordId);
            getRecordAchevierDetials({recordId : this.recordId})
            .then(result => {
                this.achiverAward = result;
                this.isEdit = true;
                this.nominee = result.gdc_ms_Nominee__r.Name;
                this.nomineeId = result.gdc_ms_Nominee__c;
                console.log('Achiever Award ::: ' + JSON.stringify(this.achiverAward));

            })
        }
    }

    handleNomineeSelection(event) {
        console.log("the selected record id is" + event.detail);
        this.nomineeId = event.detail;
    }

    async handleSave(event) {
        let gdc_ms_CustomerGeoFeedback__c = '';
        let gdc_ms_PersonalAchievements__c = '';
        let gdc_ms_WinAsTeamCharacteristic__c = '';

        const inputFields = this.template.querySelectorAll(
            '.nominationData'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.name === 'CustomerGeoFeedback') {
                    gdc_ms_CustomerGeoFeedback__c = field.value;
                } else if (field.name === 'PersonalAchievements') {
                    gdc_ms_PersonalAchievements__c = field.value;
                } else if (field.name === 'DemonstrateWinAsTeamCharacteristic') {
                    gdc_ms_WinAsTeamCharacteristic__c = field.value;
                }
            });
        }

        if (this.isEdit === true) {
            const inputFields = this.template.querySelectorAll(
                '.nominationUpdateData'
            );
            if (inputFields) {
                inputFields.forEach(field => {
                    if (field.name === 'CustomerGeoFeedback') {
                        gdc_ms_CustomerGeoFeedback__c = field.value;
                    } else if (field.name === 'PersonalAchievements') {
                        gdc_ms_PersonalAchievements__c = field.value;
                    } else if (field.name === 'DemonstrateWinAsTeamCharacteristic') {
                        gdc_ms_WinAsTeamCharacteristic__c = field.value;
                    }
                });
            }
        }

        this.achiverAward.gdc_ms_CustomerGeoFeedback__c = gdc_ms_CustomerGeoFeedback__c;
        this.achiverAward.gdc_ms_PersonalAchievements__c = gdc_ms_PersonalAchievements__c;
        this.achiverAward.gdc_ms_WinAsTeamCharacteristic__c = gdc_ms_WinAsTeamCharacteristic__c;
        this.achiverAward.gdc_ms_AwardCategory__c = 'Achievers Award';
        this.achiverAward.gdc_ms_Nominee__c = this.nomineeId;

        let missingFields = await this.checkMissingFields();


        if (missingFields.length > 0) {
            this.showToast('Error', 'Please complete all the mandatory fields to create a nomination', 'error');
        } else {
            saveNominationRecord({ nomination: this.achiverAward })
                .then(result => {
                    if (result !== undefined) {
                        console.log(result);

                        if (result.startsWith("Created")) {
                            this.showToast('Success', 'The record has been Created...!', 'success');
                            const myTimeout = setTimeout(reload => {location.reload();}, 1000);
                        } else if (result.startsWith("Updated")){
                            this.showToast('Success', 'The record has been Updated...!', 'success');
                            const myTimeout = setTimeout(reload => {location.reload();}, 1000);
                        } else {
                            this.showToast('Error', result, 'error');
                        }
                    }
                }).catch(error => {
                    console.log(error);
                });
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

    async checkMissingFields() {
        let missingFields = [];
        if (this.nomineeId === '' || this.nomineeId === undefined) {
            missingFields.push('Nominee');
        }

        if (this.achiverAward.gdc_ms_CustomerGeoFeedback__c === '' || this.achiverAward.gdc_ms_CustomerGeoFeedback__c === undefined) {
            missingFields.push('Customer/ Geo feedback');
        }

        if (this.achiverAward.gdc_ms_WinAsTeamCharacteristic__c === '' || this.achiverAward.gdc_ms_WinAsTeamCharacteristic__c === undefined) {
            missingFields.push('Demonstrate Win as a team characteristic');
        }

        console.log('Missing fields ::' + JSON.stringify(missingFields));

        return missingFields;
    }
}