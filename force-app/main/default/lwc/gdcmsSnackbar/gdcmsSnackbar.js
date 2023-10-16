/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is a reusable snackbar component currently used to display profile details and skill values 
 * for a team member , it's present on the org chart (Gdcms Team Builder Component) .
 ****************************/
import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import DefaultImage from '@salesforce/resourceUrl/GDCMSDefaultImage';

export default class GdcmsSnackbar extends NavigationMixin(LightningElement) {
    display = false;
    @api image = '';
    @api name = '';
    @api position = '';
    teamMemberId;
    displaySlot = false;
    
    @api showSnackbar(updatedMember) {
        let selectedMember = JSON.parse(JSON.stringify(updatedMember))
        this.image = selectedMember.imageUrl;
        this.teamMemberId = selectedMember.Id;
        this.display = true;
        //When the display is set as true, immediately -> querySelector is unable to query the data-id as it is still yet not rendered in DOM
        //This timeout waits for the div with data-id="snackbar" to be visible, then we add "Show" CSS to give fadein animation
        setTimeout(() => {
            let x = this.template.querySelector('[data-id="snackbar"]');
            x.classList.add("show");
            this.cleanCard();
        },100)

        // To give loading effect, we are displaying this static info after 1/2 sec for better Visualization
        setTimeout(()=>{
            this.name = selectedMember.Name;
            this.position = selectedMember.positionName;
            this.Id = this.teamMemberId;
        },500);
        
        //This setTimeout is of 1 sec, it helps in making sure that the card body only starts to loads after the animation is complete.        setTimeout(() => {
        setTimeout(() => {
            this.displaySlot = true;
        }, 1000)
    }

    @api handleClose() {
        let x = this.template.querySelector('[data-id="snackbar"]');
        x.classList.add("remove");
        // The below setTimeout helps with animation effect of fadeaway, onclick of closing the pop-up.
        setTimeout(() => {
            this.display = false;
            this.displaySlot = false;
            this.cleanCard();
            this.image = '';
            x.classList = ['snackbar']
            this.dispatchEvent(new CustomEvent('closed'));
        }, 450)
        
    }

    get imgClassName (){
        if(this.image === DefaultImage){
            return 'header-img-no-width';
        }
        else {
            return 'header-img';
        }
    }

    navigateToTeamMember() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.teamMemberId,
                objectApiName: 'gdc_ms_TeamMember__c',
                actionName: 'view'
            }
        }).then((url) => {

            var newWindow = window.open(url, "_blank");
            newWindow.document.title = this.name;
        });
    }

    cleanCard(){
        this.name = '';
        this.position = '';
    }
}