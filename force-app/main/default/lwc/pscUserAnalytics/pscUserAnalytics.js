import { LightningElement, wire, track } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getUserAnalyticsData from '@salesforce/apex/PSCUserAnalyticsDataCtrl.getUserAnalyticsData';
import getKnowledgeData from '@salesforce/apex/PSCUserAnalyticsDataCtrl.getKnowledgeData'
export default class PscUserAnalytics extends LightningElement {
    balloonImage = PSC_IMAGES + '/images/';
    @track users = [];
    @track knowledge = [];

    @wire(getUserAnalyticsData) getUserCount({ data, error }) {
        if (data) {
            this.users = data.map((userData, index) => {
                if (index <= data.length) {
                    return {
                        ...userData,
                        imgUrl: this.balloonImage + 'balloon' + index + '.png'
                    }
                } else {
                    index = index - data.length;
                    return {
                        ...userData,
                        imgUrl: this.balloonImage + 'balloon' + index + '.png'
                    }
                }

            });
        }
    }
    @wire(getKnowledgeData) getKnowledgeCount({ data, error }) {
        if (data) {
            this.knowledge = data.map((knowledgeData, index) => {
                if (index <= data.length) {
                    return {
                        ...knowledgeData,
                        imgUrl: this.balloonImage + 'balloon' + index + '.png'
                    }
                } else {
                    index = index - data.length;
                    return {
                        ...knowledgeData,
                        imgUrl: this.balloonImage + 'balloon' + index + '.png'
                    }
                }

            });
        }
    }
}