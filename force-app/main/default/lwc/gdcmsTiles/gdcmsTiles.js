import { LightningElement,api } from 'lwc';

export default class GdcmsTiles extends LightningElement {
    @api height;
    @api transform;
    @api backgroundColor;
    @api borderRadius ;
    @api hoverHeight;

    renderedCallback(){
        var x= this.template.querySelector('.gdcTile');
        x.style.height= this.height;
    }
    showDetails(){
        var x= this.template.querySelector('.gdcTile');
        x.style.height= this.hoverHeight;
        x.style.transform= this.transform;
        x.style.backgroundColor=this.backgroundColor;
        x.style.borderRadius= this.borderRadius;
    }
    hideDetails(){
        var x= this.template.querySelector('.gdcTile');
        x.style.backgroundColor= "#ffffff";
        x.style.height=this.height;
        x.style.borderRadius= "10px";
        x.style.transform="none";
    }
}