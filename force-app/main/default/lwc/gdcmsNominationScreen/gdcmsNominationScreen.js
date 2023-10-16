import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import id from '@salesforce/user/Id';
import getCurrentQuarter from '@salesforce/apex/GDCMS_NominationScreenController.getCurrentQuarter'
import getRecordDetials from '@salesforce/apex/GDCMS_NominationScreenController.getRecordDetials';
import saveNominationRecord from '@salesforce/apex/GDCMS_NominationScreenController.saveNominationRecord';

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
    UserId = id;
    soqlFilter = 'gdc_ms_Manager__r.gdc_ms_MappedUser__c = ' + "'" + id + "'";

    placeholderText = PLACEHOLDER_TEXT;

    customersuccessAward = {};
    trailblazerAward = {};
    taNominee = '';
    csaNominee = '';
    taNomineeId = '';
    csaNomineeId = '';
    recordsData = [];
    dates = {};
    diableCSS = "";

    uploadImage = false;

    async connectedCallback() {
        getRecordDetials()
            .then(result => {
                if (result !== undefined && result.length > 0) {
                    result.forEach(element => {
                        if (element.gdc_ms_AwardCategory__c === 'Trailblazer Award') {
                            console.log('Data ::::: ' + JSON.stringify(element));
                            this.trailblazerAward = element;
                            if (element.gdc_ms_Nominee__c !== undefined) {
                                this.taNominee = element.gdc_ms_Nominee__r.Name;
                                this.taNomineeId = element.gdc_ms_Nominee__c;
                            }
                        } else if (element.gdc_ms_AwardCategory__c === 'Customer Success Team Award') {
                            this.customersuccessAward = element;
                            console.log('Data ::::: ' + JSON.stringify(element));
                            if (element.gdc_ms_SuccessTeamName__c !== undefined) {
                                this.csaNominee = element.gdc_ms_SuccessTeamName__r.Name;
                                this.csaNomineeId = element.gdc_ms_SuccessTeamName__c;
                            }
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



        const recordDetails = await getCurrentQuarter();
        console.log('undefined   :::: ' + recordDetails);
        if (recordDetails != undefined) {
            this.dates = recordDetails;
        } else {
            this.showToast('Error', 'The Nominations are not yet started. Please wait for the further communicnation.', 'error');
        }
    }

    handleNomineeSelection_CSA(event) {
        console.log("the selected record id is" + event.detail);
        this.csaNomineeId = event.detail;
    }

    handleNomineeSelection_TA(event) {
        console.log("the selected record id is" + event.detail);
        this.taNomineeId = event.detail;
    }

    handleCompnayImage() {
        this.uploadImage = !this.uploadImage;
    }

    handleCompnayImage() {
        this.uploadImage = !this.uploadImage;
    }

    handleSave(event) {


        console.log(event.target.name);
        let selectedButton = event.target.name;
        if (selectedButton === 'taSave') {
            this.handleTASave();
        } else if (selectedButton === 'csaSave') {
            this.handleCSASave();
        }
    }

    async handleTASave() {
        let gdc_ms_DriveGDCGoalsAsPerVision__c = '';
        let gdc_ms_TeamPlayerRecognisedMentor__c = '';
        let gdc_ms_MeasurableContributionToGDC__c = '';


        const inputFields = this.template.querySelectorAll(
            '.nominationTAData'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.name === 'DriveGDCGoalsAsPerVision') {
                    gdc_ms_DriveGDCGoalsAsPerVision__c = field.value;
                } else if (field.name === 'TeamPlayerRecognisedMentor') {
                    gdc_ms_TeamPlayerRecognisedMentor__c = field.value;
                } else if (field.name === 'MeasurableContributionToGDC') {
                    gdc_ms_MeasurableContributionToGDC__c = field.value;
                } else if (field.nodeName === 'LIGHTNING-INPUT-FIELD') {
                    this.taNomineeId = field.value;
                }
            });
        }

        this.trailblazerAward.gdc_ms_DriveGDCGoalsAsPerVision__c = gdc_ms_DriveGDCGoalsAsPerVision__c;
        this.trailblazerAward.gdc_ms_TeamPlayerRecognisedMentor__c = gdc_ms_TeamPlayerRecognisedMentor__c;
        this.trailblazerAward.gdc_ms_MeasurableContributionToGDC__c = gdc_ms_MeasurableContributionToGDC__c;
        this.trailblazerAward.gdc_ms_AwardCategory__c = 'Trailblazer Award';
        this.trailblazerAward.gdc_ms_Nominee__c = this.taNomineeId;


        let missingFields = await this.checkMissingFieldsTA();

        let saveRecord = await this.confirmMissingFields(missingFields);

        if (saveRecord === true) {
            saveNominationRecord({ nomination: this.trailblazerAward })
                .then(result => {
                    if (result !== undefined) {
                        console.log(result);

                        if (result.startsWith("Created")) {
                            this.showToast('Success', 'The record has been Created...!', 'success');
                            this.trailblazerAward.Id = result.split(',')[1];
                        } else if (result.startsWith("Updated")){
                            this.showToast('Success', 'The record has been Updated...!', 'success');
                        } else {
                            this.showToast('Error', result, 'error');
                        }
                    }
                }).catch(error => {
                    console.log(error);
                });
        }
    }

    async handleCSASave() {
        let gdc_ms_WinAsTeamCharacteristic__c = '';
        let gdc_ms_CustomerAppreciationHighCSATScore__c = '';
        let gdc_ms_ProjectComplexityValueDelivered__c = '';
        //let gdc_ms_TeamName__c = '';
        let gdc_ms_TeamOwner__c = '';
        let gdc_ms_TeamSize__c = '';
        const inputFields = this.template.querySelectorAll(
            '.nominationCSAData'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.name === 'DemonstrateWinAsTeamCharacteristic_Team') {
                    gdc_ms_WinAsTeamCharacteristic__c = field.value;
                } else if (field.name === 'CustomerAppreciationHighCSATScore') {
                    gdc_ms_CustomerAppreciationHighCSATScore__c = field.value;
                } else if (field.name === 'ProjectComplexityValueDelivered') {
                    gdc_ms_ProjectComplexityValueDelivered__c = field.value;
                } /*else if (field.name === 'TeamName') {
                    gdc_ms_TeamName__c = field.value;
                }*/ else if (field.name === 'TeamOwner') {
                    gdc_ms_TeamOwner__c = field.value;
                } else if (field.name === 'TeamSize') {
                    gdc_ms_TeamSize__c = field.value;
                } else if (field.nodeName === 'LIGHTNING-INPUT-FIELD') {
                    this.csaNomineeId = field.value;
                }
            });
        }

        this.customersuccessAward.gdc_ms_WinAsTeamCharacteristic__c = gdc_ms_WinAsTeamCharacteristic__c;
        this.customersuccessAward.gdc_ms_CustomerAppreciationHighCSATScore__c = gdc_ms_CustomerAppreciationHighCSATScore__c;
        this.customersuccessAward.gdc_ms_ProjectComplexityValueDelivered__c = gdc_ms_ProjectComplexityValueDelivered__c;
        //this.customersuccessAward.gdc_ms_TeamName__c = gdc_ms_TeamName__c;
        this.customersuccessAward.gdc_ms_TeamOwner__c = gdc_ms_TeamOwner__c;
        this.customersuccessAward.gdc_ms_TeamSize__c = gdc_ms_TeamSize__c;
        this.customersuccessAward.gdc_ms_AwardCategory__c = 'Customer Success Team Award';
        this.customersuccessAward.gdc_ms_SuccessTeamName__c = this.csaNomineeId;

        let missingFields = await this.checkMissingFieldsCSA();

        let saveRecord = await this.confirmMissingFields(missingFields);

        if (saveRecord) {
            saveNominationRecord({ nomination: this.customersuccessAward })
                .then(result => {
                    if (result !== undefined) {
                        console.log(result);

                        if (result.startsWith("Created")) {
                            this.showToast('Success', 'The record has been Created...!', 'success');
                            this.customersuccessAward.Id = result.split(',')[1];
                        } else if (result.startsWith("Updated")){
                            this.showToast('Success', 'The record has been Updated...!', 'success');
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

    async confirmMissingFields(missingFields) {
        if (missingFields.length > 0) {
            const confirmResult = await LightningConfirm.open({
                message: 'The following fields are missing : ' + missingFields.join(" , ") + ' If the required fields are not filled before the end date they will be considered as invalid for the nomination.',
                variant: 'header',
                theme: 'warning',
                label: 'Missing Fields !'
            });

            if (confirmResult) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    async checkMissingFieldsTA() {
        let missingFields = [];
        if (this.taNomineeId === '' || this.taNomineeId === undefined) {
            missingFields.push('Nominee');
        }

        if (this.trailblazerAward.gdc_ms_TeamPlayerRecognisedMentor__c === '' || this.trailblazerAward.gdc_ms_TeamPlayerRecognisedMentor__c === undefined) {
            missingFields.push('Team player & Recognised mentor');
        }
        return missingFields;
    }

    async checkMissingFieldsCSA() {
        let missingFields = [];
        if (this.csaNomineeId === '' || this.csaNomineeId === undefined) {
            missingFields.push('Nominee');
        }

        if (this.customersuccessAward.gdc_ms_WinAsTeamCharacteristic__c === '' || this.customersuccessAward.gdc_ms_WinAsTeamCharacteristic__c === undefined) {
            missingFields.push('Demonstrate Win as a team characteristic');
        }

        if (this.customersuccessAward.gdc_ms_ProjectComplexityValueDelivered__c === '' || this.customersuccessAward.gdc_ms_ProjectComplexityValueDelivered__c === undefined) {
            missingFields.push('Project complexity & Value delivered');
        }

        // if (this.customersuccessAward.gdc_ms_TeamName__c === '' || this.customersuccessAward.gdc_ms_TeamName__c === undefined) {
        //     missingFields.push('Team Name');
        // }

        if (this.customersuccessAward.gdc_ms_TeamOwner__c === '' || this.customersuccessAward.gdc_ms_TeamOwner__c === undefined) {
            missingFields.push('Team Owner');
        }

        if (this.customersuccessAward.gdc_ms_TeamSize__c === '' || this.customersuccessAward.gdc_ms_TeamSize__c === undefined) {
            missingFields.push('Team Size');
        }

        return missingFields;
    }


}