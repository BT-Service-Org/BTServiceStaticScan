/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used to display all the certificates of a team member as the body of the gdmsBaseModal component.
 ****************************/

import { LightningElement, api } from 'lwc'; 

export default class GdcmsCertificatesBody extends LightningElement {
 
    showMore = true;
    labelShowMore = "Show All";
    @api listOfCerts; 

    @api
    updateCerts(certs){
        this.listOfCerts = JSON.parse(JSON.stringify(certs));
    }

}