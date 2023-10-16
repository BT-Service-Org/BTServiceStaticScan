import { LightningElement, track, wire, api } from 'lwc';
import getbadges from '@salesforce/apex/PSCBadgesCtrl.getbadges';
import PSC_Badges from '@salesforce/resourceUrl/PSCBadges';
export default class PscBadgeModal extends LightningElement {
    @api badgeKey;
    @track badgeData = []
    @track badges = [];
    showSpinner = true;

    @wire(getbadges, { key: '$badgeKey' }) getBadges({ error, data }) {
        if (data) {
            this.badgeData = data;
            if (this.badgeData.data != undefined) {
                let tileInfo = this.badgeData.hasOwnProperty('imgData') ? JSON.parse(this.badgeData.imgData) : [];
                this.badges = this.processCorrectData(this.badgeData.data, tileInfo);
            }

            this.showSpinner = false;
        }
        if (error) {
            console.log("Error", error);
        }
    }

    processCorrectData(processableArray, metaDataArray) {
        let targetArray = [];
        processableArray.map((data) => {
            targetArray.push({
                activityName: data.activityName,
                badgeList: data.badgeList.map(row => {
                    return {
                        ...row,
                        showPoints: row.minLevelPoints || row.minLevelPoints == 0 ? true : false,
                        tileUrl: PSC_Badges + this.getImgPath(metaDataArray, row.badgeName)
                    }

                })
            })
        });
        return targetArray;
    }

    getImgPath(imgPathData, rowName) {
        for (let x of imgPathData) {
            if (x.name !== undefined && rowName !== undefined && x.name.toLowerCase() === rowName.toLowerCase()) {
                return x.tileUrl;
            }
        }

    }
}