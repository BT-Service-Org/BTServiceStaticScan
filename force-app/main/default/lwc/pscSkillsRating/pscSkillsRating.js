import { LightningElement , track, wire} from 'lwc';
import getUserSkillsData from '@salesforce/apex/PSCSkillsRatingCtrl.getUserSkillsData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import Id from '@salesforce/user/Id';

export default class PscSkillsRating extends LightningElement {
    @track skillData ={};
    userName='';
    userRole='';
    currentGrade='';
    nextCareerGroup='';
    nextCareerGoal ='';
    profileDesc = '';
    keyExperience = '';
    currentReadinessLevel ='';
    currentReadinessPercentage='';
    currentMatchSkills ='';
    expectedMatchSkills ='';
    showToast = false;
    toastheader ='';
    toastBody ='';
    managerValidatedPct='0%';
    careerProfileId = '';
    skillInsightsLink='';
    showRecords = true;
    showSpinner = true;
    count=0;
    @track roleMovement=[];
    @track careerMovement =[];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {

        if (currentPageReference) {
            this.careerProfileId = currentPageReference.state?.careerProfileId;
        } 

        if(!this.careerProfileId) {
            this.careerProfileId = Id;
        }
    }


    @wire(getUserSkillsData, {careerProfileId:'$careerProfileId'})
    skillDataWire(data, error) {
        if (data) {
            this.count++;
            if(data.data !== undefined){
                this.showRecords = true;
                this.showErrorMessage = false;
                this.skillData = data.data;
                this.userName = this.skillData?.userName;
                if(this.skillData.cpDetail !=null) {

                    this.userRole = this.skillData.cpDetail.Name ? this.skillData.cpDetail.Name : '';
                    this.currentGrade = this.skillData.cpDetail.Job_Grade__c? this.skillData.cpDetail.Job_Grade__c : '';
                    this.nextCareerGroup = this.skillData.cpDetail.Career_Path_Group__c ? this.skillData.cpDetail.Career_Path_Group__c : '';
                    this.nextCareerGoal = this.skillData.cpDetail.Career_Path__c ? this.skillData.cpDetail.Career_Path__c :'';
                    this.profileDesc = this.skillData.cpDetail.Profile_Description__c ? this.skillData.cpDetail.Profile_Description__c : '';
                    this.keyExperience = this.skillData.cpDetail.Key_Experiences__c ? this.skillData.cpDetail.Key_Experiences__c : '';
                }
                
                this.currentReadinessLevel = this.skillData.skillReadiness ? this.skillData.skillReadiness : '';
                this.currentReadinessPercentage = this.skillData.careerMatchPct ? this.skillData.careerMatchPct + "%" : '0%';
                this.showToast = this.skillData.displaySkillWarning;
                this.toastheader = this.skillData.displaySkillWarning ? this.skillData.displaySkillWarningHeader:'';
                this.toastBody = this.skillData.displaySkillWarning ? this.skillData.displaySkillWarningBody:'';
                this.currentMatchSkills = this.skillData.totalSkillsMatchCount ? this.skillData.totalSkillsMatchCount : 0;
                this.expectedMatchSkills = this.skillData.totalSkillsCount ? this.skillData.totalSkillsCount : 0;
                this.skillInsightsLink = this.skillData.skillInsightsLink ?this.skillData.skillInsightsLink:'';

                if(this.skillData.roleMovement && this.skillData.roleMovement.length) {
                    this.roleMovement = this.skillData.roleMovement.map(role => {
                        return {
                            ...role,
                            careerProfileUrl: '/ServicesCentral/s/skill-insights?careerProfileId=' + role.Next_Career_Profile__r.Id
                        }
                    });
                }

                if(this.skillData.totalSkillsCount) {
                    this.managerValidatedPct = `${(this.skillData.managerValidatedCount / this.skillData.totalSkillsCount) * 100}%`
                }

                if(this.showToast) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.toastheader,
                            message: this.toastBody,
                            variant: 'warning',
                        }),
                    );
                }
            } else {
                this.showErrorMessage = true;
            }
            if(this.count==2) {
                this.showRecords = this.skillData.hasOwnProperty('cpDetail');
                this.showSpinner=false;
            }
        }
        else if (error) {
            console.log(error);
        }
    }
}