import { LightningElement, wire } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getFooterLinks from '@salesforce/apex/PSCThemeFooterCtrl.getFooterLinks';
export default class PscThemeFooter extends LightningElement {
    footerImage = PSC_IMAGES + '/banner/footer.png';
    footerLogo = PSC_IMAGES + '/Logo/salesforce.png';
    currentYear = new Date().getFullYear();;

    @wire(getFooterLinks)
    getFooterLinks({ data, error }) {
        if (data) {
            this.menuItems = JSON.parse(data);


        } else if (error && !isGuestUser) {
            const msg = error.body.message ? error.body.message : error.body.exceptionType;
            this.showErrorToast(msg);
        }
    }
    menuItems;
}