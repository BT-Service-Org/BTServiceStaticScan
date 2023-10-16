/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used to retrieve  a certification badge image for a particular certification from apex class.
 ****************************/
import { LightningElement,api} from 'lwc';
//import getCertURLList from '@salesforce/apex/GDC_MS_CertificationURLHandler.getCertURLList';
import BadgeImages from '@salesforce/resourceUrl/GDCMSCertificationBadges';

export default class GdcmsCertificationBadgeImage extends LightningElement {
    @api certName = '';
    //certData;

    // @wire(getCertURLList,{ certName: '$certName' })
    // wiredCertData({ data, error }) {
     
    //     console.log(this.certName);
    //     if (data) {
    //         this.certData = JSON.parse(JSON.stringify(data));
            
    //     }
    //     if (error) {
    //         console.log(error);
    //     }
    // };

    get imgName(){
        let cname = this.certName.replace(/ /g,'');
        console.log(cname);
        return BadgeImages + `/GDCMSCertificationBadges/${cname}/HighRes/${cname}.png`;

    }
 
}