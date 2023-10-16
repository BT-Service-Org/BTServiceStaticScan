import { LightningElement, api} from 'lwc';
import PSC_ASSETS from '@salesforce/resourceUrl/pscAssets';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
export default class PscCommunitiesData extends LightningElement {

    @api communities;
    //tileImg = PSC_ASSETS + '/img/icons/Appy.png';
    tileImg = PSC_IMAGES + '/Icons/communities.png';


}