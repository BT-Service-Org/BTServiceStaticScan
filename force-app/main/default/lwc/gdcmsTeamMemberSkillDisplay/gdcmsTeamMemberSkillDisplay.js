/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used to retrieve and display a skill value for a team member as part of 
 * the team member profile view page.
 ****************************/
import { LightningElement , api, wire} from 'lwc';
import getSkillData from '@salesforce/apex/GDC_MS_ProfileViewController.getSkillData';

export default class GdcmsTeamMemberSkillDisplay extends LightningElement {
    @api recordId;
    @api skillName;
    skillData;
    
    @wire (getSkillData,{ recordId:'$recordId' , skillName:'$skillName'})
    bio({ data, error }) {
        if (data) { 
            this.skillData = data.filter(item => item != '' );
        }
        if (error) {
            console.log(error);
        }
    };
}