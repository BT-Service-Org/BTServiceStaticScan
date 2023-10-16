import { LightningElement, wire, track } from 'lwc';
import PSC_ASSETS from '@salesforce/resourceUrl/pscImages';
import userId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_TYPE_FIELD from '@salesforce/schema/User.UserType';
import USER_TITLE from '@salesforce/schema/User.Title';
import COMMUNITY_NICKNAME_FIELD from '@salesforce/schema/User.CommunityNickname';
import PHOTO_URL_FIELD from '@salesforce/schema/User.MediumPhotoUrl';
import getProfileData from '@salesforce/apex/PSCProfileCardCtrl.getProfileData';
import PSC_Badges from '@salesforce/resourceUrl/PSCBadges';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PscProfileCard extends LightningElement {
    userId = userId;
    userName;
    userTitle;
    @track userPoints = [];
    @track userBadges = [];
    @track userRank = [];
    badgeLabel='badges';
    @track icons = {
        user: PSC_ASSETS + '/Icons/user.svg',
        arrow: PSC_ASSETS + '/Icons/arrow.svg#arrow'
    };

    @wire(getProfileData)
    userdata({ data, error }) {
        if (data) {
            let imgPathData;
            if (data.hasOwnProperty('imagePathData')) {
                imgPathData = JSON.parse(data.imagePathData);
            }
            if (data.articlesData != undefined && data.articlesData.length) {
                this.userPoints = [...data.articlesData];
            }
            if (data.levelData != undefined && data.levelData.hasOwnProperty('value')) {
                this.userRank.push(data.levelData);
                this.userRank = [...this.userRank].map(data => {
                    this.badgeLabel = data.nextLevelBadgesRequired > 1 ? 'badges' : 'badge';
                    return {
                        ...data,
                        badgeImgUrl: PSC_Badges + this.getImgPath(imgPathData, data.value),
                        nextBadgeUrl: data.nextLevelName ? PSC_Badges + this.getImgPath(imgPathData, data.nextLevelName):''
                    }
                });
            }

            if (data.badgeData != undefined && data.badgeData.length) {
                this.userBadges = [...data.badgeData].map(data => {
                    return {
                        ...data,
                        badgeImgUrl: PSC_Badges + this.getImgPath(imgPathData, data.label)
                    }
                });
            }



        } else if (error) {
            console.log("error", error);
            const msg = error.body.message ? error.body.message : error.body.exceptionType;
            this.showErrorToast(msg);
        }
    }

    @wire(getRecord, { recordId: '$userId', fields: [NAME_FIELD, USER_TYPE_FIELD, USER_TITLE, COMMUNITY_NICKNAME_FIELD, PHOTO_URL_FIELD] })
    userInfo({ data, error }) {
        if (data) {

            this.userName = getFieldValue(data, NAME_FIELD);
            this.userTitle = getFieldValue(data, USER_TITLE);
            const photoUrl = getFieldValue(data, PHOTO_URL_FIELD);
            if (!photoUrl.includes('/profilephoto/005/T')) {
                this.icons.user = photoUrl;
            }
        } else if (error) {
            const msg = error.body.message ? error.body.message : error.body.exceptionType;
            this.showErrorToast(msg);
        }
    }

    getImgPath(imgPathData, name) {
        for (let x of imgPathData) {
            if (x.name !== undefined && name !== undefined && x.name.toLowerCase() === name.toLowerCase()) {
                return x.tileUrl;
            }
        }
    }

    showModal() {
        const modal = this.template.querySelector('c-psc-badges-list');
        modal.showModalBox();
    }

    showErrorToast(msg) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error',
        }));
    }
}