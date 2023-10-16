import { LightningElement,api,wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getContentData from '@salesforce/apex/PSC_ContentRequest_service.getContentData';
export default class ContentRequestPage extends LightningElement {
    @api recordId;
    @track contentId;
    authorTitle = 'Requestor';
    contentRequest=false;
    assigneeName;
    autFirstName='';
    authLastName='';
    status=false;
    product=false;
    industry=false;
    audience=false;
    contentName;
    @track contentData=[];
    @track description='';
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.contentName = currentPageReference.state?.name;
        }
    }

    @wire(getContentData, { name: '$contentName' }) getContent({ data, error }) {
        if(data){
            this.contentRequest=true;
            this.contentData=data;
            this.contentId=this.contentData?.Id;
            this.description=this.contentData?.Description__c? this.contentData?.Description__c.replace( /(<([^>]+)>)/ig, ''):'';
            this.autFirstName=this.contentData?.Owner?.FirstName;
            this.authLastName=this.contentData?.Owner?.LastName;
            this.status= this.contentData?.Status__c? 'Status: '+this.contentData.Status__c : false;
            this.assigneeName=this.contentData.Assignee__r?.Name;
            this.product=this.contentData?.Product__r?.Name ?'Product: '+this.contentData.Product__r.Name: false;
            this.industry= this.contentData?.Industry__r?.Name? 'Industry: '+this.contentData?.Industry__r?.Name: false;
            this.audience=this.contentData?.Role_Family__r?.Name ?'Audience: '+this.contentData.Role_Family__r.Name:false;
        }else if(error){
            console.error(error);
        }
    }

    handleBackClick() {
        window.history.back();
    }
}