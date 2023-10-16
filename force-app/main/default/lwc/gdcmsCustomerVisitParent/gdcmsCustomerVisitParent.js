import { LightningElement, wire } from 'lwc';
import getData from '@salesforce/apex/gdcmsCustomerVisitController.getData';
import gdcmsGlobalCustomerVisits from '@salesforce/label/c.gdcmsGlobalCustomerVisits';
import gdcmsGICLeadershipConnects from '@salesforce/label/c.gdcmsGICLeadershipConnects';
import gdcmsUpcomingVisits from '@salesforce/label/c.gdcmsUpcomingVisits';

export default class GdcmsCustomerVisitParent extends LightningElement {

    label = {
        gdcmsGlobalCustomerVisits,
        gdcmsGICLeadershipConnects,
        gdcmsUpcomingVisits
    };

    autoScroll = true;
    sliderData = [];
    @wire(getData) wiredResult({data,error}){
        if(data){
            this.sliderData = data;
        }
        else{
            console.log(error);
        }
    }
}