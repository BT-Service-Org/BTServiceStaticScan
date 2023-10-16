import { LightningElement,api } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader'
import RelatedListStyling from '@salesforce/resourceUrl/RelatedListStyling'

export default class ReusableRelatedList extends LightningElement {
    @api iconName;
    @api headerName;
    @api hasRecords;
    @api tabledata = [];
    @api columns;
    @api footerval=false;
    @api shownew=false;
    boolRunonce=false;

    //handle New Record Create Funtionality
    handleCreateRecord(){
        this.dispatchEvent(new CustomEvent('handlecreaterecords'));
    }
    handleGotoRelatedList(){
        this.dispatchEvent(new CustomEvent('handlegotorelatedlist'));
    }
    handleRowAction(event){
        this.dispatchEvent(new CustomEvent('handlerowaction',{detail:event.detail}));
    }

    renderedCallback(){ 
        if(this.boolRunonce) return;
        this.boolRunonce=true;
        loadStyle(this, RelatedListStyling).then(()=>{
        }).catch(error=>{ 
            console.error("Error in loading the resource")
        })
    }
}