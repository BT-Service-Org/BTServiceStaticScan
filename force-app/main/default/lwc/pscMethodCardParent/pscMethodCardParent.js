import { LightningElement , wire , api} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
export default class PscMethodCardParent extends LightningElement {
    @api methodIds=[];
    methodId;
    methodname;
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.methodId = currentPageReference.state?.methodnumber;
            this.methodname = currentPageReference.state?.methodname;
            if(this.methodId!==undefined && this.methodId !== null){
                this.methodIds.push(this.methodId);
            }
            if(this.methodname!==undefined && this.methodname !== null){
                this.methodIds.push(this.methodname);
            }
        }
    }
}