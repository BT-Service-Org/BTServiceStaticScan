import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_TYPE_FIELD from '@salesforce/schema/User.UserType';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import COMMUNITY_NICKNAME_FIELD from '@salesforce/schema/User.CommunityNickname';
import PHOTO_URL_FIELD from '@salesforce/schema/User.SmallPhotoUrl';

import getUserMenuItems from '@salesforce/apex/PSCUserMenuCtrl.getUserMenuItems';

import PSC_ASSETS from '@salesforce/resourceUrl/pscImages';

import userId from '@salesforce/user/Id';
export default class PSCUserMenu extends LightningElement {
    userId = userId;
    @api diameter;
    @api levelPercent;
    @api userData;

    @track showUserMenu = false;
    @track arrowIconClass = 'user-icon__arrow';
    @track menuItems = [];
    @track loginUrl = '/s/login';
    userName;
    userType;
    userProfileName;
    communityNickname;

    @track icons = {
        user: PSC_ASSETS + '/Icons/user.svg',
        arrow: PSC_ASSETS + '/Icons/arrow.svg#arrow'
    };

    @wire(getRecord, { recordId: '$userId', fields: [NAME_FIELD, USER_TYPE_FIELD, PROFILE_NAME_FIELD, COMMUNITY_NICKNAME_FIELD, PHOTO_URL_FIELD] })
    userInfo({ data, error }) {
        if (data) {
            this.userName = getFieldValue(data, NAME_FIELD);
            this.userType = getFieldValue(data, USER_TYPE_FIELD);
            this.userProfileName = getFieldValue(data, PROFILE_NAME_FIELD);
            this.communityNickname = getFieldValue(data, COMMUNITY_NICKNAME_FIELD);
            const photoUrl = getFieldValue(data, PHOTO_URL_FIELD);
            if (!photoUrl.includes('/profilephoto/005/T')) {
                this.icons.user = photoUrl;
            }
            this.getUserMenuItemsHandler();
        } else if (error) {
            const msg = error.body.message ? error.body.message : error.body.exceptionType;
            this.showErrorToast(msg);
        }
    }

    connectedCallback() {
        const path = window.location.pathname;
        if (path !== '/s/') {
            this.loginUrl += '?startURL=' + encodeURIComponent(path);
        }
    }

    getUserMenuItemsHandler() {
        getUserMenuItems()
            .then(data => {
                let menuItems = JSON.parse(data);

                for (let item of menuItems) {
                    let url = item.url;
                    if (url.includes('profile') || url.includes('settings')) {
                        item.url += '/' + this.userId;
                    }
                }

                this.menuItems = menuItems.filter(item => {
                    return (!item.url.includes('lightning/app') && !item.url.includes('lightning/o/')) ||
                        (this.userType === 'Standard' && this.userProfileName !== 'MuleSoft Knowledge Hub Employee')
                });
            })
            .catch(error => {
                const msg = error.body.message ? error.body.message : error.body.exceptionType;
                this.showErrorToast(msg);
            });
    }

    showErrorToast(msg) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Something went wrong!',
            message: msg,
            variant: 'error',
        }));
    }

    openUserMenu(event) {
        event.stopPropagation();
        if (event.keyCode) {
            if (event.keyCode == '13') {
                this.showUserMenu = true;
                this.arrowIconClass += ' open';

            } else if (event.keyCode == '32' && !this.showUserMenu) {
                this.showUserMenu = true;
                this.arrowIconClass += ' open';
                event.preventDefault();

            } else if (event.keyCode == '32' && this.showUserMenu) {
                event.preventDefault();
                this.closeUserMenu(event);
            }
            else if (event.keyCode == '27') {
                this.closeUserMenu(event);
            }
        } else {
            this.showUserMenu = true;
            this.arrowIconClass += ' open';
        }
    }

    closeUserMenu(event) {
        event.stopPropagation();
        this.showUserMenu = false;
    }
    navigateLinks(event) {
        if (event.keyCode == '9' && this.menuItems.length - 1 == event.target.dataset.index) {
            this.closeUserMenu(event);
        }
    }

}