/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used for the Profile view having the skills details of an individual team member.
 ****************************/

import { api, LightningElement,track,wire } from 'lwc';
import getProfileDetails from '@salesforce/apex/GDC_MS_ProfileViewController.getProfileDetails';
import DefaultImage from '@salesforce/resourceUrl/GDCMSDefaultImageNew';
import ProfilePageAssets from '@salesforce/resourceUrl/GDCMSProfilePageAssets';

export default class GdcmsTeamMemberProfile extends LightningElement {
    @api recordId;
    @track profile;
    imgUrl;
    certificatesInString = undefined;
    certifiedProfessionalImage = undefined;
    summaryData = [];
    verticalExpertiseData = [];
    skillHighlightsData = [];
    customerCredentialsData = [];
    lightLeavesImageURL;
    darkLeavesImageURL;
    bushImageURL;


    @wire (getProfileDetails,{ recordId:'$recordId' })
    bio({ data, error }) {

        if (data) {
            //Commented below Code and added new -- Adwait - start
            this.profile = data;

            data.skillDetails.map(skill => {

                if(skill.skillKey === 'Salesforce Certificates') {

                    if(skill.skillDetails && skill.skillDetails.length > 0) {

                        this.certifiedProfessionalImage = ProfilePageAssets+'/assets/images/gdcms_certified_professional_logo_image.png';
                        this.certificatesInString = skill.skillDetails.join(' | ');
                    }
                }

                if(skill.skillKey === 'Summary') {
                    this.summaryData = skill.skillDetails.length > 0 ? skill.skillDetails.filter(item => item != '' ).join(' ') : undefined;
                }

                if(skill.skillKey === 'Industry Experience') {
                    this.verticalExpertiseData = skill.skillDetails.length > 0 ? skill.skillDetails.filter(item => item != '' ) : undefined;
                }

                if(skill.skillKey === 'Skill Highlights') {
                    this.skillHighlightsData = skill.skillDetails.length > 0 ? skill.skillDetails.filter(item => item != '' ) : undefined;
                }

                if(skill.skillKey === 'Customer Credentials') {
                    this.customerCredentialsData = skill.skillDetails.length > 0 ? skill.skillDetails.filter(item => item != '' ) : undefined;
                }
            });

            if(this.profile.userDetails.imageUrl) {
                this.imgUrl = this.profile.userDetails.imageUrl;
            } else {
                this.imgUrl = DefaultImage;
            }
        }
        if (error) {
            console.log(error);
        }
    };

    connectedCallback() {

        this.lightLeavesImageURL = ProfilePageAssets+'/assets/images/gdcms_right_light_leaves_image.png';
        this.darkLeavesImageURL = ProfilePageAssets+'/assets/images/gdcms_left_dark_leaves_image.png';
        this.bushImageURL = ProfilePageAssets+'/assets/images/gdcms_bush_image.png';
    }
}