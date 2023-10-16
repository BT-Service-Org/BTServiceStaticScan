import { LightningElement , wire, api} from 'lwc';
import getHistoryData from '@salesforce/apex/PSCGenericRevisionHistoryCtrl.getHistoryData';
export default class PscGenericRevisionHistory extends LightningElement {
    @api parentId;
    historyData;

    @wire(getHistoryData, { key: '$parentId' })
    wiredHistoryData({ error, data }) {
        if (data) {
            this.historyData = data;
        }
        if (error) {
            console.log("error", error);
        }

    }
}