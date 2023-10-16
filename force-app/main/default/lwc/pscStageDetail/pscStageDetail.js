import { LightningElement , track , wire , api} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getStageDetail from '@salesforce/apex/PSCStageDetailCtrl.getStageDetail';
export default class PscStageDetail extends LightningElement {

    stageName;
    @track stageNames=[];
    @track stageData;
    @track methodNumbers = [];
    buttonLink;
    @api sourceName;



    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.stageName = currentPageReference.state?.stageName;
            this.buttonLink = '/ServicesCentral/s/global-search/@uri#sort=relevancy&f:@gkcsource=['+encodeURIComponent(this.sourceName)+']&f:@gkcmethodstagename=['+encodeURIComponent(this.stageName)+']';
            if(this.stageName !== undefined && this.stageName !== null){
                this.stageNames.push(this.stageName);
            }
        }
    }

    @wire(getStageDetail, { key: '$stageNames' , maxNoOfResult:1})
    wiredStageData({ error, data }) {
        if (data) {
            if(data !== null && data !== undefined){
                this.stageData = data[0];
                for(let y=0;y<this.stageData.Method_with_Stages__r.length;y++){
                    if(this.stageData.Method_with_Stages__r[y].Method__r.Method_Number__c!==undefined){
                        this.methodNumbers.push(this.stageData.Method_with_Stages__r[y].Method__r.Method_Number__c);
                    }
                }
            }
        }
        if (error) {
            console.log("error occured while fetching Method card data", error);
        }
    }
    
    handleClick(){
        window.open(this.buttonLink,'_blank');
    }
}