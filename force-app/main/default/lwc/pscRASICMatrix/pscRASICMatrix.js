import { LightningElement, api, wire } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getRasicData from '@salesforce/apex/PSCRASICMatrixCtrl.getRasicData';
export default class PscRASICMatrix extends LightningElement {
    @api recId;
    rasicData = [];
    headerData = [];

    lightbulbIcon = PSC_IMAGES + '/Icons/icon-lightbulb.png';

    @wire(getRasicData, { methodId: '$recId' })
    wiredRasicData1({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null) {
                this.rasicData = data;
                if (this.rasicData.length > 0) {
                    this.headerData = data[0];
                }
            }
        }
        if (error) {
            console.log('error->', error);
        }
    }
}