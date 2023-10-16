import { LightningElement , track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getProductTypeValues from '@salesforce/apex/PSCProductDetailCtrl.getProductTypeValues';
export default class PscProductDetail extends LightningElement {
    productBanner=PSC_IMAGES + '/banner/productBanner.png';
    productData;
    @track productName;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.productName = currentPageReference.state?.name;
        }
    }

    @wire(getProductTypeValues,{key:"$productName"})
    productTypeConfig({error,data}){
        if(data){
            if(data!== undefined && data !== null){
                this.productData = JSON.parse(data)[0];
                this.productData.bannerURL = PSC_IMAGES+this.productData.bannerURL;
                this.productData.resourceTypes = this.productData.resourceTypes.map(row=>{          
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