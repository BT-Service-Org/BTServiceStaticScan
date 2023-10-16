/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used to display a team member's details inside of gdcms snackbar for the org chart
 ****************************/
import { LightningElement, api, wire } from 'lwc';
import getBioInfo from '@salesforce/apex/GDC_MS_TeamBuilderController.getBioInfo';

export default class GdcmsTeamMemberQuickDetails extends LightningElement {
    @api teamMemberId;
    @api showSpinner;
    @api bioData;
    certifications;
    certData;
    @wire(getBioInfo, { bioId: '$teamMemberId' })
    bio({ data, error }) {
        if (data) {
            this.bioData = undefined; //This cleans up the card body when freshdata is loaded.

            setTimeout(() => {
                this.showSpinner = false;
                this.bioData = JSON.parse(JSON.stringify(data));
                console.log(this.certifications);

            }, 1E3)
        }
        if (error) {
            console.log(error);
        }
    };

    handleOpenClose(event) {

        let panels = this.template.querySelectorAll('div.panel');
        const btnClicked = event.currentTarget.dataset.targetId;
        console.log("##btnClicked: ", btnClicked);
        for (let i = 0; i < panels.length; i++) {
            console.log("panels[i].dataset.id:", panels[i].dataset.id);
            if(panels[i].dataset.id == btnClicked) {
                if(panels[i].classList.contains('slds-hide')) {
                    panels[i].classList.remove('slds-hide');
                } else {
                    panels[i].classList.add('slds-hide');
                }
            } else {
                panels[i].classList.add('slds-hide');
            }
        }
    }

    connectedCallback() {
        console.log('connected callback');
    }

    renderedCallback() {
        console.log('rendered callback');
    }

    disconnectedCallback() {
        console.log('disconnected callback');
    }

}