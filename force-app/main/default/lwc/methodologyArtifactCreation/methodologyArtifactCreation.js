import { LightningElement, wire, api,track  } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TEMPLATE_OBJECT from '@salesforce/schema/Templates__c';
import LINK_FIELD from '@salesforce/schema/Templates__c.Link__c';
import METHOD_VERSION_DESCRIPTION_FIELD from '@salesforce/schema/Templates__c.Method_Version_Description__c';
import TYPE_FIELD from '@salesforce/schema/Templates__c.Type__c';
export default class methodologyArtifactCreation extends LightningElement {
    recordId;
    count = 0;
    @track artifacts = [];
    @track addedartefacts = [];
    @track showMessage = false;
    @api artefactId;
    @api artefactIds = '';
    templateObject = TEMPLATE_OBJECT;
    Link=LINK_FIELD;
    MethodVersion=METHOD_VERSION_DESCRIPTION_FIELD;
    Type=TYPE_FIELD;

     // Change Handlers.
    strLink = '';
    strVersion = '';
    strType='';
    @api selectedMethodId='';
    @api selectedLinks='';
    @api selectedDescriptions='';
    @api selectedType=''
    /**This is to get already selected artifacts from sessionstorage on click of back button in flow screen */
    connectedCallback() {
        if (this.selectedLinks !== '' || this.selectedDescriptions !== '' || this.selectedType !== '') {
            var artifacts = JSON.parse(sessionStorage.getItem('artifacts'));
            this.addedartefacts = artifacts !== null ? artifacts : [];
            this.showMessage = this.addedartefacts.length > 0 ? true : false;
            this.count = artifacts[artifacts.length - 1].id;
            //console.log('artifacts: '+this.artefactIds)
        }else {
            /**Clearing the session storage that we use to store the artifacts- FLOW: Create_Method */
            var artifacts = sessionStorage.getItem('artifacts')
            if( artifacts !== undefined || artifacts !== null) sessionStorage.removeItem('artifacts');
        }
    }
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
        console.log('Method Record Id -->' , this.recordId);
    }
    }
    linkChangedHandler(event){
        this.strLink = event.target.value.trim();
    }
    versionChangedHandler(event){
        this.strVersion = event.target.value.trim();
    }
    typeChangedHandler(event){
        this.strType = event.target.value;
    }
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
    clearCache() {
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(element => {
            element.value = '';
        });
        this.strLink=undefined;
        this.strVersion=undefined;
    }
    /**This is to add the artefact details in the respected list */
    handleAdd() {
        if((this.strLink != undefined && this.strLink != '')  && (this.strVersion != undefined && this.strVersion != '') && (this.strType != undefined && this.strType != '') ){
        this.selectedLinks += this.strLink !== '' ? this.strLink + ';' : 'NA;';
        this.selectedDescriptions += this.strVersion !== '' ? this.strVersion + ';' : 'NA;';
        this.selectedType += this.strType !== '' ? this.strType + ';' : 'NA;';
            if ( this.strLink!=='' || this.strVersion!=='' ) {
                this.count++;
                const newartefact = {};
                newartefact.id = this.count;
                newartefact.link = this.strLink;
                newartefact.description = this.strVersion;
                newartefact.typeValue = this.strType;
                this.addedartefacts.push(newartefact);
            }
    sessionStorage.setItem('artifacts', JSON.stringify(this.addedartefacts));

        this.showMessage = this.addedartefacts.length > 0 ? true : false;
        this.clearCache();
        this.showToast('Success', 'Arefact has been added for this method', 'success', 'dismissable');
    }
    else
    {
        this.showToast('ERROR', 'Please fill the mandatory fields', 'error', 'dismissable'); 
    }
}
}