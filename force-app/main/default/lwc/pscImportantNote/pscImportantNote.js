import { LightningElement, wire , api} from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import { getRecord , getFieldValue } from 'lightning/uiRecordApi';
import METHOD_NOTIFICATION_BOX_FIELD from '@salesforce/schema/Method__c.Method_Notification_Box__c';
import NAME_FIELD from '@salesforce/schema/Method__c.Name';

export default class PscImportantNote extends LightningElement {
    lightbulbIcon = PSC_IMAGES + '/Icons/icon-lightbulb.png';
    @api recId;

    @wire(getRecord, { recordId: '$recId', fields: [NAME_FIELD, METHOD_NOTIFICATION_BOX_FIELD] })
    methodData;

    get name() {
        return getFieldValue(this.methodData.data, NAME_FIELD);
    }

    get notificationBox() {
        return getFieldValue(this.methodData.data, METHOD_NOTIFICATION_BOX_FIELD);
    }
}