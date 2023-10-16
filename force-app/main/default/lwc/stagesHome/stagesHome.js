import {LightningElement, track, wire, api} from 'lwc';
//import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import myPNG_icon from '@salesforce/resourceUrl/stageDiscoverImg';
import stageDefineImage from '@salesforce/resourceUrl/stageDefineImage';
import stageDesignImage from '@salesforce/resourceUrl/stageDesignImage';
import stageDeliverImage from '@salesforce/resourceUrl/stageDeliverImage';
import stageDeployImage from '@salesforce/resourceUrl/stageDeployImage';
import stageScaleImage from '@salesforce/resourceUrl/stageScaleImage';
import stageMonitorControlImage from '@salesforce/resourceUrl/stageMonitorControlImage';
export default class NavigateFromLwc extends NavigationMixin(LightningElement) {
    @track showStagesRecords = false;
    @track stageFilter;
    lampPng = myPNG_icon;
    defineImage = stageDefineImage;
    designImage = stageDesignImage;
    deliverImage = stageDeliverImage;
    deployImage = stageDeployImage;
    scaleImage = stageScaleImage;
    monitorControl = stageMonitorControlImage;
    handleNavigate(event) {

        this.stageFilter = event.currentTarget.dataset.id;
       // this.showStagesRecords = true;
        var compDefinition = {
            componentDef: "c:servicesMethodFilter",
            attributes: {
                stageFilter : this.stageFilter
            }
        };
           
        
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        }); 
    }

    addClass(event){
        let index = event.currentTarget.dataset.id;
        console.log('event ' +JSON.stringify(event.currentTarget));
        console.log('index ' +index);
        let flipElement = this.template.querySelector('[data-id="' + index + '"]');
        flipElement.classList.add('class1');
    }

    removeClass(event){
        let index = event.currentTarget.dataset.id;
        let flipElement = this.template.querySelector('[data-id="' + index + '"]');
        flipElement.classList.remove('class1');
    }
}