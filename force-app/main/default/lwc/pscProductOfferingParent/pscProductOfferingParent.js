import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getProductStages from '@salesforce/apex/PSCProductOfferingParentCtrl.getProductStages';

export default class PscProductOfferingParent extends LightningElement {
    productParam;
    @track productData=[];
    @track stageData=[];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.productParam = currentPageReference.state?.product;
        }
    }

    @wire(getProductStages, { product: '$productParam' })
    wiredProdData({ error, data }) {
        if (data) {
            if (data !== null && data !== undefined) {
                this.productData = data;
                if(this.productData.Stages__r) {
                    this.stageData = this.productData.Stages__r.map((stage, index)=>{
                        return {
                            ...stage,
                            number: index + 1,
                            url: '/ServicesCentral/s/playbook-detail?playbookName='+encodeURIComponent(stage?.Playbook_Stage__r?.Name)+'&stageName='+encodeURIComponent(stage.Name)
                        }
                    });
                }
            }
            
        }
        if (error) {
            console.log("error", error);
        }
    }
}