import { LightningElement, wire, track } from 'lwc';
import getAllPageAttributes from '@salesforce/apex/PSCPageViewService.getAllPageAttributes';

export default class PscBrowseCommunities extends LightningElement {

    @track allCommunities =[];
    @track myCommunities = [];
    noRecordsMessage = "No Records Found"
 


    @wire (getAllPageAttributes) getAllPageAttributes({data,error}) {
        if(data) {

            data.map(community => {
                this.allCommunities.push(community);

                if(community.Contribution_Teams__r !=null && community.Contribution_Teams__r.length) {
                    this.myCommunities.push(community);
                }

            })
           
        }
    }
}