import { LightningElement,api,wire } from 'lwc';
import getBreadCrumbsRecords from '@salesforce/apex/PscReusableBreadcrumbsCntrl.fetchBreadCrumbs';
import { CurrentPageReference } from 'lightning/navigation';
export default class PscReusableBreadcrumbs extends LightningElement {
displaydata;
@api pagename;
playbookName;
playbookDetaildata={}
lastName =false;
tempvar=false;
@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.playbookName = currentPageReference.state?.playbookName;
        if(this.playbookName){
        const playbook={"url":"playbook-landing?playbookName="+encodeURIComponent(this.playbookName),
        "Name": this.playbookName};
        Object.assign(this.playbookDetaildata, playbook);
    }
    if(currentPageReference?.state){
        const state =currentPageReference.state;
        for (const property in state) {
            this.tempvar =state[property];
          }
    }
    }
}
    @wire(getBreadCrumbsRecords,{developerName: 'BreadCrumbs'})
    wiredBreadCrumbs({ data, error }) {
        if (data) {
             const  metadata = JSON.parse(data.Value__c);
            for (const prop in metadata) {
                if(this.pagename == prop){
                   this.displaydata=  metadata[prop];
                   if(this.pagename == 'playbookdetail'){
                    this.displaydata.push(this.playbookDetaildata);
                   }
                }
            }
            //to load the last breadcrumbs along with all breadcrumbs
            this.lastName=this.tempvar? this.tempvar: this.lastName;
            
        } else if (error) {
            console.log('error-->'+JSON.stringify(error));
        }
    }


}