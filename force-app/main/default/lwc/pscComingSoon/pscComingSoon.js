import { LightningElement ,api, wire} from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import { CurrentPageReference } from 'lightning/navigation';
export default class PscComingSoon extends LightningElement {
    @api description;
    pageName;
    bearImage = PSC_IMAGES + '/images/Coming-soon.png';
    salesforceLogo = PSC_IMAGES + '/Logo/salesforce.png';
    ellipseImage = PSC_IMAGES + '/images/Ellipse.png';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.pageName = currentPageReference.state?.name;
        }
    }
}