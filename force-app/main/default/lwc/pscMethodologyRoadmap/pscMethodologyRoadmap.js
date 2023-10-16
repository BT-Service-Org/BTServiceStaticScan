import { LightningElement , wire} from 'lwc';
import getVersionData from '@salesforce/apex/PSCMethodologyRoadmapCtrl.getVersionData';

const month = ["January","February","March","April","May","June","July","August","September","October","November","December"];
export default class PscMethodologyRoadmap extends LightningElement {
    versionData;

    @wire(getVersionData)
    wiredVersionData(data, error) {
        if (data) {
            if(data.data !== undefined){
                this.versionData = data.data;
                this.versionData = this.versionData.map(each=>{
                    return{
                        ...each,
                        displayLabel: ('Release ' 
                                        + (each.hasOwnProperty('Major_Release_Number__c')?each.Major_Release_Number__c :'')
                                        + (each.hasOwnProperty('Minor_Release_Number__c')?'.' + each.Minor_Release_Number__c :'')
                                        + (each.hasOwnProperty('Release_Date__c')?' - ' + month[new Date(each.Release_Date__c).getMonth()] :'') 
                                        + (each.hasOwnProperty('Release_Date__c')? ' '+new Date(each.Release_Date__c).getFullYear() :'') 
                        )
                    }
                });
            }
        }
        else if (error) {
            console.log(error);
        }
    }
}