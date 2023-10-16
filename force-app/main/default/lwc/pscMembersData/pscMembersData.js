import { LightningElement, track, wire, api } from 'lwc';
import getMembers from '@salesforce/apex/PSCMembersCtrl.getMembers';
import getUserMenuSetting from '@salesforce/apex/PSCMembersCtrl.getSetting';

export default class PscMembersData extends LightningElement {
    @api memberRole;
    @api communityPageName;
    @api showSpinner;
    @api componentName;
    @api searchMemberKey;
    @api showAllRecords = false;
    @api maxRecordsCompactMode;
    displayNumber = 16; // Total number of members that will be displayed in the component. Default is set to 16 but the value comes from the Contribution_Team_Member record of PS Connect Settings metadata.
    @track members = [];
    @track membersData = [];
    noRecordsMessage = 'No Records Found.';

    @wire(getMembers, { memberRoleStr: '$memberRole', communityPageNameStr: '$communityPageName', searchKeyStr: '$searchMemberKey' }) getMembersData({ error, data }) {
        this.members = [];
        this.membersData = [];
        if (data) {
            if (data != undefined) {
                getUserMenuSetting({settingNameStr: 'User_Menu_Items'})
                    .then(result => {
                        let urlProfilePath = '';

                        if(result) {
                            let menuItems = JSON.parse(result);
                            for (let item of menuItems) {
                                if (item.url.includes('profile')) {
                                    urlProfilePath = item.url + '/';
                                    break;
                                }
                            }
                        }
                        
                        this.membersData = data.map(row => ({ ...row, communityRole: row.psc_Role__c,memberRole: (row.Community_Title__c!=null ? row.Community_Title__c: row.psc_Team_Member__r.Title), profileURL: (urlProfilePath != '' ? urlProfilePath + row.psc_Team_Member__c : '') }));
                        this.displayNumber = this.showAllRecords ? this.membersData.length : (this.maxRecordsCompactMode ? this.maxRecordsCompactMode : this.displayNumber);
                        let count = 1;
                        for(let member of this.membersData) {
                            if(count <= this.displayNumber) {
                                this.members.push(member);
                                count++;
                            }
                        }
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        this.members = [];
                        this.membersData = [];
                        this.showSpinner = false;
                        console.log('Error', error);
                    });
            }
        }
        if (error) {
            this.showSpinner = false;
            this.members = [];
            this.membersData = [];
            console.log('Error', error);
        }
    }
}