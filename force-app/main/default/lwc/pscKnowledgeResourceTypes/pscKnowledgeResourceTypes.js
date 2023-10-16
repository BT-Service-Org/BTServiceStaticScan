import { LightningElement , api, wire} from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getProductTypeValues from '@salesforce/apex/PSCProductDetailCtrl.getProductTypeValues';
export default class PscProductDetail extends LightningElement {
    productBanner=PSC_IMAGES + '/banner/productBanner.png';
    KnowledgeData;
    @api pageName='Knowledge';

    @wire(getProductTypeValues,{key:"$pageName"})
    productTypeConfig({error,data}){
        if(data){
            if(data!== undefined && data !== null){
                this.KnowledgeData = JSON.parse(data)[0];
                this.KnowledgeData.bannerURL = PSC_IMAGES+this.KnowledgeData.bannerURL;
                this.KnowledgeData.resourceTypes = this.KnowledgeData.resourceTypes.map(row=>{          
                    return {
                        ...row,
                        tileUrl : PSC_IMAGES+row.tileUrl
                    };
                })
            }
        }
        if(error){

        }
    }
}