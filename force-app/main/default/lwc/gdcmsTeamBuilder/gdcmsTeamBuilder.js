/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is the GDC Team Page (Org Chart Component) on the experience cloud of GDC Microsite.
 ****************************/

/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
import { LightningElement, wire } from 'lwc';
import getOrgMembers from '@salesforce/apex/GDC_MS_TeamBuilderController.getOrgMembers';
import FORM_FACTOR from '@salesforce/client/formFactor';
import DefaultImage from '@salesforce/resourceUrl/GDCMSDefaultImageNew';

export default class GdcmsTeamBuilder extends LightningElement {

    selectedMember;
    dataFlattened;
    preImgData;
    isTrue = true;
    showChartSpinner = true;

    get isDesktopDevice() {
        if (FORM_FACTOR === "Large") {
            return true;
        }
        return false;
    }


    @wire(getOrgMembers)
    wiredOrgData({ data, error }) {
        if (data) {
            this.preImgData = JSON.parse(JSON.stringify(data));
            this.dataFlattened = this.preImgData.map((item)=>{
                if(!item.imageUrl) item.imageUrl = DefaultImage;
                return item;
            })
            //this.dataFlattened = JSON.parse(JSON.stringify(this.preImgData));
            this.showChartSpinner = false;

        }
        if (error) {
            console.log(error);
        }
    };

    get isDesktopDevice() {
        if (FORM_FACTOR === "Large") {
            return true;
        }
        return false;
    }

    handleSelectedMemberChange(event) {
        this.template.querySelector('c-gdcms-team-builder-desktop-view').handleSelectedMember(event.detail);
    }

    handleUpdateMembers(event) {
        this.template.querySelector('c-gdcms-team-builder-mobile-view').updateOrgMembers(event.detail);
    }

    handleResetMembers(event) {
        this.template.querySelector('c-gdcms-team-builder-mobile-view').restoreBackup();
    }
}