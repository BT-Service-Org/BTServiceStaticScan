import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRACI from '@salesforce/apex/GetRelatedRACI.getEnablementRACI';
import noRACILabel from '@salesforce/label/c.No_RACI_matrix_for_this_Enablement_Activity';


const COLUMNS = [
    {label: 'Assignment', fieldName: 'id', type: 'url', typeAttributes: {label: { fieldName: 'raci' }}, sortable: true},
    {label: 'Role', fieldName: 'stakeholderRole'},
    {label: 'Name', fieldName: 'stakeholderName'}
]


export default class EnablementRaciRelatedLWC extends LightningElement 
{
    @api recordId;
    @track racis = [];
    @track raciAvailable = false;
    @track noRACI = noRACILabel;

    columns = COLUMNS;

    @wire(getRACI, {enablementActivityId: '$recordId'})
    wiredAssets({error , data})
    {
        if(data)
        {
            let temp = [];
            if(data.length > 0)
            {
                this.raciAvailable = true;
                
                data.forEach(element => {
                    console.log(element)
                    let elt = {};
                    elt.raci = element.RACI__c;
                    elt.id = `/${element.Id}`;
                    elt.stakeholderRole = element.Stakeholder_Role__r.Name;
                    if(element.Stakeholder_Name__c)
                    {
                        elt.stakeholderName = element.Stakeholder_Name__r.Name
                    }
                    temp.push(elt);
                });
    
                this.racis = temp;
            }
        }
        else
        {
            const event = new ShowToastEvent({
                "title": "Problem retrieving RACI",
                "message": "There was a problem retrieving the related RACI for this Engagment Activity",
            });
            this.dispatchEvent(event);
        }
    }
}