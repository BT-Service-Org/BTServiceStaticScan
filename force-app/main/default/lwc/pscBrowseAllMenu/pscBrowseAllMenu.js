import { LightningElement, wire, track } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getMenuItemsByCategory from '@salesforce/apex/PSCBrowseAllMenuCtrl.getMenuItemsByCategory';
import { CurrentPageReference } from 'lightning/navigation';
export default class PscBrowseAllMenu extends LightningElement {
    productBanner = PSC_IMAGES + '/banner/products_page.png';
    fallbackImage = '/banner/product_service.png';
    @track categoryName;
    menuItems;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.categoryName = currentPageReference.state?.name;
        }
    }

    @wire(getMenuItemsByCategory, { categoryName: "$categoryName" })
    wiredMenuItems({ data, error }) {
        if (data) {
            if (data != null && data !== undefined) {
                let imgPathData = JSON.parse(data.imagePath);
                this.menuItems = data.menuItems;
                this.menuItems = this.menuItems.map(row => {
                    return {
                        ...row,
                        tileUrl: PSC_IMAGES + this.getImgPath(imgPathData, row.Name),
                        navUrl: '/ServicesCentral/s/global-search/@uri#sort=relevancy&f:@gkcparentproductnames=['+encodeURIComponent(row.Name)+']',
                        childProducts: (row.Parent_Product__r!==undefined?row.Parent_Product__r.map(each =>{
                            return {
                                ...each,
                                navUrl: '/ServicesCentral/s/global-search/@uri#sort=relevancy&f:@pscproductnames=['+encodeURIComponent(each.Name)+']'
                            }

                        }) : undefined)
                    };
                })
                this.error = undefined;
            }
        }
        else if (error) {
            this.error = error;
            this.menuItems = undefined;
            console.log('Failure: this.error->', this.error);
        }
    }

    getImgPath(imgPathData, rowName) {
        for (let x of imgPathData) {
            if (x.ProductName.toLowerCase() === rowName.toLowerCase()) {
                return x.bgImagePath;
            }
        }
        return this.fallbackImage;
    }
}