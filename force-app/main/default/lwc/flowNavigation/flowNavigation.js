import { LightningElement, api, track } from 'lwc';
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent,
    FlowAttributeChangeEvent  
} from 'lightning/flowSupport';
 
export default class FlowNavigation extends LightningElement {
    @api availableActions = [];
    @api nextButton ;
    @api backButton = false;
    @track backClicked = false;
    @api varBackClicked = false;
    @api created;
    @api MethodRecordId;
    @api statusValue;
    @api statusFieldError;

    constructor() {
        super();
        this.backButton = true;
        this.nextButton = true;
    }

    handleBack() {
        this.backClicked = true;
        this.navigateNext();
        if( this.created ) {
            sessionStorage.setItem('created', 'created');
        }
    }

    handleNext() {
        var created = sessionStorage.getItem('created')
        if( created === 'created' ) {
            const attributeChangeEvent = new FlowAttributeChangeEvent('created', true);
            this.dispatchEvent(attributeChangeEvent);
        }

        if (this.availableActions.find((action) => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.varBackClicked = false;            
            this.dispatchEvent(navigateNextEvent);
        }
    }

    navigateNext() {
            if (this.availableActions.find((action) => action === 'BACK')) {
                const navigateBackEvent = new FlowNavigationBackEvent();
                if (this.backClicked == true) {
                    this.varBackClicked = true;
                }
                this.dispatchEvent(navigateBackEvent);
            }
    }
}