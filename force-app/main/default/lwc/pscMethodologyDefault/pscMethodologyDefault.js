import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMethodologyFormData from '@salesforce/apex/PSCMethodologyDefaultCtrl.getMethodologyFormData'
export default class PscMethodologyDefault extends LightningElement {
    @api checkBoxLabel;
    @api videoUrl;
    @api title;
    @api body;
    @track enableAccessButton = true;


    handleClick() {
        this.enableAccessButton=true;
        getMethodologyFormData().then(result => {
            if(result.hasOwnProperty('Id')){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Permission Assigned',
                    variant: 'success',
                }));
                window.location.reload();
            }
            else{
                this.enableAccessButton=false;
  
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error Occurred!',
                    message: 'Something Went Wrong',
                    variant: 'error',
                }));
            }
        }).catch(()=> {
            this.enableAccessButton=false;
  
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Occurred!',
                message: 'Something Went Wrong',
                variant: 'error',
            }));

        })
       
    }

    handleChange(event) {
        this.enableAccessButton = event.target.checked?false:true;
    }
}