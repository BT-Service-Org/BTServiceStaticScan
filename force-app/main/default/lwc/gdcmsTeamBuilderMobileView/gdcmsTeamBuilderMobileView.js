/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used for the mobile view for the GDC Team Page.
 ****************************/
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */

import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 

export default class GdcmsTeamBuilderMobileView extends NavigationMixin(LightningElement) { 

    @api orgMembers; 
    @api backupOrgMembers;


    connectedCallback(){
        this.backupOrgMembers = this.orgMembers;
    }

    @api restoreBackup(){
        this.orgMembers = this.backupOrgMembers;
    }

    @api updateOrgMembers(updatedOrgMembers){
        this.orgMembers = JSON.parse(JSON.stringify(updatedOrgMembers));
    }

    navigateToTeamMember(e) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: e.currentTarget.dataset.id,
                objectApiName: 'gdc_ms_TeamMember__c',
                actionName: 'view'
            }
        });
    }
}